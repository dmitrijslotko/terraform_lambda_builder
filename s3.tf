
resource "aws_s3_bucket_object" "lambda_source" {
  count  = local.s3_source ? 0 : 1
  bucket = var.bucket
  key    = var.key
  source = data.archive_file.archive.output_path
  etag   = filebase64sha256(data.archive_file.archive.output_path)
}

data "archive_file" "archive" {
  type        = "zip"
  source_dir  = var.filename
  output_path = "${path.module}/.build/${var.function_name}.zip"
}
