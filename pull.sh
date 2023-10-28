#!/usr/bin/env bash

url='https://github.com/appkins-org/ansible-maas.git' # URL of the playbook repository
checkout='main'                                       # branch/tag/commit to checkout
directory='/var/projects/ansible-pull-update'         # directory to checkout repository to
logfile='/var/log/ansible-pull-update.log'            # where to put the logs

sudo ansible-pull -o -C ${checkout} -d ${directory} -i ${directory}/inventory/main.yaml -e "tfc_agent_token=$TFC_AGENT_TOKEN" -U ${url} site.yaml # \
#  2>&1 | sudo tee -a ${logfile}

sudo ansible-playbook -i /var/projects/ansible-pull-update/inventory/main.yaml /var/projects/ansible-pull-update/site.yaml -e "tfc_agent_token="${TFC_AGENT_TOKEN:-}""
