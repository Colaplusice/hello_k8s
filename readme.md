# k8s

brew install kubernetes-cli

## 查看k8s的配置文件

kubectl cluster-info

## bash的安装位置

  /usr/local/etc/bash_completion.d

## 配置补全信息

if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi

## minikube  totorials

brew cask install minikube
判断docker状态
docker images
开始集群
minikube start --vm-driver=hyperkit
kubectl config use-context minikube  切换上下文

kubectl cluster-info 查看集群信息
minikube dashboard   在浏览器打开

## 创建dockerfile

使用minikube内的镜像
切换使用minikub docker的命令:
eval $(minikube docker-env)
切换回本地docker
eval $(minikube docker-env -u)

### 可选的vm-driver

- virtualbox
- vmwarefusion
- kvm2
- hyperkit
  
### 安装 hyperkit

```
curl -Lo docker-machine-driver-hyperkit https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-hyperkit \
&& chmod +x docker-machine-driver-hyperkit \
&& sudo cp docker-machine-driver-hyperkit /usr/local/bin/ \
&& rm docker-machine-driver-hyperkit \
&& sudo chown root:wheel /usr/local/bin/docker-machine-driver-hyperkit \
&& sudo chmod u+s /usr/local/bin/docker-machine-driver-hyperkit
```

## Pod 的概念

pod 是一个或者多个容器的集合，多个命名空间的联合: pid命名空间， 网络命名空间，ipc命名空间，uts命名空间。磁盘是Pod级的。pod是短暂的存在。
pod 是kbs集群的原子单位，每个pod内的容器们共享 ip信息和节点空间。有着同样的调度和上下文。

### 创建pods

run将被废弃，未来将使用create
kubectl run hello-world --replicas=5 --labels="run=load-balancer-example" --image=gcr.io/google-samples/node-hello:1.0  --port=8080
pods的生命周期:

- pending Pod的定义正确，提交到master,但包含的镜像内容还未完全创建，处于Master对pod的调度过程
- ContainerCreating：Pod pod的调度完成，处于容器的创建过程，通常在拉取镜像的过程中。
- Running：Pod中所有的容器都已经成功创建，并且成功运行起来。
- Success 成功运行所有的pods,且不会被重启
- failed pod中所有的容器都结束，但至少一个容器以失败状态结束。
  
### 删除Pod

删除deployemnt即可。
kubectl delete deploy $DEPLOY_NAME

## node的概念

node是pod运行的真正主机，可以是物理机，虚拟机。 为了管理Pod,每个Node上至少要运行container runtime  每个Node 归master调度。node 上必须有的东西 。

- Kubelet   负责和master节点进行通讯。
- 容器

## service

service 是一个抽象上的概念，定义了一系列pods和一个连接这些pods的策略。通过yaml来定义。 service中的pod通常通过labelselector来决定。  即使pods有ip。如果没有service的话，pods的ip是不会对外开放的。service可以以不同的方式对外开放通过指定ServiceSpec中的type， serviceSpec中可以指定这些参数。

- ClusterIp 集群ip，在集群上expose一个内部的ip。可以让service只在集群内部开放。
- NodePort 所有被选择的Node都expose在一个相同的端口上，通过网络地址转换协议。让service可连接到集群外部使用<NodeIP>:<NodePort>,是一个集群ip的超集。
- LoadBalancer 创建一个外部的loadBalancer在当前的云上，为服务指定一个external Ip，是nodePort的超集。
- ExternalName   开放服务通过一个任意的name(通过serviceSpec中的externalName指定),需要 v1.7以上的kube-dns

### labelselector

如果服务不指定selector的话，可以手动的指定service在一个给定的节点上。还有一个原因是你在用 type:externalName

想法:
service是以Pods为原子的单位的，可能横跨多个node

使用label的好处，label是为service为单位的

- 指定 不同的环境对象 test,developemnt, production
- 鉴别一个object通过tag
- 任意api都可以通过label来调用
- label是service运行的基础

### expose service的command

- kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080 service/kubernetes-bootcamp exposed     (得到一个新的service 名称为kubernetes-bootcamp)
- 得到 service的 port 信息 (kubectl get services/kubernetes-bootcamp -o go-template='{{(index.spec.ports 0).nodePort}}')
- kubectl label pod $POD_NAME app=v1      为pod打标签
- kubectl get pods -l app=v1  通过label 得到pod的信息
- kubectl delete service -l run=kubernetes-bootcamp   删除服务
- kubectl run 来创建一个
容器的创建更多的来自docker registry，不应该从本地镜像构造

- kubectl get deployments  得到pods部署的信息
- kubectl get pod 得到部署的信息
- kubectl get events 集群的envent信息
- kubectl config view 得到配置信息
- kubectl config delete-cluster
- kubectl config delete-context
- kubectl rename-context
- 
- kubectl expose deployment hello-node --type=LoadBalancer -—name=name  根据pod创建外部服务，同时制定name
- kubectl get services  得到服务信息
- kubectl get services -l <label_name>
- kubectl logs <POD-NAME>  查看pods的日志
- kubectl get po,svc -n kube-system 得到pod和service的信息
- kubectl proxy  建立一个个和集群的连接。可以通过api来拿到集群的信息
- kubectl get  pods list sources  列出资源
- kubectl describe pods 一个资源的详细信息
- kubectl logs  打印出一个pod中container的信息  可选参数 -f
- kubectl exec  执行命令 在一个pod中的容器上
- kubectl exec $POD_NAME env 得到pod的环境变量
- kubectl exec -ti $pod_name bash  进入pods的terminal
- kubectl get replicasets 得到复制本的信息
- kcuc douya-it   切换集群上下文
- kubectl get pods —-output=wide    得到更详细的信息
- kubectl delete pods redis  删除pods
- kubectl delete secret mysql-pass  删除密码







## 外部ip
LoadBalancer Ingress 来设置外部ip

## namespace
namespace 是对一组资源和对象的抽象集合，pods,services,replication controllers,deployments 都属于某一个namespace,默认为default

Minikube使得服务可用
- minikube service hello-node

## 更新

- docker build -t hello-node:v2 .   (重新打镜像)
- kubectl set image deployment/hello-node hello-node=hello-node:v2  （更新）
- minikube service hello-node  运行服务
- minikube service wordpress --url  运行服务以及url


## Addone
- minikube addons list   查看插件的List
- minikube addons enable heapster 激活一个插件
- minikube addons open heapster    打开插件


## raplicationController
	通过模板来创建Pods
   复活pod,管理副本，负责副本的创建和运行。
 
## kubernetes proxy
负责为pod创建代理服务，从k8s api获取所有的服务， 从service到pods的请求转发，实现了 虚拟网络，
service通过 proxy 进行转发。





## deployments
为pods以及raplicationset提供一个声明式的定义方法，应用场景有
- 定义deployment
应该是把pod部署的结果
想当于一个pod的模板

## 删除
- kubectl delete service hello-node  删除service
- kubectl delete deployment hello-node 删除部署 删除所有的pods
- docker rmi hello-node:v1 hello-node:v2 -f 删除docker 镜像
- minikube stop 停止minikube
- minikube delete 删除minikube

## 顺序
创建集群———> 创建应用的docker image  —————> 部署镜像————>创建服务


## 集群
- kubectl cluster-info
- kubectl get nodes
- kubectl run kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1--port=808  从官方镜像运行
- 


## scale
多个instance的使用
- kubectl scale deployments/kubernets-bootcamp —replicas=4     部署4个Instance
- kubectl scale deployments/kubernets-bootcamp —replicas=2    由4个下降到两个



## 滚动更新  update
- kubectl rollout status deployments/kubernetes-bootcamp  检查是否更新成功  后面接Pod的label
- rollback 取消更新  kebectl rollout undo deployments/kubernetes-bootcamp
- 






## 配权限
openssl genrsa -out icecola.key 2048

openssl req -new -key icecola.key -out douya-fanjialiang.csr -subj "/CN=jialiang.fan"


 k port-forward phpmyadmin-viewer 8080:80




## configmap
- 根据本地文件创建configmap
kubectl create configmap example-redis-config --from-file=redis-config

- 检查config map是否生成
kubectl get configmap example-redis-config -o yaml

### 通过yaml来创建服务
在kind 中声明，有deployment,service,pod
设置挂载点，使用path将redis-config 配置到redis.conf
      - key: redis-config
        path: redis.conf

kubectl create -f /pods/config/redis-config.yaml

### 创建php guidebook

- kubectl apply -f redis-master-deployment.yaml   根据本地文件创造pods
- kubectl apply -f redis-slave-deployment.yaml 创造slave节点
- kubectl apply -f redis-master-service.yaml  创造service 
- kubectl apply -f redis-slave-service.yaml  创建slave服务
- kubectl apply -f frontend-deployment.yaml  创建前端pods
- kubectl apply -f frontend-service.yaml  前端service
- kubectl delete deployment -l app=redis
- kubectl delete service -l app=redis
- kubectl delete deployment -l app=guestbook
- kubectl delete service -l app=guestbook
- kubectl get statefulset web  得到有状态的web
- kubectl get secrets 得到秘钥信息
- kubectl get pvc 得到持久化数据信息
- kubectl delete pvc -l app=wordpress 删除pvc数据

## ReplicaSet

下一代复本控制器， ReplicaSet支持集合selector,(version 1.0,version 2.0)

## stateful app
配置wordpress
创建service
kubectl create -f web.yaml
kubectl get pods -w -l app=nginx

### 创建secret
kubectl create secret generic mysql-pass --from-literal=password=newpass

创建service
kubectl create -f https://k8s.io/examples/application/wordpress/mysql-deployment.yaml

- minikube service wordpress --url
- kubectl delete deployment -l app=wordpress  删除部署
- kubectl delete service -l app=wordpress 删除服务

## volumes

volume是一个简单的所在主机的目录
PersistentVolume 持久化数据储存
PersistentVolumeClaim  pvc
通过yaml来挂载 在spec中指定volumeMounts

```
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: redis-storage
      mountPath: /data/redis
  volumes:
  - name: redis-storage
    emptyDir: {}

```

## secret

解决密码，秘钥等私密问题
kubernetes.io/dockerconfigjson： 用来存储私有docker registry的认证信息
Opaque：base64  编码格式的  用来储存密码，秘钥
Service Account： 用来访问Kubernetes API，由Kubernetes自动创建，并且会自动挂载到Pod，的/run/secrets/kubernetes.io/serviceaccount目录中

## 问题解决

The connection to the server <server-name:port> was refused - did you specify the right host or port?  没有安装minikube

# docker——machine安装

下载文件
https://github.com/kubernetes/minikube/releases/download/v0.24.1/docker-machine-driver-hyperkit
chmod +x docker-machine-driver-hyperkit
sudo mv docker-machine-driver-hyperkit /usr/local/bin/
sudo chown root:wheel /usr/local/bin/docker-machine-driver-hyperkit
sudo chmod u+s /usr/local/bin/docker-machine-driver-hyperkit

国内镜像
minikube start --registry-mirror=https://registry.docker-cn.com