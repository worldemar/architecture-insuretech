# Задание 2. Динамическое масштабирование контейнеров

В данном задании реализована система автоматического горизонтального масштабирования (HPA) для тестового приложения в кластере Kubernetes (Minikube).

## Состав решения

- [`deployment.yml`](deployment.yml) - манифест развертывания приложения. Ограничение по памяти (limits) установлено в 30Mi, запросы (requests) - 10Mi памяти и 50m CPU.
- [`service.yml`](service.yml) - описание сервиса типа NodePort для обеспечения доступа к приложению.
- [`hpa.yml`](hpa.yml) - конфигурация автоскейлера. Настроен на масштабирование по потреблению **Memory** (порог 60% для более наглядной демонстрации в minikube). Диапазон реплик: 1-10.
- [`locustfile.py`](locustfile.py) - сценарий нагрузочного тестирования на Python.
- [`docker-compose.yml`](docker-compose.yml) - конфигурация для запуска распределенного кластера Locust (Master + Workers) в Docker.
- [`task2.sh`](task2.sh) - скрипт автоматизации, который полностью разворачивает окружение, настраивает проброс портов и запускает мониторинг.

## Методика тестирования

1. **Подготовка**: С помощью `task2.sh` запускается локальный кластер Minikube с аддоном `metrics-server`. Приложение развертывается с одной начальной репликой.
2. **Доступ**: Организуется проброс портов (`kubectl port-forward`) с порта 1351 хоста на сервис приложения.
3. **Генерация нагрузки**: Запускается Locust в Docker-контейнерах. Используется распределенный режим (1 мастер и 10 воркеров) для имитации большого количества одновременных пользователей. Целевой адрес - `http://host.docker.internal:1351`.
4. **Мониторинг**: Состояние HPA отслеживается через `kubectl describe hpa` и стандартный дашборд Minikube.

## Результат запуска

### Запуск автоматики
```
$ ./task2.sh                                                                                                                                                  
[ OK ] Stop all minikube dashboards :                                                                                                                         
[ OK ] Deleting old minikube : * Removed all traces of the "minikube" cluster.                                                                                
[ OK ] Starting minikube with metrics : * Готово! kubectl настроен для использования кластера "minikube" и "default" пространства имён по умолчанию           
[ OK ] Pre-pulling the image inside minikube : ghcr.io/yandex-practicum/scaletestapp@sha256:eff20ae3ae2d596375f9ed6d612a78d149a35a66cd2907ea90d7175ca918c993  
[ OK ] Applying Deployment : deployment.apps/scaletestapp created                                                                                             
[ OK ] Applying Service : service/scaletestapp-service created                                                                                                
[ OK ] Applying HPA : horizontalpodautoscaler.autoscaling/scaletestapp-hpa created                                                                            
[ OK ] Waiting for deployment 'scaletestapp' readiness : deployment "scaletestapp" successfully rolled out                                                    
[ OK ] Deploy locust load testing stack :  Container task2-locust-worker-10  Running                                                                          
[ OK ] Starting port-forwarding (1351 -> 80)                                                                                                                  
[ OK ] Starting minikube dashboard                                                                                                                            
```

### Состояние HPA демонстрирует масштабирование вверх под нагрузкой и вниз без нагрузки
```
$ kubectl describe hpa scaletestapp-hpa                                                                                                                             
Name:                                                     scaletestapp-hpa                                                                                          
Namespace:                                                default                                                                                                   
Labels:                                                   <none>                                                                                                    
Annotations:                                              <none>                                                                                                    
CreationTimestamp:                                        Tue, 30 Dec 2025 16:04:27 +0300                                                                           
Reference:                                                Deployment/scaletestapp                                                                                   
Metrics:                                                  ( current / target )                                                                                      
  resource memory on pods  (as a percentage of request):  44% (4524Ki) / 60%                                                                                        
Min replicas:                                             1                                                                                                         
Max replicas:                                             10                                                                                                        
Deployment pods:                                          3 current / 3 desired                                                                                     
Conditions:                                                                                                                                                         
  Type            Status  Reason              Message                                                                                                               
  ----            ------  ------              -------                                                                                                               
  AbleToScale     True    ReadyForNewScale    recommended size matches current size                                                                                 
  ScalingActive   True    ValidMetricFound    the HPA was able to successfully calculate a replica count from memory resource utilization (percentage of request)   
  ScalingLimited  False   DesiredWithinRange  the desired count is within the acceptable range                                                                      
Events:                                                                                                                                                             
  Type    Reason             Age                From                       Message                                                                                  
  ----    ------             ----               ----                       -------                                                                                  
  Normal  SuccessfulRescale  44m                horizontal-pod-autoscaler  New size: 2; reason: All metrics below target                                            
  Normal  SuccessfulRescale  39m                horizontal-pod-autoscaler  New size: 1; reason: All metrics below target                                            
  Normal  SuccessfulRescale  35m (x2 over 50m)  horizontal-pod-autoscaler  New size: 4; reason: memory resource utilization (percentage of request) above target    
  Normal  SuccessfulRescale  35m                horizontal-pod-autoscaler  New size: 5; reason:                                                                     
  Normal  SuccessfulRescale  34m                horizontal-pod-autoscaler  New size: 6; reason: memory resource utilization (percentage of request) above target    
  Normal  SuccessfulRescale  24m                horizontal-pod-autoscaler  New size: 5; reason: All metrics below target                                            
  Normal  SuccessfulRescale  7m37s              horizontal-pod-autoscaler  New size: 4; reason: All metrics below target                                            
  Normal  SuccessfulRescale  4m37s              horizontal-pod-autoscaler  New size: 3; reason: All metrics below target                                            
```

### Значения /metrics
```
# HELP go_gc_duration_seconds A summary of the pause duration of garbage collection cycles.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 2.4123e-05
go_gc_duration_seconds{quantile="0.25"} 5.225e-05
go_gc_duration_seconds{quantile="0.5"} 8.5881e-05
go_gc_duration_seconds{quantile="0.75"} 0.000180748
go_gc_duration_seconds{quantile="1"} 0.002109365
go_gc_duration_seconds_sum 0.00720726
go_gc_duration_seconds_count 30
# HELP go_goroutines Number of goroutines that currently exist.
# TYPE go_goroutines gauge
go_goroutines 8
# HELP go_info Information about the Go environment.
# TYPE go_info gauge
go_info{version="go1.22.12"} 1
# HELP go_memstats_alloc_bytes Number of bytes allocated and still in use.
# TYPE go_memstats_alloc_bytes gauge
go_memstats_alloc_bytes 4.585064e+06
# HELP go_memstats_alloc_bytes_total Total number of bytes allocated, even if freed.
# TYPE go_memstats_alloc_bytes_total counter
go_memstats_alloc_bytes_total 6.8817552e+07
# HELP go_memstats_buck_hash_sys_bytes Number of bytes used by the profiling bucket hash table.
# TYPE go_memstats_buck_hash_sys_bytes gauge
go_memstats_buck_hash_sys_bytes 7627
# HELP go_memstats_frees_total Total number of frees.
# TYPE go_memstats_frees_total counter
go_memstats_frees_total 670492
# HELP go_memstats_gc_sys_bytes Number of bytes used for garbage collection system metadata.
# TYPE go_memstats_gc_sys_bytes gauge
go_memstats_gc_sys_bytes 2.667872e+06
# HELP go_memstats_heap_alloc_bytes Number of heap bytes allocated and still in use.
# TYPE go_memstats_heap_alloc_bytes gauge
go_memstats_heap_alloc_bytes 4.585064e+06
# HELP go_memstats_heap_idle_bytes Number of heap bytes waiting to be used.
# TYPE go_memstats_heap_idle_bytes gauge
go_memstats_heap_idle_bytes 1.6596992e+07
# HELP go_memstats_heap_inuse_bytes Number of heap bytes that are in use.
# TYPE go_memstats_heap_inuse_bytes gauge
go_memstats_heap_inuse_bytes 6.668288e+06
# HELP go_memstats_heap_objects Number of allocated objects.
# TYPE go_memstats_heap_objects gauge
go_memstats_heap_objects 3423
# HELP go_memstats_heap_released_bytes Number of heap bytes released to OS.
# TYPE go_memstats_heap_released_bytes gauge
go_memstats_heap_released_bytes 1.622016e+07
# HELP go_memstats_heap_sys_bytes Number of heap bytes obtained from system.
# TYPE go_memstats_heap_sys_bytes gauge
go_memstats_heap_sys_bytes 2.326528e+07
# HELP go_memstats_last_gc_time_seconds Number of seconds since 1970 of last garbage collection.
# TYPE go_memstats_last_gc_time_seconds gauge
go_memstats_last_gc_time_seconds 1.7671035495145977e+09
# HELP go_memstats_lookups_total Total number of pointer lookups.
# TYPE go_memstats_lookups_total counter
go_memstats_lookups_total 0
# HELP go_memstats_mallocs_total Total number of mallocs.
# TYPE go_memstats_mallocs_total counter
go_memstats_mallocs_total 673915
# HELP go_memstats_mcache_inuse_bytes Number of bytes in use by mcache structures.
# TYPE go_memstats_mcache_inuse_bytes gauge
go_memstats_mcache_inuse_bytes 24000
# HELP go_memstats_mcache_sys_bytes Number of bytes used for mcache structures obtained from system.
# TYPE go_memstats_mcache_sys_bytes gauge
go_memstats_mcache_sys_bytes 31200
# HELP go_memstats_mspan_inuse_bytes Number of bytes in use by mspan structures.
# TYPE go_memstats_mspan_inuse_bytes gauge
go_memstats_mspan_inuse_bytes 191840
# HELP go_memstats_mspan_sys_bytes Number of bytes used for mspan structures obtained from system.
# TYPE go_memstats_mspan_sys_bytes gauge
go_memstats_mspan_sys_bytes 522240
# HELP go_memstats_next_gc_bytes Number of heap bytes when next garbage collection will take place.
# TYPE go_memstats_next_gc_bytes gauge
go_memstats_next_gc_bytes 7.522536e+06
# HELP go_memstats_other_sys_bytes Number of bytes used for other system allocations.
# TYPE go_memstats_other_sys_bytes gauge
go_memstats_other_sys_bytes 4.134661e+06
# HELP go_memstats_stack_inuse_bytes Number of bytes in use by the stack allocator.
# TYPE go_memstats_stack_inuse_bytes gauge
go_memstats_stack_inuse_bytes 6.029312e+06
# HELP go_memstats_stack_sys_bytes Number of bytes obtained from system for stack allocator.
# TYPE go_memstats_stack_sys_bytes gauge
go_memstats_stack_sys_bytes 6.029312e+06
# HELP go_memstats_sys_bytes Number of bytes obtained from system.
# TYPE go_memstats_sys_bytes gauge
go_memstats_sys_bytes 3.6658192e+07
# HELP go_threads Number of OS threads created.
# TYPE go_threads gauge
go_threads 23
# HELP http_requests_total No of request handled
# TYPE http_requests_total counter
http_requests_total 34025
# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds.
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 8.2
# HELP process_max_fds Maximum number of open file descriptors.
# TYPE process_max_fds gauge
process_max_fds 1.048576e+06
# HELP process_open_fds Number of open file descriptors.
# TYPE process_open_fds gauge
process_open_fds 10
# HELP process_resident_memory_bytes Resident memory size in bytes.
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 1.890304e+07
# HELP process_start_time_seconds Start time of the process since unix epoch in seconds.
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1.76710012387e+09
# HELP process_virtual_memory_bytes Virtual memory size in bytes.
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 1.266110464e+09
# HELP process_virtual_memory_max_bytes Maximum amount of virtual memory available in bytes.
# TYPE process_virtual_memory_max_bytes gauge
process_virtual_memory_max_bytes 1.8446744073709552e+19
# HELP promhttp_metric_handler_requests_in_flight Current number of scrapes being served.
# TYPE promhttp_metric_handler_requests_in_flight gauge
promhttp_metric_handler_requests_in_flight 1
# HELP promhttp_metric_handler_requests_total Total number of scrapes by HTTP status code.
# TYPE promhttp_metric_handler_requests_total counter
promhttp_metric_handler_requests_total{code="200"} 7
promhttp_metric_handler_requests_total{code="500"} 0
promhttp_metric_handler_requests_total{code="503"} 0
```

### Дашборды Locust и Minikube под нагрузкой

![dashboard](dashboard.png)