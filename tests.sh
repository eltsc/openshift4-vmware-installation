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

echo "Do you wish to install this program?"
select yn in "Yes" "No"; do
    case $yn in
        Yes) echo "yes"; break;;
        No) echo "no";break;;
    esac
done
echo hey2
