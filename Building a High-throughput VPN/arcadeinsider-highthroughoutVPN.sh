#!/bin/bash
set -e

# ================= COLORS =================
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# ================= WELCOME =================
echo "${CYAN_TEXT}${BOLD_TEXT}==============================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}   CAMPUSPERKS 🚀 | Site-to-Site VPN Arcade Lab Execution     ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==============================================================${RESET_FORMAT}"
echo

# ================= INPUT =================
echo "${YELLOW_TEXT}${BOLD_TEXT}Enter ZONE 1 (example: us-east1-b): ${RESET_FORMAT}"
read ZONE_1

echo "${YELLOW_TEXT}${BOLD_TEXT}Enter ZONE 2 (example: us-central1-a): ${RESET_FORMAT}"
read ZONE_2

REGION_1="${ZONE_1%-*}"
REGION_2="${ZONE_2%-*}"

export ZONE_1 ZONE_2 REGION_1 REGION_2
export DEVSHELL_PROJECT_ID=$(gcloud config get-value project)

# ================= SHARED SECRET =================
VPN_SECRET="campusperks123"

# ================= NETWORKS =================
gcloud compute networks create cloud --subnet-mode=custom
gcloud compute firewall-rules create cloud-fw --network cloud --allow tcp:22,tcp:5001,udp:5001,icmp
gcloud compute networks subnets create cloud-east --network cloud --range 10.0.1.0/24 --region "$REGION_1"

gcloud compute networks create on-prem --subnet-mode=custom
gcloud compute firewall-rules create on-prem-fw --network on-prem --allow tcp:22,tcp:5001,udp:5001,icmp
gcloud compute networks subnets create on-prem-central --network on-prem --range 192.168.1.0/24 --region "$REGION_2"

# ================= VPN GATEWAYS =================
gcloud compute target-vpn-gateways create cloud-gw1 --network cloud --region "$REGION_1"
gcloud compute target-vpn-gateways create on-prem-gw1 --network on-prem --region "$REGION_2"

gcloud compute addresses create cloud-gw1 --region "$REGION_1"
gcloud compute addresses create on-prem-gw1 --region "$REGION_2"

CLOUD_GW_IP=$(gcloud compute addresses describe cloud-gw1 --region "$REGION_1" --format='value(address)')
ONPREM_GW_IP=$(gcloud compute addresses describe on-prem-gw1 --region "$REGION_2" --format='value(address)')

# ================= FORWARDING RULES =================
for PORT in esp udp500 udp4500; do
  case $PORT in
    esp)
      gcloud compute forwarding-rules create cloud-fr-esp --ip-protocol ESP --address "$CLOUD_GW_IP" --target-vpn-gateway cloud-gw1 --region "$REGION_1"
      gcloud compute forwarding-rules create onprem-fr-esp --ip-protocol ESP --address "$ONPREM_GW_IP" --target-vpn-gateway on-prem-gw1 --region "$REGION_2"
      ;;
    udp500)
      gcloud compute forwarding-rules create cloud-fr-udp500 --ip-protocol UDP --ports 500 --address "$CLOUD_GW_IP" --target-vpn-gateway cloud-gw1 --region "$REGION_1"
      gcloud compute forwarding-rules create onprem-fr-udp500 --ip-protocol UDP --ports 500 --address "$ONPREM_GW_IP" --target-vpn-gateway on-prem-gw1 --region "$REGION_2"
      ;;
    udp4500)
      gcloud compute forwarding-rules create cloud-fr-udp4500 --ip-protocol UDP --ports 4500 --address "$CLOUD_GW_IP" --target-vpn-gateway cloud-gw1 --region "$REGION_1"
      gcloud compute forwarding-rules create onprem-fr-udp4500 --ip-protocol UDP --ports 4500 --address "$ONPREM_GW_IP" --target-vpn-gateway on-prem-gw1 --region "$REGION_2"
      ;;
  esac
done

# ================= VPN TUNNELS =================
gcloud compute vpn-tunnels create cloud-tunnel1 \
--peer-address "$ONPREM_GW_IP" \
--target-vpn-gateway cloud-gw1 \
--ike-version 2 \
--shared-secret "$VPN_SECRET" \
--local-traffic-selector 0.0.0.0/0 \
--remote-traffic-selector 0.0.0.0/0 \
--region "$REGION_1"

gcloud compute vpn-tunnels create on-prem-tunnel1 \
--peer-address "$CLOUD_GW_IP" \
--target-vpn-gateway on-prem-gw1 \
--ike-version 2 \
--shared-secret "$VPN_SECRET" \
--local-traffic-selector 0.0.0.0/0 \
--remote-traffic-selector 0.0.0.0/0 \
--region "$REGION_2"

# ================= ROUTES =================
gcloud compute routes create cloud-route --network cloud --destination-range 192.168.1.0/24 \
--next-hop-vpn-tunnel cloud-tunnel1 --next-hop-vpn-tunnel-region "$REGION_1"

gcloud compute routes create onprem-route --network on-prem --destination-range 10.0.1.0/24 \
--next-hop-vpn-tunnel on-prem-tunnel1 --next-hop-vpn-tunnel-region "$REGION_2"

# ================= VM CREATION =================
gcloud compute instances create cloud-loadtest --zone "$ZONE_1" \
--machine-type e2-standard-4 --subnet cloud-east --image-family debian-11 --image-project debian-cloud

gcloud compute instances create on-prem-loadtest --zone "$ZONE_2" \
--machine-type e2-standard-4 --subnet on-prem-central --image-family debian-11 --image-project debian-cloud

# ================= IPERF TEST =================
gcloud compute ssh on-prem-loadtest --zone "$ZONE_2" --quiet \
--command "sudo apt-get update && sudo apt-get install -y iperf && iperf -s -i 5" &

sleep 10

gcloud compute ssh cloud-loadtest --zone "$ZONE_1" --quiet \
--command "sudo apt-get update && sudo apt-get install -y iperf && iperf -c 192.168.1.2 -P 20 -x C"

# ================= DONE =================
echo
echo "${GREEN_TEXT}${BOLD_TEXT}==============================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT} 🎉 LAB COMPLETED SUCCESSFULLY – CAMPUSPERKS 🎉 ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}==============================================================${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@CampusPerkss${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}Like 👍 | Share 🔁 | Subscribe 🔔${RESET_FORMAT}"

