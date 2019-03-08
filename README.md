# Rancher Chart

本Chart不支持LetsEncrypt、cert-manager提供的证书，需要手动通过Secret导入证书。

## 自签名证书或者权威认证证书

如果有权威认证证书，需要把

## 部署架构

### 内部ingress域名访问

通过集群内置的ingress服务，使用七层域名转发来访问rancher server，请求流量转发到rancher server容器的`80`端口。

```bash
git clone -b v2.1.7 https://github.com/xiaoluhong/server-chart.git

helm install  --kubeconfig=kube_config_xxx.yml \
  --name rancher \
  --namespace cattle-system \
  --set hostname=<修改为自己的域名> \
  --set ingress.tls.source=secret \
  server-chart/rancher
```

>注意:

1. 通过`--kubeconfig=`指定kubectl配置文件;
1. 如果要把外部负载均衡器作为ssl终止，需添加参数: `--set tls=external`;
1. 如果使用自签名证书，需要设置参数: `--set privateCA=true`;

### 主机NodePort访问(主机IP+端口)

有的场景需要使用IP去直接访问rancher server, 这个时候rancher server容器作为ssl终止，请求流量转发到rancher server容器的`443`端口。

```bash
git clone -b v2.1.7 https://github.com/xiaoluhong/server-chart.git

helm install  --kubeconfig=kube_config_xxx.yml \
  --name rancher \
  --namespace cattle-system \
  --set service.type=NodePort \
  --set service.ports.nodePort=30303  server-chart/rancher
```

>注意:

1. 通过`--kubeconfig=`指定kubectl配置文件;
1. 如果要把外部负载均衡器作为ssl终止，需添加参数: `--set tls=external`;
1. 如果使用自签名证书，需要设置参数: `--set privateCA=true`;

### 外部七层负载均衡器+主机NodePort方式运行(禁用内部ingress转发)

外部有七层代理的时候，可以以nodeport方式运行Rancher。外部七层负载均衡器`443`端口代理到Rancher的nodeport端口,请求流量转发到rancher server容器的80端口。

## Chart Versioning Notes

```bash
NAME                      CHART VERSION    APP VERSION    DESCRIPTION
rancher-stable/rancher    2018.3.1           v2.1.7      Install Rancher Server to manage Kubernetes clusters acro...
```

{% mermaid %}
graph TD;
  A-->B;
  A-->C;
  B-->D;
  C-->D;
{% endmermaid %}