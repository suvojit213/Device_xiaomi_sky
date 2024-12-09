#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=sky
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."
export TARGET_ENABLE_CHECKELF="true"

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
    -n | --no-cleanup)
        CLEAN_VENDOR=false
        ;;
    -k | --kang)
        KANG="--kang"
        ;;
    -s | --section)
        SECTION="${2}"
        shift
        CLEAN_VENDOR=false
        ;;
    *)
        SRC="${1}"
        ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
    system_ext/lib64/libwfdmmsrc_system.so)
         grep -q "libgui_shim.so" "${2}" || "${PATCHELF}" --add-needed "libgui_shim.so" "${2}"
         ;;
    system_ext/lib64/libwfdnative.so)
         grep -q "libinput_shim.so" "${2}" || "${PATCHELF}" --add-needed "libinput_shim.so" "${2}"
         ;;
    system_ext/lib64/libwfdservice.so)
         "${PATCHELF}" --replace-needed "android.media.audio.common.types-V2-cpp.so" "android.media.audio.common.types-V3-cpp.so" "${2}"
         ;;
    vendor/bin/hw/android.hardware.security.keymint-service-qti|vendor/lib64/libqtikeymint.so)
        "${PATCHELF}" --add-needed "android.hardware.security.rkp-V1-ndk.so" "${2}"
        "${PATCHELF}" --replace-needed "android.hardware.security.keymint-V1-ndk_platform.so" "android.hardware.security.keymint-V1-ndk.so" "${2}"
        "${PATCHELF}" --replace-needed "android.hardware.security.secureclock-V1-ndk_platform.so" "android.hardware.security.secureclock-V1-ndk.so" "${2}"
        "${PATCHELF}" --replace-needed "android.hardware.security.sharedsecret-V1-ndk_platform.so" "android.hardware.security.sharedsecret-V1-ndk.so" "${2}"
        ;;
    vendor/bin/qcc-trd)
        "${PATCHELF}" --replace-needed "libgrpc++_unsecure.so" "libgrpc++_unsecure_prebuilt.so" "${2}"
        ;;
    vendor/bin/sensors.qti)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/bin/sensors-qesdk)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/etc/seccomp_policy/atfwd@2.0.policy)
        grep -q "gettid: 1" "${2}" || echo "gettid: 1" >> "${2}"
        ;;
     vendor/etc/seccomp_policy/c2audio.vendor.ext-arm64.policy)
        grep -q "setsockopt: 1" "${2}" || echo "setsockopt: 1" >> "${2}"
        ;;
     vendor/etc/seccomp_policy/wfdhdcphalservice.policy)
        grep -q "gettid: 1" "${2}" || echo "gettid: 1" >> "${2}"
        ;;
    vendor/etc/media_codecs_ravelin.xml)
            sed -i -E '/media_codecs_(google_audio|google_c2|google_telephony|vendor_audio)/d' "${2}"
            ;;
    vendor/lib64/hw/fingerprint.fpc.default.so)
        "${PATCHELF}" --replace-needed "com.fingerprints.extension@1.0.so" "com.fingerprints.extension@1.0_vendor.so" "${2}"
        ;;
    vendor/lib64/libcamximageformatutils.so)
        "${PATCHELF}" --replace-needed "vendor.qti.hardware.display.config-V2-ndk_platform.so" "vendor.qti.hardware.display.config-V2-ndk.so" "${2}"
        ;;
    vendor/lib64/libqshcamera.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libsnsdiaglog.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/sensors.touch.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/sensors.ssc.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libssc.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libsensorcal.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/mediadrm/libwvdrmengine.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libsnsapi.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libssccalapi@2.0.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libgnss.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libgrpc++_unsecure_prebuilt.so)
        "${PATCHELF}" --set-soname "libgrpc++_unsecure_prebuilt.so" "${2}"
        ;;
    vendor/lib64/libwvhidl.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libsnsdiaglog.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/sensors.touch.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/sensors.ssc.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libssc.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libsensorcal.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/mediadrm/libwvdrmengine.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libsnsapi.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libssccalapi@2.0.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libgnss.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libhme.so)
        "${PATCHELF}" --replace-needed "libstdc++.so" "libstdc++_vendor.so" "${2}"
        ;;
    vendor/lib64/libimp.so)
        "${PATCHELF}" --replace-needed "libjnigraphics.so" "libjnigraphics_prebuilt.so" "${2}"
        ;;
    vendor/lib64/libjnigraphics_prebuilt.so)
        "${PATCHELF}" --set-soname "libjnigraphics_prebuilt.so" "${2}"
        ;;
    vendor/lib64/libopencv_java4.so)
        "${PATCHELF}" --replace-needed "libjnigraphics.so" "libjnigraphics_prebuilt.so" "${2}"
        ;;
    vendor/lib64/vendor.libdpmframework.so)
        "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
        ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
