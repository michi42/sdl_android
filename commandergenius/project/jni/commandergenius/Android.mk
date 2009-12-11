LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := commandergenius

CG_SUBDIRS := \
src \
src/cinematics \
src/dialog \
src/include \
src/include/vorbis \
src/include/gui \
src/include/fileio \
src/vorbis \
src/vorticon \
src/vorticon/ai \
src/vorticon/finale \
src/vorticon/playgame \
src/vorticon/infoscenes \
src/graphics \
src/hqp \
src/sdl \
src/sdl/sound \
src/sdl/video \
src/scale2x \
src/fileio \
src/common \
src/common/Menu \


# Add more subdirs here, like src/subdir1 src/subdir2

LOCAL_CFLAGS := $(foreach D, $(CG_SUBDIRS), -I$(CG_SRCDIR)/$(D)) \
				-I$(LOCAL_PATH)/../sdl/include \
				-I$(LOCAL_PATH)/../sdl_mixer \
				-I$(LOCAL_PATH)/../stlport/stlport \

LOCAL_CFLAGS += -DBUILD_SDL -DBUILD_WITH_OGG

#Change C++ file extension as appropriate
LOCAL_CPP_EXTENSION := .cpp

LOCAL_SRC_FILES := $(foreach F, $(CG_SUBDIRS), $(addprefix $(F)/,$(notdir $(wildcard $(LOCAL_PATH)/$(F)/*.cpp))))
# Uncomment to also add C sources
LOCAL_SRC_FILES += $(foreach F, $(CG_SUBDIRS), $(addprefix $(F)/,$(notdir $(wildcard $(LOCAL_PATH)/$(F)/*.c))))

LOCAL_STATIC_LIBRARIES := sdl_mixer sdl tremor stlport

LOCAL_LDLIBS := -lGLESv1_CM -ldl -llog

include $(BUILD_SHARED_LIBRARY)

