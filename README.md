# Rancher Chart

本Chart基于 https://github.com/rancher/server-chart 修改，不支持LetsEncrypt、cert-manager提供证书，需手动通过Secret导入证书(导入方法见脚本结尾), 默认开启审计日志功能.
## 自签名证书或权威认证证书

仓库根目录有一键创建自签名证书脚本，会自动创建`cacerts.pem`、`tls.key`、`tls.crt`。如果使用权威认证证书，需要重命名crt和key为`tls.crt`和`tls.key`。

## 部署架构

### 内部ingress域名访问

通过集群内安装的ingress服务，使用七层域名转发来访问rancher server，请求流量将转发到rancher server容器的`80`端口。

```bash
git clone -b v2.1.7 https://github.com/xiaoluhong/server-chart.git

helm install  --kubeconfig=kube_config_xxx.yml \
  --name rancher \
  --namespace cattle-system \
  --set hostname=<修改为自己的域名> \
  --set service.type=ClusterIP \
  --set ingress.tls.source=secret \
  server-chart/rancher
```

>注意:

1. 通过`--kubeconfig=`指定kubectl配置文件;
1. 如果要把外部负载均衡器作为ssl终止，需添加参数: `--set tls=external`;
1. 如果使用自签名证书，需要设置参数: `--set privateCA=true`;

### 主机NodePort访问(主机IP+端口)

有的场景需要使用IP去直接访问rancher server, 因为ingress默认不支持IP访问，所以这里禁用ingress。通过NodePort把rancher server容器端口映射到宿主机的端口上，这个时候rancher server容器作为ssl终止，请求流量转发到rancher server容器的`443`端口。

```bash
git clone -b v2.1.7 https://github.com/xiaoluhong/server-chart.git

helm install  --kubeconfig=kube_config_xxx.yml \
  --name rancher \
  --namespace cattle-system \
  --set service.type=NodePort \
  --set ingress.tls.source=secret \
  --set service.ports.nodePort=30303  \
  server-chart/rancher
```

>注意:

1. 通过`--kubeconfig=`指定kubectl配置文件;
1. 如果要把外部负载均衡器作为ssl终止，需添加参数: `--set tls=external`;
1. 如果使用自签名证书，需要设置参数: `--set privateCA=true`;

### 外部七层负载均衡器+主机NodePort方式运行(禁用内部ingress转发)

有的场景，外部有七层负载均衡器作为ssl终止，一般使用是把负载均衡器的`443`端口代理到内部服务的`80`端口上。为了保证网络转发性能，这里禁用了内置的ingress服务，以NodePort方式把rancher server容器`80`端口映射到宿主机端口上。外部七层负载均衡器`443`端口直接代理到Rancher的NodePort端口,请求流量转发到rancher server容器的`80`端口。

```bash
git clone -b v2.1.7 https://github.com/xiaoluhong/server-chart.git

helm install  --kubeconfig=kube_config_xxx.yml \
  --name rancher \
  --namespace cattle-system \
  --set service.type=NodePort \
  --set tls=external  \
  --set service.ports.nodePort=30303  \
  server-chart/rancher
```
>注意:

1. 通过`--kubeconfig=`指定kubectl配置文件;
1. 如果使用自签名证书，需要设置参数: `--set privateCA=true`;


## Chart Versioning Notes

```bash
NAME                      CHART VERSION    APP VERSION    DESCRIPTION
rancher-stable/rancher    2018.3.1           v2.1.7      Install Rancher Server to manage Kubernetes clusters acro...
```
