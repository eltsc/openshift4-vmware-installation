#! /bin/bash

set -x

oc new-project confluence

oc adm policy add-scc-to-group anyuid system:authenticated
oc adm policy add-scc-to-user privileged system:serviceaccount:confluence:default

oc create -f ./pvc.yaml 

oc apply -f ./Deployment.yaml

oc apply -f service.yaml

oc apply -f ./route.yaml

