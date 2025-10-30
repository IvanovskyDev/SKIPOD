#include "../include/var409.h"

void relax_parallel_for(int n, double A[n][n], double *eps)
{
    // Первый проход - горизонтальное обновление
    #pragma omp parallel for collapse(2)
    for(int j = 1; j < n-1; j++)
    for(int i = 1; i < n-1; i++)
    {
        A[i][j] = (A[i-1][j] + A[i+1][j]) / 2.;
    }

    // Второй проход - вертикальное обновление с редукцией eps
    #pragma omp parallel for collapse(2) reduction(max:*eps)
    for(int j = 1; j < n-1; j++)
    for(int i = 1; i < n-1; i++)
    {
        double e = A[i][j];
        A[i][j] = (A[i][j-1] + A[i][j+1]) / 2.;
        *eps = Max(*eps, fabs(e - A[i][j]));
    }
}

void init_parallel(int n, double A[n][n])
{
    #pragma omp parallel for collapse(2)
    for(int j = 0; j < n; j++)
    for(int i = 0; i < n; i++)
    {
        if(i == 0 || i == n-1 || j == 0 || j == n-1) 
            A[i][j] = 0.;
        else 
            A[i][j] = (1. + i + j);
    }
}

void verify_parallel(int n, double A[n][n])
{
    double s = 0.;
    #pragma omp parallel for collapse(2) reduction(+:s)
    for(int j = 0; j < n; j++)
    for(int i = 0; i < n; i++)
    {
        s += A[i][j] * (i+1) * (j+1) / (n*n);
    }
    printf("S = %f\n", s);
}

double run_benchmark_parallel_for(int threads)
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
        relax_parallel_for(N, A, &eps);
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
    
    printf("=== VAR409 Parallel For Version ===\n");
    printf("Dataset: N=%d, ITMAX=%d\n", N, ITMAX);
    printf("Threads: %d\n", threads);
    
    double time = run_benchmark_parallel_for(threads);
    printf("Time: %.4f seconds\n", time);
    printf("==================================\n");
    
    return 0;
}
