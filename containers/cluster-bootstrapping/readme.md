# Cloud Cluster Bootstrapping

This Dockerfile will be utilized by AWS Lambda to bootstrap the cloud cluster. It will wait for the Talos Nodes to be up and operational, and from within the AWS networking it will be able to:

1. Clone your repository
2. Decrypt the encrypted secrets for the cluster using `SOPS` and your AGE key
3. Run the `talosctl` commands to bootstrap the initial cluster
