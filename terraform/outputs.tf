output "instance_ip" {
  value = aws_eip.sbbs_eip.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_ed25519 ec2-user@${aws_eip.sbbs_eip.public_ip}"
}

output "ansible_command" {
  value       = "cd ../ansible && ./run_playbook.sh"
  description = "Command to run the Ansible playbook with S3 inventory"
}

output "s3_inventory_location" {
  value       = "s3://synchronet-bbs/ansible-sbbs/hosts.ini"
  description = "S3 location of the Ansible inventory file"
}

output "backup_policy_arn" {
  value       = aws_dlm_lifecycle_policy.sbbs_backup.arn
  description = "ARN of the DLM backup policy"
}
