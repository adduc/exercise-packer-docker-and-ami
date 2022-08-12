packer {
  required_plugins {
    docker = {
      version = ">= 1.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_type" {
  type = string
}

source "docker" "example" {
  image       = "ubuntu:22.04"
  export_path = "data/image.tar"
}

source "amazon-ebs" "ubuntu" {
  ami_name                    = "Example AMI"
  instance_type               = var.instance_type
  region                      = var.region
  ssh_username                = "ubuntu"
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  ssh_interface               = "public_ip"
  associate_public_ip_address = true

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
}

build {
  sources = [
    "source.docker.example",
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    destination = "/tmp/provision.sh"
    content     = <<EOF
      #!/bin/bash

      set -eEuo pipefail

      if [ "$EUID" -ne 0 ]; then
        sudo bash "$0" "$@"
        exit "$?"
      fi

      touch /srv/a
      echo "Hi!"
    EOF
  }

  # Create directories before we provision files
  provisioner "shell" {
    inline = [
      "chmod +x /tmp/provision.sh",
      "bash /tmp/provision.sh"
    ]
  }

  post-processor "docker-import" {
    only       = ["docker.example"]
    repository = "exercises/packer-docker-example"
    tag        = "latest"
  }
}
