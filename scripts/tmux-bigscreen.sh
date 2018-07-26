#!/usr/bin/env bash
cd /home/Vagrant/maxphp-work/
tmux new-session -d -s maxphp
tmux send-keys 'vim' 'C-m'
tmux split-window -h -p 50
#tmux send-keys 'cd /home/Vagrant/maxphp-work/' 'C-m'
tmux split-window -v -p 66
tmux split-window -v -p 50
tmux send-keys 'vagrant up;vagrant ssh' 'C-m'
tmux send-keys 'htop' 'C-m'
tmux split-window -h -p 50
tmux send-keys 'htop' 'C-m'
tmux select-pane -t 1
tmux attach
#tmux kill-session -t maxphp

