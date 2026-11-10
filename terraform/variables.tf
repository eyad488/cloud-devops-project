variable "region" {
  type = string
  default = "us-east-1"
}
variable "instance_type" {
  type = string
  default = "t3.micro"
}
variable "key_name" {
  type = string
}
variable "ssh_cidr" {
  type = string
}
variable "web_cidr" {
  type = string
}
