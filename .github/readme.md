# Deploy Kubernetes in AWS using Talos Linux backed by ArgoCD

This repository is an opinionated way to deploy Kubernetes in [AWS](https://aws.amazon.com/) using [Talos Linux](https://www.talos.dev/) and [ArgoCD](https://argoproj.github.io/cd).

> The estimated cost (in USD) for this project [can be found here](https://calculator.aws/#/estimate?id=c5b85559c7cc50a0376c8f36c6d51c45e2c81917) and equates to about $0.1678 per hour or $122.51 per month, or $1,470.12 per year.

## Critical Notes

> [!WARNING]
> This project is still in the _very_ early stages of development and is not ready for production use. Please use at your own risk!

## 👋 Introduction

This project aims to serve as an opinioned but practical starting point for deploying cloud resources using [Infrastructure-as-Code](https://www.redhat.com/en/topics/automation/what-is-infrastructure-as-code-iac) (**IaC**), Kubernetes in AWS using [Talos Linux](https://www.talos.dev/) (_**not**_ AWS EKS), and [GitOps](https://about.gitlab.com/topics/gitops/) using [ArgoCD](https://argoproj.github.io/cd). I want to enable those interested to learn how to go from zero to operational, so I will attempt to explain everything in detail as you navigate through this repository! I hope this serves as a useful learning tool for you, dear reader, as well as a practical starting point for deploying your own Kubernetes cluster in the cloud.

As best I can, links to other resources that I have found useful in my personal learning journey and references to any technology utilized by this project will be provided.

## ✨ Features

- Automated and Immutable Deployment of Kubernetes in AWS
- ArgoCD for GitOps and declarative service management
- Encrypted Secrets in your Git Repo using [Bitnami-Labs/Sealed-Secrets](https://github.com/bitnami-labs/sealed-secrets)

...and more!

## 📝 Pre-Flight Checks

> [!CAUTION]
> Before we get started, everything below must be taken into consideration. You must make sure:

- Have an AWS account
- Install all of the necessary tooling on your local workstation:
  - [age](https://github.com/FiloSottile/age) - `brew install age`
  - [helm](https://helm.sh/) - `brew install helm`
  - [kubectl](https://kubernetes.io/docs/tasks/tools/) - `brew install kubectl`
  - [kubeseal](https://github.com/bitnami-labs/sealed-secrets) - `brew install kubeseal`
  - [kustomize](https://kustomize.io/) - `brew install kustomize`
  - [sops](https://github.com/getsops/sops) - `brew install sops`
  - [talhelper](https://github.com/budimanjojo/talhelper) - Manual Install Required
  - [yarn](https://yarnpkg.com/) - `brew install yarn`

## 🚀 Getting Started

> [!IMPORTANT]
> For all stages below, the commands **must** be ran from your personal workstation within the specified directories.

### 🎉 Stage 1: Create your Git repository

1. Create a new **public** repository by clicking the big green "Use this template" button at the top of this page.

2. Clone **your new repo** to you local workstation and `cd` into it.

### 🌱 Stage 2: Setup your local workstation environment

tbd

### 🔧 Stage 3: Prep all critical files

tbd

## 📣 Post installation

tbd

## 👉 Help and Support

tbd

## Thank You's and Project Influences

This project was heavily influenced by the following projects and communities:

### GitHub Projects

- [Onedr0p's Flux Cluster Template](https://github.com/onedr0p/flux-cluster-template)

### Communities

![Discord Banner 2](https://discordapp.com/api/guilds/673534664354430999/widget.png?style=banner2)

Without the inspiration and assistance of these individuals and communities, this project would not be possible.

Make sure to check out their projects and communities as well!
