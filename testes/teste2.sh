#!/usr/bin/bash

# Em desenvolvimento e com vários bugs...

# Compatíbilidade com utf-8
export LANG=C.UTF-8

DIRETORIO=$(dirname "$0")

# Painel de ajuda
AJUDA(){
    cat << EOF
Uso: ${0##*/} <flags>
    Opções:
    -u, --uninstall  :: Desinstala o ceifador
    -h, --help       :: Exibe o painel de ajuda
EOF
}

uninstall_(){
  #cd ~
  sudo find / -type d -iname ceifador -exec rm -rf {} \; 2>/dev/null
  echo -e "${0##*/} desinstalado!\nAté a próxima! :("
  #cd -
  exit 0
}

################################################# teste
#UNSET(){
#if [ "x${var1}${var2}" == "x" ]; then
#  echo "both variables are null"
#fi
#}
#################################################

while [[ "$1" ]]; do
  case "$1" in
    "--uninstall"|"-u") uninstall_ ;;
    "--help"|"-h") AJUDA ;;
    *) AJUDA && exit 1 ;; #echo -e "Opção inválida!"
  esac
  shift
done


# IDEIA: se o tamanho dos parâmetros for menor ou igual a 2
# ex: programa.sh param1
# executa o programa
# Se os parametros estiverem vazios, mensagem de ajuda.. senão(com a URL), executa o programa
if [[ -z "$1" || "$1" = @(-h|--help) ]]; then
  AJUDA
  exit $(( $# ? 0 : 1 ))
  #if [ "x${var1}${var2}" == "x" ]; then
elif [[ ! -z "$*" ]]; then # || ! [[ "$*" =~ [A-Za-z] ]]; then

  # Se o comando parallel não existe, sai com exit status 1 (erro)
  if [[ -z "$(command -v parallel)" ]]; then
    echo -e "${AMARELO}PARALLEL não está instalado no seu sistema!${FIM}"
    echo -e "${AMARELO}Para instalar, execute:${FIM} sudo apt-get install parallel"
    exit 1
  fi

  # Se o programa anew não existe, sai com exit status 1 (erro)
  if [[ -z "$(command -v anew)" ]]; then
    echo -e "${AMARELO}anew não está instalado no seu sistema!${FIM}"
    exit 1
  fi

  # Se o comando curl não existe, sai com exit status 1 (erro)
  if [[ -z "$(command -v curl)" ]]; then
    echo -e "${AMARELO}cURL não está instalado no seu sistema!${FIM}"
    echo -e "${AMARELO}Para instalar, execute:${FIM} sudo apt-get install curl"
    exit 1
  fi

  # Se o comando netcat não existe, sai com exit status 1 (erro)
  if [[ -z "$(command -v netcat)" ]]; then
    echo -e "${AMARELO}cURL não está instalado no seu sistema!${FIM}"
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
  echo -e "\n${VERDE}\t\t  ~-[${FIM} ${VERMELHO}Criado por: $(echo -e "\033[32;5mRodricBr\033[0m ") ${VERMELHO}| github.com/RodricBr${FIM} ${VERDE}]-~${FIM}\n\n"

  # Checando se a conexão com o site está ativa
  if nc -zw1 "$1" 443 2>/dev/null ; then
    echo -e "\n${AMARELO}+ Conexão :${FIM} ${VERDE}OK${FIM}\n"
  else
    echo -e "\n${AMARELO}+ Conexão:${FIM} ${VERMELHO}OFF${FIM}"
    echo -e "${VERMELHO}- Sem conexão à internet ou o site!\nSaíndo...${FIM}\n"
    exit 1
  fi

  # Pegando os IPS do alvo (ipv4 e ipv6)
  echo -e "${AMARELO}+ $1 IP/s:${FIM}\n$(nslookup "$1" | grep -e "Address: " | awk '{print $2}' | tr -t "#" ":")\n"

  # Banner grabbing (informações de server)
  WEBHTTP=$(echo "http://$1")
  WEBHTTPS=$(echo "https://$1")
  RESULTHTTP=$(echo | curl -s -I $WEBHTTP --connect-timeout 3 | grep -e Server:)
  RESULTHTTPS=$(echo | curl -s -I $WEBHTTPS --connect-timeout 3 | grep -e Server:)

  #######################################################
  # Perguntar se deseja fazer análise de DNS

  HKRDNS(){
  curl -s "https://api.hackertarget.com/dnslookup/?q=^(http|https)://$1"
  }

  function ANALISE_DNS {
  read -n 1 -p "$(echo -e $AMARELO"? Deseja fazer análise de DNS?"$FIM [${VERDE}Y${FIM}/${VERMELHO}n${FIM}]: )" RESP;

  case $RESP in
  *[![:alpha:]]*) echo -e "\n$RESP não é uma resposta válida!" ;
    exit 1 ;;
  esac

  [[ "$RESP" != "" ]] && echo "";

  if [ "$RESP" = "${RESP#[Nn]}" ]; then
    echo -e "Análise de DNS: ${VERDE}[+]${FIM}"
    HKRDNS
    #curl 'https://api.hackertarget.com/dnslookup/?q=^(http|https)://"$1"'
  elif [ "$RESP" = "${RESP#^[Yy]$}" ]; then
    echo -e "Análise de DNS: ${VERMELHO}[-]${FIM}"
  fi
  }
  ANALISE_DNS
  #######################################################

  if [ -z "$RESULTHTTP" ]; then
    echo -e "\n\n${VERMELHO}- Banner HTTP não encontrado!${FIM}"
    false
  else
    echo -e "\n\n${AMARELO}+ Resposta em HTTP:${FIM}\n$RESULTHTTP"
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

  # API Omnisint
  #echo -e "\n---[ + ]--- Omnisint:\n" >> url
  sleep 0.5
  OMN=$(
  curl -iL -A "$USER_AGENT" "https://sonar.omnisint.io/subdomains/$1" -s -k -H \
  "Referer:$1" | grep -oE "[a-zA-Z0-9._-]+\.$1" >> url
  )

  # if curl == 301 ou 302 --max-redirs 2 :: redirect --> sub.exemplo.com

  # API Anubis
  #echo -e "\n---[ + ]--- Anubis:\n" >> url
  sleep 0.5
  ANU=$(
  curl -iL -A "$USER_AGENT" "https://jldc.me/anubis/subdomains/$1" -s -k -H \
  "Referer:$1" | grep -oE "[a-zA-Z0-9._-]+\.$1" >> url
  )

  # API Hacker Target
  #echo -e "\n---[ + ]--- HackerTarget:\n" >> url
  HKR=$(
  curl -iL -A "$USER_AGENT" "https://api.hackertarget.com/hostsearch/?q=$1" -s -k -H \
  "Referer:$1" | grep -oE "[a-zA-Z0-9._-]+\.$1" >> url
  )
  sleep 0.5

  # CRT.SH
  #echo -e "\n---[ + ]--- crt.sh:\n" >> url
  CRT=$(
  curl -s "https://crt.sh/?q=%25.$1&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' >> url
  )

  # if curl == 301 ou 302 --max-redirs 2 :: redirect.exemplo.com --> sub.exemplo.com
  #echo -e "\n+--------------- Scan finalizado: $HORA ---------------+\n" >> url

  # Função para pegar o status code
  STATUS(){
      url="$1"
      sleep 1
      # cUrl lendário + Follow redirects (Futuro update):
      # echo -e "Url     ::\t$url"; curl -ks -o /dev/null -i -w 'Status  ::\t''%{http_code}'' \nTamanho ::\t'"%{size_download}\n" -H "X-Originally-Forwarded-For: 127.0.0.1, 68.180.194.242" -X GET "${url}" -L

      urlstatus=$(curl -o /dev/null -k -s --head --write-out '%{http_code}' "${url}" --max-time 5 -L ) &&
      echo -e "[URL]: $url \t\t[CODE]: $urlstatus" | anew
  }
  export -f STATUS

  # 200 'threads/max jobs' (rodando em paralelo)
  parallel -j100 STATUS :::: url >> resp 2>/dev/null

  # Tirando duplicadas usando anew e fazendo ajustes
  cat resp | anew >> resp-"$1"
  rm resp
  mv url url-"$1"
  cat url-"$1" | anew > urls-"$1"
  rm url-"$1"

  # Contagem de número de linhas do arquivo com os status codes
  #echo -e "\n${AMARELO}+ Número de domínios:${FIM} $(wc -l resp | awk '{print $1}')"

  # Se o arquivo resp e url existem... + contagem de linhas do resp e url
  if [ -f "$DIRETORIO/resp-$1" ] || [ -f "$DIRETORIO/urls-$1" ]; then
    echo -e "${AMARELO}+ Arquivo 'resp-$1'\t[$(wc -l resp-"$1" | awk '{print $1}')]\t--> Status Codes\n+ Arquivo 'urls-$1'\t[$(wc -l urls-"$1" | awk '{print $1}')]\t--> Todos os Sub-dominios${FIM}"
  fi

  # Se o arquivo url existe, echo. Senão, nada.
  if [[ -f "$DIRETORIO/urls-$1" ]]; then
    echo -e "\n${AMARELO}Arquivo com subdominios criado!${FIM}"

    # Recomendação de comando
    echo -e "\n${AMARELO}+ Dica de comando:${FIM}\ncat urls-$1 | httpx -status-code -follow-redirects -silent -o output.txt"
    exit 0
  else
    echo -e "\n${VERMELHO}Nada foi encontrado nesse domínio!${FIM}\n"
    exit 1
  fi

else
  false
fi
