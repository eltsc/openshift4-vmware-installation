#! /bin/bash

set -x

oc create -f ./pvc.yaml 

oc apply -f ./Deployment-gcp.yaml

