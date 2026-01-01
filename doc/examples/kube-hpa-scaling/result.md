```
$ ./proxy.sh                                                                                                            
++ minikube start --addons=metrics-server --docker-env HTTP_PROXY=http://172.16.16.170:1080 --docker-env HTTPS_PROXY=htt
p://172.16.16.170:1080 --docker-env NO_PROXY=localhost,127.0.0.1,.minikube,.k8s.local                                   
�  minikube v1.37.0 на Microsoft Windows 11 Pro 10.0.26100.7171 Build 26100.7171                                        
✨  Automatically selected the docker driver. Other choices: hyperv, virtualbox, ssh                                     
�  Using Docker Desktop driver with root privileges                                                                     
�  Starting "minikube" primary control-plane node in "minikube" cluster                                                 
�  Pulling base image v0.0.48 ...                                                                                       
�  Creating docker container (CPUs=2, Memory=16300MB) ...                                                               
❗  Failing to connect to https://registry.k8s.io/ from inside the minikube container                                    
�  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networki 
ng/proxy/                                                                                                               
�  Подготавливается Kubernetes v1.34.0 на Docker 28.4.0 ...                                                             
    ▪ env HTTP_PROXY=http://172.16.16.170:1080                                                                          
    ▪ env HTTPS_PROXY=http://172.16.16.170:1080                                                                         
    ▪ env NO_PROXY=localhost,127.0.0.1,.minikube,.k8s.local                                                             
�  Configuring bridge CNI (Container Networking Interface) ...                                                          
�  Компоненты Kubernetes проверяются ...                                                                                
    ▪ Используется образ registry.k8s.io/metrics-server/metrics-server:v0.8.0                                           
    ▪ Используется образ gcr.io/k8s-minikube/storage-provisioner:v5                                                     
�  Включенные дополнения: storage-provisioner, metrics-server, default-storageclass                                     
                                                                                                                        
❗  C:\Program Files\Docker\Docker\resources\bin\kubectl.exe is version 1.32.2, which may have incompatibilities with Ku 
bernetes 1.34.0.                                                                                                        
    ▪ Want kubectl v1.34.0? Try 'minikube kubectl -- get pods -A'                                                       
�  Готово! kubectl настроен для использования кластера "minikube" и "default" пространства имён по умолчанию            
```
```
$ minikube addons enable metrics-server                                                                       
�  metrics-server is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.          
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS   
    ▪ Используется образ registry.k8s.io/metrics-server/metrics-server:v0.8.0                                 
�  The 'metrics-server' addon is enabled                                                                      
```
```
$ kubectl get deployment metrics-server -n kube-system       
NAME             READY   UP-TO-DATE   AVAILABLE   AGE        
metrics-server   1/1     1            1           89s        
```
```
$ kubectl apply -f hpa.yml                                                           
horizontalpodautoscaler.autoscaling/scalable-pod-identifier-hpa created              
```
```
$ kubectl get hpa                                                                                                            
NAME                          REFERENCE                            TARGETS                 MINPODS   MAXPODS   REPLICAS   AGE
scalable-pod-identifier-hpa   Deployment/scalable-pod-identifier   memory: <unknown>/80%   1         10        0          42s
```