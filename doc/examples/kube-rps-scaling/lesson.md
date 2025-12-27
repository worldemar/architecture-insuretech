- Настройка может быть выполнена в несколько шагов:

    - Настройка системы мониторинга (на примере Prometheus)

        - Установите Prometheus в вашем кластере. Рекомендуется установку Prometheus в Kubernetes производить с использованием Prometheus Operator через Helm. Лучше всего будет воспользоваться Prometheus Community Helm charts. Можете воспользоваться командами:

            ```
            helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
            helm repo update
            helm install prometheus-operator prometheus-community/kube-prometheus-stack 
            ```

        - Напишите и примените Service-манифест для доступа к приложению, установленному на прошлом шаге.

        - Настройте Prometheus для сбора метрик вашего приложения. Это может потребовать добавления конфигурации сбора метрик в values.yaml при установке chart или настройки ServiceMonitor/PodMonitor в Prometheus Operator.

            Пример манифеста ServiceMonitor:

            ```
            apiVersion: monitoring.coreos.com/v1
            kind: ServiceMonitor
            metadata:
              name: scalable-pod-identifier-sm
              namespace: default
              labels:
                serviceMonitorSelector: prometheus
             spec:
              endpoints:
                - port: metrics # Имя порта из вашего Service.
              namespaceSelector:
                matchNames:
                  - default
              selector:
                matchLabels:
                 app: scalable-pod-identifier  # Этот тег должен совпадать с тегом в вашем Service.      
            ```

            Требуемый сервис можно обнаружить посредством лейбла app или же кастомного лейбла (например, prometheus-monitored), который вы можете отразить в манифесте Service.

        - ServiceMonitor можно применить как отдельный манифест или воспользоваться специальной секцией additionalServiceMonitors при настройке Prometheus Operator через Helm.

            Пример конфигурации Prometheus Operator:

            ```
            prometheus:
             enabled: true
             additionalServiceMonitors:
               - name: app-sm
                 namespace: default
                labels:
                   serviceMonitorSelector: prometheus
                 endpoints:
                   - port: metrics # Имя порта из вашего Service.
                namespaceSelector:
                  matchNames:
                     - default
                selector:
                   matchLabels:
                         app: scalable-pod-identifier  # Этот тег должен совпадать с тегом в вашем Service.
            ```
  
    - Интеграция с Prometheus Adapter

        Он помогает Kubernetes использовать метрики из Prometheus для HPA.

        - Установите Prometheus Adapter, который будет служить мостом между Prometheus и Kubernetes API для внешних метрик. Используйте Helm для установки Prometheus Adapter:

            ```
            helm repo add prometheus-community <https://prometheus-community.github.io/helm-charts>
            helm install my-prometheus-adapter prometheus-community/prometheus-adapter
            ```

        - При использовании Helm для установки или обновления Prometheus Adapter вы должны предоставить значения, которые переопределяют базовую конфигурацию. Создайте файл values.yaml, включив определение для prometheus-adapter:

            ```
            prometheus:
              url: "http://<адрес_prometheus>"
            rules:
              default: false
              custom:
                - seriesQuery: 'http_requests_total{namespace!="",pod!=""}'
                  resources:
                    overrides:
                      namespace: {resource: "namespace"}
                      pod: {resource: "pod"}
                  name:
                    matches: "^http_requests_total"
                    as: "http_requests_per_second"
                  metricsQuery: 'sum(rate(http_requests_total{<<.LabelMatchers>>}[30s])) by (<<.GroupBy>>)'
            ```

        - Установите Prometheus Adapter при помощи команды `helm intall prometheus-adapter prometheus-community/prometheus-adapter -f values.yaml.`

        - Воспользуйтесь командой kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1, чтобы убедиться в том, что кастомная метрика http_requests_per_second стала доступна.

    - Настройка HPA для масштабирования по RPS

        - Создайте HPA, используя внешние метрики (RPS, полученные от Prometheus через Adapter). Пример манифеста HPA может выглядеть так:

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
              - type: External
                external:
                  metric:
                    name: http_requests_per_second
                  target:
                    type: AverageValue
                    averageValue: 10 #Целевое значение RPS на один под
            ```

        - Примените созданный HPA в кластере Kubernetes:

            `kubectl apply -f hpa.yaml `