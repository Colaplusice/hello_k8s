kubectl create -f https://k8s.io/examples/pods/storage/redis.yaml
kubectl get pod redis --watch
kubectl exec -it redis -- /bin/bash
