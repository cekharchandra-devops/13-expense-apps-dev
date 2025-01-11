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


variable "backend_tags" {
  default = {
    Component = "backend"
  }
}

variable "domain_name" {
  default = "devsecmlops.online"
}