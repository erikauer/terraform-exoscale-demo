resource "cloudstack_ssh_keypair" "kubernetes-cluster-ssh-key" {
  name       = "kubernetes-cluster-ssh-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

# Create a security group
resource "cloudstack_security_group" "kubernetes-cluster-security-group" {
  name        = "kubernetes-cluster-security-group"
  description = "Allow access to kubernetes cluster"
}

# Create a security group
resource "cloudstack_security_group" "etcd-security-group" {
  name        = "etcd-security-group"
  description = "Allow access to etcd machines"
}

resource "cloudstack_security_group_rule" "kubernetes-cluster-security-group-rules" {
  security_group_id = "${cloudstack_security_group.kubernetes-cluster-security-group.id}"

  rule {
    cidr_list = ["0.0.0.0/0"]
    protocol  = "tcp"
    ports     = ["22", "443"]
  }
}

resource "cloudstack_security_group_rule" "etcd-security-group-rules" {
  security_group_id = "${cloudstack_security_group.etcd-security-group.id}"

  rule {
    cidr_list = ["0.0.0.0/0"]
    protocol  = "tcp"
    ports     = ["2379"]
  }
}

# Create ETCD Single Node (for production you should consider a Multi-Node installation)
resource "cloudstack_instance" "kubernetes-etcd-node01" {
  name               = "kubernetes-etcd-node01"
  template           = "cc2b7707-3e72-47a6-b881-914eac9f8caf"
  service_offering   = "Micro"
  root_disk_size     = 50
  zone               = "ch-gva-2"
  security_group_ids = ["${cloudstack_security_group.kubernetes-cluster-security-group.id}", "${cloudstack_security_group.etcd-security-group.id}"]
  keypair            = "${cloudstack_ssh_keypair.kubernetes-cluster-ssh-key.id}"
}

# Create Kubernetes-master
resource "cloudstack_instance" "kubernetes-master-node01" {
  name               = "kubernetes-master-node01"
  template           = "cc2b7707-3e72-47a6-b881-914eac9f8caf"
  service_offering   = "Micro"
  root_disk_size     = 50
  zone               = "ch-gva-2"
  security_group_ids = ["${cloudstack_security_group.kubernetes-cluster-security-group.id}"]
  keypair            = "${cloudstack_ssh_keypair.kubernetes-cluster-ssh-key.id}"
}

# Create Kubernetes-worker nodes
resource "cloudstack_instance" "kubernetes-worker-nodes" {
  name               = "kubernetes-worker-node0${count.index}"
  template           = "cc2b7707-3e72-47a6-b881-914eac9f8caf"
  service_offering   = "Micro"
  root_disk_size     = 50
  zone               = "ch-gva-2"
  security_group_ids = ["${cloudstack_security_group.kubernetes-cluster-security-group.id}"]
  keypair            = "${cloudstack_ssh_keypair.kubernetes-cluster-ssh-key.id}"
  count              = 10
}
