CC = gcc
CFLAGS = -W -Wall -finline-functions -fPIC -std=gnu99 -Wno-unused-result -O3
CLIB = -lpthread -lz -lm -llzma -lbz2 -lcurl
CF_OPTIMIZE = 1

OS := $(shell uname)
ifeq ($(OS),  Darwin)
	CFLAGS += -Wno-unused-function
else
	CLIB += -lrt -ltinfo
endif

INCLUDE = include

########################
### different modes ####
########################

PROG = dupsifter

.PHONY : setdebug debug build

build: exportcf $(PROG)

profile: CF_OPTIMIZE := 0
profile: CFLAGS += -pg
profile: CFLAGS := $(filter-out -O3,$(CFLAGS))
profile: build

debug: CF_OPTIMIZE := 0
debug: CFLAGS += -g
debug: CFLAGS := $(filter-out -O3,$(CFLAGS))
debug: build

exportcf:
	$(eval export CF_OPTIMIZE)

#####################
##### libraries #####
#####################

LHTSLIB_DIR = htslib-1.15.1
LHTSLIB_INCLUDE = $(LHTSLIB_DIR)/htslib
LHTSLIB = $(LHTSLIB_DIR)/libhts.a
$(LHTSLIB) :
	make -C $(LHTSLIB_DIR) libhts.a

# Main program
LIBS = $(LHTSLIB)
dupsifter: $(LIBS) dupsifter.o
	$(CC) $(CFLAGS) dupsifter.o -o $@ -I$(LHTSLIB_INCLUDE) $(LIBS) $(CLIB)

dupsifter.o: dupsifter.c
	$(CC) -c $(CFLAGS) dupsifter.c -o $@ -I$(LHTSLIB_INCLUDE)

# Clean
.PHONY: clean
clean:
	rm -f dupsifter dupsifter.o

purge: clean
	make -C $(LHTSLIB_DIR) clean
