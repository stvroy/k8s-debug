#!/bin/bash

# Wait for the cluster to be fully ready
echo "Preparing cluster..."
until kubectl get nodes | grep -q "Ready"; do
  sleep 3
done
sleep 5

# Create the production namespace
kubectl create namespace production

# Create a ConfigMap the deployment references (exists, correct — not a bug)
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
  namespace: production
data:
  APP_ENV: "production"
  LOG_LEVEL: "info"
  PORT: "80"
EOF

# Create the broken Deployment
# BUG 1: image tag nginx:1.99.0 does not exist  → causes ImagePullBackOff / CrashLoopBackOff
# BUG 2: pod label is app=api-gateway-v2 but deployment selector is app=api-gateway → service gets zero endpoints
# BUG 3: readinessProbe checks port 9090 but container listens on port 80 → pods never become Ready
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway-v2
    spec:
      containers:
      - name: api-gateway
        image: nginx:1.99.0
        ports:
        - containerPort: 80
        envFrom:
        - configMapRef:
            name: api-config
        readinessProbe:
          httpGet:
            path: /
            port: 9090
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "250m"
            memory: "256Mi"
EOF

# Create the Service — selector intentionally looks for app=api-gateway
# which matches nothing because pods are labelled app=api-gateway-v2 (BUG 2)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: api-gateway-svc
  namespace: production
spec:
  selector:
    app: api-gateway
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
EOF

echo "Cluster is ready. Scenario is live."
