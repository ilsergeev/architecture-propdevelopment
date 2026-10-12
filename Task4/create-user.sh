#!/usr/bin/env bash

set -euo pipefail

CA_CERT="${HOME}/.minikube/ca.crt"
CA_KEY="${HOME}/.minikube/ca.key"
DAYS=365
WORKDIR="./certs"
mkdir -p "${WORKDIR}"

USERS=(
  "developer-ivan:team-developers"
  "devops-petr:platform-devops"
)

create_user () {
  local USER_NAME="$1"
  local GROUP="$2"
 
  echo ">> Создаю пользователя ${USER_NAME} (группа ${GROUP})"
 
  openssl genrsa -out "${WORKDIR}/${USER_NAME}.key" 2048
 
  openssl req -new \
    -key "${WORKDIR}/${USER_NAME}.key" \
    -out "${WORKDIR}/${USER_NAME}.csr" \
    -subj "/CN=${USER_NAME}/O=${GROUP}"
 
  openssl x509 -req \
    -in "${WORKDIR}/${USER_NAME}.csr" \
    -CA "${CA_CERT}" -CAkey "${CA_KEY}" -CAcreateserial \
    -out "${WORKDIR}/${USER_NAME}.crt" \
    -days "${DAYS}"
 
  kubectl config set-credentials "${USER_NAME}" \
    --client-certificate="${WORKDIR}/${USER_NAME}.crt" \
    --client-key="${WORKDIR}/${USER_NAME}.key" \
    --embed-certs=true
 
  kubectl config set-context "${USER_NAME}-context" \
    --cluster=minikube \
    --user="${USER_NAME}" \
    --namespace=default
 
  echo ">> Готово: ${USER_NAME}. Переключиться: kubectl config use-context ${USER_NAME}-context"
}

for ENTRY in "${USERS[@]}"; do
  create_user "${ENTRY%%:*}" "${ENTRY##*:}"
done
 
echo "Все пользователи созданы."