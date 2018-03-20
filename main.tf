provider "scaleway" {}

data "scaleway_image" "ubuntu" {
  architecture = "arm64"
  name         = "Ubuntu Xenial"
}

module "master" {
  source   = "modules/master"
  image_id = "${data.scaleway_image.ubuntu.id}"
}

output "master-ip" {
  value = "${module.master.public_ip}"
}

module "minion-1" {
  source       = "modules/minion"
  name         = "k8s-minion-1"
  image_id     = "${data.scaleway_image.ubuntu.id}"
  join_command = "${module.master.join_command}"
}

module "minion-2" {
  source       = "modules/minion"
  name         = "k8s-minion-2"
  image_id     = "${data.scaleway_image.ubuntu.id}"
  join_command = "${module.master.join_command}"
}

module "minion-3" {
  source       = "modules/minion"
  name         = "k8s-minion-3"
  image_id     = "${data.scaleway_image.ubuntu.id}"
  join_command = "${module.master.join_command}"
}
