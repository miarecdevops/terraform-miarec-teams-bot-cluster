
# Install Azure CLI

This article describes how to install Azure CLI on local machine (Ubuntu or WSL 2).

References:

- [How to install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

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