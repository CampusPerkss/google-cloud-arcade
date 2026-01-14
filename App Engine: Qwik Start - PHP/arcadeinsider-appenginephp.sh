#!/bin/bash

# ================== COLOR VARIABLES ==================
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'

# Text formatting
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# ================== WELCOME ==================
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}   CAMPUSPERKS | APP ENGINE LAB - INITIATING EXECUTION 🚀   ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

# ================== REGION INPUT ==================
echo -e "${YELLOW_TEXT}${BOLD_TEXT}Enter your App Engine region (example: us-central):${RESET_FORMAT}"
read REGION
echo

# ================== AUTH & API ==================
echo "${BLUE_TEXT}${BOLD_TEXT}🔐 Checking gcloud authentication...${RESET_FORMAT}"
gcloud auth list

echo "${BLUE_TEXT}${BOLD_TEXT}⚙️ Enabling App Engine API...${RESET_FORMAT}"
gcloud services enable appengine.googleapis.com

# ================== CLONE SAMPLE APP ==================
echo "${MAGENTA_TEXT}${BOLD_TEXT}📥 Cloning PHP App Engine sample...${RESET_FORMAT}"
git clone https://github.com/GoogleCloudPlatform/php-docs-samples.git

cd php-docs-samples/appengine/standard/helloworld || {
  echo "${RED_TEXT}${BOLD_TEXT}❌ Failed to enter sample directory${RESET_FORMAT}"
  exit 1
}

# ================== CREATE & DEPLOY ==================
sleep 10
echo "${GREEN_TEXT}${BOLD_TEXT}🚀 Creating App Engine application...${RESET_FORMAT}"
gcloud app create --region=$REGION

echo "${GREEN_TEXT}${BOLD_TEXT}🚀 Deploying application...${RESET_FORMAT}"
gcloud app deploy --quiet

# ================== FINAL MESSAGE ==================
echo
echo "${CYAN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}          🎉 LAB COMPLETED SUCCESSFULLY! 🎉          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}YouTube: https://www.youtube.com/@CampusPerkss${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🔥 Like • Share • Subscribe for more Arcade Labs${RESET_FORMAT}"

