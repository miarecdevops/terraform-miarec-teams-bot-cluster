# terraform-miarec-teams-bot-cluster


This terraform configuration provisions infrastructure necessary for MiaRec Teams bot in Azure account.

It creates the following resources:

- A pool of virtual machines, on which MiaRec Teams Bot will be running
- Load balancer in front of VMs

## Prerequisites

- Azure account with permissions to Provision Azure Resources
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)


## Prepare local machine

It is necessary to install Terraform and Azure CLI on local machine, which will be used to provision Azure VM.

Follow the instuctions in separate guides:

- [Install Terrafom](docs/Install_Azure_CLI.md)
- [Install Azure CLI](docs/Install_Azure_CLI.md)


## Step 1. Pre-setup manual provisioning

In the Azure account, create the following resources:

1. Create manually **Resource Group** in Azure account

2. Create manually **Application Insights** resource. This will be used for cetralized logging and metrics.
   The Application Insights resource can reside in a different resource group.

## Step 2. Initialize Terraform (one-time)

When you create a new configuration — or check out an existing configuration from version control — you need to initialize the directory.

```bash
terraform init
```

## Step 3. Create the variables file

Copy a sample variables file to `terraform.tfvars`

```bash
cp terraform.tfvars.sample terraform.tfvars
```

Edit the parameters as necessary.
For a full list of supported variables, check `variables.tf` file.


## Step 4. First run - Automatic provisioning with Terraform

In this step, we will provision all the required resources except virtual machines.

In the variables faile (`terraform.tfvars`) set variable `vm_names` to empty list:

```
vm_computer_names = []
```

Apply terraform configuration by running the following command:

```bash
terraform apply
```

As a result of this run, the following resoruces will be provisioned:

- Virtual network and subnet
- Application Configuration
- Key Vault
- Load Balancer

## Step 5. Post-setup manual provisioning


## Step 6. Second run - Automatic provisioning with Terrafom


## Step 7. Verification


## Troubleshooting


### Logs

### Metric

### Login to instances


