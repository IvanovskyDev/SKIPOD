import matplotlib.pyplot as plt
import numpy as np
import os
import re

def parse_results():
    """Парсинг результатов из текстовых файлов"""
    results = {}
    
    datasets = ["mini", "small", "medium", "large", "extralarge"]
    versions = ["original", "parallel_for", "tasks", "optimized"]
    threads = [1, 2, 4, 8, 16, 32, 64]
    
    for dataset in datasets:
        results[dataset] = {}
        for version in versions:
            results[dataset][version] = []
            filename = f"results/{dataset}_{version}.txt"
            
            if os.path.exists(filename):
                with open(filename, 'r') as f:
                    content = f.read()
                    # Ищем время выполнения для каждого числа потоков
                    for thread in threads:
                        pattern = f"Threads: {thread}.*?Time: ([0-9.]+) seconds"
                        matches = re.findall(pattern, content, re.DOTALL)
                        if matches:
                            results[dataset][version].append(float(matches[0]))
                        else:
                            results[dataset][version].append(np.nan)
    
    return results, datasets, versions, threads

def plot_scalability(results, datasets, versions, threads):
    """Построение графиков масштабируемости"""
    
    for dataset in datasets:
        plt.figure(figsize=(12, 8))
        
        for version in versions:
            times = results[dataset][version]
            if all(np.isnan(times)):
                continue
                
            # Вычисляем ускорение относительно 1 потока
            base_time = times[0]
            speedup = [base_time / t if not np.isnan(t) else 0 for t in times]
            
            plt.plot(threads, speedup, marker='o', linewidth=2, label=version)
        
        plt.xlabel('Number of Threads')
        plt.ylabel('Speedup')
        plt.title(f'Scalability - {dataset.upper()} Dataset')
        plt.grid(True, alpha=0.3)
        plt.legend()
        plt.xscale('log', base=2)
        plt.savefig(f'graphs/scalability_{dataset}.png', dpi=300, bbox_inches='tight')
        plt.close()

def plot_3d_comparison(results, datasets, versions, threads):
    """3D график сравнения всех версий"""
    fig = plt.figure(figsize=(15, 10))
    ax = fig.add_subplot(111, projection='3d')
    
    # Подготовка данных для 3D графика
    x_pos = []  # Версии
    y_pos = []  # Потоки  
    z_pos = []  # Время
    colors = []
    
    color_map = {'original': 'red', 'parallel_for': 'blue', 
                 'tasks': 'green', 'optimized': 'orange'}
    
    for i, version in enumerate(versions):
        for j, thread in enumerate(threads):
            for k, dataset in enumerate(datasets):
                time = results[dataset][version][j]
                if not np.isnan(time):
                    x_pos.append(i)
                    y_pos.append(np.log2(thread))
                    z_pos.append(time)
                    colors.append(color_map[version])
    
    scatter = ax.scatter(x_pos, y_pos, z_pos, c=colors, alpha=0.7, s=50)
    
    ax.set_xlabel('Version')
    ax.set_ylabel('Threads (log2)')
    ax.set_zlabel('Time (s)')
    ax.set_title('3D Performance Comparison')
    
    # Настройка осей
    ax.set_xticks(range(len(versions)))
    ax.set_xticklabels(versions)
    ax.set_yticks([np.log2(t) for t in threads if t in [1, 2, 4, 8, 16, 32, 64]])
    ax.set_yticklabels([1, 2, 4, 8, 16, 32, 64])
    
    plt.savefig('graphs/3d_comparison.png', dpi=300, bbox_inches='tight')
    plt.close()

if __name__ == "__main__":
    results, datasets, versions, threads = parse_results()
    plot_scalability(results, datasets, versions, threads)
    plot_3d_comparison(results, datasets, versions, threads)
    print("Graphs generated in ./graphs/")
