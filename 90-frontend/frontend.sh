#!/bin/bash

COMPONENT=$1
ENV=$2
dnf install -y ansible  
ansible-pull -i localhost, -U  https://github.com/cekharchandra-devops/14-expense-anisble-roles-tf.git main.yaml -e component=$COMPONENT -e environment=$ENV

# ansible-pull -i localhost, -c local -d /tmp/expense-apps-dev -U  https://github.com/cekharchandra-devops/14-expense-anisble-roles-tf.git main.yaml 

