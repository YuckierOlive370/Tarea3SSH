#!/bin/bash
source ./FunGENERALES.sh
source ./FunDHCP.sh
while true; do
    echo "===== Automatización y Gestión del Servidor DHCP ====="
    echo "1.- Verificar la presencia del servicio"
    echo "2.- Instalar el servicio"
    echo "3.- Monitoreo"
    echo "4.- Reiniciar Servicios"
    echo "5.- Salir"
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) VerificarServicio ;;
        2) Instalar ;;
        3) ListarConcesiones ;;
        4) Reiniciar ;;
        5) echo "Saliendo..."; break ;;
        *) echo "Opción inválida" ;;
    esac
    echo ""
done