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

# Версии с разными уровнями оптимизации
O2: CFLAGS = -fopenmp -O2 -march=native -lm
O2: all

O3: CFLAGS = -fopenmp -O3 -march=native -lm
O3: all

fast: CFLAGS = -fopenmp -fast -march=native -lm
fast: all

# Комбинации оптимизаций и датасетов
mini_O2: CFLAGS = -fopenmp -O2 -march=native -lm -DMINI_DATASET
mini_O2: all

small_O2: CFLAGS = -fopenmp -O2 -march=native -lm -DSMALL_DATASET
small_O2: all

medium_O2: CFLAGS = -fopenmp -O2 -march=native -lm -DMEDIUM_DATASET
medium_O2: all

large_O2: CFLAGS = -fopenmp -O2 -march=native -lm -DLARGE_DATASET
large_O2: all

extralarge_O2: CFLAGS = -fopenmp -O2 -march=native -lm -DEXTRALARGE_DATASET
extralarge_O2: all

mini_O3: CFLAGS = -fopenmp -O3 -march=native -lm -DMINI_DATASET
mini_O3: all

small_O3: CFLAGS = -fopenmp -O3 -march=native -lm -DSMALL_DATASET
small_O3: all

medium_O3: CFLAGS = -fopenmp -O3 -march=native -lm -DMEDIUM_DATASET
medium_O3: all

large_O3: CFLAGS = -fopenmp -O3 -march=native -lm -DLARGE_DATASET
large_O3: all

extralarge_O3: CFLAGS = -fopenmp -O3 -march=native -lm -DEXTRALARGE_DATASET
extralarge_O3: all

mini_fast: CFLAGS = -fopenmp -fast -march=native -lm -DMINI_DATASET
mini_fast: all

small_fast: CFLAGS = -fopenmp -fast -march=native -lm -DSMALL_DATASET
small_fast: all

medium_fast: CFLAGS = -fopenmp -fast -march=native -lm -DMEDIUM_DATASET
medium_fast: all

large_fast: CFLAGS = -fopenmp -fast -march=native -lm -DLARGE_DATASET
large_fast: all

extralarge_fast: CFLAGS = -fopenmp -fast -march=native -lm -DEXTRALARGE_DATASET
extralarge_fast: all

clean:
	rm -f $(TARGETS)

.PHONY: all clean mini small medium large extralarge O2 O3 fast \
        mini_O2 small_O2 medium_O2 large_O2 extralarge_O2 \
        mini_O3 small_O3 medium_O3 large_O3 extralarge_O3 \
        mini_fast small_fast medium_fast large_fast extralarge_fast
