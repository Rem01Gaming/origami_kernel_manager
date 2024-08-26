#!/bin/env bash

msg="<b>$title</b><br>
#ci_$version<br><br>
<blockquote>$commit_message</blockquote><br>
<a href="$COMMIT_URL">Commit</a><br>
<a href="$RUN_URL">Workflow run</a>"

file="$1"

curl -s -F document=@$file "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" \
	-F chat_id="$CHAT_ID" \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="$msg"
