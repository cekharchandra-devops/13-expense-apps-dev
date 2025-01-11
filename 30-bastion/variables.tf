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

variable "bastion_tags" {
  default = {
    Component = "bastion"
  }
}