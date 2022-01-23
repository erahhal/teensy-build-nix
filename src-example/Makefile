include $(shell pkg-config --variable=includedir teensy3-core)/flags.mk

CPPFLAGS += -I. $(shell pkg-config --cflags teensy3-core)
LDFLAGS  += $(shell pkg-config --libs teensy3-core)

OBJCOPY = arm-none-eabi-objcopy
SIZE    = arm-none-eabi-size

DEVICE_ELF  = main.elf
DEVICE_HEX  = $(DEVICE_ELF:.elf=.hex)
C_FILES    := $(wildcard *.c)
CPP_FILES  := $(wildcard *.cpp)
OBJS       := $(C_FILES:.c=.o) $(CPP_FILES:.cpp=.o)

all: $(DEVICE_HEX)

$(DEVICE_ELF): $(OBJS)
	$(CC) $(CPPFLAGS) $(LDFLAGS) -o $@ $(OBJS)

$(DEVICE_HEX): $(DEVICE_ELF)
	$(SIZE) $(DEVICE_ELF)
	$(OBJCOPY) -O ihex -R .eeprom $(DEVICE_ELF) $@
