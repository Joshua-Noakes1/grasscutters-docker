#!/bin/sh
echo "Downloading latest version of grasscutter..."

# Check for API connectivity and rate limit
if [ $(curl -s https://api.github.com/rate_limit | jq -r '.rate.remaining') -lt 1 ]; then
    # get the number which is at x-ratelimit-reset then pass to date to get date, sed after the first space in the string
    resetTime=$(curl -s "https://api.github.com/rate_limit" | jq -r '.rate.reset')
    echo "GitHub API rate limit exceeded, please wait till $(date -d @$resetTime)"

    if [ "$CONTAINER" = "true" ]; then
        echo "Failed to download latest version of grasscutter, using older version if it exists!"
        exit 0
    else
        exit 1
    fi
fi

curlRes=$(curl -s "https://api.github.com/repos/Grasscutters/Grasscutter/releases/latest" | jq -r '.assets[0].browser_download_url')

# Check if curlRes string has the word "jar" in in
if [[ $curlRes == *"jar"* ]]; then
    # Download latest release
    echo "Latest release: $curlRes"
    cd /root/grass
    rm -rf ./grasscutter*.*jar
    wget -q $curlRes || echo "Failed to download latest release, using older version if it exists!"
    echo "Downloaded latest version of grasscutter!"
else
    if [ "$CONTAINER" = "true" ]; then
        echo "Failed to download latest version of grasscutter, using older version if it exists!"
        exit 0
    else
        exit 1
    fi
fi
