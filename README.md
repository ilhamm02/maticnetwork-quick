# Stake Counter Quick Installer
This is quick installer for you to setup node in ***Stake Counter***. Please follow the directions to use this quick installer.

1. Create your own server or you can using VPS. **For OS, this script tested in Ubuntu, or you can using Debian.**
2. Go to your $HOME in your server (```cd```)
3. Run ```curl https://raw.githubusercontent.com/ilhamm24/maticnetwork-quick/master/install_matic.sh > installer_matic.sh```
4. Then, you can run ```bash installer_matic.sh```
5. After installation completed, set up your infura.io key in `${GOPATH}/src/github.com/maticnetwork/public-testnets/CS-1001/heimdall-config.toml`.
6. Edit ~/.heimdalld/config/config.toml (`nano ~/.heimdalld/config/config.toml`) in persistent_peers="" with heimdall-seeds.txt (in CS-1001 folder)
7. Then, copy heimdall-config.toml to /.heimdalld/config/genesis.json `cp heimdall-config.toml ~/.heimdalld/config/heimdall-config.toml`.

**IMPORTANT: THE TESTNET VERSION OF THIS SCRIPT IS CS-1001**

## How to Get Infura.io API Key?
1. Register in infura.io
2. Create new project
3. Go to your project detail
4. The API key is in .../v3/THIS_IS_YOUR_KEY

Are you got some problem? Go to Stake Counter discord channel.

Telegram of creator: @OkeSip.
