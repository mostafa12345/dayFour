terraform {
  backend "s3" {
    bucket         = "testasdawf4115154"
    key            = "terraform.tfstate" 
    region         = "us-east-1"
  
  }
}
