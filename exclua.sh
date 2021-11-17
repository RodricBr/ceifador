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
