#!/usr/bin/env bash

# this script is run using a cronjob to signal to my Github Workflow when to rebuild

# When using Curl in shell scripts, always pass -fsSL, which:
#     Treats non-2xx/3xx responses as errors (-f).
#     Disables the progress meter (-sS).
#     Handles HTTP redirects (-L).

# curl -fsSL -X GET "https://mas.to/users/keb.rss" | grep -oPm1 "(?<=<lastBuildDate>)[^<]+"
FILE=last_date.txt
ISSUE_URL=https://api.github.com/repos/keb/keb.github.io/issues/1/comments
AUTH_TOKEN=$GITHUB_AUTH_TOKEN

FEED=$(curl -fsSL -X GET https://mas.to/users/keb.rss)
LAST_DATE_STR=$(echo "$FEED" | grep -oPm1 "(?<=<lastBuildDate>)[^<]+")
LAST_DATE=$(date -d "$LAST_DATE_STR" +%s)

if [ -f "$FILE" ]; then
    OLD_DATE_STR=$(head -n 1 "$FILE")
    OLD_DATE=$(date -d "$OLD_DATE_STR" +%s)

    if [ $LAST_DATE -gt $OLD_DATE ]; then
        echo "$LAST_DATE_STR" > "$FILE"

        # comment on github issue
        curl \
          -X POST \
          -H "Accept: application/vnd.github.v3+json" \
          -H "Authorization: token $GITHUB_AUTH_TOKEN" \
          $ISSUE_URL \
          -d '{"body":"dog"}'
    fi
else
    echo "$LAST_DATE_STR" > "$FILE"
fi

