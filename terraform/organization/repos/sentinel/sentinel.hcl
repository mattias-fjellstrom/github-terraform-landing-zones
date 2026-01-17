sentinel {
  features = {
    terraform = true
  }
}

import "plugin" "tfplan/v2" {
  config = {
    plan_path = "./tfplan.json"
  }
}

policy "azure_locations" {
  source            = "./azure-locations.sentinel"
  enforcement_level = "hard-mandatory"
}