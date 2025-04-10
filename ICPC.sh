#!/bin/bash
# Script para Ubuntu 24.04 que:
# 1. Eleva privilegios usando una contraseña en texto plano (inseguro).
# 2. Realiza actualizaciones del sistema con apt-get y apt.
# 3. Verifica/instala curl y sdkman.
# 4. Instala IDE’s: Visual Studio Code, IntelliJ IDEA, CLion, PyCharm, Vim y Geany.
# 5. Instala compiladores: Python 3, build-essential (para C++17/20),
#    Kotlin (mediante sdkman) y OpenJDK 11, 18 y 21 (mediante sdkman).
#
# ADVERTENCIA: El uso de contraseñas en texto plano y la automatización
# de instalaciones debe usarse solo en entornos controlados o de prueba.

# -------------------------------
# Configuración inicial y funciones
# -------------------------------

# Contraseña de sudo (NO UTILIZAR EN PRODUCCIÓN)
PASSWORD="SetiAlajuela25"

# Función para ejecutar comandos con sudo de forma automática
run_sudo() {
    echo "$PASSWORD" | sudo -S "$@"
}

# Inicializa el ticket de sudo para evitar múltiples solicitudes de contraseña
run_sudo -v

# -------------------------------
# Actualizaciones con apt-get y apt
# -------------------------------

upg() {
echo "Ejecutando apt-get upgrade (1ra vez)..."
run_sudo apt-get upgrade -y

echo "Ejecutando apt-get update..."
run_sudo apt-get update -y

echo "Ejecutando apt-get upgrade (2da vez)..."
run_sudo apt-get upgrade -y

echo "Ejecutando apt upgrade (1ra vez)..."
run_sudo apt upgrade -y

echo "Ejecutando apt update..."
run_sudo apt update -y

echo "Ejecutando apt upgrade (2da vez)..."
run_sudo apt upgrade -y
}

upg

# -------------------------------
# Verificar e instalar curl si es necesario
# -------------------------------
if ! command -v curl &> /dev/null; then
    echo "curl no está instalado. Procediendo a instalar curl..."
    run_sudo apt-get install curl -y
else
    echo "curl ya está instalado."
fi

# -------------------------------
# Verificar e instalar sdkman si es necesario
# -------------------------------
if [ ! -d "$HOME/.sdkman" ]; then
    echo "sdkman no está instalado. Procediendo a instalar sdkman..."
    curl -s "https://get.sdkman.io" | bash
    # Inicializa sdkman para la sesión actual
    source "$HOME/.sdkman/bin/sdkman-init.sh"
else
    echo "sdkman ya está instalado."
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Para evitar confirmaciones interactivas en las instalaciones con sdkman
export SDKMAN_AUTO_ANSWER=true

# -------------------------------
# Instalación de IDE's
# -------------------------------

echo "-------------------------------"
echo "Instalación de IDE's"
echo "-------------------------------"

# Visual Studio Code (instalado via apt con repositorio oficial)
if ! command -v code &> /dev/null; then
    echo "Instalando Visual Studio Code..."
    run_sudo apt install wget gpg -y
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    run_sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    run_sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    run_sudo apt update
    run_sudo apt install code -y
    rm packages.microsoft.gpg
else
    echo "Visual Studio Code ya está instalado."
fi

# Verifica que snap esté disponible; en Ubuntu 24.04 normalmente ya está instalado.
if ! command -v snap &> /dev/null; then
    echo "snap no está instalado. Instalando snapd..."
    run_sudo apt install snapd -y
fi

# IntelliJ IDEA Community Edition
if ! snap list | grep -q "intellij-idea-community"; then
    echo "Instalando IntelliJ IDEA Community Edition..."
    run_sudo snap install intellij-idea-community --classic
else
    echo "IntelliJ IDEA Community Edition ya está instalado."
fi

# CLion
if ! snap list | grep -q "clion"; then
    echo "Instalando CLion..."
    run_sudo snap install clion --classic
else
    echo "CLion ya está instalado."
fi

# PyCharm Community Edition
if ! snap list | grep -q "pycharm-community"; then
    echo "Instalando PyCharm Community Edition..."
    run_sudo snap install pycharm-community --classic
else
    echo "PyCharm Community Edition ya está instalado."
fi

# Vim
if ! command -v vim &> /dev/null; then
    echo "Instalando Vim..."
    run_sudo apt install vim -y
else
    echo "Vim ya está instalado."
fi

# Geany
if ! command -v geany &> /dev/null; then
    echo "Instalando Geany..."
    run_sudo apt install geany -y
else
    echo "Geany ya está instalado."
fi

# -------------------------------
# Instalación de compiladores y herramientas de desarrollo
# -------------------------------

echo "-------------------------------"
echo "Instalación de compiladores y herramientas"
echo "-------------------------------"

# Python 3
if ! command -v python3 &> /dev/null; then
    echo "Instalando Python3..."
    run_sudo apt install python3 -y
else
    echo "Python3 ya está instalado."
fi

# Compiladores C/C++ (build-essential incluye gcc, g++ y demás utilidades)
if ! command -v g++ &> /dev/null; then
    echo "Instalando compiladores C/C++ (build-essential)..."
    run_sudo apt install build-essential -y
else
    echo "Compiladores C/C++ ya están instalados (build-essential)."
fi

# Kotlin (Kotlinc) vía sdkman
echo "Instalando Kotlin (Kotlinc) vía sdkman..."
if sdk list kotlin | grep -q "installed"; then
    echo "Kotlin ya está instalado a través de sdkman."
else
    sdk install kotlin
fi

# OpenJDK: Instalamos versiones 11, 18 y 21 vía sdkman
# Nota: Los identificadores de versión pueden variar. Se usan aquí ejemplos basados en distribuciones Temurin.
echo "Instalando OpenJDK 11, 18 y 21 vía sdkman..."
run_sudo apt-get install openjdk-11-jdk
SDKMAN_AUTO_ANSWER=true sdk install java 18.0.2-open
run_sudo apt-get install openjdk-21-jdk
run_sudo apt install default-jre -y

upg

echo "-------------------------------"
echo "Instalación completada."

