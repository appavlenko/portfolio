## Ansible Automated Server Configuration (Apache)

This project contains Ansible playbooks to automate the configuration of a web server. The playbook installs and configures Apache (HTTPD) on a remote server. This setup reduces manual configuration time and ensures consistent setup across multiple servers.

### Prerequisites

- Ansible installed on your control node.
- SSH access to the target server.

### Files

- **inventory**: Inventory file listing the server where the playbook will be applied.
- **playbook.yml**: Main playbook that runs the Apache role.
- **roles/apache/**: Directory containing tasks, configuration files, and default variables for the Apache configuration.

### Usage

1. **Update the inventory file**:
   - Add your server's IP address or hostname to the `inventory` file.

2. **Run the playbook**:
   ```bash
   - ansible-playbook -i inventory playbook.yml
