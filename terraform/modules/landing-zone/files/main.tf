terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
    }
  }
}

resource "random_integer" "default" {
  min = 100
  max = 10000
}

resource "random_integer" "other" {
  min = 100
  max = 10000
}
