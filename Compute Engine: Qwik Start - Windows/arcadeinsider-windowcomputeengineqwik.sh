#!/bin/bash

# ================= COLOR VARIABLES =================
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
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}   CAMPUSPERKS | GOOGLE CLOUD ARCADE    ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}         INITIATING EXECUTION...        ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo

# Step 1: Check authentication
echo "${CYAN_TEXT}${BOLD_TEXT}Step 1:${RESET_FORMAT} Checking authenticated gcloud account"
gcloud auth list

# Step 2: Get default zone
echo
echo "${CYAN_TEXT}${BOLD_TEXT}Step 2:${RESET_FORMAT} Fetching default compute zone"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# Step 3: Create Windows VM
echo
echo "${CYAN_TEXT}${BOLD_TEXT}Step 3:${RESET_FORMAT} Creating Windows VM (arcadecrew)"
gcloud compute instances create arcadecrew \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --machine-type=e2-medium \
  --create-disk=auto-delete=yes,boot=yes,device-name=arcadecrew,mode=rw,size=50,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
  --image=projects/windows-cloud/global/images/windows-server-2022-dc-v20230913

# Wait for VM
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting 30 seconds for VM initialization...${RESET_FORMAT}"
sleep 30

# Step 4: Serial port output
echo
echo "${CYAN_TEXT}${BOLD_TEXT}Step 4:${RESET_FORMAT} Fetching serial port output"
gcloud compute instances get-serial-port-output arcadecrew --zone=$ZONE

# Step 5: Reset Windows password
echo
echo "${CYAN_TEXT}${BOLD_TEXT}Step 5:${RESET_FORMAT} Resetting Windows admin password"
gcloud compute reset-windows-password arcadecrew \
  --zone=$ZONE \
  --user=admin \
  --quiet

# ================= COMPLETION =================
echo
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}        LAB COMPLETED SUCCESSFULLY 🎉                 ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@CampusPerkss${RESET_FORMAT}"
echo "${WHITE_TEXT}${BOLD_TEXT}Subscribe for Google Cloud Arcade Labs 🚀${RESET_FORMAT}"

