#!/usr/bin/env bash
 
set -euo pipefail

kubectl apply -f - <<'YAML'

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: team-developers-view
  namespace: product-team
subjects:
- kind: Group
  name: team-developers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: namespace-viewer
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: platform-devops-manage
subjects:
- kind: Group
  name: platform-devops
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-devops
  apiGroup: rbac.authorization.k8s.io
YAML
 
echo "Привязки созданы."