. .\FunGENERALES.ps1

$con = "S"

while ($con -match '^[sS]$') {
    Write-Host "Tarea 4: SSH"-ForegroundColor Yellow
    Write-Host "++++++++ Menu de Opciones ++++++++"
    Write-Host "1.-Instalar"
    Write-Host "2.-Salir"
    $op = [int](Read-Host "Selecciona: ")
    switch($op){
        1{. .\FunSSH.ps1}
        2{$con = "n"}
        default{Write-Host "Opcion no valida" -ForegroundColor Red}
    }
}
Write-Host "Programa terminado. -ForegroundColor Yellow"