# Node.js Service Deployment

This repository provisions an Oracle Cloud Infrastructure (OCI) compute instance and deploys a Node.js service to it. It implements the [roadmap.sh Node.js Service Deployment project](https://roadmap.sh/projects/nodejs-service-deployment), using OCI instead of DigitalOcean for the infrastructure layer.

The repository contains two GitHub Actions deployment approaches:

- Ansible configures the server, installs the application, configures systemd, and sets up Nginx.
- SSH and `rsync` copy the application from its separate repository and restart the systemd service.

## Table of Contents

- [About](#about)
- [Features](#features)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Installation & Usage](#installation--usage)
- [Example Output](#example-output)
- [How It Works](#how-it-works)
- [Error Handling](#error-handling)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Author](#author)
- [License](#license)

## About

This is a learning project focused on infrastructure as code, configuration management, and automated deployment of a Node.js service. The deployed application is maintained in the separate [`my-nodejs-service`](https://github.com/JescAude18/my-nodejs-service) repository.

### Features

- Provisions one OCI compute instance with Terraform.
- Assigns a public IP address through a public VNIC.
- Configures the instance with Ansible.
- Installs Node.js, npm, Nginx, rsync, and supporting utilities through APT.
- Installs application dependencies with `npm install`.
- Runs the service with `systemd` and `/usr/bin/npm start`.
- Proxies public HTTP traffic on port `80` to the Node.js service on `127.0.0.1:3000`.
- Supports deployment through either Ansible or direct SSH/`rsync`.

### Project Structure

```text
.
├── .github/workflows/
│   ├── deploy_with_ansible.yaml   # Full server and application deployment
│   └── deploy_with_ssh.yaml       # Application-only SSH/rsync deployment
├── ansible/
│   ├── inventory.ini               # Target OCI server
│   ├── node_service.yaml           # Main playbook
│   └── roles/
│       ├── base/                   # Packages and OS preparation
│       ├── app/                    # Clone, dependencies, and systemd service
│       └── nginx/                  # Reverse proxy configuration
├── terraform/
│   ├── provider.tf                 # OCI provider configuration
│   ├── data.tf                     # Availability domain lookup
│   ├── main.tf                     # OCI compute instance
│   ├── variables.tf                # Terraform inputs
│   └── terraform.tfvars            # Local variable values
└── README.md
```

### Requirements

- An OCI account with permission to create a compute instance.
- An existing OCI compartment and subnet.
- An OCI image OCID and an availability domain containing the target region.
- Terraform with the OCI provider.
- An SSH key pair accepted by the OCI instance.
- An Ubuntu/Debian-based target image with an administrator account and `sudo`.
- A separate Node.js application repository containing a working `npm start` script.
- A GitHub repository with Actions enabled.

The Ansible defaults currently target user `jescaude`, application directory `/var/www/my-nodejs-service`, port `3000`, and Nginx port `80`. Update these values for another server.

### Installation & Usage

#### 1. Provision the OCI instance

Configure the variables declared in `terraform/variables.tf`. Keep credentials and private key paths outside version control. Then run:

```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply
```

The Terraform configuration creates one `oci_core_instance` with a public IP. It uses an existing subnet and image; it does not create a VCN, subnet, security list, or firewall rule.

#### 2. Configure and deploy with Ansible

Update `ansible/inventory.ini` with the instance public IP and SSH user, then run:

```bash
ansible-playbook ansible/node_service.yaml \\
-i ansible/inventory.ini \\
--become-password-file /path/to/become_password
```

The playbook requires the target user's sudo password for privileged tasks. It clones `my-nodejs-service`, runs `npm install`, creates and enables `nodejs-service.service`, installs Nginx, and starts the reverse proxy.

#### 3. Deploy with SSH and rsync

The `deploy_with_ssh.yaml` workflow checks out the application repository, creates `/var/www/my-nodejs-service`, synchronizes its files with `rsync`, runs `npm install`, and restarts `nodejs-service.service` remotely.

Both workflows run automatically on pushes to `main` and can also be started manually with `workflow_dispatch`.

Configure these GitHub Actions secrets before running either workflow:

| Secret | Purpose |
| --- | --- |
| `SSH_PRIVATE_KEY` | Private key used to connect to the OCI instance |
| `SUDO_PASSWORD` | Password used for privileged commands |
| `SERVER_HOST` | Public IP address or hostname of the instance, used by the SSH workflow |
| `SERVER_USER` | SSH username, used by the SSH workflow |

The Ansible workflow uses the host and user from `ansible/inventory.ini`; the SSH workflow uses `SERVER_HOST` and `SERVER_USER`.

### Example Output

After a successful deployment, the service should be available through the instance's public address:

```text
http://<OCI_INSTANCE_PUBLIC_IP>/
```

Typical successful deployment messages include:

```text
PLAY RECAP *************************************************************
oci_server : ok=... changed=... unreachable=0 failed=0 skipped=...
```

For the SSH workflow, a successful run finishes after `rsync`, `npm install`, and the `systemctl restart nodejs-service.service` command complete successfully.

### How It Works

1. Terraform creates an OCI compute instance in availability domain 1, attaches a public VNIC, and installs the configured SSH public key.
2. The Ansible `base` role updates the APT cache, upgrades the system, and installs Node.js, npm, Nginx, rsync, and supporting utilities.
3. The `app` role clones the application into `/var/www/my-nodejs-service`, installs dependencies, and manages a systemd unit that runs `npm start` as `jescaude`.
4. The `nginx` role listens on port `80` and forwards requests to `127.0.0.1:3000`.
5. On later application deployments, the SSH workflow synchronizes the separate application repository and restarts the service.

### Error Handling

- GitHub Actions steps fail when their commands return a non-zero exit code.
- Ansible stops on failed tasks and reports unreachable hosts separately from failed tasks.
- The systemd service uses `Restart=on-failure`, so systemd attempts to restart the Node.js process after a failure.
- Nginx is reloaded when its managed configuration changes.
- The workflows do not currently implement automatic rollback, health checks, dependency caching, or secret rotation.
- Host key checking is disabled in the workflows. This is convenient for this learning project but should be replaced with verified host keys in a production environment.

### Roadmap

- Move Terraform secrets and `terraform.tfvars` values to a secure secret-management workflow.
- Manage OCI networking and ingress rules as Terraform resources where appropriate.
- Add deployment health checks and an automatic rollback strategy.
- Pin application dependencies and use `npm ci` when a lockfile is available.
- Add automated tests and a post-deployment smoke test.
- Replace plaintext sudo-password handling with a safer privilege-management approach.

### Contributing

1. Create a branch for your change.
2. Make the smallest focused change possible.
3. Run `terraform validate` and test the Ansible or workflow changes when applicable.
4. Open a pull request describing the infrastructure or deployment impact.

Never commit private keys, OCI API credentials, sudo passwords, or other secrets.

### Author

Created by [JescAude18](https://github.com/JescAude18).

### License

No license file is currently included in this repository. All rights remain with the author unless a license is added.
