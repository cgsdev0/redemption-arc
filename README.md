# Redemption ARC

_Credit to aryajp for the name_

Redemption ARC (**A**utomatically **R**eading **C**ooldowns) is a browser-source based UI for Twitch streamers to visualize the cooldowns of channel point redemptions on their stream.

Written for https://codejam.timeenjoyed.dev/ 2023 in [a single Twitch stream](https://www.youtube.com/watch?v=HIEd60TOYLY)

## Demo

https://github.com/cgsdev0/redemption-arc/assets/4583705/3a21d222-0e2b-4d3e-9c04-40632459b121

(special thanks to https://twitch.tv/TheCoppinger)

## Usage

1. Go to [the ARC website](https://arc.bashsta.cc)
2. Connect your Twitch account
3. copy paste the given URL into a browser source
4. set the browser source size to 1920x1080 (or whatever resolution you stream at)
5. (optional) copy paste the provided example CSS into the browser source settings

you now have cooldowns for your channel point rewards! 🥳

## Running Locally

You will first need to create a folder in the root folder of the project called `.secrets`. The file should look like this:
```
TWITCH_CLIENT_ID=< obtained from twitch developer console >
TWITCH_CLIENT_SECRET=< obtained from twitch developer console >
TWITCH_EVENTSUB_SECRET=< a random string of 30-100 characters >
```

Once you have that, the easiest (and safest) way to get the project running is to use Docker. For example:
```
docker build -t redemptionarc .
docker run -p 3000:3000 redemptionarc
```

<hr>

Powered by [BASH stack](https://github.com/cgsdev0/bash-stack)
<p align="center"><img src="https://user-images.githubusercontent.com/4583705/223574260-c94bafb3-82af-4adf-8d71-d8ef7724d287.png" alt="BASH Stack Logo" /></p>




