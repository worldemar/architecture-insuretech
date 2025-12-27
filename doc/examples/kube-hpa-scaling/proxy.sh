set -x
minikube start --addons=metrics-server \
  --docker-env HTTP_PROXY=http://172.16.16.170:1080 \
  --docker-env HTTPS_PROXY=http://172.16.16.170:1080 \
  --docker-env NO_PROXY=localhost,127.0.0.1,.minikube,.k8s.local