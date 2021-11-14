resource "aws_efs_file_system" "efs_for_lambda" {
  count = var.add_efs == true ? 1 : 0
  tags = {
    Name = "${var.function_name}_efs"
  }
}

resource "aws_efs_access_point" "access_point_for_lambda" {
  count = var.add_efs == true ? 1 : 0

  file_system_id = aws_efs_file_system.efs_for_lambda[count.index].id

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
    Name = "${var.function_name}"
  }
}

resource "aws_efs_mount_target" "mount_target" {
  for_each        = var.add_efs == true ? toset(var.subnet_ids) : []
  file_system_id  = aws_efs_file_system.efs_for_lambda[0].id
  subnet_id       = each.value
  security_groups = var.security_group_ids
}
