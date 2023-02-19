resource "aws_efs_file_system" "efs_for_lambda" {
  count = var.efs_config == null ? 0 : 1
  tags = {
    Name = try("${var.config.function_name}_efs", var.efs_config.name)
  }
}

resource "aws_efs_access_point" "access_point_for_lambda" {
  count = var.efs_config == null ? 0 : 1

  file_system_id = aws_efs_file_system.efs_for_lambda[0].id

  root_directory {
    path = "/lambda"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "777"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }

  tags = {
    Name = try("${var.config.function_name}_efs", var.efs_config.name)
  }
}

resource "aws_efs_mount_target" "mount_target" {
  count           = try(length(var.efs_config.subnet_ids), 0)
  file_system_id  = aws_efs_file_system.efs_for_lambda[0].id
  subnet_id       = var.efs_config.subnet_ids[count.index]
  security_groups = var.efs_config.security_group_ids
}
