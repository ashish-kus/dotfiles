#!/bin/bash
################################
# Author: Sam Prince Franklin K
# Version: v1
#
# This script helps users communicate with the GitHub API and retrieve information.
#
# Usage:
#   Please provide your GitHub token and REST API endpoint as input.
#
################################

# Check if the required arguments are provided
if [ ${#@} -lt 2 ]; then
  echo "Usage: $0 [your GitHub token] [REST expression]"
  exit 1
fi

# Assign the arguments to variables
GITHUB_TOKEN=$1
GITHUB_API_REST=$2

# Set the GitHub API header for specifying the response format
GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.v3+json"

# Create a temporary file to store the API response
temp=$(basename $0)
TMPFILE=$(mktemp /tmp/${temp}.XXXXXX) || exit 1

# Function to make a REST API call to GitHub and store the response in the temporary file
function rest_call {
  curl -s $1 -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: token $GITHUB_TOKEN" >>$TMPFILE
}

# Check if the result uses pagination by examining the Link header in the API response
last_page=$(curl -s -I "https://api.github.com${GITHUB_API_REST}" -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: token $GITHUB_TOKEN" | grep '^Link:' | sed -e 's/^Link:.*page=//g' -e 's/>.*$//g')

# Check if the result is a single page (no pagination)
if [ -z "$last_page" ]; then
  # No pagination - this result has only one page
  rest_call "https://api.github.com${GITHUB_API_REST}"
else
  # Pagination detected - this result is on multiple pages
  for p in $(seq 1 $last_page); do
    rest_call "https://api.github.com${GITHUB_API_REST}?page=$p"
  done
fi

# Display the contents of the temporary file (API response)
cat $TMPFILE
