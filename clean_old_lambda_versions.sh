#!/bin/bash

function_name=$1
versions_to_keep=$2

versions=$(aws lambda list-versions-by-function --function-name "$function_name" --query 'Versions[?!ends_with(Version, `$LATEST`)].Version' --output text | sort -n)

num_versions=$(echo "${versions}" | wc -l)

if ((num_versions <= versions_to_keep)); then
  echo "Not enough versions to remove"
  exit 0
fi

versions_to_remove=$(echo "${versions}" | head -n $((num_versions - versions_to_keep)))

for version in ${versions_to_remove}; do
  aws lambda delete-function --function-name "$function_name" --qualifier "$version"
  echo "Removed version $version of $function_name"
done
