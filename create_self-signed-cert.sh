#!/bin/bash -e

# *为必改项

# 国家名(2个字母的代号)
C=CN
# 省
ST=rancher
# 市
L=rancher
# 公司名
O=rancher
# 组织或部门名
OU=rancher
# * 服务器FQDN或颁发者名(更换为你自己的域名)
CN=rancher.com
# 证书有效期
DATE=${DATE:-3650}
# 邮箱地址
EMAILADDRESS=support@rancher.com
# 扩展信任IP(一般ssl证书只信任域名的访问请求，有时候需要使用ip去访问server，那么需要给ssl证书添加扩展IP)
IP='IP:172.16.155.35, IP:172.16.155.36, DNS:www.rancher.com'

echo "1. 生成CA证书"
openssl req -newkey rsa:4096 -nodes -sha256 -keyout cakey.pem -x509 -days ${DATE} -out cacerts.pem \
-subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=ca.${CN}/emailAddress=${EMAILADDRESS}"

echo "2. 生成证书签名请求文件"
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ${CN}.key -out  ${CN}.csr \
-subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=${CN}/emailAddress=${EMAILADDRESS}"

echo "3. 创建服务证书"
echo "3.1. 添加扩展IP"
echo "subjectAltName = ${IP}" > extfile.cnf
echo "3.2. 生成服务证书"
openssl x509 -req -days ${DATE} -in ${CN}.csr -CA cacerts.pem -CAkey cakey.pem -CAcreateserial -extfile extfile.cnf -out  ${CN}.crt

echo "4. 重命名服务证书"
cp ${CN}.key tls.key
cp ${CN}.crt tls.crt

# 把生成的证书作为密文导入K8S
## *指定K8S配置文件路径

kubeconfig=

kubectl --kubeconfig=$kubeconfig create namespace cattle-system
kubectl --kubeconfig=$kubeconfig -n cattle-system create secret tls tls-rancher-ingress --cert=./tls.crt --key=./tls.key
kubectl --kubeconfig=$kubeconfig -n cattle-system create secret generic tls-ca --from-file=cacerts.pem

## 执行以下命令删除密文

kubectl -n cattle-system  delete  secrets  tls-rancher-ingress  tls-ca
