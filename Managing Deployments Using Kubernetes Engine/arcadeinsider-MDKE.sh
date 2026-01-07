#!/bin/bash
set -e

# ================== CAMPUSPERKS ==================
# Arcade Lab Auto Script
# Easy • Direct • One-Run Commands
# YouTube: https://www.youtube.com/@CampusPerkss
# ================================================

# ================== FETCH DETAILS ==================
ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/zone "$ZONE"

echo "ZONE: $ZONE"
echo "REGION: $REGION"
echo "PROJECT: $PROJECT_ID"
echo

# ================== LAB FILES ==================
gcloud storage cp -r gs://spls/gsp053/kubernetes .
cd kubernetes

# ================== CREATE CLUSTER ==================
gcloud container clusters create bootcamp \
--machine-type e2-small \
--num-nodes 3 \
--scopes=https://www.googleapis.com/auth/projecthosting,storage-rw

# ================== TASK 2 : BLUE DEPLOYMENT ==================
kubectl create -f deployments/fortune-app-blue.yaml
kubectl create -f services/fortune-app.yaml

kubectl scale deployment fortune-app-blue --replicas=5
kubectl get pods | grep fortune-app-blue | wc -l

kubectl scale deployment fortune-app-blue --replicas=3
kubectl get pods | grep fortune-app-blue | wc -l

# ================== TASK 3 : UPDATE IMAGE + ENV ==================
kubectl set image deployment/fortune-app-blue \
fortune-app=$REGION-docker.pkg.dev/qwiklabs-resources/spl-lab-apps/fortune-service:2.0.0

kubectl set env deployment/fortune-app-blue APP_VERSION=2.0.0

# ================== CANARY DEPLOYMENT ==================
kubectl create -f deployments/fortune-app-canary.yaml

# ================== TASK 5 : BLUE / GREEN ==================
kubectl apply -f services/fortune-app-blue-service.yaml
kubectl create -f deployments/fortune-app-green.yaml
kubectl apply -f services/fortune-app-green-service.yaml
kubectl apply -f services/fortune-app-blue-service.yaml

# ================== DONE ==================
echo
echo "=============================================="
echo " 🎉 LAB COMPLETED SUCCESSFULLY – CAMPUSPERKS 🎉"
echo "=============================================="
echo
echo "Subscribe 👉 https://www.youtube.com/@CampusPerkss"
