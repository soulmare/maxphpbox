#!/usr/bin/env bash
cd /home/Vagrant/maxphp-work/
tmux new-session -d -s monitor
tmux split-window -h -p 40
tmux split-window -v -p 66
#tmux send-keys 'tail -f /var/log/syslog' 'C-m'
tmux send-keys 'sudo su' 'C-m'
tmux split-window -v -p 50
tmux send-keys 'htop' 'C-m'
tmux select-pane -t 0
tmux send-keys 'tail -f /var/log/apache2/error.log' 'C-m'
tmux split-window -v -p 50
tmux send-keys 'tail -f /var/log/apache2/access.log' 'C-m'
tmux select-pane -t 2
tmux attach
#tmux kill-session -t monitor

