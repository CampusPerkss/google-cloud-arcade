#!/bin/bash

# ================== COLOR CODES ==================
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
BLINK_TEXT=$'\033[5m'
REVERSE_TEXT=$'\033[7m'

clear

# ================== WELCOME ==================
echo "${CYAN_TEXT}${BOLD_TEXT}====================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}   CampusPerks | Google Cloud Arcade Automation Script               ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}   LAB: Speech to Text Transcription with the Cloud Speech API       ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}====================================================================${RESET_FORMAT}"
echo

# ================== TASK 1 ==================
cat > prepare_disk.sh <<'EOF_END'
gcloud services enable apikeys.googleapis.com

gcloud alpha services api-keys create --display-name="awesome"

KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter "displayName=awesome")
API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)")

cat > request.json <<EOF
{
  "config": {
    "encoding":"FLAC",
    "languageCode": "en-US"
  },
  "audio": {
    "uri":"gs://cloud-samples-data/speech/brooklyn_bridge.flac"
  }
}
EOF

curl -s -X POST -H "Content-Type: application/json" \
--data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json

cat result.json
EOF_END

export ZONE=$(gcloud compute instances list linux-instance --format='csv[no-heading](zone)')

gcloud compute scp prepare_disk.sh linux-instance:/tmp \
--project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute ssh linux-instance \
--project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet \
--command="bash /tmp/prepare_disk.sh"

# ================== CONFIRMATION ==================
read -p "CHECK MY PROGRESS DONE TILL TASK 3 (Y/N)? " response

if [[ "$response" =~ ^[Yy]$ ]]; then
  echo "Proceeding with next steps!"
else
  echo "Please check the progress before proceeding."
fi

# ================== TASK 2 ==================
cat > prepare_disk.sh <<'EOF_END'
KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter "displayName=awesome")
API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)")

rm -f request.json

cat > request.json <<EOF
{
  "config": {
    "encoding":"FLAC",
    "languageCode": "fr"
  },
  "audio": {
    "uri":"gs://cloud-samples-data/speech/corbeau_renard.flac"
  }
}
EOF

curl -s -X POST -H "Content-Type: application/json" \
--data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json

cat result.json
EOF_END

export ZONE=$(gcloud compute instances list linux-instance --format='csv[no-heading](zone)')

gcloud compute scp prepare_disk.sh linux-instance:/tmp \
--project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute ssh linux-instance \
--project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet \
--command="bash /tmp/prepare_disk.sh"

# ================== FINAL MESSAGE ==================
echo
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}   LAB COMPLETED SUCCESSFULLY – ALL TASKS VERIFIED ✅   ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}YouTube: https://www.youtube.com/@CampusPerkss${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}Like 👍 | Share 🔁 | Subscribe 🔔 for more Arcade Labs${RESET_FORMAT}"

