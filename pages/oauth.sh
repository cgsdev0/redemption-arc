
source .secrets

HOST=${HTTP_HEADERS["host"]}
PROTOCOL="https://"
if [[ "$HOST" =~ "localhost"* ]]; then
  PROTOCOL="http://"
fi

AUTHORIZATION_CODE=${QUERY_PARAMS["code"]}

TWITCH_RESPONSE=$(curl -Ss -X POST \
  "https://id.twitch.tv/oauth2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=${TWITCH_CLIENT_ID}&client_secret=${TWITCH_CLIENT_SECRET}&code=${AUTHORIZATION_CODE}&grant_type=authorization_code&redirect_uri=${PROTOCOL}${HOST}/oauth")

ACCESS_TOKEN=$(echo "$TWITCH_RESPONSE" | jq -r '.access_token')
RESPONSE="<pre>${TWITCH_RESPONSE}</pre>"

if [[ -z "$ACCESS_TOKEN" ]] || [[ "$ACCESS_TOKEN" == "null" ]]; then
  htmx_page << EOF
  <div class="container">
    <h1>Error</h1>
    ${RESPONSE}
    <p>Something went wrong registering for Redemption ARC. :(</p>
    <p><a href="/">Back to Home</a></p>
  </div>
EOF
  return $(status_code 400)
fi

# we have to get the stupid user id
TWITCH_RESPONSE=$(curl -Ss -X GET 'https://id.twitch.tv/oauth2/validate' \
  -H "Authorization: OAuth ${ACCESS_TOKEN}")

USER_ID=$(echo "$TWITCH_RESPONSE" | jq -r '.user_id')
RESPONSE="<pre>${TWITCH_RESPONSE}</pre>"

if [[ -z "$USER_ID" ]] || [[ "$USER_ID" == "null" ]]; then
  htmx_page << EOF
  <div class="container">
    <h1>Error</h1>
    ${RESPONSE}
    <p>Something went wrong registering for Redemption ARC. :(</p>
    <p><a href="/">Back to Home</a></p>
  </div>
EOF
  return $(status_code 400)
fi

# throw away the access token lol it's irrelevant we just made it for fun
ACCESS_TOKEN=""

# now we need to get a DIFFERENT token, unrelated, but actually kinda related lol
# see here: https://dev.twitch.tv/docs/eventsub/manage-subscriptions/#subscribing-to-events
TWITCH_RESPONSE=$(curl -Ss -X POST \
  "https://id.twitch.tv/oauth2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=${TWITCH_CLIENT_ID}&client_secret=${TWITCH_CLIENT_SECRET}&grant_type=client_credentials")

ACCESS_TOKEN=$(echo "$TWITCH_RESPONSE" | jq -r '.access_token')

# register the webhook using the access token
TWITCH_RESPONSE=$(curl -Ss -X POST 'https://api.twitch.tv/helix/eventsub/subscriptions' \
-H "Authorization: Bearer ${ACCESS_TOKEN}" \
-H "Client-Id: ${TWITCH_CLIENT_ID}" \
-H 'Content-Type: application/json' \
-d '{"type":"channel.channel_points_custom_reward.update","version":"1","condition":{"broadcaster_user_id":"'${USER_ID}'"},"transport":{"method":"webhook","callback":"https://arc.bashsta.cc/webhook","secret":"'${TWITCH_EVENTSUB_SECRET}'"}}')

HAS_DATA=$(echo "$TWITCH_RESPONSE" | jq -r '.data')
STATUS=$(echo "$TWITCH_RESPONSE" | jq -r '.status')
RESPONSE="<pre>$TWITCH_RESPONSE</pre>"

if [[ "$HAS_DATA" == "null" ]] && [[ "$STATUS" != "409" ]]; then
  htmx_page << EOF
  <div class="container">
    <h1>Redemption ARC</h1>
    ${RESPONSE}
    <p>Something went wrong setting up the EventSub subscription. :(</p>
    <p><a href="/">Back to Home</a></p>
  </div>
EOF
  return $(status_code 400)
fi

htmx_page << EOF
<div class="container">
  <h1>Redemption ARC</h1>
  <p>Successfully registered. You can now add this URL as a browser source in OBS:</p>
  <form class="footer-link copy">
  <input type="text" value="${PROTOCOL}${HTTP_HEADERS["host"]}/obs/${USER_ID}">
  <button type="button">Copy</button>
</form>
<script type="text/javascript">
(function() {
  var copyButton = document.querySelector('.copy button');
  var copyInput = document.querySelector('.copy input');
  copyButton.addEventListener('click', function(e) {
    e.preventDefault();
    var text = copyInput.select();
    document.execCommand('copy');
  });

  copyInput.addEventListener('click', function() {
    this.select();
  });
})();
</script>
<h3>Example CSS</h3>
<textarea class="example" spellcheck="false">
/* Put this in the browser source Custom CSS */

body {
  background-color: rgba(0, 0, 0, 0);
  margin: 0px auto;
  overflow: hidden;
  display: inline-block;
}

* {
  font-size: 50px !important;
  font-family: Verdana !important;
}

.obs {
  font-size: 50px !important;
  display: flex;
  font-family: Verdana !important;
  flex-direction: column;
}

.cooldown {
  opacity: 80% !important;
  margin-bottom: 12px;
  justify-content: space-between;
  align-items: center;
  display: flex;
  background-color: black;
  padding: 10px;
  color: white;
  padding: 12px;
  border-radius: 20px;
}

.cooldown img {
  height: 50px;
  width: 50px;
  margin-right: 0.5em;
}

.cooldown .time {
  margin-left: 0.5em;
}
</textarea>
</div>
EOF
