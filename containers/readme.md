# Cluster Instantiation and Bootstrapping Container

This container is used for two purposes:

1. To instantiate a cluster using AWS Lambda once the Pulumi stack has been successfully created.
2. To bootstrapp the cluster resources once the cluster has been instantiated.

> [!NOTE]
> AWS Lambda requires that the container image be stored in ECR.
