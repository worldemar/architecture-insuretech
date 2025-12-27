#!/bin/bash

source ./lib/steps.sh

step "Stop all minikube dashboards" bash -c "ps -ef | grep 'minikube' | grep -v grep | awk '{print \$2}' | xargs kill -9 2>/dev/null || true"
step "Deleting old minikube" minikube delete
step "Starting minikube with metrics" minikube start --addons=metrics-server

# this helps debugging network limitations
step "Pre-pulling the image inside minikube" minikube ssh "docker pull ghcr.io/yandex-practicum/scaletestapp@sha256:eff20ae3ae2d596375f9ed6d612a78d149a35a66cd2907ea90d7175ca918c993"

step "Applying Deployment" kubectl apply -f deployment.yml
step "Applying Service" kubectl apply -f service.yml
step "Applying HPA" kubectl apply -f hpa.yml


step "Waiting for deployment 'scaletestapp' readiness" kubectl rollout status deployment/scaletestapp

step "Deploy locust load testing stack" docker compose up --detach --scale locust-worker=10

step_nocap "Starting port-forwarding (1351 -> 80)" start "" bash -c "kubectl port-forward --address 0.0.0.0 service/scaletestapp-service 1351:80"

step_nocap "Starting minikube dashboard" start "" bash -c "minikube dashboard"
