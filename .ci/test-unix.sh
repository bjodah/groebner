#!/bin/bash

if [[ "$(uname)" == "Linux" ]]; then
  sudo apt update
  sudo apt install software-properties-common
  if ! grep grep DISTRIB_CODENAME=jammy /etc/lsb-release >/dev/null; then
      sudo add-apt-repository ppa:ubuntu-toolchain-r/test
  fi
  if [[ "$EXTRA_APT_REPOSITORY" != "" ]]; then
      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 15CF4D18AF4F7421
      sudo add-apt-repository "$EXTRA_APT_REPOSITORY"
  fi
  sudo apt update
  if [[ "$WITH_LATEST_GCC" != "yes" ]]; then
      EXTRA_APT_PACKAGES="$EXTRA_APT_PACKAGES g++"
  fi
  sudo apt install binutils-dev $EXTRA_APT_PACKAGES
fi

if [[ "$MSYSTEM" != "" ]]; then
  export SOURCE_DIR=`pwd`
  export our_install_dir="$HOME/our_usr"
  export CMAKE_GENERATOR="Unix Makefiles"
  export CXX="ccache g++"
  export CC="ccache gcc"
  export CCACHE_DIR=$HOME/.ccache
  ccache -M 100M
  ccache --version
  ccache --zero-stats
  ccache --show-stats
  source .ci/run-tests.sh
else
  source .ci/install-packages.sh
  source .ci/run-tests.sh
fi
