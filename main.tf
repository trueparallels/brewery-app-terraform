provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "trueparallels"

    workspaces {
      name = "brewery-app-prod"
    }
  }
}

resource "aws_s3_bucket" "brewery-app-kyle" {
  bucket = "brewery-app-kyle"
  acl = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_dynamodb_table" "brewery-app-favorites" {
  name = "brewery-app-favorites-prod"
  billing_mode = "PROVISIONED"

  read_capacity = 5
  write_capacity = 5

  hash_key = "BreweryId"

  attribute {
    name = "BreweryId"
    type = "N"
  }
}

resource "aws_vpc" "brewery-app-vpc" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Name = "brewery-app-vpc"
  }
}

module "ecs" {
  source = "./modules/ecs"
  ecr_repo_url = module.ecr.ecr_repo_url
  brewery_app_subnet_id = module.network.brewery_app_subnet_id
}

module "ecr" {
  source = "./modules/ecr"
}

module "network" {
  source = "./modules/network"
  brewery_app_vpc_id = "${aws_vpc.brewery-app-vpc.id}"
}