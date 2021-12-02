<h1 align="center">~ Ceifador ~</h1> </br>

<p align="center">
  <img border="0" draggable="false" src="./img.png" alt="Credit: https://obloguedasantagonices.blogspot.com/2016/02/a-certeza-de-que-um-dia-morrerei_15.html">
</p>

<h4 align="center">Programa feito para coletar sub-domínios juntamente com os status codes de uma determinada URL usando as APIs: Anubis do JonLuca, Sonar do Omnisint e API do HackerTarget. A ideia do programa é para que o pesquisador não tenha contato direto com o servidor, deixando a menor quantidade possível de logs dentro dele e de explorar funcionalidades do cURL e shell script.</h4>

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
./ceifador <URL>            :: Executador o ceifador em uma determinada URL (sem HTTP/S na URL)
```
</br>

## - OBS:

```markdown
# É possível que o script não funcione em zsh e outros tipos de shell, ele só foi testado
# em bash versão 5 no sistema operacional Debian 10 buster.

# As URLs que não aparecem no arquivo de status code,
# são aquelas que retornaram status 000 (fail)
```
<hr>

### Para fazer:

> Mostrar pra onde a URL é redirecionada, igual a função
> de seguir redirect no HTTPX (-follow-redirects)

<hr>
