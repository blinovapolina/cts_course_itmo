#!/usr/bin/env bash

# Deployment Script

if [ $# -ne 3 ]
  then
    echo "No docker image / user / personal access token specified"
    echo "Example: deploy.sh ghcr.io/xxx/xxx user pat"
    exit
fi

export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

IMAGE=$1
USER=$2
PAT=$3
DOCKER="/usr/bin/docker"
COMPOSE_FILE="/var/www/websites/example.com/compose.yml"

"$DOCKER" login ghcr.io -u "$USER" -p "$PAT"

"$DOCKER" rmi "$IMAGE" -f
"$DOCKER" compose -f "$COMPOSE_FILE" up -d

service nginx reload

"$DOCKER" system prune -af