#!/bin/bash

echo "=== VAR409 Performance Testing ==="

# Параметры тестирования
THREADS_LIST=(1 2 4 8 16 32 64)
DATASETS=("mini" "small" "medium" "large" "extralarge")
VERSIONS=("original" "parallel_for" "tasks" "optimized")

# Создаем директории для результатов
mkdir -p results
mkdir -p graphs

# Функция для запуска тестов
run_tests() {
    local dataset=$1
    local version=$2
    
    echo "Testing $version with $dataset dataset..."
    
    # Компилируем версию для текущего датасета
    make clean
    make $dataset
    
    # Запускаем тесты для разного числа потоков
    for threads in "${THREADS_LIST[@]}"; do
        echo "  Threads: $threads"
        ./var409_$version $threads 2>&1 | tee -a "results/${dataset}_${version}.txt"
    done
}

# Основной цикл тестирования
for dataset in "${DATASETS[@]}"; do
    for version in "${VERSIONS[@]}"; do
        run_tests $dataset $version
    done
done

echo "=== Testing Complete ==="
echo "Results saved in ./results/"
echo "Run 'python scripts/plot_results.py' to generate graphs"
