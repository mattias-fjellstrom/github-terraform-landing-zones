variable "name_suffix" {
  type = string

  validation {
    condition     = length("rg-${var.name_suffix}") <= 90
    error_message = "Name suffix can be at most 87 characters long"
  }
}

variable "location" {
  type = string
}
