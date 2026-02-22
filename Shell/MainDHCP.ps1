. .\FunGENERALES.ps1
. .\FunDHCP.ps1

$con = "S"

while ($con -match '^[sS]$') {
    Write-Host "Tarea 2: Automatizacion y Gestion del Servidor DHCP"
    Write-Host "++++++++ Menu de Opciones ++++++++"
    Write-Host "1.-Verificar la presencia del servicio"
    Write-Host "2.-Instalar el servicio"
    Write-Host "3.-Configurar el servicio"
    Write-Host "4.-Monitoreo"
    Write-Host "5.-Reiniciar Servivicios"
    Write-Host "6.-Salir"
    $op = [int](Read-Host "Selecciona: ")
    switch($op){
        1{VerificarServicio}
        2{Instalar}
        3{Configurar}
        4{ListarConcesiones}
        5{ReiniciarDHCP}
        6{$con = "n"}
        default{Write-Host "Opcion no valida"}
    }
}
Write-Host "Programa terminado."