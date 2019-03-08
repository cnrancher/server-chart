# rancher

## NodePort方式运行

外部有七层代理的时候，可以以nodeport方式运行Rancher。外部七层负载均衡器443端口代理到Rancher的nodeport端口(80端口)上。

```bash
git clone https://github.com/xiaoluhong/server-chart.git

helm install  --kubeconfig=kube_config_xxx.yml \
  --name rancher \
  --namespace cattle-system \
  --set tls=external  \
  --set ingress.enabled=false \
  --set service.type=NodePort \
  --set service.ports.nodePort=30303  server-chart/rancher
```
>通过`--kubeconfig=`指定kubectl配置文件


## Chart Versioning Notes



```
NAME                      CHART VERSION    APP VERSION    DESCRIPTION                                                 
rancher-stable/rancher    2018.3.1           v2.1.7      Install Rancher Server to manage Kubernetes clusters acro...
```
