#!/usr/bin/env bash

# Exit on error
set -e
# Echo each command
set -x

# Shippable currently does not clean the directory after previous builds
# (https://github.com/Shippable/support/issues/238), so
# we need to do it ourselves.
git clean -dfx

if [[ "$(uname)" == "Darwin"  ]]; then
    export TRAVIS_OS_NAME="osx"
else
    export TRAVIS_OS_NAME="linux"
fi

if [[ "${CC}" == "" ]]; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
        export CC=clang
        export CXX=clang++
    else
        export CC=gcc
        export CXX=g++
    fi
fi

if [[ "${CXX}" == "" ]]; then
    if [[ "$CC" == gcc ]]; then
        export CXX=g++
    elif [[ "$CC" == clang ]]; then
        export CXX=clang++
    fi
fi
export GCOV_EXECUTABLE=gcov

if [[ "$(uname -s)" == "Linux" ]] && [[ "${CC}" == "gcc" ]]; then
    if [[ "${WITH_LATEST_GCC}" == "yes" ]]; then
        export CC=gcc-12
        export CXX=g++-12
        export GCOV_EXECUTABLE=gcov-12
    else
        if grep DISTRIB_CODENAME=jammy /etc/lsb-release >/dev/null; then
            export CC=gcc-11
            export CXX=g++-11
            export GCOV_EXECUTABLE=gcov-11
        else
            export CC=gcc-9
            export CXX=g++-9
            export GCOV_EXECUTABLE=gcov-9
        fi
    fi
fi

export SOURCE_DIR=`pwd`
export our_install_dir="$HOME/our_usr"

if [[ ! -d $HOME/conda_root/pkgs ]]; then
    rm -rf $HOME/conda_root
    if [[ "$(uname -s)" == "Darwin" ]]; then
        wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O miniconda.sh;
    else
        wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
    fi
    bash miniconda.sh -b -p $HOME/conda_root
fi
export PATH="$HOME/conda_root/bin:$PATH"
conda config --set always_yes yes --set changeps1 no
conda config --add channels conda-forge --force
# Useful for debugging any issues with conda
conda info -a
conda_pkgs="boost=1.80.0 gmp=6.2.1 gtest cmake=3.24.3 mpfr=4.1.0 libflint=2.9.0 arb=2.23.0";

retry_on_error () {
  "$@" || (sleep 5 && "$@") || (sleep 30 && "$@") || (sleep 120 && "$@")
}

if [[ "${CONDA_ENV_FILE}" == "" ]]; then
    retry_on_error conda create -q -p $our_install_dir ${conda_pkgs};
else
    retry_on_error conda env create -q -p $our_install_dir --file ${CONDA_ENV_FILE};
fi
source activate $our_install_dir;

conda install -q ccache

export CXX="ccache ${CXX}"
export CC="ccache ${CC}"
export CCACHE_DIR=$HOME/.ccache
export CCACHE_SLOPPINESS="pch_defines,time_macros"
ccache -M 100M
ccache --version
ccache --zero-stats
ccache --show-stats

cd $SOURCE_DIR;

# Since this script is getting sourced, remove error on exit
set +e
set +x
