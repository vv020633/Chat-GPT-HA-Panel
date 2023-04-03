# Chat-GPT-HA-Panel

## Prerequisite knowledge
- [Node-Red](https://nodered.org/)
- [Bash Scripting](https://devhints.io/bash)
- [Home Asssitant](https://www.home-assistant.io/)
- [Crontab](https://man7.org/linux/man-pages/man5/crontab.5.html)

## Prerequisite requirements
- You'll need to have Node Red running and a location on your host machine where you access files that are stored persistantly
- Likewise  you'll need to have Home Assistant running  on your device and a location on your host machine where you access files that are stored persistantly
- A viable method of transferring files from the Node-Red file directory to the Home Assistant file directory. In my case, Node-Red and Home Assistant are hosted on the same machine, so this can be done using a simple bash script
- An OpenAi account

## Environment
Just to paint the picture of how my system is setup, I'm running [Ubuntu Server](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview) on a Raspberry Pi 4. Home Assistant and Node-Red are being ran as docker containers via docker compose; [bind mounts](https://docs.docker.com/storage/bind-mounts/) are created for both of these containers as a means of moving files between the two containers.

## Process
1. With Node Red up and Running, you'll need to install the necessary nodes for this workflow:
  - [Home Assistant](https://docs.docker.com/storage/bind-mounts/)
  - [ChatGPT](https://flows.nodered.org/node/node-red-contrib-custom-chatgpt) 
  
 ![nodes](https://user-images.githubusercontent.com/33399376/229354686-3900e369-f157-41d9-826c-a2b782e6691d.PNG)

  
2. [Import](https://nodered.org/docs/user-guide/editor/workspace/import-export) the nodered_chatgpt_flow.json from this repository into Node-Red. It should produce the workflow shown below
![Workflow](https://user-images.githubusercontent.com/33399376/229316344-786eb510-8554-4835-8858-16d769e5b179.PNG)
 For this workflow to succeed, you'll need to provide your own API Key and  [Organzation ID](https://platform.openai.com/docs/guides/production-best-practices) as input into the ChatGPT node, and you'll need a relevant [input text](https://www.home-assistant.io/integrations/input_text/) helper to kick off the flow
 ![input_helper](https://user-images.githubusercontent.com/33399376/229316543-55b2f379-326a-4d92-82dd-26c7fb737636.PNG)

What this flow essentially does is awaits for a state change on the text input helper-> passes the input into ChatGPT -> passes the response from ChatGPT into a function which formats the response into valid JSON -> outputs the JSON to /data/json/chat_gpt_response.json in the Node-Red container

3. Ensure that the directory that Node-Red outputs the JSON to exists and ensure that you have created a directory for your Home Assistant instance from which you can store and retrieve these JSON files. In my case, its the "/data/json" directory which is mounted on the host at "/home/ubuntu/docker/homeassistant_mariadb/nodered/data/json/".

` mkdir /home/ubuntu/docker/homeassistant_mariadb/nodered/data/json/`
  
Likewise, I've created a location for the Home Assistant container where I store my API call; in the docker container this location is "/config/api_calls" which is mounted to the "/home/ubuntu/docker/homeassistant_mariadb/config/api_calls/" directory on my host.

` mkdir /home/ubuntu/docker/homeassistant_mariadb/config/api_calls/`


4. Navigate to the directory that the "move_gpt_answer.sh" shell script from this repository is located on your local machine. In my case, I've got the files from this repo stored in a local directory at "/home/ubuntu/github_repos/chatgpt_ha_panel". You'll want to ensure that this file belongs to the same user or group that your Home Assistant and Node Red instances belong to in order to avoid permission errors.
5. Make "move_gpt_answer.sh" executable

  ` chmod +x move_gpt_answer.sh`
  
This is a very short bash script that runs indefinitely. Every half second this script checks if the JSON file exists in the Node-Red directory and if the file exists, it will be moved to the Home Assistant api_calls directory:

![bash_script](https://user-images.githubusercontent.com/33399376/229351955-17d2740e-3952-4c58-af92-07da4a5cba92.PNG)

Ensure that you change the directory's in the bash script to point to the relevant directories on your own machine.

6. You can run the script in the background by using this command:

` ./move_gpt_answer.sh & `

but to ensure that this script continues to run outside of just this session and on every reboot, a quick addition to the cronfile can solve this. Use the below command to open up the cronfile

` crontab -e `

Enter the following to the bottom of the cronfile to call this script on every reboot

` @reboot /home/your_shell_script_directory/move_gpt_answer.sh `

Of course replacing the directory name with that of your own.

7. reboot your device so that the above cronjob will run

8. At this point, all that's left is to display the data from the Home Assistant api_calls location within Home Assistant using the [command line](https://www.home-assistant.io/integrations/sensor.command_line/) sensor. The following snippets will need to be added to your Home Assistant configuration.yaml file:

![configuration_yaml](https://user-images.githubusercontent.com/33399376/229352943-cae35944-74e2-4f1b-89ef-229ce1f24091.PNG)

The [allow_list_external_dirs](https://www.home-assistant.io/docs/configuration/basic/) is used to point allow Home Assistant to use the API calls folder (located at "/config/api_calls" in my docker instance) and the command line sensor is used to call a [cat](https://www.geeksforgeeks.org/cat-command-in-linux-with-examples/) command on the chat_gpt_response.json file which is now accesssible from my Home Assistant Docker instance. This will call this command every second to check for the json file as well as store the response in tha attributes of this sensor (the state/value has a 255 character limit). Bear in mind that the directories I've used here are the docker directories that are mounted to the directories on the host, so the directories that you're using and method of achieveing the same result would differ on a supervised system.

9. Restart your Home Assistant instance/configuration and if all has gone well, you should now be able to view the response from chatgpt in your Home Assistant Developer Tools (States):

![gpt_response](https://user-images.githubusercontent.com/33399376/229353710-93a71ec9-fd5a-4c89-9132-f875005d674e.PNG)

10. To actually display the content within Home Assistant, I've placed the text_input helper within an "entities" card, and the gpt_json_response sensor into a markdown card. Both cards are contained within a vertical stack card. My exact configuration for this card is stored in this repo within the "panel.yaml" file (minus any [css styling](https://github.com/thomasloven/lovelace-card-mod))
![panel config](https://user-images.githubusercontent.com/33399376/229354504-b368794d-38ce-4d67-9354-d0ab4451e138.PNG)

Within the "content" of the markdown card, you can simply use a [template](https://www.home-assistant.io/integrations/template/) to display the attributes of the json response. ENJOY!
