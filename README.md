# Chat-GPT-HA-Panel

##Prerequisite knowledge
- [Node-Red](https://nodered.org/)
- [Bash Scripting](https://devhints.io/bash)
- [Home Asssitant](https://www.home-assistant.io/)
-[Crontab](https://man7.org/linux/man-pages/man5/crontab.5.html)

##Prerequisite requirements
- You'll need to have Node Red running and a location on your host machine where you access files that are stored persistantly
- Likewise  you'll need to have Home Assistant running  on your device and a location on your host machine where you access files that are stored persistantly
- A viable method of transferring files from the Node-Red file directory to the Home Assistant file directory. In my case, Node-Red and Home Assistant are hosted on the same machine, so this can be done using a simple bash script
- An OpenAi account

##Environment
Just to paint the picture of how my system is setup, I'm running [Ubuntu Server](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview) on a Raspberry Pi 4. Home Assistant and Node-Red are being ran as docker containers via docker compose; [bind mounts](https://docs.docker.com/storage/bind-mounts/) are created for both of these containers as a means of moving files between the two containers.

##Process
1. With Node Red up and Running, you'll need to install the necessary nodes for this workflow:
  - [Home Assistant](https://docs.docker.com/storage/bind-mounts/)
  - [ChatGPT](https://flows.nodered.org/node/node-red-contrib-custom-chatgpt) 
  
  ![nodes](https://user-images.githubusercontent.com/33399376/229316184-bc243689-c2d6-440f-9f9a-2b533bafe3e8.PNG)
  
2. [Import](https://nodered.org/docs/user-guide/editor/workspace/import-export) the nodered_chatgpt_flow.json from this repository into Node-Red. It should produced the workflow shown below
![Workflow](https://user-images.githubusercontent.com/33399376/229316344-786eb510-8554-4835-8858-16d769e5b179.PNG)
 For this workflow to succeed, you'll need to provide your own API Key and  [Organzation ID](https://platform.openai.com/docs/guides/production-best-practices) as input into the ChatGPT node, and you'll need a relevant [input text](https://www.home-assistant.io/integrations/input_text/) helper to kick off the flow
 ![input_helper](https://user-images.githubusercontent.com/33399376/229316543-55b2f379-326a-4d92-82dd-26c7fb737636.PNG)

What this flow essentially does is awaits for a state change on the text input helper-> passes the input into ChatGPT -> passes the response from ChatGPT into a function which formats the response into valid JSON -> outputs the JSON to /data/json/chat_gpt_response.json in the Node-Red container

3. Ensure that the directory that Node-Red outputs the JSON to exists and ensure that you have created a directory for your Home Assistant instance from which you can store and retrieve these JSON files. In my case, its the "/data/json" directory which is mounted on the host at "/home/ubuntu/docker/homeassistant_mariadb/nodered/data/json/". Likewise, I've created a location for the Home Assistant container where I store my API call; in the docker container this location is "/config/api_calls" which is mounted to the "/home/ubuntu/docker/homeassistant_mariadb/config/api_calls/" directory on my host.

4.
