#!/bin/bash
# Google Cloud Networking Lab Setup
# Presented by CampusPerks


BOLD=$(tput bold)
UNDERLINE=$(tput smul)
RESET=$(tput sgr0)

# Text Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

# Background Colors
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)

clear
echo "${BG_BLUE}${BOLD}${WHITE}============================================${RESET}"
echo "${BG_BLUE}${BOLD}${WHITE}        WELCOME TO CAMPUSPERKS LAB          ${RESET}"
echo "${BG_BLUE}${BOLD}${WHITE}============================================${RESET}"
echo ""
echo "${CYAN}${BOLD}⚡ Arcade Lab Solutions by CampusPerks${RESET}"
echo "${YELLOW}${BOLD}📺 YouTube: ${UNDERLINE}https://www.youtube.com/@CampusPerkss${RESET}"
echo ""

# ======================
#  ENVIRONMENT SETUP
# ======================
echo "${MAGENTA}${BOLD}🌍 STEP 1: Configuring Network Environment${RESET}"

echo "${WHITE}🔍 Detecting instance zones and regions...${RESET}"
export INSTANCE_ZONE_1=$(gcloud compute instances list --filter="name:mynet-vm-1" --format="value(zone)")
export INSTANCE_ZONE_2=$(gcloud compute instances list --filter="name:mynet-vm-2" --format="value(zone)")

export REGION_1=${INSTANCE_ZONE_1%-*}
export REGION_2=${INSTANCE_ZONE_2%-*}

echo "${GREEN}✔ Detected:${RESET}"
echo "${WHITE}Zone 1: ${YELLOW}$INSTANCE_ZONE_1${RESET} (Region: ${YELLOW}$REGION_1${RESET})"
echo "${WHITE}Zone 2: ${YELLOW}$INSTANCE_ZONE_2${RESET} (Region: ${YELLOW}$REGION_2${RESET})"
echo ""

# ======================
#  NETWORK CREATION
# ======================
echo "${MAGENTA}${BOLD}🖧 STEP 2: Creating Networks and Subnets${RESET}"

gcloud compute networks create managementnet --subnet-mode=custom
gcloud compute networks subnets create managementsubnet-1 \
    --network=managementnet \
    --region=$REGION_1 \
    --range=10.130.0.0/20

gcloud compute networks create privatenet --subnet-mode=custom

gcloud compute networks subnets create privatesubnet-1 \
    --network=privatenet \
    --region=$REGION_1 \
    --range=172.16.0.0/24

gcloud compute networks subnets create privatesubnet-2 \
    --network=privatenet \
    --region=$REGION_2 \
    --range=172.20.0.0/20

echo "${GREEN}✔ All networks and subnets created successfully${RESET}"
echo ""

# ======================
#  FIREWALL RULES
# ======================
echo "${MAGENTA}${BOLD}🔥 STEP 3: Configuring Firewall Rules${RESET}"

gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp \
    --direction=INGRESS \
    --priority=1000 \
    --network=managementnet \
    --action=ALLOW \
    --rules=icmp,tcp:22,tcp:3389 \
    --source-ranges=0.0.0.0/0

gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp \
    --direction=INGRESS \
    --priority=1000 \
    --network=privatenet \
    --action=ALLOW \
    --rules=icmp,tcp:22,tcp:3389 \
    --source-ranges=0.0.0.0/0

echo "${GREEN}✔ Firewall rules configured successfully${RESET}"
echo ""

# ======================
#  INSTANCE DEPLOYMENT
# ======================
echo "${MAGENTA}${BOLD}🖥️ STEP 4: Deploying Compute Instances${RESET}"

gcloud compute instances create managementnet-vm-1 \
    --zone=$INSTANCE_ZONE_1 \
    --machine-type=e2-micro \
    --subnet=managementsubnet-1

gcloud compute instances create privatenet-vm-1 \
    --zone=$INSTANCE_ZONE_1 \
    --machine-type=e2-micro \
    --subnet=privatesubnet-1

gcloud compute instances create vm-appliance \
    --zone=$INSTANCE_ZONE_1 \
    --machine-type=e2-standard-4 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=privatesubnet-1 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=managementsubnet-1 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=mynetwork

echo "${GREEN}✔ All instances deployed successfully${RESET}"
echo ""

# ======================
#  COMPLETION MESSAGE
# ======================
echo "${BG_GREEN}${BOLD}${WHITE}============================================${RESET}"
echo "${BG_GREEN}${BOLD}${WHITE}      LAB COMPLETED SUCCESSFULLY 🎉         ${RESET}"
echo "${BG_GREEN}${BOLD}${WHITE}============================================${RESET}"
echo ""
echo "${CYAN}${BOLD}Powered by CampusPerks${RESET}"
echo "${YELLOW}${BOLD}👉 ${UNDERLINE}https://www.youtube.com/@CampusPerkss${RESET}"
echo "${GREEN}${BOLD}🔔 Like • Share • Subscribe for more Arcade Labs${RESET}"
