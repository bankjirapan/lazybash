#!/bin/bash

mapfile -t lines < <(docker ps --format '{{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}')

if [ ${#lines[@]} -eq 0 ]; then
    echo "No running containers."
    exit 0
fi

declare -A groups

for line in "${lines[@]}"; do
    IFS=$'\t' read -r name id image status ports <<< "$line"
    prefix=$(echo "$name" | cut -d'-' -f1)
    groups["$prefix"]+="${id:0:12}\t${name:0:18}\t${image:0:22}\t${status:0:20}\t${ports:0:30}\n"
done
for prefix in "${!groups[@]}"; do
    echo -e "\nContainer: $prefix"
    echo "==========================================================================================================="
    printf "%-14s %-20s %-24s %-20s %-s\n" "CONTAINER ID" "NAME" "IMAGE" "STATUS" "PORTS"
    echo "==========================================================================================================="
    echo -e "${groups[$prefix]}" | while IFS=$'\t' read -r id name image status ports; do
        printf "%-14s %-20s %-24s %-20s %-s\n" "$id" "$name" "$image" "$status" "$ports"
    done
done
