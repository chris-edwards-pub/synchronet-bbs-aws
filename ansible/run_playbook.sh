#!/bin/bash

# Pass all command-line arguments to ansible-playbook
# Usage examples:
#   ./run_playbook.sh --tags websocket
#   ./run_playbook.sh --skip-tags ssl
#   ./run_playbook.sh --limit synchronet
#   ./run_playbook.sh --check --diff
#   ./run_playbook.sh --tags websocket --verbose

echo "Downloading inventory from S3..."
aws s3 cp s3://synchronet-bbs/ansible-sbbs/hosts.ini ./hosts.ini

if [ $? -eq 0 ]; then
    echo "Running Ansible playbook with arguments: $*"
    ansible-playbook -i hosts.ini install_synchronet.yaml "$@"
else
    echo "Failed to download inventory from S3"
    exit 1
fi

# Clean up local copy
rm -f hosts.ini
