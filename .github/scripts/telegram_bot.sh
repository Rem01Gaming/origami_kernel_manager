#!/bin/env bash

msg="**$title**
#ci_$version

>> $commit_message

[Commit]($commit_url)
[Workflow run]($run_url)
"

file="$1"

curl -s -F document=@$file "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" \
	-F chat_id="$CHAT_ID" \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=markdown" \
	-F caption="$msg"
