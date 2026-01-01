# Настройка Horizontal Pod Autoscaler

Чтобы вам было легче выполнить практическую работу, настройте HPA, следуя пошаговой инструкции.

- Поднимите лоĸальный ĸластер Kubernetes в Minikube.

- Аĸтивируйте metrics-server. В Minikube это можно сделать, включив metrics-server при запуске:

    ```
    minikube start --addons=metrics-server 
    ```

    Если Minikube уже был запущен без metrics-server, его можно активировать отдельно:

    ```
    minikube addons enable metrics-server
    ```

- Убедитесь, что metrics-server активен. Вы можете проверить статус metrics-server с помощью команды:

    ```
    kubectl get deployment metrics-server -n <наименование namespace>
    ```

- Определите запросы и лимиты ресурсов приложения. В манифесте Deployment нужно указать запросы (requests) и лимиты (limits) памяти, которые будут использоваться для мониторинга и масштабирования. Для этого потребуется добавить следующий фрагмент в deployment.yaml (значения ресурсов указаны для примера):

    ```
    spec:
        containers:
        - name: scalable-pod-identifier
        image: scalable-pod-identifier:v1
        resources:
            requests:
            memory: "100Mi"
            limits:
            memory: "200Mi" 
    ```

- Напишите манифест Horizontal Pod Autoscaler. Создайте файл `hpa.yaml` и определите в нём параметры масштабирования:

    ```
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
 name: scalable-pod-identifier-hpa
spec:
 scaleTargetRef:
   apiVersion: apps/v1
   kind: Deployment
   name: scalable-pod-identifier
 minReplicas: 1
 maxReplicas: 10
  metrics:
 - type: Resource
   resource:
     name: memory
     target:
       type: Utilization
       averageUtilization: 80
    ```

- Примените манифест HPA и проверьте его состояние при помощи команд:

    ```
    kubectl apply -f hpa.yaml
    ```

    ```
    kubectl get hpa 
    ```

После настройки HPA ваше приложение будет автоматически масштабироваться в зависимости от использования памяти. Если нагрузка на приложение возрастёт и потребление памяти подами превысит указанный порог в 80%, Kubernetes начнёт автоматически увеличивать количество подов вплоть до максимально указанного значения.