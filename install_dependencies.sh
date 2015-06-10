#!/bin/bash

set -x
set -eu

start_dir=$(pwd)

PARALLEL_VERSION=${PARALLEL_VERSION:-"20150522"}
PARALLEL_DOWNLOAD_FILENAME="parallel-${PARALLEL_VERSION}.tar.bz2"
PARALLEL_URL="http://ftp.gnu.org/gnu/parallel/${PARALLEL_DOWNLOAD_FILENAME}"

BEDTOOLS_VERSION="2.24.0"
BEDTOOLS_DOWNLOAD_FILENAME="bedtools-${BEDTOOLS_VERSION}.tar.gz"
BEDTOOLS_URL="https://github.com/arq5x/bedtools2/releases/download/v${BEDTOOLS_VERSION}/${BEDTOOLS_DOWNLOAD_FILENAME}"

CDHIT_SHORT_VERSION="4.6.3"
CDHIT_LONG_VERSION="4.6.3-2015-0515"
CDHIT_DOWNLOAD_FILENAME="cd-hit-${CDHIT_SHORT_VERSION}.tar.gz"
CDHIT_URL="https://github.com/weizhongli/cdhit/releases/download/V${CDHIT_SHORT_VERSION}/cd-hit-v${CDHIT_LONG_VERSION}.tar.gz"

PRANK_VERSION="0.140603"
PRANK_DOWNLOAD_FILENAME="prank-msa-master.tar.gz"
PRANK_URL="https://github.com/ariloytynoja/prank-msa/archive/master.tar.gz"

# Make an install location
if [ ! -d 'build' ]; then
  mkdir build
fi
cd build
build_dir=$(pwd)

# Install apt packages
sudo apt-get update -q
sudo apt-get install -y -q g++ \
                           libdb-dev \
                           libssl-dev \
                           ncbi-blast+ \
                           mcl

download () {
  download_url=$1
  download_path=$2
  if [ -e "$download_path" ]; then
    echo "Skipping download of $download_url, $download_path already exists"
  else
    echo "Downloading $download_url to $download_path"
    wget $download_url -O $download_path
  fi
}

# Download parallel
PARALLEL_DOWNLOAD_PATH="$(pwd)/${PARALLEL_DOWNLOAD_FILENAME}"
download $PARALLEL_URL $PARALLEL_DOWNLOAD_PATH

# Download bedtools
BEDTOOLS_DOWNLOAD_PATH="$(pwd)/${BEDTOOLS_DOWNLOAD_FILENAME}"
download $BEDTOOLS_URL $BEDTOOLS_DOWNLOAD_PATH

# Download cd-hit
CDHIT_DOWNLOAD_PATH="$(pwd)/${CDHIT_DOWNLOAD_FILENAME}"
download $CDHIT_URL $CDHIT_DOWNLOAD_PATH

# Downlaod prank
PRANK_DOWNLOAD_PATH="$(pwd)/${PRANK_DOWNLOAD_FILENAME}"
download $PRANK_URL $PRANK_DOWNLOAD_PATH

untar () {
  to_untar=$1
  expected_directory=$2
  if [ -d "$expected_directory" ]; then
    echo "Already untarred $to_untar to $expected_directory, skipping"
  else
    echo "Untarring $to_untar to $expected_directory"
    tar xzvf $to_untar
  fi
}


# Untar parallel
PARALLEL_BUILD_DIR="$(pwd)/parallel-${PARALLEL_VERSION}"
if [ -d "$PARALLEL_BUILD_DIR" ]; then
  echo "Parallel already untarred to $PARALLEL_BUILD_DIR, skipping"
else
  echo "Untarring parallel to $PARALLEL_BUILD_DIR"
  tar xjvf $PARALLEL_DOWNLOAD_PATH
fi

# Untar bedtools
BEDTOOLS_BUILD_DIR="$(pwd)/bedtools2"
untar $BEDTOOLS_DOWNLOAD_PATH $BEDTOOLS_BUILD_DIR

# Untar cd-hit
CDHIT_BUILD_DIR="$(pwd)/cd-hit-v${CDHIT_LONG_VERSION}"
untar $CDHIT_DOWNLOAD_PATH $CDHIT_BUILD_DIR

# Untar prank
PRANK_BUILD_DIR="$(pwd)/prank-msa-master"
untar $PRANK_DOWNLOAD_PATH $PRANK_BUILD_DIR

# Build parallel
cd $PARALLEL_BUILD_DIR

if [ -e "$PARALLEL_BUILD_DIR/src/parallel" ]; then
  echo "Parallel already built, skipping"
else
  echo "Building parallel"
  ./configure
  make
fi

# Build bedtools
cd $BEDTOOLS_BUILD_DIR

if [ -e "$BEDTOOLS_BUILD_DIR/bin/bedtools" ]; then
  echo "Bedtools already built, skipping"
else
  echo "Building bedtools"
  make
fi

# Build cd-hit
cd $CDHIT_BUILD_DIR

if [ -e "$CDHIT_BUILD_DIR/cd-hit" ]; then
  echo "cd-hit already built, skipping"
else
  echo "Building cd-hit"
  make
fi

# Build prank
cd $PRANK_BUILD_DIR

if [ -e "$PRANK_BUILD_DIR/src/prank" ]; then
  echo "prank already built, skipping"
else
  echo "Building prank"
  make
fi

# Add things to PATH
update_path () {
  new_dir=$1
  if [[ ! "$PATH" =~ (^|:)"${new_dir}"(:|$) ]]; then
    export PATH=${new_dir}:${PATH}
  fi
}

export PATH
PARALLEL_BIN_DIR="$PARALLEL_BUILD_DIR/src"
update_path $PARALLEL_BIN_DIR
BEDTOOLS_BIN_DIR="$BEDTOOLS_BUILD_DIR/bin"
update_path $BEDTOOLS_BIN_DIR
CDHIT_BIN_DIR="$CDHIT_BUILD_DIR"
update_path $CDHIT_BIN_DIR

PRANK_BIN_DIR="$PRANK_BUILD_DIR/src"
update_path $PRANK_BIN_DIR

update_perl_path () {
  new_dir=$1
  PERL5LIB=${PERL5LIB-$new_dir}
  if [[ ! "$PERL5LIB" =~ (^|:)"${new_dir}"(:|$) ]]; then
    export PERL5LIB=${new_dir}:${PERL5LIB}
  fi
}

update_perl_path "$BEDTOOLS_BUILD_DIR/lib"

cd $start_dir
cpanm Dist::Zilla
dzil authordeps --missing | cpanm
dzil listdeps --missing | cpanm

cd $start_dir

set +eu
set +x
