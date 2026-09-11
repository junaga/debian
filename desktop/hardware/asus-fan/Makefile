obj-m += asus_z370_wmi_control.o

KDIR ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

all: modules

modules:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

test: protocol_test
	./protocol_test

protocol_test: protocol_test.c protocol.h
	$(CC) -std=c11 -Wall -Wextra -Werror -o $@ protocol_test.c

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
	$(RM) protocol_test
