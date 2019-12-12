#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
DF=`tput sgr0`

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install  git -y

echo -e "${GREEN} Installing Golang (1.13.3).... ${DF}"

wget https://dl.google.com/go/go1.13.5.linux-amd64.tar.gz

sudo tar -C /usr/local -xvf go1.13.5.linux-amd64.tar.gz

mkdir go

#Set golang environment
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
export GOBIN=$GOROOT/bin

#Installing dep
echo -e "${GREEN} Installing dep.... ${DF}"

go get -d -u github.com/golang/dep
cd $(go env GOPATH)/src/github.com/golang/dep
DEP_LATEST=$(git describe --abbrev=0 --tags)
git checkout $DEP_LATEST
go install -ldflags="-X main.version=$DEP_LATEST" ./cmd/dep
git checkout master

#Installing erlang
echo -e "${GREEN} Installing erlang.... ${DF}"

wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb

sudo apt-get update
sudo apt-get install erlang -y

sudo apt-get update
sudo apt-get install esl-erlang -y

#Installing rabbitmq-server
echo -e "${GREEN} Installing rabbitmq-server.... ${DF}"

echo -e "deb https://dl.bintray.com/rabbitmq/debian xenial main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install rabbitmq-server -y

#Turn on rabbitmq-server
echo -e "${GREEN} Turn on rabbitmq-server.... ${DF}"
sudo systemctl start rabbitmq-server.service
sudo systemctl enable rabbitmq-server.service

sudo apt-get install build-essential -y

#Installing Heimdall
mkdir -p $GOPATH/src/github.com/maticnetwork
cd $GOPATH/src/github.com/maticnetwork
git clone https://github.com/maticnetwork/heimdall
cd heimdall

git checkout CS-1001
make dep && make install

#Setting Heimdall Node
echo -e "${GREEN} Setting Heimdall Node.... ${DF}"

echo -e "${GREEN}"
heimdalld init
echo -e "${DF}"

echo -e "${GREEN} Please wait 15 seconds. It will be install bor.... ${DF}"
sleep 15

#Installing bor
echo -e "${GREEN} Installing bor.... ${DF}"

mkdir -p $GOPATH/src/github.com/maticnetwork
cd $GOPATH/src/github.com/maticnetwork
git clone https://github.com/maticnetwork/bor
cd bor
git checkout CS-1001
make bor

git clone https://github.com/maticnetwork/public-testnets
cd public-testnets/CS-1001
cp heimdall-genesis.json ~/.heimdalld/config/genesis.json
cd bor-config
cp ../<testnet version>/bor-genesis.json genesis.json

$GOPATH/src/github.com/maticnetwork/bor/build/bin/bor --datadir dataDir init genesis.json
cp static-nodes.json ../bor-config/dataDir/bor/

exit
