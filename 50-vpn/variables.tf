variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Terraform = true
    Project = "Expense"
    Environment = "Dev"
  }
}


variable "vpn_tags" {
  default = {
    Component = "vpn"
  }
}
