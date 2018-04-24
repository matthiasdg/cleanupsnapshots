#!/bin/bash
export AWS_ACCESS_KEY_ID=BLABLA
export AWS_SECRET_ACCESS_KEY=BLABLABLA

function usage() {
  echo "Usage: ./cleanupsnapshots.sh -d 'lldemo volumes 20??-??-?? 01:00' -t '7 days ago'"
}

while [[ $# -gt 0 ]]; do
  KEY="$1"

  case $KEY in
    -d | --description)
      DESCRIPTION="$2"
      shift # past argument
      shift # past value
      ;;
    -t | --time)
      TIME="$2"
      shift # past argument
      shift # past value
      ;;
  esac
done
if [ -z "$DESCRIPTION" ]; then
  usage
  exit
fi
if [ -z "$TIME" ]; then
  usage
  exit
fi

EXPIRY_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ" --date "$TIME")
SNAPSHOT_CANDIDATES=$(aws ec2 describe-snapshots --filters Name=description,Values="$DESCRIPTION" --query 'Snapshots[*].{ID:SnapshotId, Time:StartTime}' --output text --region eu-central-1)
while read SNAPID SNAPDATE; do
  if [[ "$SNAPDATE" < "$EXPIRY_DATE" ]]; then
    aws ec2 delete-snapshot --snapshot-id $SNAPID --region eu-central-1
  fi
done <<<"$SNAPSHOT_CANDIDATES"
