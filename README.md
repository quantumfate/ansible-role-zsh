# quantumfate/ansible-role-zsh

This is a detached fork from [viasite-ansible/ansible-role-zsh](History.md).

![Build Status](https://github.com/quantumfate/ansible-role-zsh/actions/workflows/ci.yml/badge.svg)

Tested on Debian 10, Ubuntu 16.04, Ubuntu 18.04, Ubuntu 20.04, macOS 10.12, CentOS 8, ArchLinux 5.18.16.

- [Easy Zero-knowlegde Install](#zero-knowledge-install)
- [Features](#features)
- [Install](#install)
- [Theming](#theming)
- [Basic Configuration](#basic-bonfiguration)
- [Additional Configuration](#additional-bonfiguration)
- [Notes](#notes)
- [Known Bugs](#known-bugs)


## Zero-knowledge install
If you using Ubuntu or Debian and not familiar with Ansible, you can just execute [install.sh](install.sh) on target machine:
```
curl https://raw.githubusercontent.com/quantumfate/ansible-role-zsh/master/install.sh | bash
```
It will install pip3, ansible and setup zsh for root and current user.

if you are using Manjaro or Arch you can use the script [install_arch.sh](install_arch.sh): 

```
curl https://raw.githubusercontent.com/quantumfate/ansible-role-zsh/master/install_arch.sh | bash
```

Then [configure terminal application](#configure-terminal-application).

## Features
- theming
- customize powerlevel10k theme prompt segments and colors
- default colors tested with solarized dark and default grey terminal in putty
- add custom prompt elements from yml
- custom zsh config with `~/.zshrc.local` or `/etc/zshrc.local`
- load `/etc/profile.d` scripts
- install only plugins that useful for your machine. For example, plugin `docker` will not install if you have not Docker

### Includes:
- [zsh](https://www.zsh.org/)
- [antigen](https://github.com/zsh-users/antigen)
- [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [unixorn/autoupdate-antigen.zshplugin](https://github.com/unixorn/autoupdate-antigen.zshplugin)
- [ytet5uy4/fzf-widgets](https://github.com/ytet5uy4/fzf-widgets)
- [urbainvaes/fzf-marks](https://github.com/popstas/urbainvaes/fzf-marks)


## Install
Zero-knowledge install: see [above](#zero-knowledge-install).

### Manual install

0. [Install Ansible](http://docs.ansible.com/ansible/intro_installation.html).
For Ubuntu:
``` bash
sudo apt update
sudo apt install python3-pip -y
sudo pip3 install ansible
```

1. Download role:
```
ansible-galaxy install quantumfate.zsh --force
```

2. Write playbook or use [playbook.yml](playbook.yml):
```
- hosts: all
  vars:
    zsh_antigen_bundles_extras:
      - nvm
      - joel-porquet/zsh-dircolors-solarized
    zsh_autosuggestions_bind_key: "^U"
  roles:
    - quantumfate.zsh
```

3. Provision playbook:
```
ansible-playbook -i "localhost," -c local -K playbook.yml
```

If you want to provision role for root user on macOS, you should install packages manually:
```
brew install zsh git wget
```

It will install zsh environment for ansible remote user. If you want to setup zsh for other users,
you should define variable `zsh_user`:

Via playbook:
```
- hosts: all
  roles:
    - { role: quantumfate.zsh, zsh_user: otheruser }
    - { role: quantumfate.zsh, zsh_user: thirduser }
```

Or via command:
```
ansible-playbook -i hosts zsh.yml -e zsh_user=otheruser
```

4. Install fzf **without shell extensions**, [download binary](https://github.com/junegunn/fzf-bin/releases)
or `brew install fzf` for macOS.

Note: I don't use `tmux-fzf` and don't tested work of it.

### Multiuser shared install
If you have 10+ users on host, probably you don't want manage tens of configurations and thousands of files.

In this case you can deploy single zsh config and include it to all users.

It causes some limitations:

- Users have read only access to zsh config
- Users cannot disable global enabled bundles
- Possible bugs such cache write permission denied
- Possible bugs with oh-my-zsh themes

For install shared configuration you should set `zsh_shared: yes`.
Configuration will install to `/usr/share/zsh-config`, then you just can include to user config:

``` bash
source /usr/share/zsh-config/.zshrc
```

You can still provision custom configs for several users.

## Theming

By default [pk10 theme](https://github.com/romkatv/powerlevel10k) will be used. Follow their [docs](https://github.com/romkatv/powerlevel10k/blob/master/README.md) for additional theme configuration.


### Using a different theme

You can use any theme. Just use the following variable and your theme will be applied after reloading your shell.

```yaml
zsh_antigen_theme: <yourtheme>
```

## Basic Configuration
You should not edit `~/.zshrc`! 
Add your custom config to `~/.zshrc.local` (per user) or `/etc/zshrc.local` (global).
`.zshrc.local` will never touched by ansible.

### Distros that make use of /etc/skel

By default this role will write everything to `.zshrc` and your changes belong into `~/.zshrc.local`. 
Tho, there are some distros that use the script `/etc/skel` to configure your home directory. 
To keep your changes from being affected set the following variables:

```yaml
zsh_personal_config: true
zsh_alternative_name: /.zshrc_personal # Optional | Use the value skel uses to load your personal configs
```

### Hotkeys
You can view hotkeys in [defaults/main.yml](defaults/main.yml), `zsh_hotkeys`.

Sample hotkey definitions:
``` yaml
- { hotkey: '^r', action: 'fzf-history' }
# with dependency of bundle
- { hotkey: '`', action: autosuggest-accept, bundle: zsh-users/zsh-autosuggestions }
```

Useful to set `autosuggest-accept` to <kbd>`</kbd> hotkey, but it conflicts with Midnight Commander (break Ctrl+O subshell).

You can add your custom hotkeys without replace default hotkeys with `zsh_hotkeys_extras` variable:
``` yaml
zsh_hotkeys_extras:
  - { hotkey: '^[^[[D', action: backward-word } # alt+left
  - { hotkey: '^[^[[C', action: forward-word } # alt+right
  # Example <Ctrl+.><Ctrl+,> inserts 2nd argument from end of prev. cmd
  - { hotkey: '^[,', action: copy-earlier-word } # ctrl+,
```

#### Default hotkeys from plugins:
- <kbd>&rarr;</kbd> - accept autosuggestion
- <kbd>Ctrl+Z</kbd> - move current application to background, press again for return to foreground
- <kbd>Ctrl+G</kbd> - jump to bookmarked directory. Use `mark` in directory for add to bookmarks
- <kbd>Ctrl+R</kbd> - show command history
- <kbd>Ctrl+@</kbd> - show all fzf-widgets
- <kbd>Ctrl+@,C</kbd> - fzf-change-dir, press fast!
- <kbd>Ctrl+\\</kbd> - fzf-change-recent-dir
- <kbd>Ctrl+@,G</kbd> - fzf-change-repository
- <kbd>Ctrl+@,F</kbd> - fzf-edit-files
- <kbd>Ctrl+@,.</kbd> - fzf-edit-dotfiles
- <kbd>Ctrl+@,S</kbd> - fzf-exec-ssh (using your ~/.ssh/config)
- <kbd>Ctrl+@,G,A</kbd> - fzf-git-add-file
- <kbd>Ctrl+@,G,B</kbd> - fzf-git-checkout-branch
- <kbd>Ctrl+@,G,D</kbd> - fzf-git-delete-branches

## Additional configuration

### Aliases
You can use aliases for your command with easy deploy.
Aliases config mostly same as hotkeys config:

``` yaml
zsh_aliases_extras:
  - { alias: 'dfh', action: 'df -h | grep -v docker' }
# with dependency of bundle and without replace default asiases
zsh_aliases_extras:
  - { alias: 'dfh', action: 'df -h | grep -v docker', bundle: }
```

Providing the name is not mandatory.

### Sources

You can add more custom defined sources by setting the following variable:

```yaml
zsh_sources_extras:
  - { name: 'Wal Colors', path: '$HOME/.cache/wal/colors.sh'}
```

### Export Variable

You can add more expors by setting the following variable:

```yaml
zsh_export_vars_extras:
  - { name: 'Default editor', variable: 'EDITOR', value: 'nvim'}
```

### PATH Variable

Append your paths to the path variable:

```yaml
zsh_paths_extras:
  - { name: 'Lua language server', path: '/usr/bin/lua-language-server'}
```

### Configure bundles
You can check default bundles in [defaults/main.yml](defaults/main.yml#L37).
If you like default bundles, but you want to add your bundles, use `zsh_antigen_bundles_extras` variable (see example playbook above).
If you want to remove some default bundles, you should use `zsh_antigen_bundles` variable.

Format of list matches [antigen](https://github.com/zsh-users/antigen#antigen-bundle). All bellow variants valid:
``` yaml
- docker # oh-my-zsh plugin
- zsh-users/zsh-autosuggestions # plugin from github
- zsh-users/zsh-autosuggestions@v0.3.3 # plugin from github with fixed version
- ~/projects/zsh/my-plugin --no-local-clone # plugin from local directory
```

Note that bundles can use conditions for load. There are two types of conditions:

1. Command conditions. Just add `command` to bundle:
``` yaml
- { name: docker, command: docker }
- name: docker-compose
  command: docker-compose
```
Bundles `docker` and `docker-compose` will be added to config only if commands exists on target system.

2. When conditions. You can define any ansible conditions as you define in `when` in tasks:
``` yaml
# load only for zsh >= 4.3.17
- name: zsh-users/zsh-syntax-highlighting
  when: "{{ zsh_version is version_compare('4.3.17', '>=') }}"
# load only for macOS
- { name: brew, when: "{{ ansible_os_family != 'Darwin' }}" }
```
Note: you should wrap condition in `"{{ }}"`


### Custom config
You can add any code in variable `zsh_custom_before`, `zsh_custom_after`.

- zsh_custom_before - before include antigen.zsh
- zsh_custom_after - before include ~/.zshrc.local

## Notes

### Midnight Commander Solarized Dark skin
If you using Solarized Dark scheme and `mc`, you should want to install skin, then set `zsh_mc_solarized_skin: yes`

### Demo install in Vagrant
You can test work of role before install in real machine.
Just execute `vagrant up`, then `vagrant ssh` for enter in virtual machine.

Note: you cannot install vagrant on VPS like Digital Ocean or in Docker. Use local machine for it.
[Download](https://www.vagrantup.com/downloads.html) and install vagrant for your operating system.

## Known bugs
### `su username` caused errors
See [antigen issue](https://github.com/zsh-users/antigen/issues/136).
If both root and su user using antigen, you should use `su - username` in place of `su username`.

Or you can use bundled alias `suser`.

Also, you can try to fix it, add to `~/.zshrc.local`:
```
alias su='su -'
```
But this alias can break you scripts, that using `su`.

