#!/bin/bash

Component=$1
Environment=$2
dnf install ansible -y
ansible-pull -i localhost, -U https://github.com/cekharchandra-devops/14-expense-anisble-roles-tf.git main.yaml -e component=$Component -e environment=$Environment