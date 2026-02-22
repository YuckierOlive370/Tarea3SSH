#!/bin/bash
source ./FunGENERALES.sh

function MostrarUsuarioActual {
    whoami
}

function ListarUsuarios {
    # Lista usuarios locales
    Get-LocalUser | Select-Object -ExpandProperty Name
}

function CrearUsuario {
    param (
        [string]$UserName
    )

    if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
        Write-Output "El usuario $UserName ya existe."
    }
    else {
        $Password = Read-Host "Introduce una contraseña para $UserName" -AsSecureString
        New-LocalUser -Name $UserName -Password $Password -FullName $UserName -Description "Usuario creado desde PowerShell"

        # Agregar al grupo Administradores
        Add-LocalGroupMember -Group "Administrators" -Member $UserName

        Write-Output "Usuario $UserName creado y agregado al grupo Administrators."
    }
}
