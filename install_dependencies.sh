#!/bin/bash

set -x
set -eu

start_dir=$(pwd)
ROARY_LIB_DIR="${start_dir}/lib"
ROARY_BIN_DIR="${start_dir}/bin"

PARALLEL_VERSION=${PARALLEL_VERSION:-"20160722"}
PARALLEL_DOWNLOAD_FILENAME="parallel-${PARALLEL_VERSION}.tar.bz2" 
PARALLEL_URL="http://ftp.gnu.org/gnu/parallel/${PARALLEL_DOWNLOAD_FILENAME}"

BEDTOOLS_VERSION="2.26.0"
BEDTOOLS_DOWNLOAD_FILENAME="bedtools-${BEDTOOLS_VERSION}.tar.gz"
BEDTOOLS_URL="https://github.com/arq5x/bedtools2/releases/download/v${BEDTOOLS_VERSION}/${BEDTOOLS_DOWNLOAD_FILENAME}"

CDHIT_SHORT_VERSION="4.6.6"
CDHIT_LONG_VERSION="4.6.6-2016-0711"
CDHIT_DOWNLOAD_FILENAME="cd-hit-${CDHIT_SHORT_VERSION}.tar.gz"
CDHIT_URL="https://github.com/weizhongli/cdhit/releases/download/V${CDHIT_SHORT_VERSION}/cd-hit-v${CDHIT_LONG_VERSION}.tar.gz"

PRANK_VERSION="0.140603"
PRANK_DOWNLOAD_FILENAME="prank-msa-master.tar.gz"
PRANK_URL="https://github.com/ariloytynoja/prank-msa/archive/master.tar.gz"

BLAST_VERSION="2.4.0"
BLAST_DOWNLOAD_FILENAME="ncbi-blast-${BLAST_VERSION}+-x64-linux.tar.gz"
BLAST_URL="ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/${BLAST_VERSION}/${BLAST_DOWNLOAD_FILENAME}"

MCL_VERSION="14-137"
MCL_DOWNLOAD_FILENAME="mcl-${MCL_VERSION}.tar.gz"
MCL_URL="http://micans.org/mcl/src/mcl-${MCL_VERSION}.tar.gz"

FASTTREE_VERSION="2.1.9"
FASTTREE_DOWNLOAD_FILENAME="FastTree-${FASTTREE_VERSION}.c"
FASTTREE_URL="http://microbesonline.org/fasttree/FastTree-${FASTTREE_VERSION}.c"

MAFFT_VERSION="7.271"
MAFFT_DOWNLOAD_FILENAME="mafft-${MAFFT_VERSION}-without-extensions-src.tgz"
MAFFT_URL="http://mafft.cbrc.jp/alignment/software/${MAFFT_DOWNLOAD_FILENAME}"

# Make an install location
if [ ! -d 'build' ]; then
  mkdir build
fi
cd build
build_dir=$(pwd)

PARALLEL_DOWNLOAD_PATH="$(pwd)/${PARALLEL_DOWNLOAD_FILENAME}"
BEDTOOLS_DOWNLOAD_PATH="$(pwd)/${BEDTOOLS_DOWNLOAD_FILENAME}"
CDHIT_DOWNLOAD_PATH="$(pwd)/${CDHIT_DOWNLOAD_FILENAME}"
PRANK_DOWNLOAD_PATH="$(pwd)/${PRANK_DOWNLOAD_FILENAME}"
BLAST_DOWNLOAD_PATH="$(pwd)/${BLAST_DOWNLOAD_FILENAME}"
MCL_DOWNLOAD_PATH="$(pwd)/${MCL_DOWNLOAD_FILENAME}"
FASTTREE_DOWNLOAD_PATH="$(pwd)/${FASTTREE_DOWNLOAD_FILENAME}"
MAFFT_DOWNLOAD_PATH="$(pwd)/${MAFFT_DOWNLOAD_FILENAME}"

PARALLEL_BUILD_DIR="$(pwd)/parallel-${PARALLEL_VERSION}"
BEDTOOLS_BUILD_DIR="$(pwd)/bedtools2"
CDHIT_BUILD_DIR="$(pwd)/cd-hit-v${CDHIT_LONG_VERSION}"
PRANK_BUILD_DIR="$(pwd)/prank-msa-master"
BLAST_BUILD_DIR="$(pwd)/ncbi-blast-${BLAST_VERSION}+"
MCL_BUILD_DIR="$(pwd)/mcl-${MCL_VERSION}"
FASTTREE_BUILD_DIR="$(pwd)/fasttree"
MAFFT_BUILD_DIR="$(pwd)/mafft-${MAFFT_VERSION}-without-extensions"


download () {
  download_url=$1
  download_path=$2
  cd $build_dir
  if [ -e "$download_path" ]; then
    echo "Skipping download of $download_url, $download_path already exists"
  else
    echo "Downloading $download_url to $download_path"
    wget $download_url -O $download_path
    pwd
  fi
}

untar () {
  to_untar=$1
  expected_directory=$2
  if [ -d "$expected_directory" ]; then
    rm -rf $expected_directory
  fi
  echo "Untarring $to_untar to $expected_directory"
  cd $build_dir
  tar xzvf $to_untar
  rm $to_untar
  pwd
}

if [ -e "$BLAST_BUILD_DIR/bin/blastp" ]; then
  echo "blast already untarred to $BLAST_BUILD_DIR, skipping"
else
  download $BLAST_URL $BLAST_DOWNLOAD_PATH
  untar $BLAST_DOWNLOAD_PATH $BLAST_BUILD_DIR
fi

# Build parallel
if [ -e "$PARALLEL_BUILD_DIR/src/parallel" ]; then
  echo "Parallel already built, skipping"
else
  download $PARALLEL_URL $PARALLEL_DOWNLOAD_PATH
  echo "Untarring parallel to $PARALLEL_BUILD_DIR"
  tar xjvf $PARALLEL_DOWNLOAD_PATH
  echo "Building parallel"
  cd $PARALLEL_BUILD_DIR
  ./configure
  make
fi

# Build bedtools
if [ -e "$BEDTOOLS_BUILD_DIR/bin/bedtools" ]; then
  echo "Bedtools already built, skipping"
else

  download $BEDTOOLS_URL $BEDTOOLS_DOWNLOAD_PATH
  untar $BEDTOOLS_DOWNLOAD_PATH $BEDTOOLS_BUILD_DIR
  cd $BEDTOOLS_BUILD_DIR
  echo "Building bedtools"
  ls -alrt
  make
fi

# Build cd-hit
if [ -e "$CDHIT_BUILD_DIR/cd-hit" ]; then
  echo "cd-hit already built, skipping"
else
  download $CDHIT_URL $CDHIT_DOWNLOAD_PATH
  untar $CDHIT_DOWNLOAD_PATH $CDHIT_BUILD_DIR
  echo "Building cd-hit"
  cd $CDHIT_BUILD_DIR
  make
fi

# Build prank
if [ -e "$PRANK_BUILD_DIR/src/prank" ]; then
  echo "prank already built, skipping"
else
  download $PRANK_URL $PRANK_DOWNLOAD_PATH
  untar $PRANK_DOWNLOAD_PATH $PRANK_BUILD_DIR
  echo "Building prank"
  cd $PRANK_BUILD_DIR
  cd src
  make
fi

# Build MCL
if [ -e "$MCL_BUILD_DIR/src/shmcl/mcl" ]; then
  echo "MCL already built, skipping"
else
  download $MCL_URL $MCL_DOWNLOAD_PATH
  untar $MCL_DOWNLOAD_PATH $MCL_BUILD_DIR
  echo "Building MCL"
  cd $MCL_BUILD_DIR
  ./configure
  make
fi

# Build FastTree
if [ -e "$FASTTREE_BUILD_DIR/FastTree" ]; then
  echo "FastTree already built, skipping"
else
  download $FASTTREE_URL $FASTTREE_DOWNLOAD_PATH
  mkdir -p $FASTTREE_BUILD_DIR
  mv $FASTTREE_DOWNLOAD_FILENAME $FASTTREE_BUILD_DIR
  cd $FASTTREE_BUILD_DIR
  echo "Building FastTree"
  gcc -o FastTree FastTree-${FASTTREE_VERSION}.c -lm
fi

export MAFFT_INSTALL_DIR="${MAFFT_BUILD_DIR}/build"
# Build MAFFT
if [ -e "$MAFFT_BUILD_DIR/build/mafft" ]; then
  echo "MAFFT already built, skipping"
else
  download $MAFFT_URL $MAFFT_DOWNLOAD_PATH
  untar $MAFFT_DOWNLOAD_PATH $MAFFT_BUILD_DIR
  echo "Building MAFFT"
  cd $MAFFT_BUILD_DIR
  mkdir -p $MAFFT_INSTALL_DIR
  cd core
  sed -i '1s!.*!PREFIX = $(MAFFT_INSTALL_DIR)!' Makefile
  make
  make install
fi


# Add things to PATH
update_path () {
  new_dir=$1
  if [[ ! "$PATH" =~ (^|:)"${new_dir}"(:|$) ]]; then
	echo "export PATH=${new_dir}:${PATH}"
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

BLAST_BIN_DIR="$BLAST_BUILD_DIR/bin"
update_path $BLAST_BIN_DIR

MCL_BIN_DIR="$MCL_BUILD_DIR/src/shmcl"
update_path $MCL_BIN_DIR
MCL_BIN_DIR_2="$MCL_BUILD_DIR/src/alien/oxygen/src"
update_path $MCL_BIN_DIR_2

FASTTREE_BIN_DIR=$FASTTREE_BUILD_DIR
update_path $FASTTREE_BIN_DIR
MAFFT_BIN_DIR="$MAFFT_INSTALL_DIR/bin"
update_path $MAFFT_BIN_DIR

update_perl_path () {
  new_dir=$1
  PERL5LIB=${PERL5LIB-$new_dir}
  if [[ ! "$PERL5LIB" =~ (^|:)"${new_dir}"(:|$) ]]; then
	echo "export PERL5LIB=${new_dir}:${PERL5LIB}"
    export PERL5LIB=${new_dir}:${PERL5LIB}
  fi
}

BEDTOOLS_LIB_DIR="$BEDTOOLS_BUILD_DIR/lib"
update_perl_path $BEDTOOLS_LIB_DIR

cd $start_dir
cpanm --notest Dist::Zilla 
dzil authordeps --missing | cpanm --notest
dzil listdeps --missing | cpanm --notest

cd $start_dir

echo "Add the following lines to one of these files ~/.bashrc or ~/.bash_profile or ~/.profile"
echo "export PATH=${ROARY_BIN_DIR}:${PARALLEL_BIN_DIR}:${BEDTOOLS_BIN_DIR}:${CDHIT_BIN_DIR}:${PRANK_BIN_DIR}:${BLAST_BIN_DIR}:${MCL_BIN_DIR}:${MCL_BIN_DIR_2}:${FASTTREE_BIN_DIR}:${MAFFT_BIN_DIR}:${PATH}"
echo "export PERL5LIB=${ROARY_LIB_DIR}:${BEDTOOLS_LIB_DIR}:${PERL5LIB}"

set +eu
set +x
