#!/bin/bash

#
#  Build Script for Carbonite Kernel for the OnePlus 5!
#  Based off RenderBroken's build script which is...
#  ...based off AK's build script ~~ Thanks!
#
#  git log --oneline --decorate
#

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image.gz-dtb"
DEFCONFIG="cheeseburger_defconfig"

# Kernel Details
if [ "$1" == "cr" ]
then
    ROM="CR"
    git am 0001-SQUASHED-Reconfigure-gestures-implementation.patch
else
    ROM="OOS"
fi

VER="CarboniteKERNEL-$ROM-R2"
VARIANT="OP5-N"

# Vars
export LOCALVERSION=~`echo $VER`
export ARCH=arm64
export SUBARCH=arm64

# Paths
KERNEL_DIR="${HOME}/android/kernel/op5"
REPACK_DIR="${HOME}/android/kernel/anykernel2"
MODULES_DIR="$REPACK_DIR/modules"
ZIP_MOVE="${HOME}/android/kernel/out/op5"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot"

function clean_all {
		echo
		make clean && make mrproper
		rm $ZIMAGE_DIR/$KERNEL
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
}

function make_modules {
		rm `echo $MODULES_DIR"/*"`
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
		${CROSS_COMPILE}strip --strip-unneeded $MODULES_DIR/*
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 "$VER"-"$VARIANT".zip *
		mv "$VER"-"$VARIANT".zip $ZIP_MOVE
		cd $KERNEL_DIR
}

rm -rf $REPACK_DIR/zImage
clear
echo "CarboniteKERNEL build script:"
export CROSS_COMPILE=${HOME}/android/toolchains/google/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-
echo

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		DATE_START=$(date +"%s")
		make_kernel
        	if [ -f "$ZIMAGE_DIR/$KERNEL" ]
       		then
		    cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
		    make_modules
    		    make_zip
        	else
        	    echo "!!!!!!!!!!!!!!!!!!!"
        	    echo "!! Build failed. !!"
        	    echo "!!!!!!!!!!!!!!!!!!!"
        	fi
		echo "------------------"
		echo "-- Completed in --"
		echo "------------------"
		DATE_END=$(date +"%s")
		DIFF=$(($DATE_END - $DATE_START))
		echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo
if [ -f "$ZIP_MOVE/$VER-$VARIANT.zip" ]
then
    echo $VER-$VARIANT.zip
    echo
fi
if [ "$1" == "cr" ]
then
    echo "REMEMBER THAT THIS IS A CR BUILD!"
    echo
fi
