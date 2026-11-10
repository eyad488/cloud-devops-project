#!/usr/bin/env bash
set -uo pipefail
LOG="/home/ec2-user/monitor.log"
if curl --silent --show-error --fail --max-time 5 http://localhost:5000/health | grep -q '"status":"healthy"'; then
  printf '%s HEALTHY application available\n' "$(date -Is)" >> "$LOG"
else
  printf '%s WARNING application unavailable\n' "$(date -Is)" >> "$LOG"
fi
