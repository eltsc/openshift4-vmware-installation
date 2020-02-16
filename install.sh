#! /bin/bash

set -x

oc login -u kubeadmin https://api.vmopen.bynet.dev:6443

oc new-project gitlab

oc adm policy add-scc-to-group anyuid system:authenticated

helm upgrade --install gitlab ./gitlab --set nginx-ingress.enabled=false  --set global.hosts.domain=apps.vmopen.bynet.dev --set global.ingress.configureCertmanager=false --set certmanager.install=false --set gitlab-runner.install=false

kubectl get secret gitlab-wildcard-tls-ca -ojsonpath='{.data.cfssl_ca}' | base64 --decode > gitlab.pem

namespace="jenkins"

oc new-project $namespace

oc adm policy add-scc-to-group anyuid system:authenticated
oc adm policy add-scc-to-user privileged system:serviceaccount:$namespace:default
oc adm policy add-cluster-role-to-user edit system:serviceaccount:$namespace:default

oc create -f ./jenkins/pvc.yaml 

oc create configmap ca-pemstore --from-file=./gitlab.pem -n $namespace

oc apply -f ./jenkins/jenkinsDeployment.yaml

oc expose dc jenkins

oc apply -f ./jenkins/jenkinsRoute.yaml

oc apply -f ./jenkins/ClusterRole.yaml
oc adm policy add-cluster-role-to-user CreatePods system:serviceaccount:$namespace:default

apt-get install ca-certificates
cp gitlab.pem /usr/local/share/ca-certificates/gitlab.crt
update-ca-certificates
