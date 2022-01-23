OPTIONS =  -DF_CPU=@clockRate@ -DUSB_SERIAL -DLAYOUT_US_ENGLISH
OPTIONS += -DUSING_MAKEFILE -D__@mcu@__

CPPFLAGS = -mcpu=cortex-m4 -mthumb -MMD $(OPTIONS)
CXXFLAGS = -std=gnu++0x -felide-constructors -fno-exceptions -fno-rtti

LDFLAGS =  -Wl,--gc-sections,--defsym=__rtc_localtime=0 --specs=nano.specs

LIBS = -lm

CC  = arm-none-eabi-gcc
CXX = arm-none-eabi-g++
