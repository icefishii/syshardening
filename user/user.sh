#!/bin/bash

# Script to create a user named 'syshardening' with a home directory and 'pash' as its shell.
# The password will be set interactively, and the user will be added to the sudo group.

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use sudo or log in as root."
    exit 1
fi

# Create the user with a home directory and 'pash' as its shell
useradd -m -s /bin/pash syshardening

# Check if the user was created successfully
if [[ $? -ne 0 ]]; then
    echo "Failed to create user 'syshardening'. Please check for errors."
    exit 1
fi

# Prompt for the password interactively
echo "Please enter a password for the 'syshardening' user:"
passwd syshardening

# Add the user to the sudo group
usermod -aG sudo syshardening

# Confirm the user was added to the sudo group
if [[ $? -eq 0 ]]; then
    echo "User 'syshardening' created successfully and added to the sudo group."
else
    echo "Failed to add 'syshardening' to the sudo group. Please check for errors."
fi