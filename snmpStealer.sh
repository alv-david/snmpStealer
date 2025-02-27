#!/bin/bash

target=""
wordlist=""
community=""
verbose=false
stop_on_success=false
output_file="snmp_enum_results.txt"
found_communities=()
language=""
scan_speed=1

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
NC="\e[0m"

echo "Choose language / Elige idioma / Escolha o idioma: (en/es/pt)"
read -r language

usage() {
    case "$language" in
        pt)
            echo "Uso: $0 -t <IP-alvo> -w <wordlist> [-C <comunidade>] [-v] [--sos] [-T<0-3>]"
            echo "Glossário:"
            echo "-t = target (IP-alvo)"
            echo "-w = wordlist (lista de palavras)"
            echo "-C = comunidade (comunidade manualmente definida)"
            echo "-v = verbose (detalhes adicionais durante a execução)"
            echo "--sos = stop on success (parar ao encontrar sucesso)"
            echo "-T = velocidade do scan (0 = Lento, 1 = Médio, 2 = Rápido, 3 = Extremamente rápido)"
            ;;
        es)
            echo "Uso: $0 -t <IP-objetivo> -w <lista de palavras> [-C <comunidad>] [-v] [--sos] [-T<0-3>]"
            echo "Glosario:"
            echo "-t = objetivo (IP-objetivo)"
            echo "-w = lista de palavras (wordlist)"
            echo "-C = comunidad (comunidad definida manualmente)"
            echo "-v = verboso (detalles adicionales durante la ejecución)"
            echo "--sos = parar al encontrar éxito (stop on success)"
            echo "-T = velocidad de escaneo (0 = Lento, 1 = Medio, 2 = Rápido, 3 = Extremadamente rápido)"
            ;;
        *)
            echo "Usage: $0 -t <Target IP> -w <wordlist> [-C <community>] [-v] [--sos] [-T<0-3>]"
            echo "Glossary:"
            echo "-t = target (Target IP)"
            echo "-w = wordlist (list of words)"
            echo "-C = community (manually defined community)"
            echo "-v = verbose (additional details during execution)"
            echo "--sos = stop on success (stop upon success)"
            echo "-T = scan speed (0 = Slow, 1 = Medium, 2 = Fast, 3 = Extremely fast)"
            ;;
    esac
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -t)
            target="$2"
            shift 2
            ;;
        -w)
            wordlist="$2"
            shift 2
            ;;
        -C)
            community="$2"
            shift 2
            ;;
        -v)
            verbose=true
            shift
            ;;
        --sos)
            stop_on_success=true
            shift
            ;;
        -T0)
            scan_speed=0
            shift
            ;;
        -T1)
            scan_speed=1
            shift
            ;;
        -T2)
            scan_speed=2
            shift
            ;;
        -T3)
            scan_speed=3
            shift
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z "$target" || (-z "$wordlist" && -z "$community") ]]; then
    usage
fi

case $scan_speed in
    0) wait_time=2 ;;
    1) wait_time=1 ;;
    2) wait_time=0.5 ;;
    3) wait_time=0.1 ;;
    *) wait_time=1 ;;
esac

ping -c 1 "$target" &> /dev/null
if [[ $? -ne 0 ]]; then
    case "$language" in
        pt)
            echo -e "[ ${RED}x${NC}] O host está offline ou a porta está fechada/filtrada. Abortando execução..."
            ;;
        es)
            echo -e "[ ${RED}x${NC}] El host está offline o el puerto está cerrado/filtrado. Abortando execução..."
            ;;
        *)
            echo -e "[ ${RED}x${NC}] The host is offline or the port is closed/filtered. Aborting execution..."
            ;;
    esac
    exit 1
else
    case "$language" in
        pt)
            echo "O host está online, procedendo enumeração..."
            ;;
        es)
            echo "El host está online, procediendo con la enumeración..."
            ;;
        *)
            echo "The host is online, proceeding with enumeration..."
            ;;
    esac
fi

enum_snmp() {
    if [[ -n "$community" ]]; then
        communities=("$community")
    else
        communities=()
        while read -r comm; do
            communities+=("$comm")
        done < "$wordlist"
    fi

    for community in "${communities[@]}"; do
        if $verbose; then
            case "$language" in
                pt)
                    echo -e "[ ${YELLOW}- ${NC}] Testando comunidade: $community"
                    ;;
                es)
                    echo -e "[ ${YELLOW}- ${NC}] Probando comunidad: $community"
                    ;;
                *)
                    echo -e "[ ${YELLOW}- ${NC}] Testing community: $community"
                    ;;
            esac
        fi
        
        result=$(snmpget -v1 -c "$community" "$target" 1.3.6.1.2.1.1.1.0 2>/dev/null)

        if [[ -n "$result" ]]; then
            case "$language" in
                pt)
                    echo -e "[ ${GREEN}+ ${NC}] Comunidade encontrada: $community"
                    ;;
                es)
                    echo -e "[ ${GREEN}+ ${NC}] Comunidad encontrada: $community"
                    ;;
                *)
                    echo -e "[ ${GREEN}+ ${NC}] Community found: $community"
                    ;;
            esac
            found_communities+=("$community")
            if $stop_on_success; then
                break
            fi
        else
            case "$language" in
                pt)
                    echo -e "[ ${RED}x ${NC}] Comunidade não encontrada: $community"
                    ;;
                es)
                    echo -e "[ ${RED}x ${NC}] Comunidad no encontrada: $community"
                    ;;
                *)
                    echo -e "[ ${RED}x ${NC}] Community not found: $community"
                    ;;
            esac
        fi

        sleep "$wait_time"
    done
}

enum_snmp

if [[ ${#found_communities[@]} -eq 0 ]]; then
    case "$language" in
        pt)
            echo "[ - ] Nenhuma comunidade SNMP encontrada."
            ;;
        es)
            echo "[ - ] No se encontró ninguna comunidad SNMP."
            ;;
        *)
            echo "[ - ] No SNMP community found."
            ;;
    esac
    exit 1
fi

case "$language" in
    pt)
        echo "Deseja continuar a enumeração SNMP com as comunidades encontradas? (s/n)"
        ;;
    es)
        echo "¿Desea continuar la enumeración SNMP con las comunidades encontradas? (s/n)"
        ;;
    *)
        echo "Do you want to continue SNMP enumeration with the found communities? (y/n)"
        ;;
esac
read -r continuar
if [[ "$continuar" != "s" && "$continuar" != "y" ]]; then
    case "$language" in
        pt)
            echo "[ + ] Comunidades encontradas: ${found_communities[*]}" > "$output_file"
            echo "[ + ] Resultados salvos em $output_file"
            ;;
        es)
            echo "[ + ] Comunidades encontradas: ${found_communities[*]}" > "$output_file"
            echo "[ + ] Resultados guardados en $output_file"
            ;;
        *)
            echo "[ + ] Found communities: ${found_communities[*]}" > "$output_file"
            echo "[ + ] Results saved in $output_file"
            ;;
    esac
    exit 0
fi

case "$language" in
    pt)
        echo "[ + ] Enumerando informações SNMP..."
        ;;
    es)
        echo "[ + ] Enumerando información SNMP..."
        ;;
    *)
        echo "[ + ] Enumerating SNMP information..."
        ;;
esac

{
    for community in "${found_communities[@]}"; do
        case "$language" in
            pt)
                echo "[ + ] Usando comunidade: $community"
                ;;
            es)
                echo "[ + ] Usando comunidad: $community"
                ;;
            *)
                echo "[ + ] Using community: $community"
                ;;
        esac
        echo "[ + ] Results for community: $community" >> "$output_file"
        
        hardware_info=$(snmpget -v1 -c "$community" "$target" 1.3.6.1.2.1.25.3.3.1.2.1 2>/dev/null)
        services_info=$(snmpwalk -v1 -c "$community" "$target" 1.3.6.1.2.1.25.6.3.1.2 2>/dev/null)
        network_info=$(snmpwalk -v1 -c "$community" "$target" 1.3.6.1.2.1.2.2.1.2 2>/dev/null)

        if [[ -n "$hardware_info" ]]; then
            echo "[ + ] Informações de hardware:" >> "$output_file"
            echo "$hardware_info" >> "$output_file"
            echo "" >> "$output_file"
        fi

        if [[ -n "$services_info" ]]; then
            echo "[ + ] Serviços em execução:" >> "$output_file"
            echo "$services_info" >> "$output_file"
            echo "" >> "$output_file"
        fi

        if [[ -n "$network_info" ]]; then
            echo "[ + ] Informações da rede:" >> "$output_file"
            echo "$network_info" >> "$output_file"
            echo "" >> "$output_file"
        fi

        echo "-------------------------------------------" >> "$output_file"
    done
} > "$output_file"

case "$language" in
    pt)
        echo "[ + ] Enumeração SNMP concluída. Resultados salvos em $output_file"
        ;;
    es)
        echo "[ + ] Enumeración SNMP completada. Resultados guardados en $output_file"
        ;;
    *)
        echo "[ + ] SNMP enumeration completed. Results saved in $output_file"
        ;;
esac
