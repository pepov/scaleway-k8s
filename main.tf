provider "scaleway" {}

locals {
  arch = "x86_64"
  type = "VC1S"
}

data "scaleway_image" "ubuntu" {
  architecture = "${local.arch}"
  name         = "Ubuntu Xenial"
}

module "master" {
  source   = "modules/master"
  image_id = "${data.scaleway_image.ubuntu.id}"
  type     = "${local.type}"
}

resource "null_resource" "helm-init" {
  depends_on = ["module.master"]

  provisioner "local-exec" {
    command = "${path.module}/scripts/helm-init.sh"
  }
}

module "minion-1" {
  source       = "modules/minion"
  name         = "k8s-minion-1"
  image_id     = "${data.scaleway_image.ubuntu.id}"
  join_command = "${module.master.join_command}"
  type         = "${local.type}"
}

module "minion-2" {
  source       = "modules/minion"
  name         = "k8s-minion-2"
  image_id     = "${data.scaleway_image.ubuntu.id}"
  join_command = "${module.master.join_command}"
  type         = "${local.type}"
}

module "minion-3" {
  source       = "modules/minion"
  name         = "k8s-minion-3"
  image_id     = "${data.scaleway_image.ubuntu.id}"
  join_command = "${module.master.join_command}"
  type         = "${local.type}"
}

output "master-ip" {
  value = "${module.master.public_ip}"
}

output "minion-ips" {
  value = ["${module.minion-1.public_ip}", "${module.minion-2.public_ip}", "${module.minion-3.public_ip}"]
}
