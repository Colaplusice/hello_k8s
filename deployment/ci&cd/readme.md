# CI/CD use minikube

- 清空环境 minikube stop; minikube delete; sudo rm -rf ~/.minikube; sudo rm -rf ~/.kub
- 启动 minikube start --memory 4000 --cpus 2 --kubernetes-version v1.6.0
- 安装插件 minikube addons enable heapster; minikube addons enable ingress
- kubectl get pods --all-namespaces 检查是否安装成功
- minikube service kubernetes-dashboard --namespace kube-system  打开dashboard
- kubectl run nginx --image nginx --port 80 部署nginx
- kubectl run nginx --image nginx --port 80 启动一个deployment
- kubectl expose deployment nginx --type NodePort --port 80 启动一个service 来对外暴露出去
- minikube service nginx 启动
- kubectl delete service nginx
- kubectl delete deployment nginx 删除

用applay来创建服务
kubectl apply -f manifests/registry.yaml
发布
kubectl rollout status deployments/registry
启动服务
minikube service registry-ui​​

修改下index.html文件，然后本地打镜像，上传到自己的镜像服务器
docker build -t 127.0.0.1:30400/hello-kenzan:latest -f  applications/hello-kenzan/Dockerfile applications/hello-kenzan

建造代理镜像
 docker build -t socat-registry -f applications/socat/Dockerfile applications/socat

运行'镜像服务器'容器在本地30400端口
docker stop socat-registry; docker rm socat-registry; 
 docker run -d -e "REG_IP=`minikube ip`" -e "REG_PORT=30400" --name socat-registry -p 30400:5000 socat-registry

将要发布的镜像推送到 镜像服务器
 docker push 127.0.0.1:30400/hello-kenzan:latest

然后打开k8s的那个链接，就能看到刚才推上去的容器了

停止代理
 docker stop socat-registry

将hello-kenzan image放上去后，根据镜像来创建ci/cd

kubectl apply -f applications/hello-kenzan/k8s/manual-deployment.yaml
minikube service hello-kenzan
kubectl delete service hello-kenzan
kubectl delete deployment hello-kenzan
minikube stop

## 第二步

build jenkins
docker build -t 127.0.0.1:30400/jenkins:latest -f applications/jenkins/Dockerfile applications/jenkins

push上去
docker push 127.0.0.1:30400/jenkins:latest

k8s运行 发布出去
kubectl apply -f manifests/jenkins.yaml; kubectl rollout status deployment/jenkins

看下有没有成功
kubectl get pods

jenkins属于和k8s要交互的，所以权限是k8s admin

minikube service jenkins

会提示密码在
/var/jenkins_home/secrets/initialAdminPassword 应该在pods中

显示密码
kubectl exec -it `kubectl get pods --selector=app=jenkins --output=jsonpath={.items..metadata.name}` cat /var/jenkins_home/secrets/initialAdminPassword 
新建账户: 账号 icecola 密码：jianpan
新建item  选择pipeline 设置git 设置

minikube service hello-kenzan 运行kenzan服务器
然后 git commit 和git push
 