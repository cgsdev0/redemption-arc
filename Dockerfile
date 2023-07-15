FROM ubuntu

RUN apt-get update && apt-get install ucspi-tcp curl jq

EXPOSE 3000

COPY . /app

CMD [ "/app/start.sh" ]
