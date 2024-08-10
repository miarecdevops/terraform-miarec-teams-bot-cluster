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


In the previous steps, Terraform created **Azure Key Vault** and **Azure App Configuration** resources.

The Key Vault will be used to store safely application credentials.

The App Configuration will be used to store configuration of the application.


In Azure web portal, open the Resource Group and locate the Key Valut that was created automatically on the previous steps.

In the left pane, select **Object > Secret**. Click **+ Generate/Import** button to create new secrents.

If you see the warning message that you have no permission to list or create secrets, then first navigate in the left pane to
**Access control (IAM)**, click **Add > Add role assignment** button. 
In the **Role** tab, select **Key Vault Administrator** under **Job function roles**. Click **Next**.
In the **Members** tab, select **Assign access to User, group, or service principal**. 
Select your account under **Members** list. Click **Review and Create**.

Now, you should be able to create secrets now.

Create the following secrets in Key Vault:

- `ApplicationInsights--ConnectionString`
- `AppSettings--AadAppSecret`
- `AppSettings--AadAppId`


In **Azure App Configuration** service, navigate to **Operations > Configuration explorer**.

Create the following Key/Values:

- `AppSettings:SipRecHost`
- `AppSettings:SipRecPort`
- `AppSettings:SipRecProtocol`




## Step 6. Second run - Automatic provisioning with Terrafom

This time, provide a non-empty list of virtual machines in `terraform.tfvars` file:

```
vm_computer_names = ['bot01', 'bot02', 'bot03']
```

Run `terraform apply` command to provision instances.

After successfull run, you should have the bot cluster up and running, ready to handle recording.

## Step 7. Create Bastion host

Bastion host is used for secure access to Windows servers via RDP protocol.

Azure provides managed service **Bastion**, which will provision a dedicated instance inside the virtual netowrk,
so you can securily access the servers RDP interface via web browser without exposing RDP port to public.

In the Azure portal, locate one of the provisioned instances, select **Connect > Bastion** in the left pane and 
click **Create Bastion** button.

To access the instances, you need to know the admin username and password.

The username is configured in `terraform.tfvars` file as parameter `vm_admin_user`.

The password is randomly generated during terraform run. Run the following command to see the password:

```bash
terraform output admin_password
```

This will print the password to console enclosed in double quotes. Note, the double quotes are not part of the password.

## Step 7. Verification


## Troubleshooting

Short check-list:

- Verify if you can access individual bot web interface by opening in browser `https://botXX.example.com/ping`
- Verify if you can access bots cluster via shared address (i.e. via load balancer) by opening in browser `https://bots.example.com/ping`
- Make test calls
- Check logs (see the next section)
- Login to servers via Bastion and see if services **Traefik** and **MiaRec.TeamsBot** are running.
- If `MiaRec.TeamsBot.exe` process is not running on the machine. Try to run it manually by opening `cmd.exe` console, navigating to `C:/Progs/MiaRec.TeamsBot/` directory and running the EXE file. Check any errors printed to console.

## Logs

### Centralized logging to Application Insights

The application pushes logs to **Application Insights** service, where they can be reviewed in web browser.

In Azure portal, navigate to the **Application Insights** resource, then select **Monitoring > Logs**, query table **traces**.

### Local logs on virtual machines

Login to the server(s) via Bastion and check the following locations for logs:

- Event Viewer (Operating system logs)
- Traefik log file `C:/Progs/Traefik/traefik.log`
- MiaRec.TeamsBot log files(s) at `C:/Progs/MiaRec.TeamsBot/logs`. Note, these same log records should be accessible via centralized logging service (**Application Insights**, table `trace`). If a connection to the Application Insights doesn't work, you can check the local copy of logs. Such logs are retained for 30 days


## Metrics

Some application metrics are pushed to **Application Insights** service and can be reviewed there.

## How to login to the instance(s)?

Use the Bastion host, that was provisioned as part of setup.

The OS username was configured in `terraform.tfvars` file as a parameter `vm_admin_user`.

The OS password is randomly generated during terraform run. Run the following command to see the password:

```bash
terraform output admin_password
```

This will print the password to console enclosed in double quotes. Note, the double quotes are not part of the password.

## How to update the application?

TBD
