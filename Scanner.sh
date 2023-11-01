#!/bin/bash

# Check if nmap is installed
if ! command -v nmap &> /dev/null; then
  echo "nmap is not installed. Please install nmap and try again."
  exit 1
fi

# Check if a file containing domain names is provided as an argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <domain_list_file>"
  exit 1
fi

# Input file containing a list of domain names, one per line
input_file="$1"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "Input file not found: $input_file"
  exit 1
fi

# Output file to store all results
output_file="scan_results.txt"

# Output file to store only the up hosts
up_hosts_file="up_hosts.txt"

# Create empty output files
> "$output_file"
> "$up_hosts_file"

# Loop through the list of domains in the input file
while IFS= read -r domain; do
  # Use nmap to find the IP address and scan the top 100 ports
  result=$(nmap -Pn -F -T4 -sT -oG - "$domain" | grep Ports)
  
  # Extract IP address and open ports
  ip_address=$(echo "$result" | awk '{print $2}')
  open_ports=$(echo "$result" | cut -d' ' -f4-)

  # Print the result in the desired format in the terminal
  echo "$domain ($ip_address) [$open_ports]"

  # Append the result to the all results output file
  echo "$domain ($ip_address) [$open_ports]" >> "$output_file"

  # Check if the host is up (IP address is not empty)
  if [ -n "$ip_address" ]; then
    # Append the up host to the up hosts output file
    echo "$domain ($ip_address)" >> "$up_hosts_file"
  fi

  # Add a newline in the output files for separation
  echo "" >> "$output_file"
  echo "" >> "$up_hosts_file"

done < "$input_file"

echo "All scan results have been saved to $output_file"
echo "Up hosts have been saved to $up_hosts_file"
