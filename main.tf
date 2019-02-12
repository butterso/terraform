/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["us-east-1a", "us-east-1b"]
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "key" {
  key_name   = "production_key"
  public_key = "${file("production_key.pub")}"
}

module "networking" {
  source               = "./modules/networking"
  environment          = "production"
  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]
  region               = "${var.region}"
  availability_zones   = "${local.production_availability_zones}"
  key_name             = "production_key"
}

module "rds" {
  source            = "./modules/rds"
  environment       = "production"
  allocated_storage = "20"
  database_name     = "${var.database_name}"
  database_username = "${var.database_username}"
  database_password = "${var.database_password}"
  subnet_ids        = ["${module.networking.private_subnets_id}"]
  vpc_id            = "${module.networking.vpc_id}"
  instance_class    = "db.t2.micro"
}

module "ecs" {
  source             = "./modules/ecs"
  environment        = "production"
  vpc_id             = "${module.networking.vpc_id}"
  availability_zones = "${local.production_availability_zones}"
  subnets_ids        = ["${module.networking.private_subnets_id}"]
  public_subnet_ids  = ["${module.networking.public_subnets_id}"]

  security_groups_ids = [
    "${module.networking.security_groups_ids}",
    "${module.rds.db_access_sg_id}",
  ]

  database_host     = "${module.rds.rds_address}"
  database_username = "${var.database_username}"
  database_password = "${var.database_password}"
  database_name     = "${var.database_name}"
  django_secret_key = "${var.django_secret_key}"
  plaid_client_id   = "${var.plaid_client_id}"
  plaid_public_key  = "${var.plaid_public_key}"
  plaid_secret      = "${var.plaid_secret}"
  plaid_env         = "${var.plaid_env}"
}

module "route53" {
  source      = "./modules/route53"
  environment = "production"
  dns_name    = "${module.ecs.alb_dns_name}"
  zone_id     = "${module.ecs.alb_zone_id}"
}