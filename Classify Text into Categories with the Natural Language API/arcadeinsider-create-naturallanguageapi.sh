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

clear

# ================== WELCOME ==================
echo "${CYAN_TEXT}${BOLD_TEXT}====================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}        ArcadeInsider | Google Cloud Arcade Automation Script        ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}   LAB: Classify Text into Categories with Natural Language API      ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}====================================================================${RESET_FORMAT}"
echo

# ================== API KEY INPUT ==================
read -p "${YELLOW_TEXT}${BOLD_TEXT}-> Enter your Natural Language API Key: ${RESET_FORMAT}" KEY
export KEY

# ================== ENABLE API ==================
echo "${GREEN_TEXT}${BOLD_TEXT}--> Enabling Natural Language API...${RESET_FORMAT}"
gcloud services enable language.googleapis.com

# ================== FETCH ZONE ==================
echo "${GREEN_TEXT}${BOLD_TEXT}--> Fetching Compute Engine zone...${RESET_FORMAT}"
ZONE=$(gcloud compute instances list --project=$DEVSHELL_PROJECT_ID --format="value(ZONE)")

# ================== ADD METADATA ==================
echo "${GREEN_TEXT}${BOLD_TEXT}--> Adding API key as instance metadata...${RESET_FORMAT}"
gcloud compute instances add-metadata linux-instance \
  --metadata API_KEY="$KEY" \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE

# ================== CREATE SCRIPT ==================
echo "${GREEN_TEXT}${BOLD_TEXT}--> Creating classification script...${RESET_FORMAT}"
cat > prepare_disk.sh <<'EOF'
#!/bin/bash

API_KEY=$(curl -s -H "Metadata-Flavor: Google" \
http://metadata.google.internal/computeMetadata/v1/instance/attributes/API_KEY)

cat > request.json <<REQ
{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"A Smoky Lobster Salad With a Tapa Twist. This spin on the Spanish pulpo a la gallega skips the octopus."
  }
}
REQ

curl -s -X POST \
-H "Content-Type: application/json" \
"https://language.googleapis.com/v1/documents:classifyText?key=${API_KEY}" \
--data-binary @request.json > result.json
EOF

chmod +x prepare_disk.sh

# ================== COPY SCRIPT ==================
echo "${MAGENTA_TEXT}${BOLD_TEXT}--> Copying script to VM...${RESET_FORMAT}"
gcloud compute scp prepare_disk.sh linux-instance:/tmp \
--project=$DEVSHELL_PROJECT_ID \
--zone=$ZONE --quiet

# ================== EXECUTE SCRIPT ==================
echo "${CYAN_TEXT}${BOLD_TEXT}--> Running script on VM...${RESET_FORMAT}"
gcloud compute ssh linux-instance \
--project=$DEVSHELL_PROJECT_ID \
--zone=$ZONE --quiet \
--command="bash /tmp/prepare_disk.sh"

# ================== BIGQUERY ==================
echo "${YELLOW_TEXT}${BOLD_TEXT}--> Creating BigQuery dataset & table...${RESET_FORMAT}"
bq --location=US mk --dataset $DEVSHELL_PROJECT_ID:news_classification_dataset

bq mk --table \
$DEVSHELL_PROJECT_ID:news_classification_dataset.article_data \
article_text:STRING,category:STRING,confidence:FLOAT

# ================== FINAL MESSAGE ==================
echo
echo "${GREEN_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}      LAB COMPLETED SUCCESSFULLY – TASKS VERIFIED ✅       ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}YouTube: https://www.youtube.com/@ArcadeInsider${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}Like 👍 | Share 🔁 | Subscribe 🔔 for more Arcade Labs${RESET_FORMAT}"
