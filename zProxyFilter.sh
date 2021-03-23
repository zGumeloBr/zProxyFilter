#!/bin/bash

#
#
# Criado por zGumeloBr
#
#

#Verificações importantes

if [[ $EUID -ne 0 ]]; then
  echo -e "\033[1;31m * Esse script precisa ser executado em super usuário (sudo). \033[0m" 1>&2
  exit 1

fi

if ! [ -x "$(command -v wget)" ]; then
  echo "\033[1;31m * O comando (wget) não foi encontrado, por favor instale-o\033[0m"
  exit 1
fi

if ! [ -x "$(command -v iptables)" ]; then
  echo "\033[1;31m * O comando (iptables) não foi encontrado, por favor instale-o\033[0m"
  exit 1
fi

if ! [ -x "$(command -v ipset)" ]; then
  echo "\033[1;31m * O comando (ipset) não foi encontrado, por favor instale-o\033[0m"
  exit 1
fi

# Criando tabela para bloquear as proxies.

ipset create zProxyFilter -exist hash:ip hashsize 9999999 maxelem 9999999 timeout 0

#
#
# Metódo (MPB)
#
#

wget -O mpb.toml https://raw.githubusercontent.com/zGumeloBr/zMPB-Module/main/proxies.txt

#
#
# Metódo (APB)
#
#

wget -O pl1.toml https://www.proxy-list.download/api/v1/get?type=socks4

wget -O pl2.toml https://api.proxyscrape.com/?request=displayproxies&proxytype=all&timeout=all&country=all

wget -O pl3.toml https://raw.githubusercontent.com/ktsaou/blocklist-ipsets/master/nixspam.ipset

wget -O pl4.toml https://check.torproject.org/torbulkexitlist

wget -O pl5.toml https://www.proxy-list.download/api/v1/get?type=socks5

wget -O pl6.toml https://www.proxyscan.io/download?type=socks4

wget -O pl7.toml https://www.proxyscan.io/download?type=socks5

wget -O pl8.toml https://api.proxyscrape.com/v2/?request=getproxies

wget -O pl9.toml https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list-raw.txt

wget -O pl10.toml https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/socks5.txt

wget -O pl11.toml https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/socks4.txt

wget -O pl12.toml https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/https.txt

wget -O pl13.toml https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/http.txt

wget -O pl14.toml https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/socks5.txt

wget -O pl15.toml https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/socks4.txt

wget -O pl16.toml https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/http.txt

# Compactando todas as proxies em um arquivo.

cat mpb.toml pl1.toml pl2.toml pl3.toml pl4.toml pl5.toml pl6.toml pl7.toml pl8.toml pl9.toml pl10.toml pl11.toml pl12.toml pl13.toml pl14.toml pl15.toml pl16.toml >> proxies.txt

# Replace para retirar as portas e caracteres inuteis.

sed -i 's/$/:/' proxies.txt

sed -i 's/:.*/:/' proxies.txt

sed -i 's/[:]\+//g' proxies.txt

sed -i '/^#/d' proxies.txt

sed -i '/^$/d' proxies.txt

sed -n '/^This/d' proxies.txt

# Bloqueando todos as proxys coletadas.

for x in $(cat proxies.txt)
do
        ipset -A zProxyFilter $x
done

iptables -I INPUT -m set --match-set zProxyFilter src -j DROP

#Limpando arquivos de proxies antigos

rm *.toml

rm proxies.txt

#Limpando terminal

clear

#Mensagem de finalização

echo ""
echo ""
echo -e "\033[1;34m ____  ____  ____  _____  _  _  _  _  ____  ____  __    ____  ____  ____ \033[0m"  
echo -e "\033[1;34m(_   )(  _ \(  _ \(  _  )( \/ )( \/ )( ___)(_  _)(  )  (_  _)( ___)(  _ \\033[0m" 
echo -e "\033[1;34m / /_  )___/ )   / )(_)(  )  (  \  /  )__)  _)(_  )(__   )(   )__)  )   / \033[0m"
echo -e "\033[1;34m(____)(__)  (_)\_)(_____)(_/\_) (__) (_)   (____)(____) (__) (____)(_)\_) \033[0m"
echo ""
echo -e "\033[0;37m❖ Proxys bloqueadas com sucesso! Lembre-se de sempre re-ativar\033[0m"
echo -e "\033[0;37messa proteção para atualizar as lista de proxys bloqueadas. \033[0m"
echo ""
echo -e "\033[1;33m❖ Total de proxys bloqueadas:\033[0m"

#Contando proxies bloqueadas

echo ""
for x in $(wc -l proxies.txt)
do
        echo "⋄ | $x"
done
