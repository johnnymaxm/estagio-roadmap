#!/bin/bash

# Definindo cores para o texto
VERDE='\033[0;32m'
AZUL='\033[0;34m'
NEGRITO='\033[1m'
RESET='\033[0m'

# Sua frase personalizada - modifique como desejar
MENSAGEM="${VERDE}${NEGRITO}Bem-vindo ao seu WSL2! Vamos começar o trabalho.${RESET}"

# Exibe a mensagem no console e a salva em um arquivo de log
echo -e "$MENSAGEM"

# Opcionalmente, envia a mensagem para todos os terminais conectados
echo -e "$MENSAGEM" | wall
