#!/bin/bash
# set -x

export LOCATION='flatrock'
export SPACE='Default'
export SPACE_ENCODED=$(echo -n -e "$SPACE" | od -An -tx1 | tr ' ' % | xargs printf "%s")

ACCESS_TOKEN=$(curl -s -k -X POST \
  "${HPEGL_IAM_SERVICE_URL}/v1/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=${HPEGL_USER_ID}" \
  -d "client_secret=${HPEGL_USER_SECRET}" \
  -d grant_type=client_credentials \
  -d scope=hpe-tenant | jq -r '.access_token')

echo "Token: ${ACCESS_TOKEN}"

curl -s -k -X GET \
   "https://client.greenlake.hpe.com/api/iac-vmaas/v1/whoami?space=${SPACE_ENCODED}&location=${LOCATION}" \
   -H "Authorization: ${ACCESS_TOKEN}" | jq '.'
