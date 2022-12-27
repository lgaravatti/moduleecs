variable "namecluster" { 
  description = "Nome do cluster"
  type = string
} 

variable "allowed_cidr_blocks" {
  type = list
}

variable "vpc_id" { 
  description = "ID VPC"
  type = string
}

variable "subnet_id" { 
  description = "ID Subnet1"
  type = list
} 