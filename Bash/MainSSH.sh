#!/bin/bash
source ./FunGENERALES.sh
while true; do
    echo "===== Automatización y Gestión de DNS ====="
    echo "1.- Instalar"
    echo "2.- Salir"
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) ./FunSSH.sh ;;
        2) echo "Saliendo..."; break ;;
        *) echo "Opción inválida" ;;
    esac
    echo ""
done