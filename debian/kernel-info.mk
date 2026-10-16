########################################################################
# Kernel settings - Oppo A38 (CPH2579, joan)
# MediaTek MT6768 | stock: oplus/ossi:14 (Android 14) on A12-era MTK vendor
# boot header v2 | init_boot + vendor_boot partitions are ZERO-FILLED
# (MTK keeps the whole ramdisk in boot.img).
# Every boot parameter below was verified by unpacking the stock boot_a.img.
########################################################################

# Android ("downstream") kernel
VARIANT = android

# kernel Makefile: VERSION=4 PATCHLEVEL=19 SUBLEVEL=191
KERNEL_BASE_VERSION = 4.19.191

# Stock cmdline is: bootopt=64S3,32N2,64N2 buildvariant=user
# Appended: permissive selinux for the Halium LXC container, loop partitions,
# console, and the droidian.lvm.prefer entry Droidian needs (no 'systempart').
KERNEL_BOOTIMAGE_CMDLINE = bootopt=64S3,32N2,64N2 buildvariant=user androidboot.selinux=permissive loop.max_part=7 console=tty0 droidian.lvm.prefer

DEVICE_VENDOR = oppo
DEVICE_MODEL = joan
DEVICE_FULL_NAME = Oppo A38 (CPH2579)

# Base defconfig = full stock config extracted from the boot_a kernel image
# (CONFIG_IKCONFIG=y) shipped as droidian/droidian_joan_defconfig.
# Deltas: droidian/common_fragments/{halium,droidian}.config + joan.config.
KERNEL_CONFIG_USE_FRAGMENTS = 1
KERNEL_CONFIG_USE_DIFFCONFIG = 0
KERNEL_DEFCONFIG = droidian_joan_defconfig
KERNEL_CONFIG_EXTRA_FRAGMENTS = joan.config

# DTB: stock boot.img carries a separate 139279-byte DTB section (header v2);
# the shipped kernel is a plain gzip Image with no appended dtb.
KERNEL_IMAGE_WITH_DTB = 1
KERNEL_IMAGE_DTB = arch/arm64/boot/dts/mediatek/mt6768.dtb

# DTBO: the stock dtbo partition carries 18 oplus6769 overlays matched to the
# unit's board revision. Do NOT build or flash a dtbo.img - keep stock.
KERNEL_IMAGE_WITH_DTB_OVERLAY = 0
KERNEL_IMAGE_WITH_DTB_OVERLAY_IN_KERNEL = 0

# mkbootimg offsets - verified against the stock boot_a.img
KERNEL_BOOTIMAGE_PAGE_SIZE = 2048
KERNEL_BOOTIMAGE_BASE_OFFSET = 0x40000000
KERNEL_BOOTIMAGE_KERNEL_OFFSET = 0x00080000
KERNEL_BOOTIMAGE_INITRAMFS_OFFSET = 0x07c80000
KERNEL_BOOTIMAGE_SECONDIMAGE_OFFSET = 0x00000000
KERNEL_BOOTIMAGE_TAGS_OFFSET = 0x0bc80000
KERNEL_BOOTIMAGE_DTB_OFFSET = 0x0bc80000

# Mirror the stock header values (as reported by magiskboot)
KERNEL_BOOTIMAGE_OS_VERSION = 12.0.0
KERNEL_BOOTIMAGE_PATCH_LEVEL = 2024-12

# Stock boot_a.img is boot image header version 2 (MTK, non-GKI)
KERNEL_BOOTIMAGE_VERSION = 2

KERNEL_INITRAMFS_COMPRESSION = gz

# init_boot / vendor_boot exist as partitions but are 100% zero-filled;
# do not generate or flash them.
KERNEL_BOOTIMAGE_GENERATE_VENDOR_BOOT = 0
KERNEL_BOOTIMAGE_VENDOR_CMDLINE =

########################################################################
# Android verified boot
########################################################################

DEVICE_VBMETA_REQUIRED = 1
DEVICE_VBMETA_IS_SAMSUNG = 0

# boot_a/boot_b are 64 MiB
KERNEL_BOOTIMAGE_PARTITION_SIZE = 67108864

########################################################################
# Automatic flashing on package upgrades
########################################################################

FLASH_ENABLED = 1
FLASH_IS_AONLY = 0
FLASH_IS_LEGACY_DEVICE = 0
FLASH_IS_EXYNOS = 0
FLASH_USE_TELNET = 0

# Must match ro.product.vendor.manufacturer / ro.product.vendor.model of the
# stock firmware (Oppo's generic "ossi" mainline identity).
FLASH_INFO_MANUFACTURER = oplus
FLASH_INFO_MODEL = ossi
FLASH_INFO_CPU = MT6768
FLASH_INFO_DEVICE_IDS = joan CPH2579

########################################################################
# Kernel build settings
########################################################################

BUILD_CROSS = 1
BUILD_TRIPLET = aarch64-linux-gnu-
BUILD_CLANG_TRIPLET = aarch64-linux-gnu-

# MTK pins clang-r383902 (build.config.mtk.aarch64) and clang-r433403b (clang 12.0.5) —
# (build.config.mtk.aarch64.tiramisu - the variant used for the Android 14
# build). If this package is unavailable in the build container, try
# 10.0-r383902 or see the Droidian porting guide for the clang-android-* packages)
# package list.
CLANG_CUSTOM = 0
CLANG_VERSION = 12.0-r416183b
BUILD_PATH = /usr/lib/llvm-android-$(CLANG_VERSION)/bin

BUILD_LLVM = 1
BUILD_SKIP_MODULES = 0

DEB_TOOLCHAIN = binutils-aarch64-linux-gnu

DEB_BUILD_ON = amd64
DEB_BUILD_FOR = arm64
KERNEL_ARCH = arm64

# Stock kernel image is plain gzip
KERNEL_BUILD_TARGET = Image.gz
