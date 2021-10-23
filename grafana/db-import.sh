#!/bin/bash

mysql --host="$1" --port=3306 --user="$2" --password="$3" grafana < /tmp/grafana.sql