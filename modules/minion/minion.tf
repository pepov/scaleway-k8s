variable "image_id" {}
variable "join_command" {}
variable "name" {}
variable "type" {}

resource "scaleway_ip" "k8s-minion-ip" {
  server = "${scaleway_server.k8s-minion.id}"
}

resource "scaleway_server" "k8s-minion" {
  name  = "${var.name}"
  image = "${var.image_id}"
  type  = "${var.type}"
}

resource "null_resource" "minion-provisioner" {
  connection {
    host = "${scaleway_ip.k8s-minion-ip.ip}"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../../scripts/install-kubeadm.sh",
    ]
  }
}

resource "null_resource" "kubeadm-join" {
  connection {
    host = "${scaleway_ip.k8s-minion-ip.ip}"
  }

  provisioner "remote-exec" {
    inline = "${var.join_command}"
  }
}

output "public_ip" {
  value = "${scaleway_ip.k8s-minion-ip.ip}"
}
