#!/bin/bash
set -e

if [ ! -d "$STAGING_DIR" ]; then
    echo "STAGING_DIR needs to be set to your cross toolchain path";
    exit 1
fi

ARCH=${ARCH:-mipsel}
NODE=${NODE:-0.12.7}

TOOLCHAIN_DIR=$(ls -d "$STAGING_DIR/toolchain-"*)
echo $TOOLCHAIN_DIR

export SYSROOT=$(ls -d "$STAGING_DIR/target-"*)

source $TOOLCHAIN_DIR/info.mk # almost a bash script

echo "Cross-compiling for" $TARGET_CROSS

export PATH=$TOOLCHAIN_DIR/bin:$PATH
export CPPPATH=$TARGET_DIR/usr/include
export LIBPATH=$TARGET_DIR/usr/lib

#TODO: anything better than this hack?
OPTS="-I $SYSROOT/usr/include -L $TOOLCHAIN_DIR/lib -L $SYSROOT/usr/lib"

export CC="${TARGET_CROSS}gcc $OPTS"
export CXX="${TARGET_CROSS}g++ $OPTS"
export AR=${TARGET_CROSS}ar
export RANLIB=${TARGET_CROSS}ranlib
export LINK="${TARGET_CROSS}g++ $OPTS"
export CPP="${TARGET_CROSS}gcc $OPTS -E"
export STRIP=${TARGET_CROSS}strip
export OBJCOPY=${TARGET_CROSS}objcopy
export LD="${TARGET_CROSS}g++ $OPTS"
export OBJDUMP=${TARGET_CROSS}objdump
export NM=${TARGET_CROSS}nm
export AS=${TARGET_CROSS}as

export npm_config_arch=$ARCH
node-gyp rebuild --target=$NODE -v

PKG=$(npm ls --depth=0 | head -n1 | cut -f1 -d' ' | tr @ -)
tar czvf $PKG-$ARCH.tgz $(find build -type f -executable)