## Создание NAT-instance
resource "yandex_compute_instance" "nat-instance" {
  name     = var.nat-instance-name
  hostname = "${var.nat-instance-name}.${var.domain}"
  zone     = var.default_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = var.nat_instance_id
      name        = "root-${var.nat-instance-name}"
      type        = "network-nvme"
      size        = "50"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_public.id
    ip_address = var.nat-instance-ip
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.public_key}"
  }
}

## Создание Public_VM
resource "yandex_compute_instance" "public-vm" {
  name     = var.public-vm-name
  hostname = "${var.public-vm-name}.${var.domain}"
  zone     = var.default_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = var.vm_private_and_public
      name        = "root-${var.public-vm-name}"
      type        = "network-nvme"
      size        = "50"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.public_key}"
  }
}

## Создание Private_VM
resource "yandex_compute_instance" "private-vm" {
  name     = var.private-vm-name
  hostname = "${var.private-vm-name}.${var.domain}"
  zone     = var.default_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = var.vm_private_and_public
      name        = "root-${var.private-vm-name}"
      type        = "network-nvme"
      size        = "50"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_private.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${var.public_key}"
  }
}
