CC := gcc
CFLAGS := -Wall -std=c11 -O2
CLIBS := -lpthread -lm
INCS := -Isrc/

SRC_HFILES := $(wildcard src/*.h)
SRC_CFILES := $(wildcard src/*.c)
UTL_FILES := $(wildcard utils/*)

export BOTS_FILE := backups/bots.dat
export BOTS_CHANGED := $(shell stat --format=%y $(BOTS_FILE) 2>/dev/null | cut -d'.' -f1)
BOTS_BACKUP := backups/$(shell date --date="$(BOTS_CHANGED)" +bots_%Y%m%d_%H%M).dat

default: compile backup

bin/idx: $(SRC_HFILES) $(SRC_CFILES)
	$(CC) $(INCS) $(CFLAGS) $^ -o $@ $(CLIBS)

$(BOTS_BACKUP):
ifneq (,$(wildcard $(BOTS_FILE)))
	cp $(BOTS_FILE) $@
endif

bin/idx_ucombine: utils/idx_combine.c src/idx_load.c
	$(CC) $(INCS) $(CFLAGS) $^ -o $@ $(CLIBS)

bin/idx_umtx: utils/idx_mtx.c src/idx_matrix.c
	$(CC) $(INCS) $(CFLAGS) $^ -o $@ $(CLIBS)

deploy.tar.gz: data/img.idx data/lbl.idx bin/idx idx.sh
	tar -czf $@ $^

idx.zip: $(SRC_HFILES) $(SRC_CFILES) $(UTL_FILES) makefile idx.sh $(BOTS_FILE) 
	zip -er9 $@ $^

compile: bin/idx

backup: $(BOTS_BACKUP)

utils: bin/idx_ucombine bin/idx_umtx

deploy: deploy.tar.gz
	scp deploy.tar.gz user@172.18.20.125:/opt/idx/
	scp deploy.tar.gz user@172.18.20.126:/opt/idx/

sync: idx.zip

clean:
	rm -f bin/* *~ *~ idx.zip deploy.tar.gz

all: clean compile utils backup deploy sync
