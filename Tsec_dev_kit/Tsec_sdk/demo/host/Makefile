
####################################################################
## parameter define 
####################################################################

## Toolchain
CROSS_COMPILE ?= /home/qbq/work/src/xuantie-tee/toolchains/riscv64/bin/riscv64-linux-gnu-

## TEE export path
TEEC_EXPORT ?= ../../export/tee-client

CC      = $(CROSS_COMPILE)gcc
LD      = $(CROSS_COMPILE)ld
AR      = $(CROSS_COMPILE)ar
NM      = $(CROSS_COMPILE)nm
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
READELF = $(CROSS_COMPILE)readelf

OBJS = main.o

CFLAGS += -Wall -I../ta/include -I$(TEEC_EXPORT)/include -I./include
#Add/link other required libraries here
LDADD += -lteec -L$(TEEC_EXPORT)/lib

BINARY = optee_example_hello_world

.PHONY: all
all: $(BINARY)
	echo $(CROSS_COMPILE)

$(BINARY): $(OBJS)
	echo $(CROSS_COMPILE)
	$(CC) $(LDFLAGS) -o $@ $< $(LDADD)

.PHONY: clean
clean:
	rm -f $(OBJS) $(BINARY)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
