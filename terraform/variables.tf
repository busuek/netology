###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "vpc_name" {
  type        = string
  default     = "network1"
  description = "VPC network&subnet name"
}

variable "nat_instance_id" {
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1" 
}

variable "vm_private_and_public" {
  type        = string
  default     = "fd8aptfr48hdvlflumbe" 
}

variable "cidr_subnet_public" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "cidr_subnet_private" {
  type        = list(string)
  default     = ["192.168.20.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "domain" {
  default = "netology.cloud"
}

variable "nat-instance-name" {
  default = "nat-instance-vm1"
}

variable "nat-instance-ip" {
  default = "192.168.10.254"
}

variable "public-vm-name" {
  default = "public-vm1"
}

variable "private-vm-name" {
  default = "private-vm1"
}

variable "public_key" {
  type    = string
  default = ""
}
