variable "image_id" {}
variable "type" {}

resource "scaleway_ip" "k8s-master-ip" {
  server = "${scaleway_server.k8s-master.id}"
}

resource "scaleway_server" "k8s-master" {
  name  = "k8s-master"
  image = "${var.image_id}"
  type  = "${var.type}"
}

resource "null_resource" "master-provisioner" {
  connection {
    host = "${scaleway_ip.k8s-master-ip.ip}"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../../scripts/install-kubeadm.sh",
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../../scripts/kubeadm-init.sh",
    ]
  }
}

resource "null_resource" "master-network" {
  connection {
    host = "${scaleway_ip.k8s-master-ip.ip}"
  }

  depends_on = ["null_resource.master-provisioner"]

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../../scripts/install-network.sh",
    ]
  }
}

resource "null_resource" "download-config" {
  depends_on = ["null_resource.master-provisioner"]

  provisioner "local-exec" {
    command = "${path.module}/../../scripts/download-config.sh ${scaleway_ip.k8s-master-ip.ip} ${path.root}"
  }
}

resource "null_resource" "remove-old-join" {
  provisioner "local-exec" {
    command = "rm -f ${path.module}/../../.secret/join_command"
  }
}

data "external" "join_command" {
  depends_on = ["null_resource.master-provisioner", "null_resource.remove-old-join"]
  program    = ["${path.module}/../../scripts/join-command.sh", "${scaleway_ip.k8s-master-ip.ip}"]
}

output "public_ip" {
  value = "${scaleway_ip.k8s-master-ip.ip}"
}

output "join_command" {
  value = "${data.external.join_command.result["join"]}"
}
