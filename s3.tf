
resource "aws_s3_bucket_object" "lambda_source" {
  count  = var.s3_source_config == null ? 0 : 1
  bucket = var.s3_source_config.bucket
  key    = var.s3_source_config.key
  source = data.archive_file.archive.output_path
  etag   = filebase64sha256(data.archive_file.archive.output_path)
}

data "archive_file" "archive" {
  type        = "zip"
  source_dir  = var.config.filename
  output_path = "${path.module}/.build/${var.config.function_name}.zip"
}
