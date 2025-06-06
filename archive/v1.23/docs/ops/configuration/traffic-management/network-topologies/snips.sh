#!/bin/bash
# shellcheck disable=SC2034,SC2153,SC2155,SC2164

# Copyright Istio Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

####################################################################################################
# WARNING: THIS IS AN AUTO-GENERATED FILE, DO NOT EDIT. PLEASE MODIFY THE ORIGINAL MARKDOWN FILE:
#          docs/ops/configuration/traffic-management/network-topologies/index.md
####################################################################################################
source "content/en/boilerplates/snips/gateway-api-support.sh"

snip_install_num_trusted_proxies_two() {
cat <<EOF > topology.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  meshConfig:
    defaultConfig:
      gatewayTopology:
        numTrustedProxies: 2
EOF
istioctl install --set values.pilot.env.PILOT_ENABLE_CONFIG_DISTRIBUTION_TRACKING=true -f topology.yaml
}

snip_create_httpbin_namespace() {
kubectl create namespace httpbin
}

! IFS=$'\n' read -r -d '' snip_create_httpbin_namespace_out <<\ENDSNIP
namespace/httpbin created
ENDSNIP

snip_label_httpbin_namespace() {
kubectl label --overwrite namespace httpbin istio-injection=enabled
}

! IFS=$'\n' read -r -d '' snip_label_httpbin_namespace_out <<\ENDSNIP
namespace/httpbin labeled
ENDSNIP

snip_apply_httpbin() {
kubectl apply -n httpbin -f samples/httpbin/httpbin.yaml
}

snip_deploy_httpbin_gateway() {
kubectl apply -n httpbin -f samples/httpbin/httpbin-gateway.yaml
}

snip_deploy_httpbin_k8s_gateway() {
kubectl apply -n httpbin -f samples/httpbin/gateway-api/httpbin-gateway.yaml
kubectl wait --for=condition=programmed gtw -n httpbin httpbin-gateway
}

snip_export_gateway_url() {
export GATEWAY_URL=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
}

snip_export_k8s_gateway_url() {
export GATEWAY_URL=$(kubectl get gateways.gateway.networking.k8s.io httpbin-gateway -n httpbin -ojsonpath='{.status.addresses[0].value}')
}

snip_curl_xff_headers() {
curl -s -H 'X-Forwarded-For: 56.5.6.7, 72.9.5.6, 98.1.2.3' "$GATEWAY_URL/get?show_env=true" | jq '.headers["X-Forwarded-For"][0]'
}

! IFS=$'\n' read -r -d '' snip_curl_xff_headers_out <<\ENDSNIP
  "56.5.6.7, 72.9.5.6, 98.1.2.3,10.244.0.1"
ENDSNIP

! IFS=$'\n' read -r -d '' snip_proxy_protocol_2 <<\ENDSNIP
metadata:
  annotations:
    "proxy.istio.io/config": '{"gatewayTopology" : { "proxyProtocol": {} }}'
ENDSNIP
