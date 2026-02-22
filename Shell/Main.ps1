. .\FunGENERALES.ps1

$con = "S"

while ($con -match '^[sS]$') {
    Write-Host "++++++++ Menu de Opciones ++++++++"
    Write-Host "1.-Gestion de DHCP"
    Write-Host "2.-Gestion de DNS"
    Write-Host "2.-Gestion de SSH"
    Write-Host "3.-Salir"
    $op = [int](Read-Host "Selecciona: ")
    switch($op){
        1{. .\MainDHCP.ps1}
        2{. .\MainDNS.ps1}
        3{. .\MainSSH.ps1}
        4{$con = "n"}
        default{Write-Host "Opcion no valida"}
    }
}
Write-Host "Programa terminado." -ForegroundColor Yellow