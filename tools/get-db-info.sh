#!/bin/bash
cd ../
DB_USER=$(terraform output -raw 'database_admin_user')
DB_PASS=$(terraform output -raw 'database_master_password')
DB_HOST=$(terraform output -raw 'database_host')
DB_NAME=$(terraform output -raw 'database_name')

kubectl apply -f tools/mysql-client.yaml > /dev/null

showProcs(){
    echo -e "select * from information_schema.processlist;\n"
    kubectl exec mysql-client -- bash -c "mysql \
    --host=$DB_HOST \
    --port=3306 \
    --user=$DB_USER \
    --password=$DB_PASS \
    -e 'select * from information_schema.processlist;'"
}

countPeople(){
    echo -e "\nselect count(*) from $DB_NAME.people \n"
    kubectl exec mysql-client -- bash -c "mysql \
    --host=$DB_HOST \
    --port=3306 \
    --user=$DB_USER \
    --password=$DB_PASS \
    -e 'select count(*) from jaylabs.people;'"
}

showPeople(){
    echo -e "select * from $DB_NAME.people\n"
    kubectl exec mysql-client -- bash -c "mysql \
    --host=$DB_HOST \
    --port=3306 \
    --user=$DB_USER \
    --password=$DB_PASS \
    -e 'select * from jaylabs.people;'"
}

showProcs 2> /dev/null
countPeople 2> /dev/null
echo -e "\n"
showPeople 2> /dev/null

kubectl delete -f tools/mysql-client.yaml > /dev/null