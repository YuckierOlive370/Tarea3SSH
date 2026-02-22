#!/bin/bash
./VerificarRoot
while true; do
    echo "===== Menu de Opciones ====="
    echo "1.- Gestion de DHCP"
    echo "2.- Gestion de DNS"
    echo "3.- Gestion de SSH"
    echo "4.- Salir"
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) ./MainDHCP.sh ;;
        2) ./MainDNS.sh ;;
        3) ./MainSSH.sh ;;
        4) echo "Saliendo..."; break ;;
        *) echo "Opción inválida" ;;
    esac
    echo ""
done