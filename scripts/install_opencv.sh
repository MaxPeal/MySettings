#!/usr/bin/bash

source utils.sh

print_delim

print_info "install soft for OpenCV"
# you need install also compilers, because cuda not support compilers above
# 7 version
apt-get install -y \
  libgtk2.0-dev \
  libtbb-dev \
  zlib1g-dev \
  libpng-dev \
  libjpeg-dev \
  libtiff-dev \
  gcc-7 g++-7

if [ $? -ne 0 ]; then
  print_error "neded packages can not be installed"
  exit 1
fi


# also install packages for python (in this case for python2.7)
apt-get install -y \
  python3-numpy \
  libavcodec-dev \
  ffmpeg \
  python3-matplotlib

if [ $? -ne 0 ]; then
  print_error "neded packages can not be installed"
  exit 1
fi


print_delim

PACKAGE=opencv
OPENCV_VER=4.1.0
OPENCV_LINK="https://github.com/opencv/opencv/archive/$OPENCV_VER.tar.gz"
OPENCV_SHA="8f6e4ab393d81d72caae6e78bd0fd6956117ec9f006fba55fcdb88caf62989b7"
CONTRIB_LINK="https://github.com/opencv/opencv_contrib/archive/$OPENCV_VER.tar.gz"
CONTRIB_SHA="e7d775cc0b87b04308823ca518b11b34cc12907a59af4ccdaf64419c1ba5e682"

OPENCV_ARCHIVE=$TMP_DIR/opecv_archive
OPENCV_DIR=$TMP_DIR/opencv_dir
CONTRIB_ARCHIVE=$TMP_DIR/contrib_archive
CONTRIB_DIR=$TMP_DIR/contrib_dir

check_package $PACKAGE
if [ $? -ne 0 ]; then
  print_info "load $PACKAGE"

  package_loader $OPENCV_LINK $OPENCV_ARCHIVE $OPENCV_SHA
  if [ $? -ne 0 ]; then
    print_error "$PACKAGE can not be loaded"
    exit 1
  fi
  package_loader $CONTRIB_LINK $CONTRIB_ARCHIVE $CONTRIB_SHA
  if [ $? -ne 0 ]; then
    rm $OPENCV_ARCHIVE
    print_error "contrib can not be loaded"
    exit 1
  fi

  mkdir $OPENCV_DIR
  mkdir $CONTRIB_DIR
  tar -xzvf $OPENCV_ARCHIVE --directory $OPENCV_DIR --strip-components=1
  tar -xzvf $CONTRIB_ARCHIVE --directory $CONTRIB_DIR --strip-components=1
  rm $OPENCV_ARCHIVE
  rm $CONTRIB_ARCHIVE


  mkdir $OPENCV_DIR/build
  cd $OPENCV_DIR/build
  # Note! In cuda10 nvidia-video-codec was be deprecated, so you need option
  # BUILD_opencv_cudacodec=OFF. If cuda version less then 10, then you can not
  # set this (by default ON)
  cmake \
    -DCMAKE_C_COMPILER=gcc-7 \
    -DCMAKE_CXX_COMPILER=g++-7 \
    -DBUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DOPENCV_EXTRA_MODULES_PATH=$CONTRIB_DIR/modules \
    -DWITH_CUDA=ON \
    -DOPENCV_DNN_CUDA=ON \
    -DBUILD_opencv_cudacodec=OFF \
    -DWITH_OPENCL=ON \
    -DOPENCV_DNN_OPENCL=ON \
    $OPENCV_DIR
  cmake --build . -- -j4

  ch_install $PACKAGE $VERSION
  if [ $? -ne 0 ]; then
    cd $CUR_DIR
    rm -rf $OPENCV_DIR
    rm -rf $CONTRIB_DIR
    print_error "opencv can not be installed"
    exit 1
  fi

  cd $CUR_DIR
  rm -rf $OPENCV_DIR
  rm -rf $CONTRIB_DIR
fi

print_delim


print_info "Install python3 support"
pip3 install opencv-python opencv-contrib-python
if [ $? -ne 0 ]; then
  print_error "Can not install python3 support for opencv"
  exit 1
fi

print_delim
