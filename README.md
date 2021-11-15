<h1 align="center">~ Ceifador ~</h1> </br>

<p align="center">
  <img border="0" src="./img.png" alt="Credit: https://obloguedasantagonices.blogspot.com/2016/02/a-certeza-de-que-um-dia-morrerei_15.html">
</p>

<h4 align="center">Programa feito para coletar sub-domínios juntamente com os status codes de uma determinada URL usando as APIs: Anubis do JonLuca, e Sonar do Omnisint. A ideia do programa é para que o pesquisador não tenha contato direto com o servidor, deixando a menor quantidade possível de logs dentro dele.</h4>

</br>

## - Instalação:

> git clone https://github.com/rodricbr/ceifador.git </br>

> cd ceifador/;chmod +x ceifador </br>

</br>

> **Para deixar o programa funcional em qualquer parte do sistema:** </br>

> sudo mv ceifador /usr/local/bin </br>

## - Uso:

> bash ceifador </br>

> ./ceifador </br>
## - Opções:

```markdown
./ceifador -h | --help      :: Mostrar o painel de ajuda
./ceifador -u | --uninstall :: Desinstalar o programa (Não funciona no momento!)
./ceifador <URL>            :: Executador o ceifador em uma determinada URL
```
</br>

## - OBS:

```markdown
# É possível que o script não funcione em zsh e outros tipos de shell, ele só foi testado
# em bash versão 4 no sistema operacional Debian 10 buster 64 bits
```
<hr>

### Para fazer:
> Ele não pega todas as urls do output file pra fazer o scan de status code, </br>
> só algumas... mas quais?? </br>

> Checar se urls do resp tiveram redirects (302), </br>
> seguir os redirects usando o -L do curl </br>
> EX: AA=$(cat resp | awk '{print $3}') | curl -L -k -s "$AA" -v </br>

<hr>
