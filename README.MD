# Linux Code Runner Resource Manager Template
This template sets up a Linux Azure Virtual Machine that will execute all the bash scripts in an Azure Storage Blob Container and then self-destruct.

1. Create a VM
1. Run the custom script extension
    1. Runs a default script that downloads everything in a container
    1. Runs the indicated script (must be included in the container)
1. (PENDING) Kill the VM

### Testing bootstrap.sh
```bash
docker run -v $(pwd):/app --name runner-debug -it ubuntu bash /app/bootstrap.sh somescript.sh somecontainer someaccountname  saskey AzureUSGovernment
```

### Testing the ARM template
```bash
az group create -n runner -l usgovvirginia
az group deployment create -n $(date +%Y%m%d%H%M%S) -g runner --template-file azuredeploy.json --parameters azuredeploy.parameters.json
```