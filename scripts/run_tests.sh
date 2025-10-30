#!/bin/bash

echo "=== VAR409 Performance Testing ==="

# Параметры тестирования
THREADS_LIST=(1 2 4 8 16 32 64 80 100 120 140 160)
DATASETS=("mini" "small" "medium" "large" "extralarge")
VERSIONS=("original" "parallel_for" "tasks" "optimized")
OPTIMIZATIONS=("O2" "O3" "fast")
RUNS=3  # Кол-во запусков для усреднения

# директории для результатов
mkdir -p results
mkdir -p graphs
mkdir -p temp

# Функция для извлечения времени из вывода программы
extract_time() {
    local output="$1"
    echo "$output" | grep "Time:" | awk '{print $NF}'
}

# Функция для извлечения информации о запуске (для отладки)
extract_info() {
    local output="$1"
    echo "$output" | grep -E "(===|Dataset:|Threads:|S = |Time:)"
}

# Функция для запуска одного теста несколько раз
run_single_test() {
    local program="$1"
    local threads="$2"
    local runs="$3"
    
    local total_time=0
    local times=()
    
    for ((i=1; i<=runs; i++)); do
        echo "    Run $i/$runs..."
        local output
        output=$(./"$program" "$threads" 2>&1)
        local time
        time=$(extract_time "$output")
        
        if [[ -n "$time" ]]; then
            times+=("$time")
            total_time=$(echo "$total_time + $time" | bc -l)
            
            # сохраняю полный вывод первого запуска для отладки
            if [[ $i -eq 1 ]]; then
                echo "$output" > "temp/${program}_${threads}_run1.txt"
            fi
        else
            echo "    ERROR: Could not extract time from run $i"
            echo "Output was: $output"
        fi
    done
    
    if [[ ${#times[@]} -eq 0 ]]; then
        echo "0 0"
        return 1
    fi
    
    # среднее время
    local average_time
    average_time=$(echo "scale=6; $total_time / ${#times[@]}" | bc -l)
    
    # стандартное отклонение
    local variance=0
    for time in "${times[@]}"; do
        local diff
        diff=$(echo "scale=6; $time - $average_time" | bc -l)
        variance=$(echo "scale=6; $variance + $diff * $diff" | bc -l)
    done
    variance=$(echo "scale=6; $variance / ${#times[@]}" | bc -l)
    local stddev
    stddev=$(echo "scale=6; sqrt($variance)" | bc -l)
    
    echo "$average_time $stddev"
}

# Функция для запуска тестов с усреднением
run_tests_with_averaging() {
    local dataset="$1"
    local version="$2"
    local optimization="$3"
    
    echo "Testing $version with $dataset dataset ($optimization optimization)..."
    
    local program="var409_${version}"
    local result_file="results/${dataset}_${version}_${optimization}.txt"
    
    # Очищаем файл результатов
    > "$result_file"
    
    # Записываем заголовок
    echo "=== VAR409 ${version} Version ===" >> "$result_file"
    echo "Dataset: $dataset" >> "$result_file"
    echo "Optimization: $optimization" >> "$result_file"
    echo "Test runs: $RUNS" >> "$result_file"
    echo "==================================" >> "$result_file"
    
    # Проверяем существование программы
    if [[ ! -f "./$program" ]]; then
        echo "  ERROR: Program $program not found!"
        echo "Threads: ALL - ERROR: Program not found" >> "$result_file"
        return 1
    fi
    
    # Тестируем для разного количества потоков
    for threads in "${THREADS_LIST[@]}"; do
        echo "  Threads: $threads"
        
        # Запускаем тест несколько раз
        local result
        result=$(run_single_test "$program" "$threads" "$RUNS")
        local average_time
        average_time=$(echo "$result" | awk '{print $1}')
        local stddev
        stddev=$(echo "$result" | awk '{print $2}')
        
        # Записываем результаты
        if [[ "$average_time" != "0" ]]; then
            printf "Threads: %3d | Time: %8.4f seconds | StdDev: %8.4f | Runs: %d\n" \
                   "$threads" "$average_time" "$stddev" "$RUNS" >> "$result_file"
            printf "    Average: %.4f seconds (±%.4f)\n" "$average_time" "$stddev"
        else
            echo "Threads: $threads | ERROR: No valid measurements" >> "$result_file"
            echo "    ERROR: No valid measurements"
        fi
    done
    
    # Добавляем информацию из первого запуска для проверки корректности
    echo "" >> "$result_file"
    echo "=== Sample output (Threads: 1, Run 1) ===" >> "$result_file"
    if [[ -f "temp/${program}_1_run1.txt" ]]; then
        extract_info "$(cat "temp/${program}_1_run1.txt")" >> "$result_file"
    fi
    
    echo "Completed testing $version with $dataset dataset ($optimization optimization)"
    echo "----------------------------------------"
}

# Функция для компиляции с помощью Makefile
compile_with_make() {
    local dataset="$1"
    local optimization="$2"
    
    echo "Compiling with make for $dataset dataset and $optimization optimization..."
    
    make clean
    if make ${dataset}_${optimization}; then
        echo "  Compilation successful"
        return 0
    else
        echo "  ERROR: Compilation failed!"
        return 1
    fi
}

# Основной цикл тестирования
main() {
    # Проверяем зависимости
    if ! command -v bc &> /dev/null; then
        echo "ERROR: 'bc' command not found. Please install bc."
        exit 1
    fi
    
    if ! command -v make &> /dev/null; then
        echo "ERROR: 'make' command not found. Please install make."
        exit 1
    fi
    
    # Основной цикл тестирования
    for optimization in "${OPTIMIZATIONS[@]}"; do
        echo "=== Testing with optimization: $optimization ==="
        
        for dataset in "${DATASETS[@]}"; do
            echo "--- Dataset: $dataset ---"
            
            # Компилируем все версии для данного датасета и оптимизации
            if compile_with_make "$dataset" "$optimization"; then
                for version in "${VERSIONS[@]}"; do
                    run_tests_with_averaging "$dataset" "$version" "$optimization"
                done
            else
                echo "Skipping $dataset due to compilation error"
            fi
            echo
        done
    done
    
    # Очищаем временные файлы
    rm -rf temp/
    
    echo "=== Testing Complete ==="
    echo "Results saved in ./results/"
    echo "Optimization levels tested: ${OPTIMIZATIONS[*]}"
    echo "Run 'python scripts/plot_results.py' to generate graphs"
}

# Запускаем основную функцию
main
