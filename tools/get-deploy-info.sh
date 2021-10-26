#!/bin/bash
API_ADDRESS="$(kubectl get svc --all-namespaces | grep LoadBalancer | grep myapp |awk {'print $5'})"
GRAFANA_ADDRESS="$(kubectl get svc --all-namespaces | grep LoadBalancer | grep grafana | awk {'print $5'})"
API_HOME=$(curl -s http://$API_ADDRESS)
POD_DETAILS="$(kubectl get pods -l app.kubernetes.io/name=myapp --all-namespaces -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{"\t"}{@.status.podIP}{"\t"}{range .spec.containers[*]}{.image}{""}{end}{end}' |\
sort)"

clear

echo -e "\n$API_HOME"
echo -e "\nPOD Details \n $POD_DETAILS\n"

echo -e "myApp Access: \n"
echo "http://$API_ADDRESS"
echo "http://$API_ADDRESS/health"
echo "http://$API_ADDRESS/metrics"
echo "http://$API_ADDRESS/get"

echo -e "\nGrafana Access: \n"
echo "http://$GRAFANA_ADDRESS"
echo -e "\nUser: admin"
echo -e "Pass: R3sLtzASpQNk8TfRsTBvMxa25B58bCWjadyKK0Ko"

echo -e "\nPods running:\n"

kubectl get pods -l app.kubernetes.io/name=myapp --all-namespaces

echo -e "\n$(date)\n"


