#! /bin/bash

set -x

# oc new-project jira

oc adm policy add-scc-to-group anyuid system:authenticated
oc adm policy add-scc-to-user privileged system:serviceaccount:jira:default

oc create configmap ca-pemstore --from-file=../../bos.pem

# oc create -f ./pvc.yaml 

oc apply -f ./deployment.yaml

oc apply -f service.yaml

oc apply -f ./route.yaml

oc exec -it -n postgresql postgresql-stolon-keeper-0  -- psql --host 172.30.15.149 --port 5432 --username postgres -W -c 'CREATE DATABASE jira OWNER postgres;'