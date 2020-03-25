#! /bin/bash

set -x

namespace="jenkins"

oc new-project $namespace

oc adm policy add-scc-to-user privileged system:serviceaccount:$namespace:default
oc adm policy add-cluster-role-to-user edit system:serviceaccount:$namespace:default

#oc create -f pv.yaml 

oc create -f pvc.yaml 

oc apply -f jenkinsDeployment.yaml

oc expose dc jenkins

oc apply -f jenkinsRoute.yaml

oc apply -f ClusterRole.yaml
oc adm policy add-cluster-role-to-user CreatePods system:serviceaccount:$namespace:default
