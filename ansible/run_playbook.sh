#!/bin/bash

echo "Downloading inventory from S3..."
aws s3 cp s3://synchronet-bbs/ansible-sbbs/hosts.ini ./hosts.ini

if [ $? -eq 0 ]; then
    echo "Running Ansible playbook..."
    ansible-playbook -i hosts.ini install_synchronet.yaml
else
    echo "Failed to download inventory from S3"
    exit 1
fi

# Clean up local copy
rm -f hosts.ini
