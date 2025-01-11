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
variable "web_alb_tags" {
  default = {
    Component = "web-alb"
  }
}

variable "domain_name" {
  type = string
  default = "devsecmlops.onlin"
}