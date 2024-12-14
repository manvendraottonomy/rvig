#!/bin/bash

#Colours
red="\033[00;31m"
RED="\033[01;31m"

green="\033[00;32m"
GREEN="\033[01;32m"

brown="\033[00;33m"
YELLOW="\033[01;33m"

blue="\033[00;34m"
BLUE="\033[01;34m"

purple="\033[00;35m"
PURPLE="\033[01;35m"

cyan="\033[00;36m"
CYAN="\033[01;36m"

white="\033[00;37m"
WHITE="\033[01;37m"

NC="\033[00m"


meta_data="/home/ottonomyio/worlds/"
pid_file="/tmp/gnome_terminal_pids.txt"
global_world="NULL"
global_zone=""
global_utm1=0
global_utm2=0

kill_all_terminals(){
            # Kill all terminals
            while IFS= read -r line; do
                for pid in $line; do
                        if kill -0 "$pid" >/dev/null 2>&1; then
                                #echo "Killing PID: $pid"
                                kill "$pid"
        #                else
                                #echo "PID $pid does not exist or you do not have permission to kill it."
                        fi
                done 
                done < "$pid_file"
	rm /tmp/gnome_terminal_pids.txt
}
echo "Processing bag file: "

extract_map_from_bag(){
	echo "$RED   By Default its taking Downloads Path So enter the bag name only$WHITE"
	#read -p "$(echo "$brown   Please provide the bag name: $WHITE") " bag_path
  bag_path=$1
	echo "$RED   Bag Path is : $bag_path $WHITE"
	#read -p "$(echo "$brown   Enter the Robot Name(please enter the exact robot name which is on the site and collect that bag ### MAKE SURE YOU DOUBLE CHECK ): $WHITE")" robot_name
	#read -p "$(echo "$PURPLE   Do you Want to create default robot of $robot_name? (y/n): $WHITE")" default_robot
	# Source file path
	echo "$green   Detecting robot name from bag.... $WHITE"

	gnome-terminal --tab --title="Roscore" -- bash -c "echo -e '\e[1;31mCommand running: \e[1;33mroscore\e[0m';roscore; $SHELL"
        sleep 1	
	rosbag play $HOME/Downloads/$bag_path --clock --duration=10.0 &

	TOPIC_NAME="/ottonomy_robot_node/robot_info"

	# Function to extract the 'id' field from the topic messages
	get_id_from_topic() {
    	# Use rostopic echo to get the messages and grep to find the id
    		rostopic echo -n 1 "$TOPIC_NAME" | grep 'id:' | awk '{print $2}' | tr -d '"'
	}

	# Call the function and store the result
	robot_name=$(get_id_from_topic)

	echo "$RED   Please wait for 10 sec $WHITE "
	sleep 10

	# Print the extracted id value
	echo "$RED   Detected : $green $robot_name $RED from the bag $WHITE"
	source_file="/home/ottonomyio/rover_stack/rover_ws/src/system_parameters/robots/$robot_name"

	ouster_metadata="$HOME/rover_stack/rover_ws/src/system_parameters/robots/$robot_name/ouster_metadata"

	if [ ! -f "$ouster_metadata" ]; then
		echo "$RED Ouster Metadata doesnt exits at: $ouster_metadata $WHITE"
		echo "$RED Pull the system_parameter and update the ouster metadata $WHITE"
		exit 1
	else
		echo "$RED Ouster Metadata exits at: $ouster_metadata $WHITE"
	fi

	# Destination symlink path
	symlink_path="/home/ottonomyio/rover_stack/rover_ws/src/system-tools/ottonomy_parameters/default_robot"

	# Create the symlink
	#if [ "$default_robot" = "y" ]; then
    	#rm "$symlink_path"
    	#ln -s "$source_file" "$symlink_path"

    	# Optionally, you can check if the symlink creation was successful
    	#if [ $? -eq 0 ]; then
        #	echo "$RED   Symlink created successfully!$WHITE"
    	#else
        #	echo "$RED   Failed to create symlink.$WHITE"
    	#fi
    	#cd ~/
	#else
        #	echo "$RED   Using previous symlink$WHITE"
        #	cd ~/
	#fi

	#read -p "Do you want to create the default robot of $robot_name? (y/n): " default_robot

	# Check user input and proceed if 'y' is entered
	#if [ "$default_robot" == "y" ]; then
    	# Change directory to ottonomy_parameters

    	# Create symbolic link for the default robot
#    		roscd ottonomy_parameters
#    		if ! ln -s /home/ottonomyio/rover_stack/rover_ws/src/system_parameters/robots/$robot_name default_robot; then
#        	echo "Error: Failed to create symbolic link for the default robot." >&2
#        	exit 1
#    	fi

    	# Return to home directory
    	cd ~/
#	else
#    		echo "No changes made."
#	fi

	#read -p "Is the front camera available? (y/n): " front
	#read -p "Is the left camera available? (y/n): " left
	#read -p "Is the right camera available? (y/n): " right

	#gnome-terminal --tab --title="Roscore" -- bash -c "echo -e '\e[1;31mCommand running: \e[1;33mroscore\e[0m';roscore; $SHELL"
	sleep 1

	gnome-terminal --tab --title="Sim Time & Decompress" -- bash -c "echo -e '\e[1;31mCommand running: \e[1;33mrosparam set /use_sim_time true && ./decompress.sh\e[0m';source ~/rover_stack/rover_ws/devel/setup.bash;rosparam set /use_sim_time true;roscd build_map/scripts;./decompress.sh; $SHELL"

#	gnome-terminal --tab --title="Fake cameras" -- bash -c "echo -e '\e[1;31mCommand running: \e[1;33m./publish_top_front.sh || ./publish_top_left.sh || ./publish_top_right.sh\e[0m';roscd build_map/scripts $SHELL"
	sleep 0.1

#	if [ "$front" = "n" ]; then
#    		cd /home/ottonomyio/rover_stack/rover_ws/src/mapping-tools/build_map/scripts
#    		gnome-terminal --tab --title="Top_front" -- bash -c "echo -e '\e[1;31mCommand running: \e[1;33m./publish_top_front\e[0m';./publish_top_front.sh; $SHELL"
#    		sleep 0.1
#	fi

#	if [ "$left" = "n" ]; then
#    		cd /home/ottonomyio/rover_stack/rover_ws/src/mapping-tools/build_map/scripts
#    		gnome-terminal --tab --title="Top_left" -- bash -c "echo -e '\e[1;31mCommand running: \e[1;33m./publish_top_left\e[0m';./publish_top_left.sh; $SHELL"
#    		sleep 0.1
#	fi

#	if [ "$right" = "n" ]; then
#    		cd /home/ottonomyio/rover_stack/rover_ws/src/mapping-tools/build_map/scripts
#    	gnome-terminal --tab --title="Top_right" -- bash -c "echo -e '\e[1;31mCommand running: \e[1;33m./publish_top_right\e[0m';./publish_top_right.sh; $SHELL"
#    	sleep 0.1
#	fi

	sleep 0.1


	gnome-terminal --tab --title="bringup_agx" -- bash -c "echo -e '\e[1;31mCommand running: \e[1;33mroslaunch bringup bringup_agx.launch\e[0m';roslaunch bringup bringup_agx.launch; $SHELL"
	sleep 0.1

	gnome-terminal --tab --title="Metadata" -- bash -c "echo -e '\e[1;31mCommand running: \e[1;33mroslaunch ouster_ros replay.launch  metadata:=$HOME/rover_stack/rover_ws/src/system_parameters/robots/$robot_name/ouster_metadata\e[0m';roslaunch ouster_ros replay.launch  metadata:=$HOME/rover_stack/rover_ws/src/system_parameters/robots/$robot_name/ouster_metadata; $SHELL"
	sleep 0.1

	gnome-terminal --tab --title="Rosbag" -- bash -c "echo -e '\e[1;31mCommand running: \e[1;33mrosbag play $HOME/Downloads/$bag_path /tf:=/tf_ --clock\e[0m';rosbag play $HOME/Downloads/$bag_path /tf:=/tf_ --clock; $SHELL"
	sleep 0.1

#	read -p "$(echo "$PURPLE   Did you updated the imu frequency ?? (y/n): $WHITE")" imu_status
	# if [ "$imu_status" = "n" ]; then
  #       	echo "$RED   Update the frequency first (command = rostopic hz /imu/data) $white"
  #       	echo "$RED   Then update the frequency in the build_map/config/lidar_mapping.yaml $WHITE"
  #       	echo "$RED   Update the imuRate: 500/60 $WHITE"
	# fi
#	read -p "$(echo "$PURPLE   Do you want to proceed with Continue mapping? (y/n): $WHITE")" continue_mapping

	# if [ "$continue_mapping" = "y" ]; then
  #       	gnome-terminal --tab --title="Lidar Mapping" -- bash -c "echo -e '\e[1;31mCommand running: \e[1;33mroslaunch build_map lidar_mapping.launch\e[0m';roslaunch build_map lidar_mapping.launch continue_mappping:=true; $SHELL"
  #       	sleep 0.1
  #       	echo -e "$RED With continue mapping$WHITE"
#	else
        	gnome-terminal --tab --title="Lidar Mapping" -- bash -c "echo -e '\e[1;31mCommand running: \e[1;33mroslaunch build_map lidar_mapping.launch\e[0m';roslaunch build_map lidar_mapping.launch; $SHELL"
        	sleep 0.1
        	echo "$RED Without continue mapping $WHITE"
#	fi
	echo $(pgrep -f "roscore") >> "$pid_file"
	echo $(pgrep -f "./decompress.sh") >> "$pid_file"
	echo $(pgrep -f "bringup") >> "$pid_file"
	echo $(pgrep -f "./publish_top") >> "$pid_file"
	echo $(pgrep -f "rosbag") >> "$pid_file"
	echo $(pgrep -f "build_map") >> "$pid_file"
	echo $(pgrep -f "ouster_ros") >> "$pid_file"



}

	extract_map_from_bag $1
	read -p "$(echo "$PURPLE   If the bag is finished playing then press: (y) $WHITE ") " bag_completion
	if [ "$bag_completion" = "y" ]; then
	       save_map_in_world n
	       kill_all_terminals
       	fi	       
	

exit 0
