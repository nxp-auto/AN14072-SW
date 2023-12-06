# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2023 NXP

#!/bin/bash

rootca_cer="../ecc/tls_rootca.cer"
client_cer="../ecc/tls_client.cer"
# client_key="../ecc/tls_client_key.pem"
client_key="pkcs11:token=NXP-HSE-Token;object=HSE-ECCPRIV-TLS;type=private"

if [ $# -ne 2 ]; then
    echo "Usage: tlsSeClient.sh <ip-address> <ECDH|ECDHE|ECDHE_256>"
	echo "Provide the ip address of the server you want to connect to as first argument!"
	echo "Additional argument enforces ciphersuite"
	echo "   Eg. tlsSeClient.sh 192.168.1.42 ECDHE"
	echo "   Eg. tlsSeClient.sh 192.168.1.60 ECDHE"	
	exit 1
fi 

sel_cipher="none"
if [ "${2}" == "ECDHE" ]; then		
	sel_cipher="ECDHE-ECDSA-AES128-SHA"
	echo "Request cipher ${sel_cipher}"
elif [ "${2}" == "ECDH" ]; then		
	sel_cipher="ECDH-ECDSA-AES128-SHA"
	echo "Request cipher ${sel_cipher}"
elif [ "${2}" == "ECDHE_256" ]; then		
	sel_cipher="ECDHE-ECDSA-AES128-SHA256"
	echo "Request cipher ${sel_cipher}"
else
	echo "Usage: tlsSeClient.sh <ip-address> <ECDH|ECDHE|ECDHE_256>"
	exit 4
fi

echo "Connecting to ${1}:8080... requesting cipher ${sel_cipher}"

cmd="openssl s_client -engine pkcs11 -keyform engine -connect ${1}:8080 -tls1_2 \
	-CAfile ${rootca_cer} \
	-cert ${client_cer} -key "${client_key}" \
	-cipher ${sel_cipher} -state -msg"
echo "${cmd}"
${cmd}
