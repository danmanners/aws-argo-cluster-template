# Talos Configs using Talhelper

In order to generate the configs for your cluster, you will need to run the following commands:

```bash
# Generate your Initial Talos Cluster Secrets
talhelper gensecret > talsecret.sops.yaml
# Encrypt your secrets using the AGE key with SOPS
sops -e -i talsecret.sops.yaml
# Replace the DOMAIN variable with your domain
sed -i '.bak' 's/DOMAIN/cloud.danmanners.com/g' talconfig.yaml
```

Once you have generated your secrets, you can validate that your cluster config files will work by running:

```bash
talhelper genconfig
```
