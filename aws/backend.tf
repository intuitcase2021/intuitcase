terraform {
  backend "s3" {
    bucket = "intuit-demo-remote-backend"
    key    = "remotedemo.tfstate"
    region = "us-east-1"
  }
}