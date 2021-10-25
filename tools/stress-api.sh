#!/bin/bash
API_ADDRESS="$(kubectl get svc --all-namespaces | grep LoadBalancer | grep myapp |awk {'print $5'})"
COUNT=1
COUNT_MAX="$1"

if [ -z "$COUNT_MAX" ]
then
   COUNT_MAX="1000"
fi

stress(){
while [ $COUNT -lt $COUNT_MAX ]
do
  string1="$(echo $RANDOM | md5sum | head -c 10; echo;)"
  string2="$(echo $RANDOM | md5sum | head -c 10; echo;)"
  random_id="$(echo $RANDOM)"
  curl -s -k --location --request POST "http://$API_ADDRESS/create" \
  --header 'Content-Type: application/json' \
  --data-raw '{
      "id": '$COUNT',
      "firstName": '\"$string1\"',
      "lastName": '\"$string2\"'
  }' | jq .
  curl -s -k --location --request POST "http://$API_ADDRESS/create" \
  --header 'Content-Type: application/json' \
  --data-raw '{
      "id": '$random_id',
      "firstName": '\"$string1\"',
      "lastName": '\"$string2\"'
  }' > /dev/null
  COUNT=`expr $COUNT + 1`
done
}

echo -e "\n Starting API stress\n"
stress