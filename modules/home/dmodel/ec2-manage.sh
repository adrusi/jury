#!/usr/bin/env bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Shared config per region
KEY="anish"
DEFAULT_IAM_PROFILE="EC2-SSM-Profile"

# us-east-1
SG_USE1="sg-07c982f37f423b6f8"
SUBNET_USE1="subnet-0c320e74a20bac8af"
AMI_USE1="ami-020cba7c55df1f615"

# us-east-2
SG_USE2="sg-0788ba0e61110be22"
SUBNET_USE2="subnet-0215d0f5f69f13777"
AMI_USE2="ami-0fa2a5724d24fc098"

echo -e "${BOLD}${CYAN}═══════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}         EC2 Instance Manager          ${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════${NC}"
echo ""

# ─────────────────────────────────────────
# REGION SELECTION
# ─────────────────────────────────────────
echo -e "${BOLD}Select region:${NC}"
echo ""
echo -e "  ${BOLD}1)${NC}  us-east-1 (Virginia)  ${YELLOW}← primarily CPU${NC}"
echo -e "  ${BOLD}2)${NC}  us-east-2 (Ohio)      ${YELLOW}← primarily GPU${NC}"
echo ""
read -p "Enter region [1-2, default=2]: " REGION_CHOICE
REGION_CHOICE="${REGION_CHOICE:-2}"

if [ "$REGION_CHOICE" = "1" ]; then
  REGION="us-east-1"
  DEFAULT_SG="$SG_USE1"
  DEFAULT_SUBNET="$SUBNET_USE1"
  DEFAULT_AMI="$AMI_USE1"
elif [ "$REGION_CHOICE" = "2" ]; then
  REGION="us-east-2"
  DEFAULT_SG="$SG_USE2"
  DEFAULT_SUBNET="$SUBNET_USE2"
  DEFAULT_AMI="$AMI_USE2"
else
  echo -e "${RED}Invalid region.${NC}"
  exit 1
fi

echo ""
echo -e "${CYAN}Region: ${BOLD}${REGION}${NC}"
echo ""

# ─────────────────────────────────────────
# TOP-LEVEL MENU
# ─────────────────────────────────────────
echo -e "${BOLD}What would you like to do?${NC}"
echo ""
echo -e "  ${BOLD}1)${NC}  Manage existing instance"
echo -e "  ${BOLD}2)${NC}  Launch new instance"
echo -e "  ${BOLD}3)${NC}  Check quota for instance type"
echo ""
read -p "Enter choice [1-3, default=1]: " TOP_ACTION
TOP_ACTION="${TOP_ACTION:-1}"

# ─────────────────────────────────────────
# CHECK QUOTA
# ─────────────────────────────────────────
if [ "$TOP_ACTION" = "3" ]; then
  read -p "Enter instance type (e.g. c7i.16xlarge): " QUOTA_TYPE

  FAMILY=$(echo "$QUOTA_TYPE" | sed 's/[0-9].*//' | tr '[:lower:]' '[:upper:]')

  echo ""
  echo -e "${YELLOW}Fetching quota info for ${QUOTA_TYPE} (family: ${FAMILY})...${NC}"
  echo ""

  VCPUS=$(aws ec2 describe-instance-types --region "$REGION" --instance-types "$QUOTA_TYPE" \
    --query "InstanceTypes[0].VCpuInfo.DefaultVCpus" --output text 2>/dev/null || echo "unknown")

  echo -e "${BOLD}Instance type:${NC} $QUOTA_TYPE"
  echo -e "${BOLD}vCPUs needed:${NC}  $VCPUS"
  echo ""

  if echo "A C D H I M R T Z" | grep -qw "$FAMILY"; then
    QUOTA_GREP="On-Demand Standard"
  elif [ "$FAMILY" = "P" ]; then
    QUOTA_GREP="On-Demand P instances"
  elif echo "G VT" | grep -qw "$FAMILY"; then
    QUOTA_GREP="On-Demand G and VT"
  else
    QUOTA_GREP="On-Demand Standard"
  fi

  FAMILY_LOWER=$(echo "$FAMILY" | tr '[:upper:]' '[:lower:]')

  for R in us-east-1 us-east-2; do
    QUOTA=$(aws service-quotas list-service-quotas --service-code ec2 --region "$R" \
      --output text 2>/dev/null | grep "$QUOTA_GREP" | awk '{print int($NF)}')
    QUOTA=${QUOTA:-0}

    USED=$(aws ec2 describe-instances --region "$R" \
      --filters "Name=instance-state-name,Values=running" "Name=instance-type,Values=${FAMILY_LOWER}*" \
      --query "Reservations[].Instances[].[CpuOptions.CoreCount, CpuOptions.ThreadsPerCore]" \
      --output text 2>/dev/null | awk '{s += $1 * $2} END {print s+0}')
    USED=${USED:-0}

    AVAILABLE=$((QUOTA - USED))

    if [ "$VCPUS" != "unknown" ] && [ "$AVAILABLE" -ge "$VCPUS" ] 2>/dev/null; then
      STATUS="${GREEN}✓ Can launch${NC}"
    else
      STATUS="${RED}✗ Insufficient quota or unknown type${NC}"
    fi

    printf "  ${BOLD}%-12s${NC}  Quota: %-8s Used: %-8s Available: %-8s %b\n" \
      "$R" "$QUOTA" "$USED" "$AVAILABLE" "$STATUS"
  done
  echo ""
  exit 0
fi

# ─────────────────────────────────────────
# LAUNCH NEW INSTANCE
# ─────────────────────────────────────────
if [ "$TOP_ACTION" = "2" ]; then
  read -p "Instance name: " NEW_NAME
  read -p "Instance type (e.g. c7i.16xlarge): " NEW_TYPE

  echo ""
  echo -e "${YELLOW}Checking quota for ${NEW_TYPE}...${NC}"

  VCPUS=$(aws ec2 describe-instance-types --region "$REGION" --instance-types "$NEW_TYPE" \
    --query "InstanceTypes[0].VCpuInfo.DefaultVCpus" --output text 2>/dev/null || echo "unknown")

  FAMILY=$(echo "$NEW_TYPE" | sed 's/[0-9].*//' | tr '[:lower:]' '[:upper:]')

  if echo "A C D H I M R T Z" | grep -qw "$FAMILY"; then
    QUOTA_GREP="On-Demand Standard"
  elif [ "$FAMILY" = "P" ]; then
    QUOTA_GREP="On-Demand P instances"
  elif echo "G VT" | grep -qw "$FAMILY"; then
    QUOTA_GREP="On-Demand G and VT"
  else
    QUOTA_GREP="On-Demand Standard"
  fi

  QUOTA=$(aws service-quotas list-service-quotas --service-code ec2 --region "$REGION" \
    --output text 2>/dev/null | grep "$QUOTA_GREP" | awk '{print int($NF)}')
  QUOTA=${QUOTA:-0}
  FAMILY_LOWER=$(echo "$FAMILY" | tr '[:upper:]' '[:lower:]')
  USED_VCPUS=$(aws ec2 describe-instances --region "$REGION" \
    --filters "Name=instance-state-name,Values=running" "Name=instance-type,Values=${FAMILY_LOWER}*" \
    --query "Reservations[].Instances[].[CpuOptions.CoreCount, CpuOptions.ThreadsPerCore]" \
    --output text 2>/dev/null | awk '{s += $1 * $2} END {print s+0}')
  USED_VCPUS=${USED_VCPUS:-0}
  AVAILABLE=$((QUOTA - USED_VCPUS))

  echo -e "  vCPUs needed:    ${BOLD}${VCPUS}${NC}"
  echo -e "  Quota:           ${BOLD}${QUOTA}${NC}"
  echo -e "  Currently used:  ${BOLD}${USED_VCPUS}${NC}"
  echo -e "  Available:       ${BOLD}${AVAILABLE}${NC}"

  if [ "$VCPUS" != "unknown" ] && [ "$AVAILABLE" -lt "$VCPUS" ]; then
    echo ""
    echo -e "${RED}Warning: Insufficient quota. You may get InsufficientCapacity error.${NC}"
    read -p "Proceed anyway? (yes/no): " PROCEED
    [ "$PROCEED" != "yes" ] && exit 0
  fi

  echo ""
  echo -e "${YELLOW}Launching ${NEW_NAME} (${NEW_TYPE})...${NC}"
  echo -e "  Region:          ${REGION}"
  echo -e "  Security Group:  ${DEFAULT_SG}"
  echo -e "  Subnet:          ${DEFAULT_SUBNET}"
  echo -e "  Key pair:        ${KEY}"
  echo -e "  AMI:             ${DEFAULT_AMI}"
  echo -e "  IAM Profile:     ${DEFAULT_IAM_PROFILE}"
  echo ""
  read -p "Confirm launch? (yes/no): " LAUNCH_CONFIRM
  [ "$LAUNCH_CONFIRM" != "yes" ] && echo -e "${YELLOW}Cancelled.${NC}" && exit 0

  NEW_ID=$(aws ec2 run-instances \
    --region "$REGION" \
    --instance-type "$NEW_TYPE" \
    --key-name "$KEY" \
    --image-id "$DEFAULT_AMI" \
    --subnet-id "$DEFAULT_SUBNET" \
    --security-group-ids "$DEFAULT_SG" \
    --iam-instance-profile Name="$DEFAULT_IAM_PROFILE" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${NEW_NAME}}]" \
    --query "Instances[0].InstanceId" --output text)

  echo ""
  echo -e "${YELLOW}Waiting for instance to start...${NC}"
  aws ec2 wait instance-running --region "$REGION" --instance-ids "$NEW_ID"

  NEW_IP=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$NEW_ID" \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

  echo -e "${GREEN}Instance launched!${NC}"
  echo -e "  ID:         ${BOLD}${NEW_ID}${NC}"
  echo -e "  Public IP:  ${BOLD}${NEW_IP}${NC}"
  echo -e "  SSH:        ${BOLD}ssh -i ~/.ssh/anish.pem ubuntu@${NEW_IP}${NC}"
  echo -e "  SSM:        ${BOLD}aws ssm start-session --region ${REGION} --target ${NEW_ID}${NC}"
  exit 0
fi

# ─────────────────────────────────────────
# MANAGE EXISTING INSTANCE
# ─────────────────────────────────────────

echo -e "${YELLOW}Fetching instances...${NC}"
INSTANCES_JSON=$(aws ec2 describe-instances \
  --region "$REGION" \
  --filters "Name=instance-state-name,Values=pending,running,stopping,stopped" \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0],PublicIpAddress,KeyName]' \
  --output json)

INSTANCE_IDS=()
INSTANCE_TYPES=()
INSTANCE_STATES=()
INSTANCE_NAMES=()
INSTANCE_IPS=()
INSTANCE_KEYS=()

while IFS= read -r line; do
  INSTANCE_IDS+=("$(echo "$line" | jq -r '.[0]')")
  INSTANCE_TYPES+=("$(echo "$line" | jq -r '.[1]')")
  INSTANCE_STATES+=("$(echo "$line" | jq -r '.[2]')")
  INSTANCE_NAMES+=("$(echo "$line" | jq -r '.[3] // "unnamed"')")
  INSTANCE_IPS+=("$(echo "$line" | jq -r '.[4] // "N/A"')")
  INSTANCE_KEYS+=("$(echo "$line" | jq -r '.[5] // "N/A"')")
done < <(echo "$INSTANCES_JSON" | jq -c '.[][]')

COUNT=${#INSTANCE_IDS[@]}

if [ "$COUNT" -eq 0 ]; then
  echo -e "${RED}No instances found in ${REGION}.${NC}"
  exit 1
fi

echo ""
echo -e "${BOLD}Select an instance:${NC}"
echo ""
for i in $(seq 0 $((COUNT - 1))); do
  STATE="${INSTANCE_STATES[$i]}"
  case "$STATE" in
    running) STATE_COLOR="${GREEN}" ;;
    stopped) STATE_COLOR="${RED}" ;;
    *)       STATE_COLOR="${YELLOW}" ;;
  esac
  printf "  ${BOLD}%d)${NC}  %-25s %-15s ${STATE_COLOR}%-10s${NC} IP: %-16s Key: %s\n" \
    $((i + 1)) \
    "${INSTANCE_NAMES[$i]}" \
    "${INSTANCE_TYPES[$i]}" \
    "${STATE}" \
    "${INSTANCE_IPS[$i]}" \
    "${INSTANCE_KEYS[$i]}"
done

echo ""
read -p "Enter number [1-${COUNT}]: " SELECTION

if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "$COUNT" ]; then
  echo -e "${RED}Invalid selection.${NC}"
  exit 1
fi

IDX=$((SELECTION - 1))
SELECTED_ID="${INSTANCE_IDS[$IDX]}"
SELECTED_NAME="${INSTANCE_NAMES[$IDX]}"
SELECTED_STATE="${INSTANCE_STATES[$IDX]}"

echo ""
echo -e "${CYAN}Selected: ${BOLD}${SELECTED_NAME}${NC} ${CYAN}(${SELECTED_ID})${NC} — state: ${SELECTED_STATE}"
echo ""

echo -e "${BOLD}Choose an action:${NC}"
echo ""
echo -e "  ${BOLD}1)${NC}  Check instance state, IPs & key pair"
echo -e "  ${BOLD}2)${NC}  Start instance"
echo -e "  ${BOLD}3)${NC}  Stop instance"
echo -e "  ${BOLD}4)${NC}  SSM session"
echo -e "  ${BOLD}5)${NC}  Terminate instance"
echo -e "  ${BOLD}6)${NC}  Attach SSM profile"
echo -e "  ${BOLD}7)${NC}  Expand disk"
echo ""
read -p "Enter action [1-7]: " ACTION

case "$ACTION" in
  1)
    echo ""
    echo -e "${YELLOW}Fetching instance details...${NC}"
    aws ec2 describe-instances --region "$REGION" --instance-ids "$SELECTED_ID" \
      --query 'Reservations[0].Instances[0].{InstanceId:InstanceId,State:State.Name,InstanceType:InstanceType,PublicIp:PublicIpAddress,PrivateIp:PrivateIpAddress,KeyName:KeyName,LaunchTime:LaunchTime}' \
      --output table
    ;;

  2)
    if [ "$SELECTED_STATE" = "running" ]; then
      echo -e "${YELLOW}Instance is already running.${NC}"
    else
      echo -e "${YELLOW}Starting instance...${NC}"
      aws ec2 start-instances --region "$REGION" --instance-ids "$SELECTED_ID" > /dev/null
      echo -e "${YELLOW}Waiting for instance to be running...${NC}"
      aws ec2 wait instance-running --region "$REGION" --instance-ids "$SELECTED_ID"
      NEW_IP=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$SELECTED_ID" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
      echo -e "${GREEN}Instance is now running!${NC} Public IP: ${NEW_IP}"
    fi
    echo ""
    echo -e "${BOLD}To SSM into this instance, run:${NC}"
    echo -e "${CYAN}aws ssm start-session --region ${REGION} --target ${SELECTED_ID}${NC}"
    ;;

  3)
    if [ "$SELECTED_STATE" = "stopped" ]; then
      echo -e "${YELLOW}Instance is already stopped.${NC}"
    else
      echo -e "${YELLOW}Stopping instance...${NC}"
      aws ec2 stop-instances --region "$REGION" --instance-ids "$SELECTED_ID" > /dev/null
      echo -e "${YELLOW}Waiting for instance to stop...${NC}"
      aws ec2 wait instance-stopped --region "$REGION" --instance-ids "$SELECTED_ID"
      echo -e "${GREEN}Instance is now stopped.${NC}"
    fi
    ;;

  4)
    if [ "$SELECTED_STATE" != "running" ]; then
      echo -e "${RED}Instance is not running (state: ${SELECTED_STATE}). Start it first.${NC}"
      exit 1
    fi
    echo -e "${YELLOW}Starting SSM session...${NC}"
    exec aws ssm start-session --region "$REGION" --target "$SELECTED_ID"
    ;;

  5)
    echo -e "${RED}${BOLD}WARNING: This will permanently terminate ${SELECTED_NAME} (${SELECTED_ID})${NC}"
    read -p "Type 'yes' to confirm: " CONFIRM
    if [ "$CONFIRM" = "yes" ]; then
      aws ec2 terminate-instances --region "$REGION" --instance-ids "$SELECTED_ID" > /dev/null
      echo -e "${GREEN}Termination initiated.${NC}"
    else
      echo -e "${YELLOW}Cancelled.${NC}"
    fi
    ;;

  6)
    echo -e "${YELLOW}Checking current SSM profile...${NC}"
    CURRENT_PROFILE=$(aws ec2 describe-iam-instance-profile-associations \
      --region "$REGION" \
      --filters "Name=instance-id,Values=$SELECTED_ID" "Name=state,Values=associated" \
      --query 'IamInstanceProfileAssociations[0].IamInstanceProfile.Arn' --output text 2>/dev/null)
    if [ "$CURRENT_PROFILE" != "None" ] && [ -n "$CURRENT_PROFILE" ]; then
      echo -e "${YELLOW}Already has profile: ${CURRENT_PROFILE}${NC}"
    else
      echo -e "${YELLOW}Attaching EC2-SSM-Profile...${NC}"
      aws ec2 associate-iam-instance-profile \
        --region "$REGION" \
        --iam-instance-profile Name=EC2-SSM-Profile \
        --instance-id "$SELECTED_ID"
      echo -e "${GREEN}SSM profile attached to ${SELECTED_NAME}!${NC}"
    fi
    ;;

  7)
    echo -e "${YELLOW}Fetching current disk info...${NC}"
    VOL_ID=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$SELECTED_ID" \
      --query "Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId" --output text)
    CURRENT_SIZE=$(aws ec2 describe-volumes --region "$REGION" --volume-ids "$VOL_ID" \
      --query "Volumes[0].Size" --output text)

    echo -e "  Volume ID:      ${BOLD}${VOL_ID}${NC}"
    echo -e "  Current size:   ${BOLD}${CURRENT_SIZE} GB${NC}"
    echo ""
    read -p "How many GB to add? " ADD_GB

    NEW_SIZE=$((CURRENT_SIZE + ADD_GB))
    echo ""
    echo -e "${YELLOW}Expanding ${VOL_ID} from ${CURRENT_SIZE}GB to ${NEW_SIZE}GB...${NC}"
    aws ec2 modify-volume --region "$REGION" --volume-id "$VOL_ID" --size "$NEW_SIZE" > /dev/null

    INSTANCE_IP=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$SELECTED_ID" \
      --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

    if [ "$INSTANCE_IP" = "None" ] || [ -z "$INSTANCE_IP" ]; then
      echo -e "${YELLOW}Instance has no public IP (stopped?). Volume resized on AWS side.${NC}"
      echo -e "${YELLOW}After starting, run manually:${NC}"
      echo -e "  ${CYAN}sudo growpart /dev/nvme0n1 1 && sudo resize2fs /dev/nvme0n1p1${NC}"
    else
      echo -e "${YELLOW}Waiting for volume modification to complete...${NC}"
      sleep 5
      echo -e "${YELLOW}Growing partition and filesystem on instance...${NC}"
      ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i ~/.ssh/anish.pem ubuntu@"$INSTANCE_IP" \
        "sudo growpart /dev/nvme0n1 1 && sudo resize2fs /dev/nvme0n1p1 && df -h /" 2>&1
      echo -e "${GREEN}Disk expanded successfully!${NC}"
    fi
    ;;

  *)
    echo -e "${RED}Invalid action.${NC}"
    exit 1
    ;;
esac
