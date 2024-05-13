resource "yandex_vpc_network" "network-1" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "subnet_public" {
  name           = "public"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = var.cidr_subnet_public
}

resource "yandex_vpc_subnet" "subnet_private" {
  name           = "private"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.network-1.id
  route_table_id = yandex_vpc_route_table.route_table.id
  v4_cidr_blocks = var.cidr_subnet_private
}

resource "yandex_vpc_route_table" "route_table" {
  network_id     = yandex_vpc_network.network-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = var.nat_instance_ip
  }
}
