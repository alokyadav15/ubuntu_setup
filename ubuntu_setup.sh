#!/usr/bin/env bash
clear
echo "################################################"
echo ""
echo "Ubuntu Setup Script"
echo "Author : Alok Yadav"
echo "version : 0.1"

sleep 2
clear

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# initial update and upgrade
function update_and_upgrade {
    echo "Updating and upgrading system"
    apt update
    apt upgrade -y
    apt-get dist-upgrade -y
}

function install_build_tools {
    clear
    echo "Installing linux header and build tools"
    sudo apt-get install linux-headers-$(uname -r) -yy
    apt-get install build-essential curl git ssh openssh-server openssh-client -y
}

function add_repositories {
	# TODO check if already exist
    clear 
    echo "adding repositories and ppa"
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/chrome.list
      
    #firefox
    sudo add-apt-repository ppa:mozillateam/firefox-next -y
    
    # webup8 java
    sudo add-apt-repository ppa:webupd8team/java -y
    
    #sublime 
    
    sudo apt-get install apt-transport-https
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    # opera
    
    sudo add-apt-repository 'deb https://deb.opera.com/opera-stable/ stable non-free'
    wget -qO- https://deb.opera.com/archive.key | sudo apt-key add -
    
    # yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

    
    #vscode 
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    
    sudo apt update
}

function setup_zsh {
    # check if already installed
    zsh --version >> /dev/null
    
    if [[ $? == 0 ]]; then
        echo "zsh installed"
    else
        sudo apt-get install zsh -y
    fi
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "ohmyzsh is already installed"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        exit
        echo "ZSH installed"
    fi
}

function setup_fonts {
	# TODO check if already installed
    sh -c "$(curl -fsSL https://gist.githubusercontent.com/alokyadav15/c3a2bbe6089ceff286215113bd092703/raw/3a3dd9af2ec59e4756bee5282e7c1e714dbf7db2/setup_fonts.sh)"
}

function install_code_editors {
	# TODO check if already installed
    clear
    echo "Installing editors"
    sudo apt-get install -y code sublime-text vim vim-gtk emacs
}

function install_jdk {
	sudo apt-get install oracle-java8-installer oracle-java8-set-default -y
}

function install_node_and_libs {
	# TODO check if already installed
	curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
	sudo apt-get install -y nodejs yarn
}

function install_browsers {
	sudo apt-get install -y chromium-browser google-chrome-beta google-chrome-stable opera-beta
}

function install_ruby_on_rails {
	sudo su `logname`
	clear
	echo $USER 
	command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
	\curl -sSL https://get.rvm.io | bash -s stable --ruby=2.3.3 --rails
}


function install_docker {
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	   $(lsb_release -cs) \
	   stable"
	sudo apt-get update
	sudo apt-get install docker-ce -y
	sudo usermod -aG docker $USER
	clear
}

function install_common_libs {
	sudo apt-get install -y libmysqlclient20 libmysqlclient-dev libpq5 \
	libpq-dev python3.6 python3.6-dev -y \
	python3.6-minimal python3.6-venv python-dev -y
}

function exit_message {
	clear
	echo "Done! Everythings is installed , please restart your system"
	sleep 1
	echo -n "Restart Now ? [Y/N] "
	read restart
	if [[ "$restart" == "Y" ]]; then
		sudo reboot
	else
		exit
	fi
}

# starting main
update_and_upgrade
install_build_tools
add_repositories
setup_zsh
setup_fonts
#install_ruby_on_rails
install_node_and_libs
install_browsers
install_jdk
install_code_editors
install_docker
exit_message
