variables {
  name_suffix = "valid"
  location    = "swedencentral"
}

provider "azurerm" {
  features {}
}

run "should_accept_valid_values" {
  command = plan
}

run "should_not_accept_invalid_name_suffix" {
  command = plan

  variables {
    name_suffix = join("", [
      "aaaaaaaaaa",
      "bbbbbbbbbb",
      "cccccccccc",
      "dddddddddd",
      "eeeeeeeeee",
      "ffffffffff",
      "gggggggggg",
      "hhhhhhhhhh",
      "iiiiiiiiii",
    ])
  }

  expect_failures = [
    var.name_suffix,
  ]
}