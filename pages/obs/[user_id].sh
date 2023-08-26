
USER_ID="${PATH_VARS[user_id]}"

COOLDOWNS=$(find data -type f -iname "cooldown_${USER_ID}_*")
for COOLDOWN in $COOLDOWNS; do
  REDEEM_ID=$(echo "$COOLDOWN" | cut -d'_' -f3)
  CHILDREN="${CHILDREN}$(component "/cooldowns/${USER_ID}/${REDEEM_ID}")"
done

HIDE_LOGO=true
NO_STYLES=true
htmx_page << EOF
<div class="obs" hx-sse="connect:/sse/${USER_ID} swap:cooldown" hx-swap="afterend">
  ${CHILDREN}
</div>
EOF
