# Dotfiles
My personal configuration

## Table of contents
- [Clone this repo](#clone-this-repo)
- [Install configuration](#install-configuration)


## Clone this repo
Clone the repo with --recursive for github submodules
```/bin/bash
git clone --recursive
```

## Install configuration
The installation of this configuration is handled by the ./provisioning/provision.sh script.

TAKE CARE! You need to clone this repository (NOT copy it from some local friends' PC), otherwize Neovim could have problems due to .gitignored files untracked in the local repo you copied.

## Testing with Vagrant
When testing with Vagrant, take care that in the Vagrantfile the config of the provisioning scripts assumes the repo to be cloned with path ``~/repos/dotfiles/``.
