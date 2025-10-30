#include "../include/var409.h"

void relax_parallel_tasks(int n, double A[n][n], double *eps)
{
    // Первый проход - горизонтальное обновление с tasks
    #pragma omp parallel
    {
        #pragma omp single
        {
            for(int j = 1; j < n-1; j++)
            {
                #pragma omp task firstprivate(j)
                {
                    for(int i = 1; i < n-1; i++)
                    {
                        A[i][j] = (A[i-1][j] + A[i+1][j]) / 2.;
                    }
                }
            }
        }
    }

    // Второй проход - вертикальное обновление с tasks и atomic
    double local_eps = 0.;
    #pragma omp parallel
    {
        #pragma omp single
        {
            for(int i = 1; i < n-1; i++)
            {
                #pragma omp task firstprivate(i) private(local_eps)
                {
                    local_eps = 0.;
                    for(int j = 1; j < n-1; j++)
                    {
                        double e = A[i][j];
                        A[i][j] = (A[i][j-1] + A[i][j+1]) / 2.;
                        local_eps = Max(local_eps, fabs(e - A[i][j]));
                    }
                    #pragma omp atomic
                    *eps = Max(*eps, local_eps);
                }
            }
        }
    }
}

double run_benchmark_tasks(int threads)
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
        relax_parallel_tasks(N, A, &eps);
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
    
    printf("=== VAR409 Parallel Tasks Version ===\n");
    printf("Dataset: N=%d, ITMAX=%d\n", N, ITMAX);
    printf("Threads: %d\n", threads);
    
    double time = run_benchmark_tasks(threads);
    printf("Time: %.4f seconds\n", time);
    printf("====================================\n");
    
    return 0;
}
