# DroidianKernel — Oppo A38 (CPH2579, `joan`)

Paket kernel Debian/Droidian (Halium 14, base Android 14) untuk **Oppo A38 CPH2579 (codename `joan`, MediaTek MT6768)**.

Repo ini **tidak** menyimpan source kernel — CI meng-clone source resmi Oppo dan
menambahkan lapisan packaging Droidian dari repo ini:

| CI clone | Branch |
|---|---|
| [oppo-source/android_kernel_oppo_mt6769](https://github.com/oppo-source/android_kernel_oppo_mt6769) | `oppo/mt6769_u_14.0_a38_a18` (Linux **4.19.191**, base Android 14) |

## Apa yang di-build

* `linux-image-4.19.191-oppo-joan` — kernel + modul
* `linux-bootimage-4.19.191-oppo-joan` — **boot.img** (kernel Image.gz + DTB `mt6768` + **initramfs Halium/Droidian** dari `initramfs-tools-halium`) + `vbmeta.img` kosong (verifikasi AVB dimatikan)
* `linux-headers-…` dan paket "latest" (metapackage)

Boot image ini adalah **halium-boot untuk base Android 14** versi Droidian:
kernel kustom + initramfs halium (`linux-initramfs-halium-generic`) yang
memasang rootfs Droidian di `userdata`, menarik `vendor` dari partisi dinamis
`super` (via dm-linear `parse-android-dynparts`), lalu menyalakan container
LXC `android` yang menjalankan Halium GSI 14 di atas vendor Android 12 stock.

## Struktur repo

```
debian/kernel-info.mk      # parameter boot.img (offset, cmdline, header v2) — diverifikasi dari boot_a.img
debian/rules               # memakai droidian/linux-packaging-snippets
droidian/
  droidian_joan_defconfig  # CONFIG LENGKAP hasil extract-ikconfig dari boot_a.img (5841 baris)
  common_fragments/        # halium.config + droidian.config (di-merge via merge_config)
  joan.config              # hook khusus device
scripts/publish-apt.sh     # publikasi .deb ke gh-pages sebagai apt repo
.github/workflows/kernel.yml
```

## Defconfig

Defconfig asli diekstrak dari **image kernel yang benar-benar berjalan di slot A**
(`boot_a.img`) memakai `scripts/extract-ikconfig` — memungkinkan karena kernel
stock punya `CONFIG_IKCONFIG=y`. Karena MTK menulis defconfig dengan direktif
preprosesor (`#ifdef OPLUS_FEATURE_*`), config hasil ekstraksi ini justru
lebih akurat daripada `k69v1_64_k419_defconfig` di source tree.

Delta Halium (namespace, cgroups, AppArmor, devtmpfs, VT, binder/ashmem, RNDIS,
BT RFCOMM/BNEP/HIDP, matikan LOW_MEMORY_KILLER/PARANOID_NETWORK/USER_HELPER)
ada di `droidian/common_fragments/halium.config`.

## Parameter boot image (dari boot_a.img stock)

| Parameter | Nilai |
|---|---|
| header version | **2** (non-GKI) |
| page size | 2048 |
| base | `0x40000000` |
| kernel offset | `0x00080000` |
| ramdisk offset | `0x07c80000` |
| tags offset | `0x0bc80000` |
| dtb offset | `0x0bc80000` (dtb 139279 B, section v2) |
| cmdline | `bootopt=64S3,32N2,64N2 buildvariant=user` + `androidboot.selinux=permissive loop.max_part=7 console=tty0 droidian.lvm.prefer` |

`init_boot` dan `vendor_boot` di perangkat ini **100% kosong (zero-fill)** —
MTK menaruh seluruh ramdisk di `boot.img`, jadi tidak digenerate.

## Toolchain

MTK mem-pinning clang `r383902` / `r433403b` (variant tiramisu, dipakai build
Android 14). Repo ini memakai `clang-android-12.0-r433403b` +
`BUILD_LLVM=1 LLVM_IAS=1` sesuai `build.config.mtk.aarch64`. Jika paket
tidak ada di container build, ganti `CLANG_VERSION` di `debian/kernel-info.mk`.

## Build manual (lokal)

```bash
git clone -b oppo/mt6769_u_14.0_a38_a18 --depth=1 \
  https://github.com/oppo-source/android_kernel_oppo_mt6769 kernel-src
cp -a debian droidian kernel-src/
cp droidian/droidian_joan_defconfig kernel-src/arch/arm64/configs/

docker run --rm -it -v "$PWD/kernel-src:/buildd/sources" -v "$PWD/packages:/buildd" \
  quay.io/droidian/build-essential:next-amd64 bash -c \
  'cd /buildd/sources && rm -f debian/control && debian/rules debian/control && RELENG_HOST_ARCH=arm64 releng-build-package'
```

## Repo terkait

* **DroidianLinux** — paket adaptasi (`adaptation-oppo-joan`), build image GSI
  Droidian api34, dokumentasi port: <https://github.com/giel-arch/DroidianLinux>
* Apt repo hasil CI (branch `gh-pages` repo ini):
  `deb [trusted=yes] https://giel-arch.github.io/DroidianKernel current main`
