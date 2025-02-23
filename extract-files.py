#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.file import File
from extract_utils.fixups_blob import (
    BlobFixupCtx,
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixup_remove,
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    "hardware/qcom-caf/msm8953",
    "hardware/qcom-caf/wlan",
    "vendor/qcom/opensource/dataservices",
    "vendor/qcom/opensource/display",
]


lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    (
        'libmm-qcamera',
        'libmm-omxcore'
    ): lib_fixup_remove,
}


blob_fixups: blob_fixups_user_type = {
    (
        'vendor/lib/libwvhidl.so',
        'vendor/lib/mediadrm/libwvdrmengine.so'
    ): blob_fixup()
        .add_needed('libcrypto_shim.so'),
    'vendor/lib/libmmcamera_faceproc2.so': blob_fixup()
        .fix_soname(),
}  # fmt: skip

module = ExtractUtilsModule(
    'gtowifi',
    'samsung',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
