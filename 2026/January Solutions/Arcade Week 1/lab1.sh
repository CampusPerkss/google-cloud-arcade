clear

#!/bin/bash
# ===================== CampusPerks Cloud Lab ===================== #

# Define color variables
BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

# Array of color codes
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)

RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

# ----------------------------- Banner ----------------------------- #

echo
echo "${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}        🚀 Welcome to CampusPerks Cloud Lab 🚀          ${RESET}"
echo "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo

echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Starting Lab Execution...${RESET}"
echo

# Step 1: Set Compute Zone
echo "${BOLD}${BLUE}Step 1: Setting Compute Zone${RESET}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# Step 2: Get Project ID
echo "${BOLD}${MAGENTA}Step 2: Fetching Project ID${RESET}"
export PROJECT_ID=$(gcloud config get-value project)

# Step 3: Get Project Number
echo "${BOLD}${GREEN}Step 3: Retrieving Project Number${RESET}"
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")

# Step 4: Create VM Instance `gcelab`
echo "${BOLD}${YELLOW}Step 4: Creating VM Instance 'gcelab'${RESET}"
gcloud compute instances create gcelab \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --tags=http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=gcelab,image=projects/debian-cloud/global/images/debian-11-bullseye-v20241009,mode=rw,size=10,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any

# Step 5: Create second instance
echo "${BOLD}${RED}Step 5: Creating second VM 'gcelab2'${RESET}"
gcloud compute instances create gcelab2 --machine-type e2-medium --zone=$ZONE

# Step 6: Install nginx
echo "${BOLD}${CYAN}Step 6: Installing & Verifying NGINX${RESET}"
gcloud compute ssh --zone "$ZONE" "gcelab" \
--project "$DEVSHELL_PROJECT_ID" --quiet \
--command "sudo apt-get update && sudo apt-get install -y nginx && ps auwx | grep nginx"

# Step 7: Firewall rule
echo "${BOLD}${MAGENTA}Step 7: Allowing HTTP Traffic${RESET}"
gcloud compute firewall-rules create allow-http \
--network=default --allow=tcp:80 --target-tags=allow-http

echo

# ---------------------- Completion Message ----------------------- #

random_congrats() {
    MESSAGES=(
        "${GREEN}🎉 Lab Completed Successfully! Great work!${RESET}"
        "${CYAN}🔥 Awesome! You're crushing Cloud Labs!${RESET}"
        "${YELLOW}🚀 Well done! Keep learning with CampusPerks!${RESET}"
        "${BLUE}👏 Excellent execution!${RESET}"
        "${MAGENTA}🏆 Mission Accomplished!${RESET}"
    )
    echo -e "${BOLD}${MESSAGES[$RANDOM % ${#MESSAGES[@]}]}"
}

random_congrats
echo

echo "${CYAN}${BOLD}══════════════════════════════════════════════════════${RESET}"
echo "${GREEN}${BOLD}  Subscribe for more Cloud Arcade Labs & Shortcuts 👇  ${RESET}"
echo "${BLUE}${BOLD}  https://www.youtube.com/@CampusPerkss               ${RESET}"
echo "${CYAN}${BOLD}══════════════════════════════════════════════════════${RESET}"
echo
