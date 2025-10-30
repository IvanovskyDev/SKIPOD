#include "../include/var409.h"

void relax_optimized(int n, double A[n][n], double *eps)
{
    int block_size = 16; // Оптимальный размер блока для кэша
    
    // Блочная версия с cache-friendly доступом
    #pragma omp parallel for collapse(2) reduction(max:*eps)
    for(int jj = 1; jj < n-1; jj += block_size)
    for(int ii = 1; ii < n-1; ii += block_size)
    {
        int j_end = (jj + block_size < n-1) ? jj + block_size : n-1;
        int i_end = (ii + block_size < n-1) ? ii + block_size : n-1;
        
        // Локальный блок для лучшего использования кэша
        for(int j = jj; j < j_end; j++)
        for(int i = ii; i < i_end; i++)
        {
            A[i][j] = (A[i-1][j] + A[i+1][j]) / 2.;
        }
        
        for(int j = jj; j < j_end; j++)
        for(int i = ii; i < i_end; i++)
        {
            double e = A[i][j];
            A[i][j] = (A[i][j-1] + A[i][j+1]) / 2.;
            *eps = Max(*eps, fabs(e - A[i][j]));
        }
    }
}

double run_benchmark_optimized(int threads)
{
    double A[N][N];
    double eps;
    int it;
    
    omp_set_num_threads(threads);
    double start_time = omp_get_wtime();
    
    init_parallel(N, A);
    
    for(it = 1; it <= ITMAX; it++)
    {
        eps = 0.;
        relax_optimized(N, A, &eps);
        if (eps < MAXEPS) break;
    }
    
    verify_parallel(N, A);
    
    double end_time = omp_get_wtime();
    return end_time - start_time;
}

int main(int argc, char **argv)
{
    int threads = 1;
    if (argc > 1) threads = atoi(argv[1]);
    
    printf("=== VAR409 Optimized Version ===\n");
    printf("Dataset: N=%d, ITMAX=%d\n", N, ITMAX);
    printf("Threads: %d\n", threads);
    
    double time = run_benchmark_optimized(threads);
    printf("Time: %.4f seconds\n", time);
    printf("================================\n");
    
    return 0;
}
