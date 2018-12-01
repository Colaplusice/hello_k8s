## Assign Memory Resources to Containers and Pods

- minikube addons enable metrics-server
- kubectl get apiservices
- kubectl create namespace mem-example
kubectl create -f memory-resource-limit.yaml

kubectl get pod memory-demo --output=yaml --namespace=mem-example
查看内存
kubectl top pod memory-demo --namespace=mem-example
删除pods
kubectl delete pod memory-demo --namespace=mem-example





