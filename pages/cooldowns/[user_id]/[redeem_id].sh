
USER_ID="${REQUEST_PATH%/*}"
USER_ID="${USER_ID##*/}"
REDEEM_ID="${REQUEST_PATH##*/}"

DATA=$(cat "data/cooldown_${USER_ID}_${REDEEM_ID}")
COOLDOWN_EXPIRES_AT=$(echo "$DATA" | head -1)
IMAGE=$(echo "$DATA" | head -2 | tail -1)
TITLE=$(echo "$DATA" | head -3 | tail -1)
COLOR=$(echo "$DATA" | tail -1)

if [[ "$IMAGE" != "null" ]]; then
  IMAGE_TEXT="<img src=\"${IMAGE}\" />"
fi

htmx_page << EOF
<div class="cooldown"_="on load
  repeat forever
    js return moment.duration(moment(\`${COOLDOWN_EXPIRES_AT}\`).diff(moment())) end then
    set x to it then
    js(x) return window.formatDuration(x.as(\`seconds\`)) end then
    put it into the first .time in me
    if x is less than 0 then remove me end
    wait 1s
  end">
${IMAGE_TEXT}
<span class="title" style="color: $COLOR;">${TITLE}</span>
<span class="time" ></span>
</div>
EOF
