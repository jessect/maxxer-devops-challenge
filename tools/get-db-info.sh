#!/bin/bash
DB_USER=$(terraform output -raw 'database_admin_user')
DB_PASS=$(terraform output -raw 'database_master_password')
DB_HOST=$(terraform output -raw 'database_host')
DB_NAME=$(terraform output -raw 'database_name')

clear

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: mysql
spec:
  containers:
  - name: mysql
    image: mysql:8 
    args:
    - sleep
    - "1000000"
EOF

countPeople(){
kubectl exec mysql -- bash -c "mysql \
    --host=$DB_HOST \
    --port=3306 \
    --user=$DB_USER \
    --password=$DB_PASS \
    -e 'select count(*) from jaylabs.people;'"
}

showPeople(){
kubectl exec mysql -- bash -c "mysql \
    --host=$DB_HOST \
    --port=3306 \
    --user=$DB_USER \
    --password=$DB_PASS \
    -e 'select * from jaylabs.people ORDER by id DESC;'"
}

echo -e "\n"
countPeople 2> /dev/null

echo -e "\n"
showPeople 2> /dev/null
echo -e "\n"