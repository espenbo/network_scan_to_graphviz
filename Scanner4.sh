#!/bin/bash
NETWORK="192.168.1.1-254"
OUTPUT_FILE="networkmap.dot"

# Initialize arrays to store the information
declare -A host_ips
declare -A hostnames
declare -A open_ports
declare -A host_status

# Run Nmap scan and save the results to a file
nmap -vv -T4 -oA scan_results "$NETWORK" || {
  echo "Nmap scan failed!"
  exit 1
}

# Read the scan_result.gnmap file line by line
while IFS= read -r line; do
  # Extract IP address
  if [[ $line =~ ^Host:\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
    ip="${BASH_REMATCH[1]}"
    host_ips["$ip"]=""
  fi

  # Extract hostname
  if [[ $line =~ ^Host:\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\ (.+)$ ]]; then
    ip="${BASH_REMATCH[1]}"
    hostname="${BASH_REMATCH[2]}"
    hostnames["$ip"]="$hostname"
  fi

  # Extract open ports
  if [[ $line =~ ^Host:\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\ .*$ ]]; then
    ip="${BASH_REMATCH[1]}"
    port_and_service=$(echo "$line" | grep -oP '(\d+)\/open\/tcp\/\/[^/]+')
    if [[ ! -z "$port_and_service" ]]; then
      port=$(echo "$port_and_service" | awk -F'/' '{print $1}')
      service=$(echo "$port_and_service" | awk -F'/' '{print $4}')
      open_ports["$ip"]+=" $port/$service"
    fi
  fi

  # Extract host status (Up or Down)
  if [[ $line =~ ^Host:\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\ (.+)\ Status:\ (.+)$ ]]; then
    ip="${BASH_REMATCH[1]}"
    status="${BASH_REMATCH[3]}"
    host_status["$ip"]="$status"
  fi

done < scan_results.gnmap

# Generate the networkmap.dot file
echo "digraph NetworkMap {" > "$OUTPUT_FILE"
echo "    bgcolor=\"dimgrey\";" >> "$OUTPUT_FILE"
echo "    label = \"NetworkMap\";" >> "$OUTPUT_FILE"

# Add switch node
echo "    switch [" >> "$OUTPUT_FILE"
echo "        label=\"switch\";" >> "$OUTPUT_FILE"
echo "        tooltip=\"switch\";" >> "$OUTPUT_FILE"
echo "        group =\"switch\";" >> "$OUTPUT_FILE"
echo "        shape=box;" >> "$OUTPUT_FILE"
echo "        color=black;" >> "$OUTPUT_FILE"
echo "        fillcolor=\"#d9e7ee\";" >> "$OUTPUT_FILE"
echo "        style=filled;" >> "$OUTPUT_FILE"
echo "    ];" >> "$OUTPUT_FILE"

# Loop through host information and generate nodes and edges
host_counter=1
for ip in "${!host_ips[@]}"; do
  echo "    host$host_counter [" >> "$OUTPUT_FILE"
  echo "        label=\"hostname: (${hostnames[$ip]})\\nIP: $ip\";" >> "$OUTPUT_FILE"
  echo "        tooltip=\"Ports open:${open_ports[$ip]}\";" >> "$OUTPUT_FILE"
  echo "        group =\"Nettverk\";" >> "$OUTPUT_FILE"
  echo "        shape=box;" >> "$OUTPUT_FILE"
  echo "        color=black;" >> "$OUTPUT_FILE"
  echo "        fillcolor=\"#d9e7ee\";" >> "$OUTPUT_FILE"
  echo "        style=filled;" >> "$OUTPUT_FILE"
  echo "    ];" >> "$OUTPUT_FILE"
  echo "    switch -> host$host_counter [" >> "$OUTPUT_FILE"
  echo "        arrowhead = \"none\";" >> "$OUTPUT_FILE"
  echo "        color = black;" >> "$OUTPUT_FILE"
  echo "        label = \"\";" >> "$OUTPUT_FILE"
  echo "        style = \"filled,setlinewidth(1)\";" >> "$OUTPUT_FILE"
  echo "    ];" >> "$OUTPUT_FILE"
  host_counter=$((host_counter + 1))
done


# Close the networkmap.dot file
echo "}" >> "$OUTPUT_FILE"
