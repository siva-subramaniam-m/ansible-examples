#!/bin/bash
# set -x


if [[ -z "${VM_USERNAME}" ]]; then
  echo "VM_USERNAME environment variable not set!"
  exit 1
fi

if [[ -z "${VM_PASSWORD}" ]]; then
  echo "VM_PASSWORD environment variable not set!"
  exit 1
fi

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


# Sets user settings

curl -s -k -X POST \
  "https://client.greenlake.hpe.com/api/iac-vmaas/v1beta1/user-settings?space=${SPACE_ENCODED}&location=${LOCATION}" \
  -H "Authorization: ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "linuxUsername": '${VM_USERNAME}',
      "linuxPassword": '${VM_PASSWORD}',
      "windowsUsername": '${VM_USERNAME}',
      "windowsPassword": '${VM_PASSWORD}'
    }
  }'

