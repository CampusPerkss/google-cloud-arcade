#!/bin/bash

# ==============================================
# Google Kubernetes Engine Complete Lab Setup
# Welcome to CampusPerks!
# YouTube: https://www.youtube.com/@CampusPerkss
# ==============================================

# ASCII Art Banner
echo "                                                                               
  ____  _       _     _           _    _           _       _     _   
 |  _ \(_)     | |   | |         | |  | |         | |     | |   | |  
 | |_) |_  __ _| |__ | |__   ___ | | _| | ___  ___| |_ ___| |__ | |_ 
 |  _ <| |/ _\` | '_ \| '_ \ / _ \| |/ / |/ _ \/ __| __/ __| '_ \| __|
 | |_) | | (_| | | | | | | | (_) |   <| |  __/\__ \ || (__| | | | |_ 
 |____/|_|\__, |_| |_|_| |_|\___/|_|\_\_|\___||___/\__\___|_| |_|\__|
           __/ |                                                     
          |___/                                                      
"

echo "=================================================================="
echo "              WELCOME TO CAMPUSPERKS!"
echo "=================================================================="
echo " YouTube Channel: https://www.youtube.com/@CampusPerkss"
echo "=================================================================="
echo "   SUBSCRIBE for Google Cloud & Kubernetes Arcade Labs!"
echo "=================================================================="
echo ""
sleep 3

echo "Starting Google Kubernetes Engine lab setup..."
echo "CampusPerks style – simple & working 🔥"
echo ""

# Display progress function
progress() {
    echo "✅ $1"
    sleep 2
}

# Task: Initial Setup
progress "Setting up initial configuration..."
gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/zone "$ZONE"

# Task: Create Kubernetes Cluster
progress "Creating Kubernetes cluster 'io' in zone: $ZONE"
gcloud container clusters create io --zone $ZONE

# Task: Get Sample Code
progress "Downloading sample code from Google Cloud Storage..."
gsutil cp -r gs://spls/gsp021/* .
cd orchestrate-with-kubernetes/kubernetes
ls

# Task: Quick Kubernetes Demo
progress "Creating nginx deployment (version 1.27.0)..."
kubectl create deployment nginx --image=nginx:1.27.0
kubectl get pods

progress "Exposing nginx as LoadBalancer service..."
kubectl expose deployment nginx --port 80 --type LoadBalancer
kubectl get services

progress "Waiting for external IP assignment..."
sleep 30
kubectl get services

# Task: Create Fortune App Pod
progress "Creating fortune-app pod..."
kubectl create -f pods/fortune-app.yaml
kubectl get pods

progress "Describing fortune-app pod..."
kubectl describe pods fortune-app

# Task: Interact with Pods
progress "Setting up port forwarding for fortune-app..."
kubectl port-forward fortune-app 10080:8080 &
PORT_FORWARD_PID=$!
sleep 5

progress "Testing fortune app endpoint..."
curl http://127.0.0.1:10080

progress "Testing secure endpoint (expected to fail)..."
curl http://127.0.0.1:10080/secure

progress "Logging in to get authentication token..."
TOKEN=$(curl -s -u user:password http://127.0.0.1:10080/login | jq -r '.token')

progress "Testing secure endpoint with authentication token..."
curl -H "Authorization: Bearer $TOKEN" http://127.0.0.1:10080/secure

progress "Viewing application logs..."
kubectl logs fortune-app

# Task: Secure Fortune Setup
progress "Creating TLS certificates secret..."
kubectl create secret generic tls-certs --from-file tls/

progress "Creating nginx proxy configuration..."
kubectl create configmap nginx-proxy-conf --from-file nginx/proxy.conf

progress "Creating secure-fortune pod..."
kubectl create -f pods/secure-fortune.yaml

progress "Creating fortune-app service..."
kubectl create -f services/fortune-app.yaml

progress "Creating firewall rule for port 31000..."
gcloud compute firewall-rules create allow-fortune-nodeport --allow=tcp:31000

progress "Labeling secure-fortune pod..."
kubectl label pods secure-fortune 'secure=enabled'
kubectl get pods secure-fortune --show-labels

progress "Checking service endpoints..."
kubectl describe services fortune-app | grep Endpoints

EXTERNAL_IP=$(gcloud compute instances list --format="value(EXTERNAL_IP)" | head -1)
progress "Testing secure fortune service..."
curl -k https://$EXTERNAL_IP:31000

# Microservices
progress "Creating microservices..."
kubectl create -f deployments/auth.yaml
kubectl create -f services/auth.yaml
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml
kubectl create -f deployments/fortune-service.yaml
kubectl create -f services/fortune-service.yaml

progress "Creating frontend..."
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml

sleep 30
kubectl get services frontend

FRONTEND_IP=$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
[ ! -z "$FRONTEND_IP" ] && curl -k https://$FRONTEND_IP

kubectl create -f pods/monolith.yaml
kubectl get pods

kill $PORT_FORWARD_PID 2>/dev/null

echo ""
echo "=================================================================="
echo "🎉 LAB COMPLETED SUCCESSFULLY – CAMPUSPERKS STYLE!"
echo "=================================================================="
kubectl get pods
kubectl get services
kubectl get deployments

echo ""
echo "📺 Subscribe: https://www.youtube.com/@CampusPerkss"
echo "🚀 CampusPerks – Cloud Arcade Labs made simple!"
echo ""

gcloud container clusters describe io --zone $ZONE --format="value(name, currentMasterVersion, endpoint)"
