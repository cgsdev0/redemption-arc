
source .secrets

HOST=${HTTP_HEADERS["host"]}
PROTOCOL="https://"
if [[ "$HOST" =~ "localhost"* ]]; then
  PROTOCOL="http://"
fi

htmx_page << EOF
<div class="container">
  <h1>Redemption ARC</h1>
  <p class="credit"><em>Credit to aryajp for the name</em></p>
  <p class="desc">Redemption ARC (<strong>A</strong>utomatically <strong>R</strong>eading <strong>C</strong>ooldowns) is a browser-source based UI for Twitch streamers to visualize the cooldowns of channel point redemptions on their stream.</p>
  <h2>Get Started</h2>
  <form hx-post="/register">
  <a class="twitch" href="https://id.twitch.tv/oauth2/authorize?client_id=${TWITCH_CLIENT_ID}&response_type=code&scope=channel:read:redemptions&force_verify=true&redirect_uri=${PROTOCOL}${HOST}/oauth">Connect with Twitch</a>
  </form>
</div>
EOF
