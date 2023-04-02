#! /bin/bash
while true
do
	sleep .5
	[ -f /home/your_nodered_directory/chat_gpt_response.json ] && mv /home/your_nodered_directory/chat_gpt_response.json /home/your_homeassistant_api_calls_directory/chat_gpt_response.json
done
