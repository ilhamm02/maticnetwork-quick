#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
DF=`tput sgr0`

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install  git -y

if ! [ -x "$(command -v go)" ];then
  echo -e "${GREEN} Installing Golang (1.13.3).... ${DF}"

  sudo rm -rf /usr/local/go
  wget https://dl.google.com/go/go1.13.5.linux-amd64.tar.gz

  sudo tar -C /usr/local -xvf go1.13.5.linux-amd64.tar.gz

  export GOROOT=/usr/local/go
  export GOPATH=$HOME/go
  export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
  export GOBIN=$GOROOT/bin

  sudo rm -rf go1.13.5.linux-amd64.tar.gz
else
  echo -e "${GREEN} Golang already installed... ${DF}"
fi

if ! [ -x "$(command -v rabbitmq-server)" ];then
  echo -e "${GREEN} Installing rabbitmq-server.... ${DF}"

  echo -e "deb https://dl.bintray.com/rabbitmq/debian xenial main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list
  wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
  sudo apt-get update
  sudo apt-get install rabbitmq-server -y
  
  sudo rabbitmqctl stop
  sudo rabbitmq-server -detached
else
  sudo rabbitmqctl stop
  sudo rabbitmq-server -detached
  echo -e "${GREEN} Rabbitmq-server already installed... ${DF}"
fi

if ! [ -x "$(command -v make)" ];then
  sudo apt-get install build-essential -y
else
  echo -e "${GREEN} Build essential already installed... ${DF}"
fi

if ! [ -x "$(command -v heimdalld)" ];then
  echo -e "${GREEN} Installing Heimdall.... ${DF}"
  sudo mkdir -p $GOPATH/src/github.com/maticnetwork
  if ! [[ -d $GOPATH/src/github.com/maticnetwork ]]; then
    sudo mkdir -p $GOPATH/src/github.com/maticnetwork
    cd $GOPATH/src/github.com/maticnetwork
    sudo git clone https://github.com/maticnetwork/heimdall
    if ! [[ -d $GOPATH/src/github.com/maticnetwork/heimdall ]]; then
      sudo git clone https://github.com/maticnetwork/heimdall
      cd heimdall

      sudo git checkout CS-2001
      sudo make install
    else
      cd heimdall

      sudo git checkout CS-2001
      sudo make install
    fi
  else
    cd $GOPATH/src/github.com/maticnetwork
    sudo git clone https://github.com/maticnetwork/heimdall
    if ! [[ -d $GOPATH/src/github.com/maticnetwork/heimdall ]]; then
      sudo git clone https://github.com/maticnetwork/heimdall
      cd heimdall

      sudo git checkout CS-2006
      sudo make install
    else
      cd heimdall

      sudo git checkout CS-2006
      sudo make install
    fi
  fi
else
  echo -e "${GREEN} Heimdalld already installed... ${DF}"
fi

#Setting Heimdall Node
echo -e "${GREEN} Setting Heimdall Node.... ${DF}"

echo -e "${GREEN}"
heimdalld init
echo -e "${DF}"

echo -e "${GREEN} Please wait 15 seconds. It will be install bor.... ${DF}"
sleep 15

if ! [ -x "$(command -v bor)" ];then
  echo -e "${GREEN} Installing bor.... ${DF}"

  cd $GOPATH/src/github.com/maticnetwork
  sudo git clone https://github.com/maticnetwork/bor
  if ! [[ -d $GOPATH/src/github.com/maticnetwork/bor ]]; then
    sudo git clone https://github.com/maticnetwork/bor
    cd bor
    sudo git checkout CS-2006
    sudo make bor
  else
    cd bor
    sudo git checkout CS-2006
    sudo make bor
  fi
else
  echo -e "${GREEN} Bor already installed... ${DF}"
fi

cd $GOPATH/src/github.com/maticnetwork
sudo git clone https://github.com/maticnetwork/public-testnets
if ! [[ -d $GOPATH/src/github.com/maticnetwork/public-testnets ]]; then
  sudo git clone https://github.com/maticnetwork/public-testnets
  cd public-testnets/CS-2006
  echo "export CONFIGPATH=$PWD" >> ~/.bashrc
  source ~/.bashrc
  sudo cp $CONFIGPATH/heimdall/config/genesis.json $HEIMDALLDIR/config/genesis.json
  sudo cp $CONFIGPATH/heimdall/config/heimdall-config.toml $HEIMDALLDIR/config/heimdall-config.toml
else
  sudo git clone https://github.com/maticnetwork/public-testnets
  cd public-testnets/CS-2006
  echo "export CONFIGPATH=$PWD" >> ~/.bashrc
  source ~/.bashrc
  sudo cp $CONFIGPATH/heimdall/config/genesis.json $HEIMDALLDIR/config/genesis.json
  sudo cp $CONFIGPATH/heimdall/config/heimdall-config.toml $HEIMDALLDIR/config/heimdall-config.toml
fi

exit
