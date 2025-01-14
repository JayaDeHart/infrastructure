#create s3 bucket for state
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "todo-backend-state"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}


resource "aws_dynamodb_table" "statelock" {
    name="state-lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"


    attribute {
      name = "LockID"
      type = "S"
    }
}


#create dynamo to create state lock

