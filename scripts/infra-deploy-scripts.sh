# 1) create cluster
kind create cluster --name demo-cluster 

# 2) deploy v1 and service
kubectl apply -f nginx-v1.yaml
kubectl rollout status deployment/my-nginx
kubectl apply -f nginx-service.yaml

# test
curl -sS http://localhost:30080 | head -n 5

# 3) upgrade to v2
kubectl apply -f nginx-v2.yaml
kubectl rollout status deployment/my-nginx
kubectl rollout history deployment/my-nginx

# 4) broken v3
kubectl apply -f nginx-v3-broken.yaml
kubectl rollout status deployment/my-nginx || true
kubectl get pods -l app=nginx

# 5) rollback to previous
kubectl rollout undo deployment/my-nginx
kubectl rollout status deployment/my-nginx
curl -sS http://localhost:30080 | head -n 5

# cleanup when done
# kubectl delete -f nginx-v1.yaml
# kubectl delete -f nginx-service.yaml
# kind delete cluster --name kind-demo
