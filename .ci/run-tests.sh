#!/usr/bin/env bash

# Exit on error
set -e
# Echo each command
set -x

if [[ "${WITH_SANITIZE}" != "" ]]; then
        export CXXFLAGS="$CXXFLAGS -fsanitize=${WITH_SANITIZE}"
        if [[ "${WITH_SANITIZE}" == "address" ]]; then
            export ASAN_OPTIONS=symbolize=1,detect_leaks=1,external_symbolizer_path=/usr/lib/llvm-12/bin/llvm-symbolizer
        elif [[ "${WITH_SANITIZE}" == "undefined" ]]; then
            export UBSAN_OPTIONS=print_stacktrace=1,halt_on_error=1,external_symbolizer_path=/usr/lib/llvm-12/bin/llvm-symbolizer
            export CXXFLAGS="$CXXFLAGS -std=c++20"
        elif [[ "${WITH_SANITIZE}" == "memory" ]]; then
            # for reference: https://github.com/google/sanitizers/wiki/MemorySanitizerLibcxxHowTo#instrumented-libc
            echo "=== Building libc++ instrumented with memory-sanitizer (msan) for detecting use of uninitialized variables"
            LLVM_ORG_VER=15.0.5  # should match llvm-X-dev package.
            export CC=clang-15
            export CXX=clang++-15
            which $CXX
            cmake_line="-DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
            LIBCXX_15_MSAN_ROOT=/opt/libcxx-15-msan
            # export PATH="/usr/lib/llvm-15/bin:$PATH"  # llvm-config
            curl -Ls https://github.com/llvm/llvm-project/archive/llvmorg-${LLVM_ORG_VER}.tar.gz | tar xz -C /tmp
            ( \
              set -xe; \
              mkdir /tmp/build_libcxx; \
              CXXFLAGS="$CXXFLAGS -nostdinc++" cmake \
                  $cmake_line \
                  -DCMAKE_BUILD_TYPE=Debug \
                  -DCMAKE_INSTALL_PREFIX=$LIBCXX_15_MSAN_ROOT \
                  -DLLVM_USE_SANITIZER=MemoryWithOrigins \
                  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind;compiler-rt" \
                  -DCOMPILER_RT_BUILD_ORC=OFF \
                  -S /tmp/llvm-project-llvmorg-${LLVM_ORG_VER}/runtimes \
                  -B /tmp/build_libcxx; \
              cmake --build /tmp/build_libcxx --verbose -j 2 ;\
              cmake --build /tmp/build_libcxx --target install
            )
            if [ ! -e $LIBCXX_15_MSAN_ROOT/lib/libc++abi.so ]; then >&2 echo "Failed to build libcxx++abi?"; exit 1; fi
            export MSAN_OPTIONS=print_stacktrace=1,halt_on_error=1,external_symbolizer_path=/usr/lib/llvm-15/bin/llvm-symbolizer
            export CXXFLAGS="$CXXFLAGS \
 -fsanitize-memory-track-origins=2 \
 -fsanitize-memory-param-retval \
 -stdlib=libc++ \
 -nostdinc++ \
 -isystem $LIBCXX_15_MSAN_ROOT/include/c++/v1 \
 -fno-omit-frame-pointer \
 -fno-optimize-sibling-calls \
 -O1 \
 -glldb \
 -DHAVE_GCC_ABI_DEMANGLE=no"
            export CFLAGS="$CFLAGS \
 -fsanitize=memory \
 -fsanitize-memory-track-origins=2 \
 -fsanitize-memory-param-retval \
 -fno-omit-frame-pointer \
 -fno-optimize-sibling-calls \
 -O1 \
 -glldb"
            export LDFLAGS="$LDFLAGS \
 -fsanitize=memory \
 -fsanitize-memory-track-origins=2 \
 -fsanitize-memory-param-retval $LDFLAGS \
 -Wl,-rpath,$LIBCXX_15_MSAN_ROOT/lib \
 -L$LIBCXX_15_MSAN_ROOT/lib \
 -lc++abi"
        else
            2>&1 echo "Unknown sanitize option: ${WITH_SANITIZE}"
            exit 1
        fi
elif [[ "${CC}" == *"clang"* ]] && [[ "$(uname)" == "Linux" ]]; then
    if [[ "${BUILD_TYPE}" == "Debug" ]]; then
        export CXXFLAGS="$CXXFLAGS -ftrapv"
    fi
elif [[ "$(uname)" == "Linux" ]]; then
    export CXXFLAGS="$CXXFLAGS -Werror"
    if [[ "${USE_GLIBCXX_DEBUG}" == "yes" ]]; then
        export CXXFLAGS="$CXXFLAGS -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC"
    fi
fi

echo "=== Generating cmake command from environment variables"

# Shippable currently does not clean the directory after previous builds
# (https://github.com/Shippable/support/issues/238), so
# we need to do it ourselves.
git clean -dfx

mkdir build
# We build the command line here. If the variable is empty, we skip it,
# otherwise we pass it to cmake.
cmake_line="$cmake_line -DCMAKE_INSTALL_PREFIX=$our_install_dir -DCMAKE_PREFIX_PATH=$our_install_dir"
if [[ "${BUILD_TYPE}" != "" ]]; then
    cmake_line="$cmake_line -DCMAKE_BUILD_TYPE=${BUILD_TYPE}"
fi
if [[ "${WITH_COVERAGE}" != "" ]]; then
    cmake_line="$cmake_line -DWITH_COVERAGE=${WITH_COVERAGE}"
fi
if [[ "${CC}" == *"gcc"* ]] && [[ "$(uname)" == "Darwin" ]]; then
    cmake_line="$cmake_line -DBUILD_FOR_DISTRIBUTION=yes"
fi

echo "=== Generating build scripts for groebner using cmake"
echo "CMAKE_GENERATOR = ${CMAKE_GENERATOR}"
echo "Current directory:"
export BUILD_DIR=`pwd`
pwd
echo "Running cmake:"
cmake $cmake_line -S ${SOURCE_DIR} -B ./build/


echo "=== Running build scripts for groebner"
pwd
echo "Running make:"
cmake --build ./build/ --parallel
cmake --install ./build/
ccache --show-stats

echo "=== Running tests in build directory:"
# C++
ctest --output-on-failure

if [[ "${WITH_COVERAGE}" == "yes" ]]; then
    echo "=== Collecting coverage data"
    curl --connect-timeout 10 --retry 5 -L https://codecov.io/bash -o codecov.sh
    bash codecov.sh -x $GCOV_EXECUTABLE 2>&1 | grep -v "has arcs to entry block" | grep -v "has arcs from exit block"
    return 0;
fi

if [[ "${WITH_SANITIZE}" != "" ]]; then
    # currently compile_flags and link_flags below won't pick up -fsanitize=...
    return 0;
fi
