#!/usr/bin/env bash
set -eu

title() {
    local color='\033[1;37m'
    local nc='\033[0m'
    printf "\n${color}$1${nc}\n"
}

title "Install pip and Ansible"
sudo pacman -Sy
sudo pacman -S --needed ansible

title "Install quantumfate.zsh"
ansible-galaxy install quantumfate.zsh --force

title "Download playbook to /tmp/zsh.yml"
curl https://raw.githubusercontent.com/quantumfate/ansible-role-zsh/master/playbook.yml > /tmp/zsh.yml

title "Provision playbook for root"
ansible-playbook -i "localhost," -c local -b /tmp/zsh.yml

title "Provision playbook for $(whoami)"
ansible-playbook -i "localhost," -c local -b /tmp/zsh.yml --extra-vars="zsh_user=$(whoami)"

title "Finished! Please, restart your shell."
echo ""
