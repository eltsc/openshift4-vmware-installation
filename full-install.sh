#! /bin/bash

set -x

read -e -p "Enter Your cluster name: " -i "vmopen" cluster

cluster="${cluster:-vmopen}"

oc login -u kubeadmin https://api.$cluster.bynet.dev:6443

oc create -f sc-slave.yaml

read -e -p "Enter Your postgresql Namespace: " -i "postgresql" postgresNamespace

postgresNamespace="${postgresNamespace:-postgresql}"

oc new-project $postgresNamespace


oc create secret generic pg-su --from-literal=username='postgres' --from-literal=password='password'

oc create secret generic pg-repl --from-literal=username='repl_username' --from-literal=password='repl_password'

helm upgrade --install $postgresNamespace ./stolon  

for i in 0 1 2
do
COMMAND=$(kubectl get pod $postgresNamespace-stolon-keeper-$i -o 'jsonpath={.status.phase}')
until [[ $COMMAND == "Running" ]]
do
    COMMAND=$(kubectl get pod $postgresNamespace-stolon-keeper-$i -o 'jsonpath={.status.phase}')
    echo "waiting for pod $postgresNamespace-stolon-keeper-$i to be ready"
    sleep 2.5
done
echo "pod $postgresNamespace-stolon-keeper-$i ready"
done

PROXYIP=$(kubectl get services | fgrep proxy | grep -oP '\d+\.\d+\.\d+\.\d+')

# oc exec -it $postgresNamespace-stolon-keeper-0 -- psql --host $PROXYIP --port 5432 --username postgres -W -c 'CREATE DATABASE gitlabhq_production OWNER postgres;' 

read -e -p "Enter Your gitlab Namespace: " -i "gitlab" gitlabNamespace

gitlabNamespace="${gitlabNamespace:-gitlab}"

oc new-project $gitlabNamespace

oc adm policy add-scc-to-group anyuid system:authenticated

oc create -f secret-post-git.yaml

helm upgrade --install gitlab ./gitlab --set nginx-ingress.enabled=false  --set global.hosts.domain=apps.vmopen.bynet.dev --set global.ingress.configureCertmanager=false --set certmanager.install=false --set gitlab-runner.install=false --set postgresql.install=false --set global.psql.host=$PROXYIP --set global.psql.password.secret=postgres-pass --set global.psql.password.key=pass --set global.psql.username=postgres --set redis-ha.image.tag=fd4f46221e7361d5736a1039cb429f042d28478b --set redis.enabled=false

# helm upgrade --install gitlab ./gitlab --set nginx-ingress.enabled=false  --set global.hosts.domain=apps.$cluster.bynet.dev --set global.ingress.configureCertmanager=false --set certmanager.install=false --set gitlab-runner.install=false

if test -f "./gitlab.pem"; then
	rm ./gitlab.pem
fi

kubectl get secret gitlab-wildcard-tls-ca -ojsonpath='{.data.cfssl_ca}' | base64 --decode > gitlab.pem

read -e -p "Enter Your jenkins Namespace: " -i "jenkins" jenkinsNamespace

jenkinsNamespace="${jenkinsNamespace:-jenkins}"

oc new-project $jenkinsNamespace

oc adm policy add-scc-to-group anyuid system:authenticated
oc adm policy add-scc-to-user privileged system:serviceaccount:$jenkinsNamespace:default
oc adm policy add-cluster-role-to-user edit system:serviceaccount:$jenkinsNamespace:default

oc create -f ./jenkins/pvc.yaml 

oc create configmap ca-pemstore --from-file=./gitlab.pem -n $jenkinsNamespace

oc apply -f ./jenkins/jenkinsDeployment.yaml

oc expose dc jenkins

oc apply -f ./jenkins/jenkinsRoute.yaml

oc apply -f ./jenkins/ClusterRole.yaml
oc adm policy add-cluster-role-to-user CreatePods system:serviceaccount:$jenkinsNamespace:default

apt-get install ca-certificates
cp gitlab.pem /usr/local/share/ca-certificates/gitlab.crt
update-ca-certificates
