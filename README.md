# network_scan_to_graphviz
Diffrent Bash script that uses Nmap to scan a local network and generates a Graphviz-compatible file for network map visualization.

This Bash script performs a comprehensive Nmap scan of a specified network range and generates a Graphviz file for visualizing the network map. The script includes:

Automated Nmap Scanning: The script scans all ports on a given IP range and saves the results in XML format.
Data Parsing: Extracts IP addresses, hostnames, ports, and states from the Nmap results for further processing.
Graphviz Generation: Creates a Graphviz file based on the scan results, adding hosts with tooltips that display available ports and their states.
User-Friendly Error Handling: If the Nmap scan fails, the script exits with an error message.

This script is useful for system administrators and network analysts who want to map and visualize network topologies. The Graphviz output can be easily customized for more detailed network analysis.
