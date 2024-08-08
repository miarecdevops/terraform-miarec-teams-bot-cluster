# terraform-miarec-teams-bot-cluster


This terraform configuration provisions infrastructure necessary for MiaRec Teams bot in Azure account.

It creates the following resources:

- A pool of virtual machines, on which MiaRec Teams Bot will be running
- Load balancer in front of VMs

## Prerequisites

```text
- Azure account with permissions to Provision Azure Resources
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
```

## Prepare local machine

It is necessary to install Terraform and Azure CLI on local machine, which will be used to provision Azure VM.

### Install Terraform locally (instructions for Ubuntu)

References:

- <https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started>

Add the HashiCorp GPG key.

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

Add the official HashiCorp Linux repository.

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Update and install.

```bash
sudo apt update && sudo apt install terraform
```

### Install Azure CLI

References:

- https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

The Azure CLI team maintains a script to run all installation commands in one step. This script is downloaded via curl and piped directly to bash to install the CLI.

If you wish to inspect the contents of the script yourself before executing, simply download the script first using curl and inspect it in your favorite text editor.

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Login to Azure to save your details in ~/.azure/

```bash
az login
```

It will give you a link, please open it in your browser and login to your azure account. The login operation has a unique session identifier. Once you sign in with this session ID, the CLI receives a notification on its back channel. The notification contains a JWT access token.

From this point on, the access token is used by most other CLI commands to access Azure Management REST API. API uses OAuth protocol where the access token is passed in the Authorization HTTP header.

### Initialize Terraform

When you create a new configuration — or check out an existing configuration from version control — you need to initialize the directory.

```bash
terraform init
```

### Create variables file

Copy a sample variables file to `terraform.tfvars`

```bash
cp terraform.tfvars.sample terraform.tfvars
```

Edit the parameters as necessary.
For a full list of supported variables, check `variables.tf` file.

Required variable

- `azure_resource_group` is a name of Resource Group in Azure account, where the resources will be provisioned. Such group must exist.

## Provision infrastructure

Apply the configuration now with the terraform apply command.

```bash
terraform apply
```

### Result

Terraform will build the specificed infrasturcture, prepare the bastion instance to act as an ansible controller for the configuration of the Miarec cluster

In addition, terrform will output commands needed to complete the configuration of the Miarec cluster from the Admin portal

Example output

```text
```