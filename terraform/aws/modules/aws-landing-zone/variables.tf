variable "github_owner" {
  description = "GitHub organization name"
  type        = string
}

variable "name" {
  description = "Name of landing zone"
  type        = string
}

variable "state_backend" {
  description = "Terraform state backend HCL"
  type        = string
}
