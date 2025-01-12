variable "project_name" {
  default = "expense"  
}

variable "environment" {
  default = "dev"  
}

variable "common_tags" {
  default = {
    Project = "Expense"
    Environment = "Dev"
    Terraform = true
  }
}

variable "frontend_tags" {
  default = {
    Component = "cdn"
  }  
}

variable "domain_name" {
  type = string
  default = "devsecmlops.online"
  
}