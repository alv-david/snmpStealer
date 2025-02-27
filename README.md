# snmpStealer.sh

## Descrição

O snmpStealer é utilizado para enumerar o protocol SNMP de um alvo especificado. Ele permite a verificação de comunidades conhecidas definidas pelo usuário através de wordlists ou testes manuais para efetivar a enumeração de outras informações, como hardware, serviços e informações da rede.

É possível também escolher o idioma em que a aplicação funcionará, ao executar o script o usuário poderá escolher entre Inglês (en), Espanhol (es) e Português (pt).

## Saída

Os dados são armazenados automaticamente após a enumeração das informações no arquivo "*snmp_enum_results.txt*"

## Uso

```bash
./snmp_enum.sh -t <IP-alvo> -w <wordlist> [-C <comunidade>] [-v] [--sos] [-T<0-3>]
 ```

## Parâmetros

-t <IP-alvo>: IP do alvo a ser analisado;

-w <wordlist>: Caminho para uma lista de palavras (wordlist) que contém comunidades SNMP.

-C <comunidade>: Comunidade SNMP definida manualmente.

-v: Habilita o modo verboso, exibindo detalhes adicionais durante a execução.

--sos: Para a execução ao encontrar uma comunidade válida.

-T<0-3>: Define a velocidade do scan. - 0: lento, 1: médio, 2: rápido, 3: extremamente rápido 
* lembrando que ao utilizar o T3, falsos positivos podem ocorrer.
