#! /bin/bash

set -x

oc new-project confluence

oc adm policy add-scc-to-group anyuid system:authenticated
oc adm policy add-scc-to-user privileged system:serviceaccount:confluence:default

oc create configmap ca-pemstore --from-file=../../bos.pem

oc create -f ./pvc.yaml 

oc apply -f ./Deployment-gcp.yaml

oc apply -f service.yaml

oc apply -f ./route.yaml

