#!/bin/sh
# Compile and install soft for developing

CUR_DIR=$(pwd)
FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo --------------------------------------------------------------------------

# if checkinstall not install
if [ ! -x "$(command -v checkinstall)" ]; then
  echo Install tool for installation
  apt-get install -y \
    checkinstall

  if [ $? -ne 0 ]; then
    echo checkinstall can not be installed
    exit 1
  fi
fi

if [ ! -x "$(command -v automake)" ]; then
  echo Install automake
  apt-get install -y \
    automake

  if [ $? -ne 0 ]; then
    echo automake can not be installed
    exit 1
  fi
fi

if [ ! -x "$(command -v wget)" ]; then
  echo Install automake
  apt-get install -y \
    wget

  if [ $? -ne 0 ]; then
    echo wget can not be installed
    exit 1
  fi
fi

# add repository for 3.5 python (because bionic not contains the version)
if [ "$(lsb_release -cs)" = "bionic" ]; then
  add-apt-repository ppa:deadsnakes/ppa
  apt-get update
fi

echo Prepare for install custom deb packages
# For vim, vifm and vimb
echo Install libraries for future packages
apt-get install -y \
  libncurses5-dev libncursesw5-dev \
  libgtk2.0-dev libgnomeui-dev libgnome2-dev \
  libbonoboui2-dev \
  libcairo2-dev \
  libatk1.0-dev \
  libx11-dev libxpm-dev libxt-dev \
  liblua5.3-0 liblua5.3-dev \
  libperl-dev \
  ruby-dev \
  xz-utils libpthread-workqueue-dev \
  libgtk-3-dev \
  libwebkit2gtk-4.0-dev \
  python3.5-dev \
  libcurl4-openssl-dev \
  autoconf

if [ $? -ne 0 ]; then
  echo neded packages can not be installed
  exit 1
fi

echo Add links for lua
LUA_DIR=/usr/include/lua5.3
if [ ! -d $LUA_DIR/lib ]; then
  mkdir $LUA_DIR/lib
fi
ln -sf /usr/lib/x86_64-linux-gnu/liblua5.3.so $LUA_DIR/lib/liblua.so
ln -sf /usr/lib/x86_64-linux-gnu/liblua5.3.a  $LUA_DIR/lib/liblua.a
ln -sf $LUA_DIR                               $LUA_DIR/include


# go to /tmp dir
cd /tmp


# all packages have -ch at the end. It points that it from checkinstall
echo --------------------------------------------------------------------------

echo Install boost
wget "https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.gz"
echo "9a2c2819310839ea373f42d69e733c339b4e9a19deab6bfec448281554aa4dbb boost_1_69_0.tar.gz" | sha256sum -c | grep -v OK
if [ $? -eq 0 ]; then
  echo boost can not be loaded
  exit 1
fi

tar -xzvf boost_1_69_0.tar.gz
rm boost_1_69_0.tar.gz
cd boost_1_69_0

./bootstrap.sh
./b2
checkinstall -D -y --pkgname=boost-ch --pkgversion=1.69.0 --nodoc --backup=no ./b2 install
if [ $? -ne 0 ]; then
  echo boost can not be installed
  exit 1
fi

cd ..
rm -rf boost_1_69_0

echo --------------------------------------------------------------------------

echo Install cmake
wget "https://github.com/Kitware/CMake/releases/download/v3.14.1/cmake-3.14.1.tar.gz"
echo "7321be640406338fc12590609c42b0fae7ea12980855c1be363d25dcd76bb25f  cmake-3.14.1.tar.gz" | sha256sum -c | grep -v OK
if [ $? -eq 0 ]; then
  echo cmake can not be loaded
  exit 1
fi

tar -xzvf cmake-3.14.1.tar.gz
rm cmake-3.14.1.tar.gz
cd cmake-3.14.1

./bootstrap --system-curl
make -j4
checkinstall -D -y --pkgname=cmake-ch --pkgversion=3.14.1 --nodoc --backup=no
if [ $? -ne 0 ]; then
  echo cmake can not be installed
  exit 1
fi

cd ..
rm -rf cmake-3.14.1

echo --------------------------------------------------------------------------

# need for vim (tagbar)
echo Install universal ctags
wget "https://github.com/universal-ctags/ctags/archive/master.zip"
unzip master.zip
rm master.zip

cd ctags-master
./autogen.sh
./configure
make -j4
# real version of universal-ctags is 0.0.0, but we can not set it as version in checkinstall
checkinstall -D -y --pkgname=ctags-ch --pkgversion=0.0.1 --nodoc --backup=no
if [ $? -ne 0 ]; then
  echo ctags can not be installed
  exit 1
fi

cd ..
rm -rf ctags-master

echo --------------------------------------------------------------------------

echo Install vim
wget "https://github.com/vim/vim/archive/v8.1.1140.tar.gz"
echo "b2bd214f9e562308af7203e3e8cfeb13327d503ab2fe23090db9c42f13ca0145  v8.1.1140.tar.gz" | sha256sum -c | grep -v OK
if [ $? -eq 0 ]; then
  echo vim can not be loaded
  exit 1
fi

tar -xzvf v8.1.1140.tar.gz
rm v8.1.1140.tar.gz
cd vim-8.1.1140

./configure --with-features=huge \
            --enable-luainterp=yes \
            --with-lua-prefix=/usr/include/lua5.3 \
            --enable-python3interp=yes \
            --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu \
            --enable-rubyinterp=yes \
            --enable-perlinterp=yes \
            --enable-multibyte \
            --enable-gui=no \
            --enable-cscope \
            --enable-largefile \
            --disable-netbeans \
            --prefix=/usr/local
make -j4
checkinstall -D -y --pkgname=vim-ch --pkgversion=8.1.1140 --nodoc --backup=no
if [ $? -ne 0 ]; then
  echo vim can not be installed
  exit 1
fi

cd ..
rm -rf vim-8.1.1140

echo --------------------------------------------------------------------------

echo Install vifm
wget "https://github.com/vifm/vifm/archive/v0.10.tar.gz"
echo "e5681c9e560e23d9deeec3b5b12e0ccad82612d9592c00407f3dd75cf5066548  v0.10.tar.gz" | sha256sum -c | grep -v OK
if [ $? -eq 0 ]; then
  echo vifm can not be loaded
  exit 1
fi

tar -xzvf v0.10.tar.gz
rm v0.10.tar.gz
cd vifm-0.10

./configure
make -j4
checkinstall -D -y --pkgname=vifm-ch --pkgversion=0.10 --nodoc --backup=no
if [ $? -ne 0 ]; then
  echo vifm can not be installed
  exit 1
fi

cd ..
rm -rf vifm-0.10

echo --------------------------------------------------------------------------

echo Install vimb
wget "https://github.com/fanglingsu/vimb/archive/3.3.0.tar.gz"
echo "5c6fe39b1b2ca18a342bb6683f7fd5b139ead53903f57dd9eecd5a1074576d6c  3.3.0.tar.gz" | sha256sum -c | grep -v OK
if [ $? -eq 0 ]; then
  echo vimb can not be loaded
  exit 1
fi

tar -xzvf 3.3.0.tar.gz
rm 3.3.0.tar.gz
cd vimb-3.3.0

make -j4
checkinstall -D -y --pkgname=vimb-ch --pkgversion=3.3.0 --nodoc --backup=no
if [ $? -ne 0 ]; then
  echo vimb can not be installed
  exit 1
fi

cd ..
rm -rf vimb-3.3.0

echo --------------------------------------------------------------------------

echo Install diff tool to git
cp $FILE_DIR/../git/git_diff_wrapper /usr/local/bin

echo Set vim as default editor
update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
update-alternatives --set editor /usr/local/bin/vim
update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
update-alternatives --set vi /usr/local/bin/vim

echo --------------------------------------------------------------------------

# go back
cd $CUR_DIR