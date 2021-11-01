#!/usr/bin/bash

if [[ -z "$*" ]] || [[ "$*" == "-h" ]] || [[ "$*" == "--help" ]]; then
  echo -e "Uso: $0 <URL sem http/s>\n\nOpções: $0 -h | --help:: Mostra esse painel de ajuda\n $0<URL>       :: Ceifar sub-domínios e status code de uma determinada URL"
elif [[ ! -z "$*" ]]; then
  
  VERDE='\033[32;1m'
  VERMELHO='\033[31;1m'
  AMARELO='\033[33;1m'
  FIM='\033[m'
  
  echo -e "${VERDE}
  ####   ######  #  ######    ##    #####    ####   #####  
 #    #  #       #  #        #  #   #    #  #    #  #    # 
 #       #####   #  #####   #    #  #    #  #    #  #    # 
 #       #       #  #       ######  #    #  #    #  #####  
 #    #  #       #  #       #    #  #    #  #    #  #   #  
  ####   ######  #  #       #    #  #####    ####   #    # 
  ${FIM}"
  echo -e "--[ ${VERMELHO}\nCriado por: RodricBr | github.com/RodricBr${FIM} ]--\n\n"
  
  HORA="$(date +'%d/%m/%y | %T')"
  
  touch url
  echo -e "\n---[ + ]--- Omnisint:\n" >> url
  OMN=$(curl "https://sonar.omnisint.io/subdomains/$1" -s -k | grep -oE "[a-zA-Z0-9._-]+\.$1" >> url)
  echo -e "\n---[ + ]--- Anubis:\n" >> url
  ANU=$(curl "https://jldc.me/anubis/subdomains/$1" -s -k | grep -oE "[a-zA-Z0-9._-]+\.$1" >> url)
  echo -e "\n+--------------- Scan terminado $HORA ---------------+\n" >> url

  STATUS() {
      url="$1"
      urlstatus=$(curl -o /dev/null -k -s --head --write-out  '%{http_code}' "${url}" --max-time 5 ) &&
      echo "URL: $url CODE: $urlstatus"
  }
  export -f STATUS

  parallel -j200 STATUS :::: url >> resp 2>/dev/null

  if [[ -f "url" ]]; then
    echo -e "${AMARELO}Arquivo com subdominios criado!${FIM}"
    exit 0
  else
    echo -e "${VERMELHO}Nada foi encontrado nesse domínio!${FIM}"
    exit 1
  fi
else
  false
fi
