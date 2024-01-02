# Cluster Worker Node and Service Instantiation

This Dockerfile will be utilized as a job within the cluster to instantiate the worker nodes and services. It will be able to:

1. Clone your repository
2. Decrypt the encrypted secrets for the cluster using `SOPS` and your AGE key
3. Run the `talosctl` commands to instantiate the worker nodes and services
