#!/usr/bin/env bash
tmux new-session -d -s maxphp
tmux split-window -h -p 40
tmux send-keys 'vagrant up' 'C-m'
tmux split-window -v -p 40
tmux send-keys 'htop' 'C-m'
tmux select-pane -t 0
tmux attach
#tmux kill-session -t maxphp

