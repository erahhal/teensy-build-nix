include flags.mk

CPPFLAGS += -I.
LDFLAGS  += -T@linkerScript@

C_FILES   := $(wildcard *.c)
CPP_FILES := $(wildcard *.cpp)
OBJS      := $(C_FILES:.c=.o) $(CPP_FILES:.cpp=.o)

all: $(OBJS)

-include $(OBJS:.o=.d)
