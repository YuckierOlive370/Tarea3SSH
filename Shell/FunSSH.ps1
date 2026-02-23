. .\FunGENERALES.ps1

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

function AbrirPuerto22 {
    # Regla Firewall para abilitar el puerto 22
    New-NetFirewallRule -Name "SSH" `
        -DisplayName "OpenSSH Server (Port 22)" `
        -Enabled True `
        -Direction Inbound `
        -Protocol TCP `
        -Action Allow `
        -LocalPort 22

    Write-Output "Puerto 22 habilitado en el firewall."
}

function EliminarClaveSSH {
    param (
        [string]$Host
    )
    # Elimina la clave antigua del archivo known_hosts
    ssh-keygen -R $Host
    Write-Output "Clave SSH antigua para $Host eliminada de known_hosts."
}
