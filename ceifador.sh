#!/usr/bin/bash

if [[ -z "$*" ]]; then
  echo -e "Uso: $0 <URL>"
elif [[ ! -z "$*" ]]; then
  
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
    echo -e "Arquivo com subdominios criado!"
  else
    echo -e "Nenhuma informação pode ser obtida!"
  fi
else
  false
fi
