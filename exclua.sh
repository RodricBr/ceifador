#!/usr/bin/bash

# Em desenvolvimento e com vários bugs...

# Compatíbilidade com utf-8
export LANG=C.UTF-8

DIRETORIO=$(dirname "$0")

if [[ "$*" == "-u" ]] || [[ "$*" == "--uninstall" ]]; then
  read -n 1 -p "Deseja desinstalar? [Y/n]: " RESP;

  [[ "$RESP" != "" ]] && echo "";

  if [ "$RESP" = "${RESP#[Nn]}" ]; then
    echo -e "SIM"
    # Desinstalar...
  elif [ "$RESP" = "${RESP#^[Yy]$}" ]; then
    echo -e "NAO"
    # exit 0
  fi
fi

if [[ "$*" == "-o" ]] || [[ "$*" == "-out" ]]; then
  principal >> output.txt
fi
# Se os parametros estiverem vazios, mensagem de ajuda.. senão(com a URL), executa o programa
if [[ -z "$*" ]] || [[ "$*" == "-h" ]] || [[ "$*" == "--help" ]]; then
  echo -e "\nUso: $0 <URL sem http/s>\n\nOpções:"
  echo -e "$0 -h | --help      :: Mostra esse painel de ajuda\n\
$0 -u | --uninstall :: Desinstalar o programa (não está funcional!)\n\
$0 <URL>            :: Ceifar sub-domínios e status code de uma determinada URL
"
#elif [[ ! -z "$*" ]]; then
elif [[ ! -z "$*" ]] || ! [[ "$*" =~ [A-Za-z] ]]; then

  # Se o comando parallel não existe, sai com exit status 1 (erro)
  if [[ -z "$(command -v parallel)" ]]; then
    echo -e "${AMARELO}PARALLEL não está instalado no seu sistema!"
    echo -e "${AMARELO}Para instalar, execute:${FIM} sudo apt-get install parallel"
    exit 1
  fi

  # Se o programa anew não existe, sai com exit status 1 (erro)
  if [[ -z "$(command -v anew)" ]]; then
    echo -e "${AMARELO}anew não está instalado no seu sistema!"
    exit 1
  fi

  # Se o comando curl não existe, sai com exit status 1 (erro)
  if [[ -z "$(command -v curl)" ]]; then
    echo -e "${AMARELO}cURL não está instalado no seu sistema!"
    echo -e "${AMARELO}Para instalar, execute:${FIM} sudo apt-get install curl"
    exit 1
  fi

  # Se o comando netcat não existe, sai com exit status 1 (erro)
  if [[ -z "$(command -v netcat)" ]]; then
    echo -e "${AMARELO}cURL não está instalado no seu sistema!"
    echo -e "${AMARELO}Para instalar, execute:${FIM} sudo apt-get install curl"
    exit 1
  fi

  # Variável de cores
  VERDE='\033[32;1m'
  VERMELHO='\033[31;1m'
  AMARELO='\033[33;1m'
  FIM='\033[m'

  # Encerramentos...
  trap encerr 2

  encerr(){
    echo -e "\n\n${AMARELO}Processo interrompido\nSaíndo!${FIM}\n"
    exit 130
  }

  # Banner
  echo -e "\n"
  echo -e ${VERDE}'\t @@@@@@@  @@@@@@@@  @@@  @@@@@@@@   @@@@@@   @@@@@@@    @@@@@@   @@@@@@@   '${FIM}
  echo -e ${VERDE}'\t@@@@@@@@  @@@@@@@@  @@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  '${FIM}
  echo -e ${VERDE}'\t!@@       @@!       @@!  @@!       @@!  @@@  @@!  @@@  @@!  @@@  @@!  @@@  '${FIM}
  echo -e ${VERDE}'\t!@!       !@!       !@!  !@!       !@!  @!@  !@!  @!@  !@!  @!@  !@!  @!@  '${FIM}
  echo -e ${VERDE}'\t!@!       @!!!:!    !!@  @!!!:!    @!@!@!@!  @!@  !@!  @!@  !@!  @!@!!@!   '${FIM}
  echo -e ${VERDE}'\t!!!       !!!!!:    !!!  !!!!!:    !!!@!!!!  !@!  !!!  !@!  !!!  !!@!@!    '${FIM}
  echo -e ${VERDE}'\t:!!       !!:       !!:  !!:       !!:  !!!  !!:  !!!  !!:  !!!  !!: :!!   '${FIM}
  echo -e ${VERDE}'\t:!:       :!:       :!:  :!:       :!:  !:!  :!:  !:!  :!:  !:!  :!:  !:!  '${FIM}
  echo -e ${VERDE}'\t ::: :::   :: ::::   ::   ::       ::   :::   :::: ::  ::::: ::  ::   :::  '${FIM}
  echo -e ${VERDE}'\t :: :: :  : :: ::   :     :         :   : :  :: :  :    : :  :    :   : :  '${FIM}
  echo -e "\n${VERDE}\t\t  ~-[${FIM} ${VERMELHO}Criado por: RodricBr | github.com/RodricBr${FIM} ${VERDE}]-~${FIM}\n\n"

  # Checando se a conexão com o site está ativa
  if nc -zw1 "$1" 443 2>/dev/null ; then
    echo -e "\n${AMARELO}+ Conexão :${FIM} ${VERDE}OK${FIM}\n"
  else
    echo -e "\n${AMARELO}+ Conexão:${FIM} ${VERMELHO}OFF${FIM}"
    echo -e "${VERMELHO}- Sem conexão à internet ou o site!\nSaíndo...${FIM}\n"
    exit 1
  fi

  # Pegando os IPS do alvo (ipv4 e ipv6)
  echo -e "${AMARELO}+ $1 IP/s:${FIM}\n$(nslookup "$1" | grep -e Address: | awk '{print $2}' | tr -t "#" ":")\n"

  # Banner grabbing (informações de server)
  WEBHTTP=$(echo "http://$1")
  WEBHTTPS=$(echo "https://$1")
  RESULTHTTP=$(echo | curl -s -I $WEBHTTP --connect-timeout 3 | grep -e Server:)
  RESULTHTTPS=$(echo | curl -s -I $WEBHTTPS --connect-timeout 3 | grep -e Server:)

  if [ -z "$RESULTHTTP" ]; then
    echo -e "${VERMELHO}- Banner HTTP não encontrado!${FIM}"
    false
  else
    echo -e "${AMARELO}+ Resposta em HTTP:${FIM}\n$RESULTHTTP"
  fi

  if [ -z "$RESULTHTTPS" ]; then
    echo -e "${VERMELHO}- Banner HTTPS não encontrado!${FIM}"
    false
  else
    echo -e "${AMARELO}+ Resposta em HTTPS:${FIM}\n$RESULTHTTPS"
  fi
  ###############################################################################

  # Indicando a hora: dia/mês/ano + tempo
  HORA="$(date +'%d/%m/%y | %T')"

  # Randomizando os user agents
  NUMBER=$(( $RANDOM % 9 ))
  AGENTS=(
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/37.0.2062.94 Chrome/37.0.2062.94 Safari/537.36"
    "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36"
    "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko"
    "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/600.8.9 (KHTML, like Gecko) Version/8.0.8 Safari/600.8.9"
    "Mozilla/5.0 (iPad; CPU OS 8_4_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12H321 Safari/600.1.4"
    "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.10240"
    "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0"
    "Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko"
    "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/600.7.12 (KHTML, like Gecko) Version/8.0.7 Safari/600.7.12"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.0"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/600.8.9 (KHTML, like Gecko) Version/7.1.8 Safari/537.85.17"
    "Mozilla/5.0 (iPad; CPU OS 8_4 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12H143 Safari/600.1.4"
    "Mozilla/5.0 (iPad; CPU OS 8_3 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12F69 Safari/600.1.4"
    "Mozilla/5.0 (Windows NT 6.1; rv:40.0) Gecko/20100101 Firefox/40.0"
    "Mozilla/5.0 (Windows NT 6.1; rv:31.0) Gecko/20100101 Firefox/31.0"
    )
  USER_AGENT=$(echo ${AGENTS[$NUMBER]})

  # Parte da criação do arquivo url e o scan do status code dele
  touch url
  #echo -e "\n---[ + ]--- Omnisint:\n" >> url
  sleep 1
  while IFS= read -r line; do
    OMN=$(curl -iL -A "$USER_AGENT" "https://sonar.omnisint.io/subdomains/$line" -s -k -H \
    "Referer:$1" | grep -oE "[a-zA-Z0-9._-]+\.$1" >> url)
    # if curl == 301 ou 302 --max-redirs 2 :: redirect --> sub.exemplo.com
    #echo -e "\n---[ + ]--- Anubis:\n" >> url
    sleep 1
    ANU=$(curl -iL -A "$USER_AGENT" "https://jldc.me/anubis/subdomains/$line" -s -k -H \
    "Referer:$1" | grep -oE "[a-zA-Z0-9._-]+\.$1" >> url)
    # if curl == 301 ou 302 --max-redirs 2 :: redirect --> sub.exemplo.com
    #echo -e "\n+--------------- Scan finalizado: $HORA ---------------+\n" >> url

    # Função para pegar o status code
    STATUS(){
        URL="$1"
        sleep 1
        urlstatus=$(curl -o /dev/null -k -s --head --write-out  '%{http_code}' "${url}" --max-time 5 -L ) &&
        echo -e "[URL]: $url \t\t[CODE]: $urlstatus" | anew
    }
    export -f STATUS

    # 200 'threads' (rodando em paralelo)
    parallel -j200 STATUS :::: url >> resp 2>/dev/null
  done < "$URL"
  # Contagem de número de linhas do arquivo com os status codes
  #echo -e "\n${AMARELO}+ Número de domínios:${FIM} $(wc -l resp | awk '{print $1}')"

  # Se o arquivo resp e url existem... + contagem de linhas do resp e url
  if [ -f "$DIRETORIO/resp" ] || [ -f "$DIRETORIO/url" ]; then
    echo -e "${AMARELO}+ Arquivo 'resp' [$(wc -l resp | awk '{print $1}')]\t--> Status Codes\n+ Arquivo 'url'  [$(wc -l url | awk '{print $1}')]\t--> Todos os Sub-dominios${FIM}"
  fi

  # Se o arquivo url existe, echo. Senão, nada.
  if [[ -f "url" ]]; then
    echo -e "\n${AMARELO}Arquivo com subdominios criado!${FIM}"
    exit 0
  else
    echo -e "\n${VERMELHO}Nada foi encontrado nesse domínio!${FIM}\n"
    exit 1
  fi
else
  false
fi
# Comandos cURL para burlar redirect e firewalls:
# proxychains4 curl -s -k -X POST <URL> -v -H "Content-Length:0"


# Flag -d | -dns
# seila=$2 ?
# https://api.hackertarget.com/dnslookup/?q=$seila
