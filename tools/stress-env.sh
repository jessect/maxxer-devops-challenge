#!/bin/bash
APP_LB="$(kubectl get svc --all-namespaces | grep LoadBalancer | grep myapp |awk {'print $5'})"

count=1
while [ $count -lt 1000 ]
do
  string1="$(echo $RANDOM | md5sum | head -c 10; echo;)"
  string2="$(echo $RANDOM | md5sum | head -c 10; echo;)"
  id="$(echo $RANDOM)"
  curl -s -k --location --request POST "http://$APP_LB/create" \
  --header 'Content-Type: application/json' \
  --data-raw '{
      "id": '$id',
      "firstName": '\"$string1\"',
      "lastName": '\"$string2\"'
  }' | jq .
    count=`expr $count + 1`
done