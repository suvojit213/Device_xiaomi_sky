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

function vendor_imports() {
    cat << EOF >> "$1"
		"device/xiaomi/sky",
		"hardware/qcom-caf/sm8450",
		"hardware/qcom-caf/wlan",
		"hardware/xiaomi",
		"vendor/qcom/opensource/commonsys/display",
		"vendor/qcom/opensource/commonsys-intf/display",
		"vendor/qcom/opensource/dataservices",
EOF
}

function lib_to_package_fixup_vendor_variants() {
    if [ "$2" != "vendor" ]; then
        return 1
    fi
    case "$1" in
        vendor.qti.hardware.dpmservice@1.0 | \
        vendor.qti.hardware.dpmservice@1.1 | \
        vendor.qti.hardware.fm@1.0 | \
        vendor.qti.hardware.qccsyshal@1.0 | \
        vendor.qti.hardware.qccsyshal@1.1 | \
        vendor.qti.hardware.qccvndhal@1.0 | \
        vendor.qti.imsrtpservice@3.0 | \
        vendor.qti.diaghal@1.0 | \
        vendor.qti.hardware.wifidisplaysession@1.0 | \
        vendor.xiaomi.hardware.fingerprintextension@1.0 | \
        com.qualcomm.qti.dpm.api@1.0)
            echo "$1-vendor"
            ;;
        libagm | \
        libagmclient | \
        libagmmixer | \
        libar-pal | \
        libpalclient | \
        libsndcardparser | \
        libwpa_client | \
        vendor.qti.hardware.pal@1.0-impl)
            ;;
        *)
            return 1
    esac
}

function lib_to_package_fixup() {
    lib_to_package_fixup_clang_rt_ubsan_standalone "$1" || \
    lib_to_package_fixup_proto_3_9_1 "$1" || \
    lib_to_package_fixup_vendor_variants "$@"
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}"

# Warning headers and guards
write_headers

write_makefiles "${MY_DIR}/proprietary-files.txt"

# Finish
write_footers
