{ persistentDir, confDir, ... }:
{
	home-manager.users.me.programs.bash = {

		enable = true;
		enableCompletion = true;

		historyFile = "${persistentDir}/bash-history";
		historyFileSize = 100000;
		historyControl = [ "ignoredups" ];
		historyIgnore = [
			"ls"
			"cd"
			"exit"
		];

		shellOptions = [
			# append to the history file, don't overwrite it
			"histappend"

			# check the window size after each command and, if necessary,
			# update the values of LINES and COLUMNS.
			"checkwinsize"

			# If set, the pattern "**" used in a pathname expansion context will
			# match all files and zero or more directories and subdirectories.
			"globstar"
		];

		sessionVariables = {
			# this does not work aparently....

			# is needed to that ssh works
			TREM = "xterm";

			# my prompt
			PS1 = ''\[\033[01;34m\]\W\[\033[00m\]\[\033[01;32m\]\[\033[00m\] ❯❯❯ '';

			TEST = "hiiiiiiiiiiiiiiiiiiiiiiiiiii";

			HIII = "hiiiiiiiiiiiiiiiiiiiiii";
		};

		shellAliases = {
			shutdown = "echo try harder.... xD";
			npw = "nmcli c up pw";
			nixre = "sd nixos-rebuild switch --flake ~/work/config/ --impure";
			flex = "neofetch | lolcat";
			kwoche = "curl https://kalenderwoche.celll.net/?api=1; echo";
			psg = "ps -e | grep";
			vilias = "nvim -c 'set syntax=bash' ${confDir}/common/programs/bash.nix";
			stl = "sudo systemctl";
			vim = "nvim";
			sl = "ls";
			virsh = "virsh -c qemu:///system";
			nmgui = ''
				nm-applet 2>&1 > /dev/null &
				stalonetray 2>&1 > /dev/null
				killall nm-applet
			'';
			c = "cd ..";
			ne= "alacritty &";
			cbs = "history | tail -n 2 | head -n 1 | awk '{\$1=\"\"; print \$0}' | cut -c 2- | cb";
			gs = "git status";
			gitlog = "git log --all --graph";
			ipa= ''
				echo -e "IPv4:\n-----------------"
				ip -o a show | cut -d " " -f 2,7 | grep -v : | column -t
				echo -e "\nIPv6:\n-----------------"
				ip -o a show | cut -d " " -f 2,7 | grep : | column -t
			'';
		};

		bashrcExtra = ''
			export TREM="xterm"

			# my prompt
			export PS1="\[\033[01;34m\]\W\[\033[00m\]\[\033[01;32m\]\[\033[00m\] ❯❯❯ "


			# so that programms i spawn from my shell don't have so high cpu priority
			renice -n 9 $$ > /dev/null


			# If not running interactively, don't do anything
			case $- in
				 *i*) ;;
					*) return;;
			esac


			# make less more friendly for non-text input files, see lesspipe(1)
			[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

			# making reverse search "going back" work with strg+s
			stty -ixon


			#################### functions ####################

			# A shortcut function that simplifies usage of xclip.
			# - Accepts input from either stdin (pipe), or params.
			# ------------------------------------------------
			cb() {
			  local _scs_col="\e[0;32m"; local _wrn_col='\e[1;31m'; local _trn_col='\e[0;33m'
			  # Check that xclip is installed.
			  if ! type xclip > /dev/null 2>&1; then
				 echo -e "$_wrn_col""You must have the 'xclip' program installed.\e[0m"
			  # Check user is not root (root doesn't have access to user xorg server)
			  elif [[ "$USER" == "root" ]]; then
				 echo -e "$_wrn_col""Must be regular user (not root) to copy a file to the clipboard.\e[0m"
			  else
				 # If no tty, data should be available on stdin
				 if ! [[ "$( tty )" == /dev/* ]]; then
					input="$(< /dev/stdin)"
				 # Else, fetch input from params
				 else
					input="$*"
				 fi
				 if [ -z "$input" ]; then  # If no input, print usage message.
					echo "Copies a string to the clipboard."
					echo "Usage: cb <string>"
					echo "       echo <string> | cb"
				 else
					# Copy input to clipboard
					echo -n "$input" | xclip -selection c
					# Truncate text for status
					if [ ''${#input} -gt 80 ]; then input="$(echo $input | cut -c1-80)$_trn_col...\e[0m"; fi
					# Print status.
					echo -e "$_scs_col""Copied to clipboard:\e[0m $input"
				 fi
			  fi
			}


			# a little programm, that changes the ssh config to always be able to acces rpi
			function rpi(){
			ssh_dir=~/.ssh
			if [ "$1" == "l" ]
			then
				cp $ssh_dir/rpi/local $ssh_dir/current_rpi_config
			fi

			if [ "$1" == "local" ]
			then
				cp $ssh_dir/rpi/local $ssh_dir/current_rpi_config
			fi

			if [ "$1" == "r" ]
			then
				cp $ssh_dir/rpi/remote $ssh_dir/current_rpi_config
			fi

			if [ "$1" == "remote" ]
			then
				cp $ssh_dir/rpi/remote $ssh_dir/current_rpi_config
			fi

			if [ "$1" == "w" ]
			then
				cp $ssh_dir/rpi/wstunnel $ssh_dir/current_rpi_config
			fi

			}


			# while true -> do cat.....
			function follow (){
			while true;
			do 
				cat $@;
			done
			}


			# little looping func
			function loop (){
			if [ "$1" == "-s" ]
			then
				for (( i=1; i<=$3; i++ )); do sleep $2; ''${@:4}; done
				return
			fi
			case $1 in
				 ${"''"}|*[!0-9]*) 
					# infinit iterations
					while true; do $@; done
					return
				 ;;
				 *) ;;
			esac
			for (( i=1; i<=$1; i++ ));do ''${@:2}; done
			}


			function psk(){
				ps -e | grep $1 | awk '{print $1}' | xargs kill
			}


			sd() {
				if [ "$1" == "" ]
				then
					sudo $(history | tail -n 2 | head -n 1 | awk '{$1=""; print $0}')
				else
					sudo $@
				fi
			}


			# rech
			function rech(){
			python3 -c "print($@)"
			}


			# map
			function map(){
			if [ "$1" == "" ]
			then
			bash ~/work/virtchord/reset
			xmodmap \
				-e "clear control" \
				-e "clear mod1" \
				-e "keycode 64 = Control_L" \
				-e "keycode 37 = Alt_L" \
				-e "add control = Control_L" \
				-e "add mod1 = Alt_L"

			xset r rate 130 85

			elif [ "$1" != "" ]
			then
				echo -en "set-map $1" > ~/work/config/virtchord/pipe1
			fi
			}


			# cf - copy file
			function cf() { cat "$1" | cb; }


			# shorter zathura
			function zath(){
			zathura "$@" 2>/dev/null &
			}


			# shorter mupdf
			function mu(){
			mupdf "$@" 1>/dev/null 2>/dev/null &
			}


			# ipaa
			function ipaa(){
				ip -json addr show $1 | jq -r '.[] | .addr_info[] | select(.family == "inet") | .local'
			}


			#################### completions ####################
			complete -cf sudo
			complete -cf sd
			complete -W "start stop restart status daemon-reload" stl

			# run 
			complete -W "mnt-wechner sync-school wstunnel hibernate p speed-test-nixos-iso bat bstat mnt-files-local mnt-lan-local mnt-files-remote mnt-lan-remote" ru


		'';
	};
}