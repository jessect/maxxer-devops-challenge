#!/bin/bash
cd ../
DB_USER=$(terraform output -raw 'database_admin_user')
DB_PASS=$(terraform output -raw 'database_master_password')
DB_HOST=$(terraform output -raw 'database_host')
DB_NAME=$(terraform output -raw 'database_name')

kubectl apply -f tools/mysql-client.yaml > /dev/null

showProcs(){
    kubectl exec mysql-client -- bash -c "mysql \
    --host=$DB_HOST \
    --port=3306 \
    --user=$DB_USER \
    --password=$DB_PASS \
    -e 'select Id,User,Host,db,Command from information_schema.processlist;'"
}

countPeople(){
    kubectl exec mysql-client -- bash -c "mysql \
    --host=$DB_HOST \
    --port=3306 \
    --user=$DB_USER \
    --password=$DB_PASS \
    -e 'select count(*) from jaylabs.people;'"
}

showPeople(){
    kubectl exec mysql-client -- bash -c "mysql \
    --host=$DB_HOST \
    --port=3306 \
    --user=$DB_USER \
    --password=$DB_PASS \
    -e 'select * from jaylabs.people;'"
}

echo -e "\nselect Id,User,Host,db,Command from information_schema.processlist;\n"
showProcs 2> /dev/null | column -t 

echo -e "\nselect count(*) from $DB_NAME.people \n"
countPeople 2> /dev/null | column -t

echo -e "\nselect * from $DB_NAME.people\n"
showPeople 2> /dev/null | column -t

kubectl delete -f tools/mysql-client.yaml > /dev/null