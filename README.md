# GitHub-Terraform Landing Zones

![Terraform landing zone on GitHub](feature.png)

This repository contains an implementation of the Terraform landing zone on GitHub discussed in my blog post at [mattias.engineer](https://mattias.engineer/).

The blog post discuss the setup when the target provider is Azure, the code for this example is found in the [azure](/terraform/azure/) directory.

## Setup

If you want to try this out you should start by configuring your GitHub organization using the Terraform configuration under [terraform/organization/](./terraform/organization/).

Next, provision the Terraform infrastructure under [terraform/azure/](./terraform/azure/).

* * *

Note that there is also code for a similar landing zone for AWS infrastructure, but it is not fully implemented with custom properties and rulesets (see [terraform/aws](./terraform/aws/)).