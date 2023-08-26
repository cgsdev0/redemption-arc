# headers

source .secrets

SIGNATURE=${HTTP_HEADERS['twitch-eventsub-message-signature']}
TOPIC=${HTTP_HEADERS['twitch-eventsub-subscription-type']}
MSG_ID=${HTTP_HEADERS['twitch-eventsub-message-id']}
TIMESTAMP=${HTTP_HEADERS['twitch-eventsub-message-timestamp']}
TYPE=${HTTP_HEADERS['twitch-eventsub-message-type']}
HMAC_MSG="${MSG_ID}${TIMESTAMP}${REQUEST_BODY}"

SIGNATURE2="sha256=$(echo -n "$HMAC_MSG" | openssl sha256 -hmac "$TWITCH_EVENTSUB_SECRET" | cut -d' ' -f2)"

if [[ -z "$SIGNATURE" ]] || [[ -z "$SIGNATURE2" ]] || [[ "$SIGNATURE" != "$SIGNATURE2" ]]; then
  echo "invalid signature"
  return $(status_code 400)
fi

if [[ "$TYPE" == "webhook_callback_verification" ]]; then
  CHALLENGE=$(echo "$REQUEST_BODY" | jq -r '.challenge')
  CHALLEN=$(echo "$CHALLENGE" | wc -c)
  printf "%s\r\n" "Content-Type: $CHALLEN"
  printf "\r\n"
  printf "\r\n"
  echo "$CHALLENGE"
  return $(status_code 200)
fi

printf "\r\n"
printf "\r\n"

if [[ "$TYPE" == "notification" ]]; then
  USER_ID=$(echo "$REQUEST_BODY" | jq -r '.event.broadcaster_user_id')
  COOLDOWN_EXPIRES_AT=$(echo "$REQUEST_BODY" | jq -r '.event.cooldown_expires_at')
  IMG=$(echo "$REQUEST_BODY" | jq -r '.event.image.url_4x')
  TITLE=$(echo "$REQUEST_BODY" | jq -r '.event.title' | sed "s/'/\\&apos\\;/g" | sed "s/</\\&lt\\;/g" | sed "s/>/\\&gt\\;/g" | sed "s/\"/\\&quot\\;/g")
  STOCK=$(echo "$REQUEST_BODY" | jq -r '.event.is_in_stock')
  REDEEM_ID=$(echo "$REQUEST_BODY" | jq -r '.event.id')
  COLOR=$(echo "$REQUEST_BODY" | jq -r '.event.background_color')
  FILE="data/cooldown_${USER_ID}_${REDEEM_ID}"
  if [[ "$STOCK" == "true" ]] && [[ "$COOLDOWN_EXPIRES_AT" != "null" ]]; then
    # stick it in the database
    printf "%s\n%s\n%s\n%s\n" "${COOLDOWN_EXPIRES_AT}" "${IMG}" "${TITLE}" "${COLOR}" > "$FILE"
    # publish it to subscribers
    COOLDOWN=$(component "/cooldowns/${USER_ID}/${REDEEM_ID}" | tr '\n' ' ')
    event cooldown "$COOLDOWN" | publish "$USER_ID"
  fi
  return $(status_code 204)
fi
