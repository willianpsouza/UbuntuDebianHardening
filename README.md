# UbuntuDebianHardening
Micro script post install Ubuntu/Debian hardening
**Running

- **Clean UP
```bash
curl -fsSL https://raw.githubusercontent.com/willianpsouza/UbuntuDebianHardening/refs/heads/main/clean_service.sh | sudo /usr/bin/env bash
```
--
- **Set To Provengo
```bash
curl -fsSL https://raw.githubusercontent.com/willianpsouza/UbuntuDebianHardening/refs/heads/main/adjusts_for_provengo_cloud.sh | sudo /usr/bin/env bash
```  

--
- **Install Docker Server
```bash
curl -fsSL https://raw.githubusercontent.com/willianpsouza/UbuntuDebianHardening/refs/heads/main/docker-install.sh | sudo /usr/bin/env bash
```  


--
- **Install Auto Update
```bash
curl -fsSL https://raw.githubusercontent.com/willianpsouza/UbuntuDebianHardening/refs/heads/main/autoupdate.sh | sudo /usr/bin/env bash 
```  

--
- **Install NodeJS
```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && apt install nsolid -y
```

-- 
- **Install HPSSascli Proxmox
```bash
# HPE Management Component Pack (https://gist.github.com/mrpeardotnet/a9ce41da99936c0175600f484fa20d03)
# https://downloads.linux.hpe.com/SDR/project/mcp/
# deb [signed-by=/usr/share/keyrings/hpePublicKey.gpg] https://downloads.linux.hpe.com/SDR/repo/mcp/ dist/project_ver non-free
#trixie
echo "deb [signed-by=/usr/share/keyrings/hpePublicKey.gpg] https://downloads.linux.hpe.com/SDR/repo/mcp/ trixie/current non-free" | tee /etc/apt/sources.list.d/hp-mcp.list
curl https://downloads.linux.hpe.com/SDR/hpPublicKey2048_key1.pub | gpg --dearmor | tee -a /usr/share/keyrings/hpePublicKey.gpg > /dev/null
curl https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub | gpg --dearmor | tee -a /usr/share/keyrings/hpePublicKey.gpg > /dev/null
curl https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key2.pub | gpg --dearmor | tee -a /usr/share/keyrings/hpePublicKey.gpg > /dev/null

apt update
apt install ssacli
ssacli ctrl all show
ssacli ctrl all show status
ssacli ctrl slot=0 pd all show
ssacli ctrl slot=0 pd all show detail
ssacli ctrl slot=0 pd all show
```
