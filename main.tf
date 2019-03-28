provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
  region     = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
  }
}

module "vpc" {
  source = "./modules/vpc/"
  cidr_block = "${var.vpc_cidr_block}"
  cluster_name = "${var.aws_cluster_name}"
}

module "security_group" {
  source = "./security_group/"
  vpc_id = "${module.vpc_network.vpc_id}"
}
