#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j6"
KERNEL="zImage"
DEFCONFIG="velvet_defconfig"
CM_CHECK=`grep -c "case MDP_YCBYCR_H2V1:" drivers/video/msm/mdp4_overlay.c`

# Kernel Details
BASE_HC_VER="Velvet"
VERSION=1
DEVICE="Mako"
if [[ "$1" =~ "cm" || "$1" =~ "CM" ]] ; then
HC_VER="$BASE_HC_VER-V$VERSION-$DEVICE-CM"

if [ $CM_CHECK -eq 0 ] ; then
git am CM/*
fi
else
HC_VER="$BASE_HC_VER-V$VERSION-$DEVICE"
fi

# Vars
export LOCALVERSION=-`echo $BASE_HC_VER`
export ARCH=arm
export SUBARCH=arm

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/android/kernel/Velvet-N4-anykernel"
ZIP_MOVE="${HOME}/android/kernel"
ZIMAGE_DIR="${HOME}/android/kernel/Velvet-N4/arch/arm/boot"

# Functions
function clean_all {
		rm -rf $REPACK_DIR/kernel/zImage
		make clean && make mrproper
}

function make_kernel {
		let "VERSION -= 1"
		echo $VERSION > .version
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 `echo $HC_VER`.zip * -x README .
		mv  `echo $HC_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}

DATE_START=$(date +"%s")

echo -e "${green}"
echo "Velvet Kernel Creation Script:"
echo

echo "---------------"
echo "Kernel Version:"
echo "---------------"

echo -e "${red}"; echo -e "${blink_red}"; echo "$HC_VER"; echo -e "${restore}";

echo -e "${green}"
echo "-----------------"
echo "Making Velvet Kernel:"
echo "-----------------"
echo -e "${restore}"

while read -p "Please choose your option: [1]clean-build / [2]dirty-build / [3]abort " cchoice
do
case "$cchoice" in
	1 )
		echo -e "${green}"
		echo
		echo "[..........Cleaning up..........]"
		echo
		echo -e "${restore}"
		clean_all
		echo -e "${green}"
		echo
		echo "[....Building `echo $HC_VER`....]"
		echo
		echo -e "${restore}"
		make_kernel
		echo -e "${green}"
		echo
		echo "[....Make `echo $HC_VER`.zip....]"
		echo
		echo -e "${restore}"
		make_zip
		echo -e "${green}"
		echo
		echo "[.....Moving `echo $HC_VER`.....]"
		echo
		if [[ "$1" =~ "cm" || "$1" =~ "CM" ]] ; then
		echo "[.....Reverting CM patches.....]"
		git reset --hard HEAD~3
		fi
		echo -e "${restore}"
		break
		;;
	2 )
		echo -e "${green}"
		echo
		echo "[....Building `echo $HC_VER`....]"
		echo
		echo -e "${restore}"
		make_kernel
		echo -e "${green}"
		echo
		echo "[....Make `echo $HC_VER`.zip....]"
		echo
		echo -e "${restore}"
		make_zip
		echo -e "${green}"
		echo
		echo "[.....Moving `echo $HC_VER`.....]"
		echo
		if [[ "$1" =~ "cm" || "$1" =~ "CM" ]] ; then
		echo "[.....Reverting CM patches.....]"
		git reset --hard HEAD~3
		fi
		echo -e "${restore}"
		break
		;;
	3 )
		echo -e "${green}"
		if [[ "$1" =~ "cm" || "$1" =~ "CM" ]] ; then
		echo "[.....Reverting CM patches.....]"
		echo -e "${restore}"
		echo
		git reset --hard HEAD~3
		fi
		break
		;;
	* )
		echo -e "${red}"
		echo
		echo "Invalid try again!"
		echo
		echo -e "${restore}"
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo

