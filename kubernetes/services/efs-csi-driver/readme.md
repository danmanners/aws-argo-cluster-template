# AWS EFS CSI Driver

The AWS EFS CSI Driver is a Container Storage Interface (CSI) driver that manages the lifecycle of Amazon Elastic File System (Amazon EFS) file systems for use with Kubernetes. The driver allows Kubernetes pods to request EFS file systems dynamically, and allows administrators to control the creation and lifecycle of EFS file systems using Kubernetes primitives like PersistentVolumeClaims (PVCs).

```bash
# Add the CoreDNS Helm repository
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver
# Update your local Helm chart repository cache
helm repo update
# Template out and install the CoreDNS Helm chart via pipe to `kubectl apply`
helm template efs aws-efs-csi-driver/aws-efs-csi-driver -n kube-system \
--version 2.5.3 --values values.yaml | \
kubectl apply -f -
```

aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
