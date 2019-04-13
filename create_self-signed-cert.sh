#!/bin/bash -e

CMDOPTS="$*"
for OPTS in $CMDOPTS;
do
    key=$(echo ${OPTS} | awk -F"=" '{print $1}' )
    value=$(echo ${OPTS} | awk -F"=" '{print $2}' )
    case "$key" in
        --domain) CN=$value ;;
        --trusted-ip) SSL_IP=$value ;;
        --trusted-domain) SSL_DNS=$value ;;
        --ssl-size) SSL_SIZE=$value ;;
        --ssl-date) SSL_DATE=$value ;;
        --ca-date) CA_DATE=$value ;;
    esac
done

# 国家名(2个字母的代号)
C=CN

# 配置文件
SSL_CONFIG='openssl.cnf'

echo "----------------------------"
echo "| 生成 SSL Cert |"
echo "----------------------------"
echo

export CN=${CN:-localhost}

export CA_KEY=${CA_KEY-"cakey.pem"}
export CA_CERT=${CA_CERT-"cacerts.pem"}
export CA_SUBJECT=ca-$CN
export CA_EXPIRE=${CA_DATE:-3650}

export SSL_CONFIG=${SSL_CONFIG}
export SSL_KEY=$CN.key
export SSL_CSR=$CN.csr
export SSL_CERT=$CN.crt
export SSL_EXPIRE=${SSL_DATE}

export SSL_SUBJECT=${CN}
export SSL_DNS=${SSL_DNS}
export SSL_IP=${SSL_IP}

export SSL_SIZE=${SSL_SIZE:-2048}

# 证书有效期
export SSL_DATE=${SSL_DATE:-3650}

echo "--> 生成自签名ssl证书"

if [[ -e ./${CA_KEY} ]]; then
    echo "====> 备份"${CA_KEY}"为"${CA_KEY}"-bak" \
    && mv ${CA_KEY} "${CA_KEY}"-bak \
    && openssl genrsa -out ${CA_KEY} ${SSL_SIZE} > /dev/null
else
    echo "====> 生成新的CA私钥 ${CA_KEY}"
    openssl genrsa -out ${CA_KEY} ${SSL_SIZE} > /dev/null
fi

if [[ -e ./${CA_CERT} ]]; then
    echo "====> 备份"${CA_CERT}"为"${CA_CERT}"-bak" \
    && mv ${CA_CERT} "${CA_CERT}"-bak \
    && openssl req -x509 -sha256 -new -nodes -key ${CA_KEY} -days ${CA_EXPIRE} \
    -out ${CA_CERT} -subj "/CN=${CA_SUBJECT}" > /dev/null || exit 1
else
    echo "====> 生成新的CA证书 ${CA_CERT}"
    openssl req -x509 -sha256 -new -nodes -key ${CA_KEY} \
    -days ${CA_EXPIRE} -out ${CA_CERT} -subj "/CN=${CA_SUBJECT}" > /dev/null || exit 1
fi

echo "====> 生成新的配置文件 ${SSL_CONFIG}"
cat > ${SSL_CONFIG} <<EOM
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
EOM

if [[ -n ${SSL_DNS} || -n ${SSL_IP} ]]; then
    cat >> ${SSL_CONFIG} <<EOM
subjectAltName = @alt_names
[alt_names]
EOM
    IFS=","
    dns=(${SSL_DNS})
    dns+=(${SSL_SUBJECT})
    for i in "${!dns[@]}"; do
      echo DNS.$((i+1)) = ${dns[$i]} >> ${SSL_CONFIG}
    done

    if [[ -n ${SSL_IP} ]]; then
        ip=(${SSL_IP})
        for i in "${!ip[@]}"; do
          echo IP.$((i+1)) = ${ip[$i]} >> ${SSL_CONFIG}
        done
    fi
fi

echo "====> 生成新的SSL KEY ${SSL_KEY}"
openssl genrsa -out ${SSL_KEY} ${SSL_SIZE} > /dev/null || exit 1

echo "====> 生成新的SSL CSR ${SSL_CSR}"
openssl req -sha256 -new -key ${SSL_KEY} -out ${SSL_CSR} \
    -subj "/CN=${SSL_SUBJECT}" -config ${SSL_CONFIG} > /dev/null || exit 1

echo "====> 生成新的SSL CERT ${SSL_CERT}"
openssl x509 -sha256 -req -in ${SSL_CSR} -CA ${CA_CERT} \
    -CAkey ${CA_KEY} -CAcreateserial -out ${SSL_CERT} \
    -days ${SSL_EXPIRE} -extensions v3_req \
    -extfile ${SSL_CONFIG} > /dev/null || exit 1

echo "====> 证书制作完成"
echo
echo "====> 以YAML格式输出结果"
echo "---"
echo "ca_key: |"
cat $CA_KEY | sed 's/^/  /'
echo
echo "ca_cert: |"
cat $CA_CERT | sed 's/^/  /'
echo
echo "ssl_key: |"
cat $SSL_KEY | sed 's/^/  /'
echo
echo "ssl_csr: |"
cat $SSL_CSR | sed 's/^/  /'
echo
echo "ssl_cert: |"
cat $SSL_CERT | sed 's/^/  /'
echo

echo "====> 附加CA证书到Cert文件中"
cat ${CA_CERT} >> ${SSL_CERT}
echo "ssl_cert: |"
cat $SSL_CERT | sed 's/^/  /'
echo

echo "4. 重命名服务证书"
echo "cp ${CN}.key tls.key"
cp ${CN}.key tls.key
echo "cp ${CN}.crt tls.crt"
cp ${CN}.crt tls.crt