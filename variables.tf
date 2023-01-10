variable "region"{
default = "ap-south-1"
}
variable "avail_zones" {
  description = "AZs in this region to use"
  default = ["ap-south-1a", "ap-south-1b"]
  type = list
}
variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  type = list
}

variable "subnet_cidrs_private" {
  description = "Subnet CIDRs for private subnets (length must match configured availability_zones)"
  default = ["10.0.3.0/24", "10.0.4.0/24"]
  type = list
}

