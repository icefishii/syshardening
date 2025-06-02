# Secure Deno Web Application Deployment

This project details the secure deployment of a Deno-based web application (a simple Todo-App) on an **Ubuntu 24.04** virtual machine. The setup prioritizes security, exposing the application to the internet via **HTTPS** through a robust **Nginx** reverse proxy. While the application is a Todo-App, the underlying architecture is flexible and can host any web application.

## System Architecture and Key Components

The application stack is designed for security and efficiency:

* **Deno:** The web application runtime, compiled into a Linux binary with restricted permissions for enhanced security.
* **SQLite:** A lightweight, file-based database for the Todo-App, secured through strict file permissions.
* **Nginx:** Configured as a reverse proxy to handle external traffic, enforce HTTPS, apply security headers, rate-limit requests, and route traffic to the Deno application.
* **Certbot with Let's Encrypt:** Automates the acquisition and renewal of SSL/TLS certificates for HTTPS.
* **systemd:** Manages the Deno application as a service, applying sandboxing and resource limits.
* **UFW (Uncomplicated Firewall):** A host-based firewall limiting network access to only essential ports (HTTP, HTTPS, SSH, DNS, NTP).
* **Fail2ban:** Protects SSH and other services from brute-force attacks by dynamically banning malicious IPs.
* **OpenSSH:** Hardened for secure remote access, requiring SSH keys and disallowing root login.
* **Ubuntu Pro Security Features:** Utilizes ESM (Expanded Security Maintenance) repositories and Livepatch for continuous security updates.
* **Aide (Advanced Intrusion Detection Environment):** Monitors file and directory integrity for unauthorized changes.
* **auditd:** Provides comprehensive system call and event logging for security monitoring and forensics.
* **General Hardening:** Includes kernel parameter tuning, restricted file permissions, and other security best practices to reduce the overall attack surface.

## Security Highlights

* **HTTPS Everywhere:** All traffic is forced over HTTPS, secured by modern TLS protocols and strong ciphers.
* **Least Privilege:** The Deno application runs under a dedicated, unprivileged user (`denoapp`) with minimal permissions.
* **Layered Security:** Multiple security tools and configurations work in concert (firewall, reverse proxy, integrity monitoring, intrusion detection) to protect the server.
* **Automated Updates:** The system automatically applies security patches and software updates to minimize vulnerabilities.
* **Proactive Monitoring:** Aide and auditd provide essential capabilities for detecting unauthorized changes and suspicious activities.

## Getting Started

This repository contains the configuration files and scripts used to set up and harden the server. While specific installation steps are detailed in the project documentation, the general approach involves:

1.  **Initial OS Setup:** Start with a clean Ubuntu 24.04 LTS installation.
2.  **User Management:** Create a non-root user with sudo access and configure SSH key-based authentication.
3.  **Deno Application Deployment:** Compile and deploy the Deno application binary with appropriate permissions.
4.  **Systemd Service Configuration:** Set up the Deno app as a systemd service with sandboxing.
5.  **Nginx as Reverse Proxy:** Configure Nginx for HTTPS termination, proxying requests to the Deno app, and applying security headers.
6.  **Firewall Configuration:** Set up UFW rules to control incoming and outgoing network traffic.
7.  **Security Tooling:** Install and configure Fail2ban, Aide, and auditd for intrusion prevention and detection.
8.  **System Hardening:** Apply kernel parameter adjustments, secure file permissions, and enable Ubuntu Pro features.
