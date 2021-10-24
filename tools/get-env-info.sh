#!/bin/bash
APP_LB="$(kubectl get svc --all-namespaces | grep LoadBalancer | grep myapp |awk {'print $5'})"
GRAFANA_LB="$(kubectl get svc --all-namespaces | grep LoadBalancer | grep grafana | awk {'print $5'})"
APP_URL=$(curl -s http://$APP_LB)
APP_RUNNING_INSTANCES="$(kubectl get pods  --all-namespaces | grep myapp | grep -i running | wc -l)"

clear

echo -e "\n$APP_URL\n"
echo -e "$APP_RUNNING_INSTANCES running instances\n"

echo -e "myApp access: \n"
echo "http://$APP_LB"
echo "http://$APP_LB/health"
echo "http://$APP_LB/metrics"
echo "http://$APP_LB/create"
echo "http://$APP_LB/get"
echo "http://$APP_LB/get/{id}"
echo "http://$APP_LB/update/{id}"
echo "http://$APP_LB/delete/{id}"

echo -e "\nGrafama access: \n"
echo "http://$GRAFANA_LB"
echo -e "\nUser: admin"
echo -e "Pass: R3sLtzASpQNk8TfRsTBvMxa25B58bCWjadyKK0Ko"

echo -e "\nPods running:\n"

kubectl get pods -l app.kubernetes.io/name=myapp --all-namespaces

echo -e "\n$(date)\n"
