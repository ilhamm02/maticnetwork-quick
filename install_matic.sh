#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
DF=`tput sgr0`

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install  git -y

if ! [ -x "$(command -v go)" ];then
  echo -e "${GREEN} Installing Golang (1.13.3).... ${DF}"

  rm -rf /usr/local/go
  wget https://dl.google.com/go/go1.13.5.linux-amd64.tar.gz

  sudo tar -C /usr/local -xvf go1.13.5.linux-amd64.tar.gz

  export GOROOT=/usr/local/go
  export GOPATH=$HOME/go
  export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
  export GOBIN=$GOROOT/bin

  rm -rf go1.13.5.linux-amd64.tar.gz

  echo -e "${GREEN} Installing dep.... ${DF}"
  curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
else
  if ! [ -x "$(command -v dep)" ];then
    echo -e "${GREEN} Installing dep.... ${DF}"
    sudo apt-get install go-dep
  else
    echo -e "${GREEN} Golang and dep already installed... ${DF}"
  fi
fi

if ! [ -x "$(command -v erl)" ];then
  echo -e "${GREEN} Installing erlang.... ${DF}"

  wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
  sudo dpkg -i erlang-solutions_1.0_all.deb

  sudo apt-get update
  sudo apt-get install erlang -y

  sudo apt-get update
  sudo apt-get install esl-erlang -y
else
  echo -e "${GREEN} Erlang already installed... ${DF}"
  rm -rf erlang-solutions_1.0_all.deb
fi

if ! [ -x "$(command -v rabbitmq-server)" ];then
  echo -e "${GREEN} Installing rabbitmq-server.... ${DF}"

  echo -e "deb https://dl.bintray.com/rabbitmq/debian xenial main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list
  wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
  sudo apt-get update
  sudo apt-get install rabbitmq-server -y
else
  echo -e "${GREEN} Rabbitmq-server already installed... ${DF}"
fi

#Turn on rabbitmq-server
echo -e "${GREEN} Turn on rabbitmq-server.... ${DF}"
sudo systemctl start rabbitmq-server.service
sudo systemctl enable rabbitmq-server.service

if ! [ -x "$(command -v make)" ];then
  sudo apt-get install build-essential -y
else
  echo -e "${GREEN} Build essential already installed... ${DF}"
fi

if ! [ -x "$(command -v heimdalld)" ];then
  mkdir -p $GOPATH/src/github.com/maticnetwork
  if ! [[ -d $GOPATH/src/github.com/maticnetwork ]]; then
    mkdir -p $GOPATH/src/github.com/maticnetwork
    cd $GOPATH/src/github.com/maticnetwork
    git clone https://github.com/maticnetwork/heimdall
    if ! [[ -d $GOPATH/src/github.com/maticnetwork/heimdall ]]; then
      git clone https://github.com/maticnetwork/heimdall
      cd heimdall

      git checkout CS-2001
      make dep && make install
    else
      cd heimdall

      git checkout CS-2001
      make dep && make install
    fi
  else
    cd $GOPATH/src/github.com/maticnetwork
    git clone https://github.com/maticnetwork/heimdall
    if ! [[ -d $GOPATH/src/github.com/maticnetwork/heimdall ]]; then
      git clone https://github.com/maticnetwork/heimdall
      cd heimdall

      git checkout CS-2001
      make dep && make install
    else
      cd heimdall

      git checkout CS-2001
      make dep && make install
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
  git clone https://github.com/maticnetwork/bor
  if ! [[ -d $GOPATH/src/github.com/maticnetwork/bor ]]; then
    git clone https://github.com/maticnetwork/bor
    cd bor
    git checkout CS-2001
    make bor
    curl https://raw.githubusercontent.com/maticnetwork/public-testnets/master/CS-2001/static-nodes.json > static-nodes.json
  else
    cd bor
    git checkout CS-2001
    make bor
    curl https://raw.githubusercontent.com/maticnetwork/public-testnets/master/CS-2001/static-nodes.json > static-nodes.json
  fi
else
  echo -e "${GREEN} Bor already installed... ${DF}"
fi

cd $GOPATH/src/github.com/maticnetwork
git clone https://github.com/maticnetwork/public-testnets
if ! [[ -d $GOPATH/src/github.com/maticnetwork/public-testnets ]]; then
  git clone https://github.com/maticnetwork/public-testnets
  cd public-testnets/CS-2001
  cp heimdall-genesis.json ~/.heimdalld/config/genesis.json
  cd bor-config
  cp ../CS-2001/bor-genesis.json genesis.json
else
  cd public-testnets/CS-2001
  cp heimdall-genesis.json ~/.heimdalld/config/genesis.json
  cd ../bor-config
  cp ../CS-2001/bor-genesis.json genesis.json
fi

$GOPATH/src/github.com/maticnetwork/bor/build/bin/bor --datadir dataDir init genesis.json
cp ../CS-2001/static-nodes.json $GOPATH/src/github.com/maticnetwork/public-testnets/bor-config/dataDir/bor/

cd $GOPATH/src/github.com/maticnetwork/public-testnets/bor-config/dataDir/bor
curl https://raw.githubusercontent.com/maticnetwork/public-testnets/master/CS-2001/static-nodes.json > static-nodes.json

exit
