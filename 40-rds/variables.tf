variable "project_name" {
  default = "expense"
}

variable "environmet" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project     = "Expense"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "rds_tags" {
  default = {
    Component = "mysql"
  }
}
variable "domain_name" {
  default = "devsecmlops.online"
}