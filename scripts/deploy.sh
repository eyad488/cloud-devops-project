#!/usr/bin/env bash
set -euo pipefail
CONFIG="/home/ec2-user/app-config.env"
LOG="/home/ec2-user/deploy.log"
CONTAINER="student-app"
exec >> "$LOG" 2>&1
printf '%s deployment check started\n' "$(date -Is)"
if [[ ! -f "$CONFIG" ]]; then echo "ERROR: Missing $CONFIG"; exit 1; fi
# Configuration is written by the student on EC2, never committed to Git.
source "$CONFIG"
if [[ -z "${IMAGE:-}" || ! "$IMAGE" =~ ^[a-zA-Z0-9_.-]+/cloud-devops-app:latest$ ]]; then
  echo "ERROR: Invalid IMAGE value"; exit 1
fi
old_id="$(sudo docker image inspect --format '{{.Id}}' "$IMAGE" 2>/dev/null || true)"
if ! sudo docker pull "$IMAGE"; then
  echo "WARNING: Pull failed; retaining existing container"; exit 0
fi
new_id="$(sudo docker image inspect --format '{{.Id}}' "$IMAGE")"
running="$(sudo docker inspect --format '{{.State.Running}}' "$CONTAINER" 2>/dev/null || true)"
if [[ "$new_id" != "$old_id" || "$running" != "true" ]]; then
  sudo docker rm -f "$CONTAINER" 2>/dev/null || true
  sudo docker run -d --restart unless-stopped --name "$CONTAINER" -p 5000:5000 "$IMAGE"
  echo "Deployed image $new_id"
else
  echo "Image unchanged; container already running"
fi
