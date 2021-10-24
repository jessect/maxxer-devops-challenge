#!/bin/bash
API_ADDRESS="$(kubectl get svc --all-namespaces | grep LoadBalancer | grep myapp |awk {'print $5'})"
GRAFANA_ADDRESS="$(kubectl get svc --all-namespaces | grep LoadBalancer | grep grafana | awk {'print $5'})"
API_HOME=$(curl -s http://$API_ADDRESS)
RUNNING_INSTANCES="$(kubectl get pods  --all-namespaces | grep myapp | grep -i running | wc -l)"

clear

echo -e "\n$API_HOME\n"
echo -e "$RUNNING_INSTANCES running instances\n"

echo -e "myApp access: \n"
echo "http://$API_ADDRESS"
echo "http://$API_ADDRESS/health"
echo "http://$API_ADDRESS/metrics"
echo "http://$API_ADDRESS/create"
echo "http://$API_ADDRESS/get"
echo "http://$API_ADDRESS/get/{id}"
echo "http://$API_ADDRESS/update/{id}"
echo "http://$API_ADDRESS/delete/{id}"

echo -e "\nGrafama access: \n"
echo "http://$GRAFANA_ADDRESS"
echo -e "\nUser: admin"
echo -e "Pass: R3sLtzASpQNk8TfRsTBvMxa25B58bCWjadyKK0Ko"

echo -e "\nPods running:\n"

kubectl get pods -l app.kubernetes.io/name=myapp --all-namespaces

echo -e "\n$(date)\n"
