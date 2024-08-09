# Install Terraform 

This article described how to install Terraform on local machine.

References:

- [Install Terraform - HashiCorp](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli)



### Install Terraform locally (instructions for Ubuntu)


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