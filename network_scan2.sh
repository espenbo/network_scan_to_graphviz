#!/bin/bash

NETWORK="192.168.1.1-254"
OUTPUT_FILE="networkmap.dot"

nmap -p- -oX scan_results.xml "$NETWORK" || {
  echo "Nmap scan failed!"
  exit 1
}

readarray -t ips < <(cat scan_results.xml | grep -oE 'addr="[0-9\.]+' | cut -d\" -f2)
readarray -t names < <(cat scan_results.xml | grep -oE '<hostname name="\S+' | cut -d\" -f2)
readarray -t ports < <(cat scan_results.xml | grep -oE 'portid=["][0-9]+[.]' | cut -d\" -f2)  
readarray -t states < <(cat scan_results.xml | grep -oE 'state=["][^"]+[' | cut -d\" -f2)

echo "digraph NetworkMap {" > "$OUTPUT_FILE"
echo "  bgcolor=\"dimgrey\";" >> "$OUTPUT_FILE" 
echo "  label = \"NetworkMap\";" >> "$OUTPUT_FILE"
echo "  switch [" >> "$OUTPUT_FILE"
echo "    label=\"switch\";" >> "$OUTPUT_FILE"
echo "    tooltip=\"switch\";" >> "$OUTPUT_FILE"  
echo "    group = \"switch\";" >> "$OUTPUT_FILE"
echo "    shape=box;" >> "$OUTPUT_FILE"
echo "    color=black;" >> "$OUTPUT_FILE"   
echo "    fillcolor = \"#d9e7ee\";" >> "$OUTPUT_FILE"
echo "    style=filled;" >> "$OUTPUT_FILE"
echo "    ];" >> "$OUTPUT_FILE"
echo "  " >> "$OUTPUT_FILE"

for ((i=0;i<${#ips[*]};i++)); do

  ip=${ips[i]} 
  name=${names[i]}

  echo "  host$i [" >> "$OUTPUT_FILE"
  echo "    label=\"hostname: ${name// /_} \n$ip\";" >> "$OUTPUT_FILE"

  tooltip="Port: "
  for ((j=0;j<${#ports[*]};j++)); do
    port=${ports[j]}
    state=${states[j]}
    if [[ ${ips[j]} == "$ip" ]]; then
      tooltip+="${port} State: ${state} \n"
    fi
  done

  echo "    tooltip=\"${tooltip%\n}\";" >> "$OUTPUT_FILE"

  echo "    group = \"Nettverk\";" >> "$OUTPUT_FILE"
  echo "    shape=box;" >> "$OUTPUT_FILE"
  echo "    color=black;" >> "$OUTPUT_FILE"   
  echo "    fillcolor = \"#d9e7ee\";" >> "$OUTPUT_FILE"
  echo "    style=filled;" >> "$OUTPUT_FILE"
  echo "    ];" >> "$OUTPUT_FILE"

done

echo "}" >> "$OUTPUT_FILE"

echo "Graphviz file written to $OUTPUT_FILE"

