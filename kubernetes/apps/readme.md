# Argo Applications

The default Argo Applications in this directory are used to manage and maintain the ["core"](../core) services and applications of the Kubernetes cluster. These applications should be default and are required for the cluster to function properly.

In order to deploy the applications, make sure you replace the `GIT_USERNAME` and `GIT_REPOSITORY` fields with your own GitHub username and repository name. You can do this by running the following commands:

## Mac OS

```bash
GIT_USERNAME="danmanners"
GIT_REPOSITORY="aws-argo-cluster-template"
for file in $(find . -type f -name '*.yaml'); do
  sed -i '' "s/USERNAME/${GIT_USERNAME}/g" $file
  sed -i '' "s/REPOSITORY/${GIT_REPOSITORY}/g" $file
done
```

## Linux

```bash
GIT_USERNAME="danmanners"
GIT_REPOSITORY="aws-argo-cluster-template"
for file in $(find . -type f -name '*.yaml'); do
  sed -i "s/USERNAME/${GIT_USERNAME}/g" $file
  sed -i "s/REPOSITORY/${GIT_REPOSITORY}/g" $file
done
```

> [!IMPORTANT]
> Once you've replaced the `GIT_USERNAME` and `GIT_REPOSITORY` fields, make sure you commit the changes to your repository. This way, when you run `pulumi up` to deploy the cluster and associated resources to AWS, the applications can be deployed to the cluster successfully.
