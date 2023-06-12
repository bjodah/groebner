((nil .
      ((compile-command . "cmake \
-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
-DCMAKE_BUILD_TYPE=Debug \
-DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
-B=/bld/groebner \
--fresh \
-S /work/external/groebner \
&& cmake --build /bld/groebner --verbose --clean-first \
&& cd /bld/groebner \
&& ctest --output-on-failure \
&& ln -s /bld/groebner/compile_commands.json /work/external/groebner"))))
