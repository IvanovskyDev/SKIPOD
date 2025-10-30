CC = gcc
CFLAGS = -fopenmp -O3 -march=native -lm
INCLUDE = -I./include

# Версии для разных датасетов
TARGETS = var409_original var409_parallel_for var409_tasks var409_optimized

all: $(TARGETS)

# Компиляция с разными датасетами
var409_original: src/var409_original.c
$(CC) $(CFLAGS) $(INCLUDE) -o $@ $<

var409_parallel_for: src/var409_parallel_for.c
$(CC) $(CFLAGS) $(INCLUDE) -o $@ $<

var409_tasks: src/var409_tasks.c
$(CC) $(CFLAGS) $(INCLUDE) -o $@ $<

var409_optimized: src/var409_optimized.c
$(CC) $(CFLAGS) $(INCLUDE) -o $@ $<

# Специальные версии для тестирования
mini: CFLAGS += -DMINI_DATASET
mini: all

small: CFLAGS += -DSMALL_DATASET
small: all

medium: CFLAGS += -DMEDIUM_DATASET
medium: all

large: CFLAGS += -DLARGE_DATASET
large: all

extralarge: CFLAGS += -DEXTRALARGE_DATASET
extralarge: all

clean:
rm -f $(TARGETS)

.PHONY: all clean mini small medium large extralarge
