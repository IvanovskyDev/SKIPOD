#include "../include/var409.h"

void init(int n, double A[n][n])
{ 
    for(int j = 0; j < n; j++)
    for(int i = 0; i < n; i++)
    {
        if(i == 0 || i == n-1 || j == 0 || j == n-1) 
            A[i][j] = 0.;
        else 
            A[i][j] = (1. + i + j);
    }
}

void relax_sequential(int n, double A[n][n], double *eps)
{
    // Первый проход - горизонтальное обновление
    for(int j = 1; j < n-1; j++)
    for(int i = 1; i < n-1; i++)
    {
        A[i][j] = (A[i-1][j] + A[i+1][j]) / 2.;
    }

    // Второй проход - вертикальное обновление с вычислением eps
    for(int j = 1; j < n-1; j++)
    for(int i = 1; i < n-1; i++)
    {
        double e = A[i][j];
        A[i][j] = (A[i][j-1] + A[i][j+1]) / 2.;
        *eps = Max(*eps, fabs(e - A[i][j]));
    }
}

void verify(int n, double A[n][n])
{
    double s = 0.;
    for(int j = 0; j < n; j++)
    for(int i = 0; i < n; i++)
    {
        s += A[i][j] * (i+1) * (j+1) / (n*n);
    }
    printf("S = %f\n", s);
}

double run_benchmark(int version, int threads)
{
    double A[N][N];
    double eps;
    int it;
    
    omp_set_num_threads(threads);
    double start_time = omp_get_wtime();
    
    init(N, A);
    
    for(it = 1; it <= ITMAX; it++)
    {
        eps = 0.;
        relax_sequential(N, A, &eps);
        if (eps < MAXEPS) break;
    }
    
    verify(N, A);
    
    double end_time = omp_get_wtime();
    return end_time - start_time;
}

int main(int argc, char **argv)
{
    int threads = 1;
    if (argc > 1) threads = atoi(argv[1]);
    
    printf("=== VAR409 Sequential Version ===\n");
    printf("Dataset: N=%d, ITMAX=%d\n", N, ITMAX);
    printf("Threads: %d\n", threads);
    
    double time = run_benchmark(0, threads);
    printf("Time: %.4f seconds\n", time);
    printf("==============================\n");
    
    return 0;
}
