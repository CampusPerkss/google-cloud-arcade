
#!/bin/bash

# Define color variables
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

# Define text formatting variables
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# ================== WELCOME ==================
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}   CAMPUSPERKS | CLOUD STORAGE LAB - STARTING EXECUTION 🚀   ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

export PROJECT_ID=$(gcloud config get-value project)

gsutil mb -l $REGION -c Standard gs://$PROJECT_ID

curl -O https://github.com/gcpsolution99/GCP-solution/blob/main/kitten.png

gsutil cp kitten.png gs://$PROJECT_ID/kitten.png

gsutil iam ch allUsers:objectViewer gs://$PROJECT_ID

# ================== FINAL MESSAGE ==================
echo
echo "${CYAN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}          🎉 LAB COMPLETED SUCCESSFULLY! 🎉          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}YouTube: https://www.youtube.com/@CampusPerkss${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🔥 Like • Share • Subscribe for more Arcade Labs${RESET_FORMAT}"
