#!/bin/bash

echo "=== Compiling all VAR409 versions ==="

DATASETS=("mini" "small" "medium" "large" "extralarge")
VERSIONS=("original" "parallel_for" "tasks" "optimized")

for dataset in "${DATASETS[@]}"; do
    for version in "${VERSIONS[@]}"; do
        echo "Compiling $version for $dataset dataset..."
        
        case $dataset in
            "mini") 
                gcc -fopenmp -O3 -DMINI_DATASET -o "var409_${version}" "var409_${version}.c" -lm
                ;;
            "small")
                gcc -fopenmp -O3 -DSMALL_DATASET -o "var409_${version}" "var409_${version}.c" -lm
                ;;
            "medium")
                gcc -fopenmp -O3 -DMEDIUM_DATASET -o "var409_${version}" "var409_${version}.c" -lm
                ;;
            "large")
                gcc -fopenmp -O3 -DLARGE_DATASET -o "var409_${version}" "var409_${version}.c" -lm
                ;;
            "extralarge")
                gcc -fopenmp -O3 -DEXTRALARGE_DATASET -o "var409_${version}" "var409_${version}.c" -lm
                ;;
        esac
        
        if [[ $? -eq 0 ]]; then
            echo "  ✓ Success"
        else
            echo "  ✗ Failed"
        fi
    done
done

echo "=== Compilation complete ==="