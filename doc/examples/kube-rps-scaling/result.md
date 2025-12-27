```
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts                                                                     
"prometheus-community" has been added to your repositories                                                                                                  
```
```
$ helm repo update                                                                                                                                          
Hang tight while we grab the latest from your chart repositories...                                                                                         
...Successfully got an update from the "prometheus-community" chart repository                                                                              
Update Complete. ⎈Happy Helming!⎈                                                                                                                           
```
```
$ helm install prometheus-operator prometheus-community/kube-prometheus-stack                                                                               
I1227 12:50:49.246663   29092 warnings.go:110] "Warning: unrecognized format \"int64\""                                                                     
I1227 12:50:49.247182   29092 warnings.go:110] "Warning: unrecognized format \"int32\""                                                                     
I1227 12:50:49.742812   29092 warnings.go:110] "Warning: unrecognized format \"int32\""                                                                     
I1227 12:50:49.743334   29092 warnings.go:110] "Warning: unrecognized format \"int64\""                                                                     
I1227 12:50:49.842666   29092 warnings.go:110] "Warning: unrecognized format \"int64\""                                                                     
I1227 12:50:49.843910   29092 warnings.go:110] "Warning: unrecognized format \"int32\""                                                                     
I1227 12:50:50.060496   29092 warnings.go:110] "Warning: unrecognized format \"int64\""                                                                     
I1227 12:50:50.668326   29092 warnings.go:110] "Warning: unrecognized format \"int32\""                                                                     
I1227 12:50:50.668867   29092 warnings.go:110] "Warning: unrecognized format \"int64\""                                                                     
I1227 12:50:51.859065   29092 warnings.go:110] "Warning: unrecognized format \"int32\""                                                                     
I1227 12:50:51.859620   29092 warnings.go:110] "Warning: unrecognized format \"int64\""                                                                     
I1227 12:50:51.960811   29092 warnings.go:110] "Warning: unrecognized format \"int64\""                                                                     
I1227 12:50:52.536047   29092 warnings.go:110] "Warning: unrecognized format \"int32\""                                                                     
I1227 12:50:52.537092   29092 warnings.go:110] "Warning: unrecognized format \"int64\""                                                                     
I1227 12:50:52.735532   29092 warnings.go:110] "Warning: unrecognized format \"int64\""                                                                     
I1227 12:50:53.352753   29092 warnings.go:110] "Warning: unrecognized format \"int32\""                                                                     
I1227 12:50:53.353268   29092 warnings.go:110] "Warning: unrecognized format \"int64\""                                                                     
I1227 12:51:11.455890   29092 warnings.go:110] "Warning: spec.SessionAffinity is ignored for headless services"                                             
I1227 12:51:11.461240   29092 warnings.go:110] "Warning: spec.SessionAffinity is ignored for headless services"                                             
I1227 12:51:11.461240   29092 warnings.go:110] "Warning: spec.SessionAffinity is ignored for headless services"                                             
I1227 12:51:11.461240   29092 warnings.go:110] "Warning: spec.SessionAffinity is ignored for headless services"                                             
I1227 12:51:11.461240   29092 warnings.go:110] "Warning: spec.SessionAffinity is ignored for headless services"                                             
NAME: prometheus-operator                                                                                                                                   
LAST DEPLOYED: Sat Dec 27 12:50:56 2025                                                                                                                     
NAMESPACE: default                                                                                                                                          
STATUS: deployed                                                                                                                                            
REVISION: 1                                                                                                                                                 
NOTES:                                                                                                                                                      
kube-prometheus-stack has been installed. Check its status by running:                                                                                      
  kubectl --namespace default get pods -l "release=prometheus-operator"                                                                                     
                                                                                                                                                            
Get Grafana 'admin' user password by running:                                                                                                               
                                                                                                                                                            
  kubectl --namespace default get secrets prometheus-operator-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo                               
                                                                                                                                                            
Access Grafana local instance:                                                                                                                              
                                                                                                                                                            
  export POD_NAME=$(kubectl --namespace default get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=prometheus-operator" -oname)          
  kubectl --namespace default port-forward $POD_NAME 3000                                                                                                   
                                                                                                                                                            
Get your grafana admin user password by running:                                                                                                            
                                                                                                                                                            
  kubectl get secret --namespace default -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo 
                                                                                                                                                            
                                                                                                                                                            
Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the O
perator.                                                                                                                                                    
```
