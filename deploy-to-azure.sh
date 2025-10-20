#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   LMS Platform - Azure Deployment Script${NC}"
echo -e "${BLUE}================================================${NC}\n"

# Configuration
RESOURCE_GROUP="prepsurge-rg"
APP_NAME="prepsurge"
LOCATION="westeurope"
GITHUB_REPO_URL="https://github.com/YOUR_USERNAME/YOUR_REPO" # CHANGE THIS

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI is not installed${NC}"
    echo "Install from: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

echo -e "${GREEN}✓ Azure CLI is installed${NC}\n"

# Login to Azure
echo -e "${BLUE}Step 1: Logging in to Azure...${NC}"
az login

if [ $? -ne 0 ]; then
    echo -e "${RED}Login failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Successfully logged in${NC}\n"

# Select subscription
echo -e "${BLUE}Step 2: Selecting subscription...${NC}"
az account list --output table
echo ""
read -p "Enter your subscription ID: " SUBSCRIPTION_ID
az account set --subscription "$SUBSCRIPTION_ID"

echo -e "${GREEN}✓ Subscription set${NC}\n"

# Create resource group
echo -e "${BLUE}Step 3: Creating resource group...${NC}"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output table

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Resource group created${NC}\n"
else
    echo -e "${RED}Failed to create resource group${NC}"
    exit 1
fi

# Update GitHub repo URL
echo -e "${BLUE}Step 4: GitHub Repository Configuration${NC}"
read -p "Enter your GitHub repository URL (https://github.com/shemrun/next_prepsurg): " GITHUB_REPO_URL

# Create Static Web App
echo -e "${BLUE}Step 5: Creating Azure Static Web App...${NC}"
echo "This will open a browser for GitHub authentication..."

az staticwebapp create \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --source "$GITHUB_REPO_URL" \
  --location "$LOCATION" \
  --branch main \
  --app-location "/" \
  --output-location ".next" \
  --login-with-github

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Static Web App created${NC}\n"
else
    echo -e "${RED}Failed to create Static Web App${NC}"
    exit 1
fi

# Get the app URL
APP_URL=$(az staticwebapp show \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "defaultHostname" -o tsv)

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   Deployment Initiated Successfully!${NC}"
echo -e "${GREEN}================================================${NC}\n"

echo -e "${BLUE}Your app will be available at:${NC}"
echo -e "https://$APP_URL\n"

echo -e "${BLUE}Next Steps:${NC}"
echo "1. Add environment variables in Azure Portal:"
echo "   - Go to: https://portal.azure.com"
echo "   - Navigate to: Static Web Apps → $APP_NAME → Configuration"
echo "   - Add all your environment variables"
echo ""
echo "2. Update Clerk Dashboard:"
echo "   - Add https://$APP_URL to Allowed Origins"
echo "   - Add https://$APP_URL/* to Redirect URLs"
echo ""
echo "3. Update Stripe Webhook:"
echo "   - Webhook URL: https://$APP_URL/api/stripe-checkout/webhook"
echo "   - Add event: checkout.session.completed"
echo ""
echo "4. Monitor deployment:"
echo "   - GitHub Actions: $GITHUB_REPO_URL/actions"
echo "   - Azure Portal: https://portal.azure.com"
echo ""
echo -e "${GREEN}Deployment script completed!${NC}"