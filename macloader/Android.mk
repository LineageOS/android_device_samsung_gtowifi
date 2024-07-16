LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    main.c

LOCAL_SHARED_LIBRARIES := \
    liblog

LOCAL_MODULE := macloader_wcnss
LOCAL_INSTALLED_MODULE_STEM := macloader
LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_MODULE_TAGS := optional
LOCAL_VENDOR_MODULE := true

include $(BUILD_EXECUTABLE)
