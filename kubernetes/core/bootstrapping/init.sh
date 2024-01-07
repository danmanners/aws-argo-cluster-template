#!/bin/bash
# Get all files in the /opt/directory
install_scripts=$(ls -l /opt)

# Run all files in the /opt/directory
for item in ${install_scripts}; do
    echo "Running $item"
    /opt/${item} --dry-run
done
