output "instance_ip" {
  value = aws_instance.sbbs_server.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_ed25519 ec2-user@${aws_instance.sbbs_server.public_ip}"
}

output "ansible_command" {
  value       = "cd ../ansible && ./run_playbook.sh"
  description = "Command to run the Ansible playbook with S3 inventory"
}

output "s3_inventory_location" {
  value       = "s3://synchronet-bbs/ansible-sbbs/hosts.ini"
  description = "S3 location of the Ansible inventory file"
}
