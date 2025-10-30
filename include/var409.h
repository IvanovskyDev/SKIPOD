#ifndef _VAR409_H
#define _VAR409_H

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <omp.h>

#define Max(a,b) ((a)>(b)?(a):(b))

// Размеры датасетов
#ifdef MINI_DATASET
    #define N 50
    #define ITMAX 50
#elif defined(SMALL_DATASET)
    #define N 100
    #define ITMAX 100
#elif defined(MEDIUM_DATASET)
    #define N 200
    #define ITMAX 200
#elif defined(LARGE_DATASET)
    #define N 400
    #define ITMAX 400
#elif defined(EXTRALARGE_DATASET)
    #define N 800
    #define ITMAX 500
#else
    // Default - MEDIUM
    #define N 200
    #define ITMAX 200
#endif

// Параметры алгоритма
#define MAXEPS 0.1e-7

// Прототипы функций
void init(int n, double A[n][n]);
void relax_sequential(int n, double A[n][n], double *eps);
void relax_parallel_for(int n, double A[n][n], double *eps);
void relax_parallel_tasks(int n, double A[n][n], double *eps);
void relax_optimized(int n, double A[n][n], double *eps);
void verify(int n, double A[n][n]);
double run_benchmark(int version, int threads);

#endif
