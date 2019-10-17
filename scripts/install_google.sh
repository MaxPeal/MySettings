#!/bin/sh
# Install protobuf, gflags and glog

source utils.sh

cd /tmp

print_delim

PB_PACKAGE=protobuf
PB_VERSION=3.9.1
PB_LINK="https://github.com/protocolbuffers/protobuf/releases/download/v3.9.1/protobuf-all-3.9.1.tar.gz"
PB_SHA_SUM="3040a5b946d9df7aa89c0bf6981330bf92b7844fd90e71b61da0c721e421a421"
PB_ARCHIVE=pb_archive
PB_DIR=pb_dir

check_package $PB_PACKAGE
if [ $? -ne 0 ]; then
  print_info "Install $PB_PACKAGE"
  package_loader $PB_LINK $PB_ARCHIVE $PB_SHA_SUM
  if [ $? -ne 0 ]; then
    print_error "$PB_PACKAGE can not be loaded"
    exit 1
  fi

  mkdir $PB_DIR
  tar -xzvf $PB_ARCHIVE --directory $PB_DIR --strip-components=1
  rm $PB_ARCHIVE
  cd $PB_DIR

  ./autogen.sh
  ./configure
  make -j4

  ch_install $PACKAGE $VERSION
  if [ $? -ne 0 ]; then
    cd $CUR_DIR
    rm -rf $PB_DIR
    print_error "$PB_PACKAGE can not be installed"
    exit 1
  fi
  ldconfig

  cd $CUR_DIR
  rm -rf $PB_DIR
fi

print_delim

GF_PACKAGE=gflags
GF_VERSION=2.2.2
GF_LINK="https://github.com/gflags/gflags/archive/v2.2.2.tar.gz"
GF_SHA_SUM="34af2f15cf7367513b352bdcd2493ab14ce43692d2dcd9dfc499492966c64dcf"
GF_ARCHIVE=$TMP_DIR/gf_ar
GF_DIR=$TMP_DIR/gf_dir
GF_SHA_SUM="34af2f15cf7367513b352bdcd2493ab14ce43692d2dcd9dfc499492966c64dcf"

check_package $GF_PACKAGE
if [ $? -ne 0 ]; then
  print_info "Install $GF_PACKAGE"
  package_loader $GF_LINK $GF_ARCHIVE $GF_SHA_SUM
  if [$? -ne 0 ]; then
    print_error "$GF_PACKAGE can not be installed"
    exit 1
  fi

  mkdir $GF_DIR
  tar -xzvf $GF_ARCHIVE --directory $GF_DIR --strip-components=1
  rm $ARCHIVE
  mkdir $GF_DIR/build
  cd $GF_DIR/build

  cmake ..
  cmake --build . -- -j4

  ch_install $GF_PACKAGE $GF_VERSION
  if [ $? -ne 0 ]; then
    cd $CUR_DIR
    rm -rf $GF_DIR
    print_error "$GF_PACKAGE can not be installed"
    exit 1
  fi

  cd $CUR_DIR
  rm -rf $GF_DIR
fi

print_delim

GL_PACKAGE=glog
GL_LINK="https://github.com/google/glog/archive/v0.4.0.tar.gz"
GL_SHA_SUM="f28359aeba12f30d73d9e4711ef356dc842886968112162bc73002645139c39c"
GL_ARCHIVE=$TMP_DIR/gl_ar
GL_DIR=$TMP_DIR/gl_dir

check_package $GL_PACKAGE
if [ $? -ne 0 ]; then
  print_info "Install $GL_PACKAGE"
  package_loader $GL_LINK $GL_ARCHIVE $GL_SHA_SUM
  if [ $? -eq 0 ]; then
    print_error "$GL_PACKAGE can not be loaded"
    exit 1
  fi

  mkdir $GL_DIR
  tar -xzvf $GL_ARCHIVE --directory $GL_DIR --strip-components=1
  rm $GL_ARCHIVE
  mkdir $GL_DIR/build
  cd $GL_DIR/build

  cmake ..
  cmake --build . -- -j4

  ch_install $PACKAGE $VERSION
  if [ $? -ne 0 ]; then
    cd $CUR_DIR
    rm -rf $GL_DIR
    print_error "$GL_PACKAGE can not be installed"
    exit 1
  fi

  cd $CUR_DIR
  rm -rf $GL_DIR
fi

print_delim
