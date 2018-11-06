# rancher

Chart for installing Rancher Server to manage Kubernetes clusters across providers.

## Chart Documentation

* [Installing Rancher with Helm](https://rancher.com/docs/rancher/v2.x/en/installation/ha/)
* [Chart Options](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/chart-options/)

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

## Rancher Resources

* Rancher Documentation: https://rancher.com/docs
* GitHub: https://github.com/rancher/rancher
* DockerHub Images: https://hub.docker.com/r/rancher/rancher

## Issues

Please file issues in [rancher/rancher](https://github.com/rancher/rancher/issues/new?labels=area/server-chart)

## Chart Versioning Notes

Up until the initial helm chart release for v2.1.0, the helm chart version matched the Rancher version (i.e `appVersion`).

Since there are times where the helm chart will require changes without any changes to the Rancher version, we have moved to a `yyyy.mm.<build-number>` helm chart version.

Run `helm search rancher` to view which Rancher version will be launched for the specific helm chart version.  

```
NAME                      CHART VERSION    APP VERSION    DESCRIPTION                                                 
rancher-stable/rancher    2018.10.1            v2.1.0      Install Rancher Server to manage Kubernetes clusters acro...
```
