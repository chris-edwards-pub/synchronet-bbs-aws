# Data Lifecycle Manager (DLM) for automated EBS snapshots
resource "aws_dlm_lifecycle_policy" "sbbs_backup" {
  description        = "SBBS EBS snapshot lifecycle policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types   = ["VOLUME"]
    target_tags = {
      Name = "${var.project_name}-sbbs-server"
    }

    # Daily snapshots - keep 7
    schedule {
      name = "Daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["03:00"]
      }

      retain_rule {
        count = 7
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
        Type           = "Daily"
      }

      copy_tags = true
    }

    # Weekly snapshots - keep 1 (taken on Sunday)
    schedule {
      name = "Weekly snapshots"

      create_rule {
        cron_expression = "cron(0 3 ? * SUN *)"
      }

      retain_rule {
        count = 1
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
        Type           = "Weekly"
      }

      copy_tags = true
    }

    # Monthly snapshots - keep 12 (taken on 1st of month)
    schedule {
      name = "Monthly snapshots"

      create_rule {
        cron_expression = "cron(0 3 1 * ? *)"
      }

      retain_rule {
        count = 12
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
        Type           = "Monthly"
      }

      copy_tags = true
    }
  }

  tags = {
    Name        = "${var.project_name}-dlm-policy"
    Environment = var.environment
  }
}

# IAM role for DLM
resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "${var.project_name}-dlm-lifecycle-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dlm.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-dlm-role"
    Environment = var.environment
  }
}

# IAM policy for DLM
resource "aws_iam_role_policy" "dlm_lifecycle_policy" {
  name = "${var.project_name}-dlm-lifecycle-policy"
  role = aws_iam_role.dlm_lifecycle_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:CreateTags",
          "ec2:DeleteSnapshot",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes",
          "ec2:ModifySnapshotAttribute"
        ]
        Resource = "*"
      }
    ]
  })
}
