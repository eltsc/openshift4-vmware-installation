#! /bin/bash

#read -e -p "Enter Your Name:" -i "postgresql" postgresNamespace

#postgresNamespace="${postgresNamespace:-posgresql}"

#echo $postgresNamespace

#if test -f "./rem"; then
#	rm rem
#fi

echo hey
#while true; do
#    read -p "Do you wish to install this program?" yn
 #   case $yn in
  #      [Yy]* ) echo "install" ; break;;
   #     [Nn]* ) echo "not install";break;;
    #    * ) echo "Please answer yes or no.";;
   # esac
#done
#echo hey2

# echo "Do you wish to install this program?"
# select yn in "Yes" "No"; do
#     case $yn in
#         Yes) echo "yes"; break;;
#         No) echo "no";break;;
#     esac
# done
# echo hey2
# read -e -p "Enter Your cluster name: " -i "vmopen" cluster

# cluster="${cluster:-vmopen}"

# oc login -u kubeadmin https://api.$cluster.bynet.dev:6443

# oc create -f sc-slave.yaml

read -e -p "Enter Your postgresql Namespace: " -i "postgresql" postgresNamespace

postgresNamespace="${postgresNamespace:-postgresql}"

# oc new-project $postgresNamespace

# oc create secret generic pg-su --from-literal=username='postgres' --from-literal=password='password'

# oc create secret generic pg-repl --from-literal=username='repl_username' --from-literal=password='repl_password'

# helm upgrade --install $postgresNamespace ./stolon  

COMMAND=$(kubectl get pod $postgresNamespace-stolon-keeper-0 -o 'jsonpath={.status.phase}')
until [[ $COMMAND == "Running" ]]
do
    echo 'waiting for pod to be ready'
    sleep 2
done

PROXYIP=$(kubectl get services | fgrep proxy | grep -oP '\d+\.\d+\.\d+\.\d+')

oc exec -it $postgresNamespace-stolon-keeper-0 -- psql --host $PROXYIP --port 5432 --username postgres -W -c 'CREATE DATABASE gitlabhq_production OWNER postgres;' 

