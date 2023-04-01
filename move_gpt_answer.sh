#! /bin/bash
while true
do
	sleep .5
	[ -f /home/ubuntu/docker/homeassistant_mariadb/nodered/data/json/chat_gpt_response.json ] && mv /home/ubuntu/docker/homeassistant_mariadb/nodered/data/json/chat_gpt_response.json /home/ubuntu/docker/homeassistant_mariadb/config/api_calls/chat_gpt_response.json
done
