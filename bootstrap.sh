#Bail on error
set -e

#Require parameters
set -u

#Retrieve parameters
RUN_SCRIPT="$1"
RUN_CONTAINER="$2"
RUN_ACCOUNT_NAME="$3"
RUN_ACCOUNT_SAS_KEY="$4"
RUN_ACCOUNT_ENVIRONMENT="$5"

echo "********Run script: $RUN_SCRIPT"
echo "********Run container: $RUN_CONTAINER"
echo "********Run account name: $RUN_ACCOUNT_NAME"
echo "********Run account environment: $RUN_ACCOUNT_ENVIRONMENT"

#Install Azure CLI
#Source: https://docs.microsoft.com/cli/azure/install-azure-cli-apt?view=azure-cli-latest
echo "********Installing Azure CLI"
apt-get update && apt-get install apt-transport-https --yes
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ xenial main" | \
     tee /etc/apt/sources.list.d/azure-cli.list
apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
apt-get update && apt-get install azure-cli --yes

echo "********Setting Cloud Environment"
az cloud set -n $RUN_ACCOUNT_ENVIRONMENT

echo "********Retrieving blobs in container"
BLOBS=$(az storage blob list -c $RUN_CONTAINER --account-name $RUN_ACCOUNT_NAME --sas-token "$RUN_ACCOUNT_SAS_KEY" --query [*].name --output tsv)

mkdir /scripts && cd /scripts

for BLOB in $BLOBS
do
  echo "********Downloading $BLOB"
  az storage blob download -n $BLOB -f $BLOB -c $RUN_CONTAINER --account-name $RUN_ACCOUNT_NAME --sas-token "$RUN_ACCOUNT_SAS_KEY"
  chmod +x $BLOB
done

echo "********Running $RUN_SCRIPT"
./$RUN_SCRIPT

echo "********Bootstrapping complete."