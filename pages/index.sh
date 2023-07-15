
source .secrets

HOST=${HTTP_HEADERS["Host"]}
PROTOCOL="https://"
if [[ "$HOST" =~ "localhost"* ]]; then
  PROTOCOL="http://"
fi

htmx_page << EOF
<div class="container">
  <h1>Redemption ARC</h1>
  <p><em>Credit to aryajp for the name</em></p>
  <p>Redemption ARC (Automatically Reading Cooldowns) is a browser-source based UI for Twitch streamers to visualize the cooldowns of channel point redemptions on their stream.</p>
  <h2>Get Started</h2>
  <form hx-post="/register">
  <a href="https://id.twitch.tv/oauth2/authorize?client_id=${TWITCH_CLIENT_ID}&response_type=code&scope=channel:read:redemptions&force_verify=true&redirect_uri=${PROTOCOL}${HOST}/oauth">Connect with Twitch</a>
  </form>
</div>
EOF
