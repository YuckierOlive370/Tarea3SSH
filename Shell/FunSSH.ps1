. .\FunGENERALES.ps1

function MostrarUsuarioActual() {
    whoami
}

function ListarUsuarios() {
    cut -d: -f1 /etc/passwd
}

function CrearUsuario() {
    param (
        [string]$FeatureName
    )
    if $FeatureName &>/dev/null; then
        echo "El usuario $FeatureName ya existe."
    else
        sudo adduser $FeatureName
        sudo usermod -aG sudo $FeatureName
        echo "Usuario $FeatureName creado y agregado al grupo sudo."
    fi
}
