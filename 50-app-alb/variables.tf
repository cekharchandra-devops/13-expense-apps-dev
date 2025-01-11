variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project     = "Expense"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "app_alb_tags" {
  default = {
    Component = "app-alb"
  }
}
variable "domain_name" {
  default = "devsecmlops.online"
}