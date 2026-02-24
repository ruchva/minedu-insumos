# demo frontend
docker build -t svg-demo-app .
docker run -p 3000:3000 svg-demo-app
# demo worker
docker build -t svg-worker -f Dockerfile.worker .
docker run --env-file .env svg-worker
# git
git config pull.rebase false
git fetch origin
git log --name-status --pretty=format: -1
git checkout -b fix-paralelos-director
git push --set-upstream origin fix-paralelos-director
git checkout -b 'fix-paralelos-director' 'origin/fix-paralelos-director'
git branch -a
git merge main
git merge --continue
# GitHub Auth
sudo apt install gh
gh auth login
# configuracion proxy Minedu para desarrollo
git config --global http.proxy http://10.20.30.2:3128
git config --global https.proxy http://10.20.30.2:3128
npm config set proxy http://10.20.30.2:3128
npm config set https-proxy http://10.20.30.2:3128
    ## revisar configuracion proxy: ~/.m2/settings.xml
    ## si usas zshrc revisar configuracion proxy: nano ~/.zshrc
#
npm install -g @github/copilot
npm install -g @google/gemini-cli
rm -rf /home/rchiara/.nvm/versions/node/v22.16.0/lib/node_modules/@google/gemini-cli
npm install -g npm@11.7.0 # o sea actualizar npm
npm install -g @google/gemini-cli
#  si error ENOTEMPTY: directory not empty, rename '/home/rchiara/.nvm/versions/node/v22.16.0/lib/node_modules/@google/gemini-cli' -> '/home/rchiara/.nvm/versions/node/v22.16.0/lib/node_modules/@google/.gemini-cli-RGEtWzur'
#  rm -rf /home/rchiara/.nvm/versions/node/v22.16.0/lib/node_modules/@google/gemini-cli
#  npm cache clean --force
#
#
sudo apt update && sudo apt full-upgrade -y && flatpak update -y && sudo apt autoremove && sudo apt autoclean
sudo journalctl --vacuum-size=500M
flatpak uninstall --unused
docker system prune -a --volumes
#
# installing vscode on Debian
#
# You can install vscode using following commands:
# 1- Start by updating the packages index and installing the dependencies by typing:
sudo apt update
sudo apt install software-properties-common apt-transport-https curl
# 3- Import the Microsoft GPG key using the following curl command:
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
# 4- Add the Visual Studio Code repository to your system:
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
# 5- Install the Visual Studio Code package with:
sudo apt update
sudo apt install code
# updating vscode on Debian
# You can update vscode using following commands:
wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O /tmp/code_latest_amd64.deb
sudo dpkg -i /tmp/code_latest_amd64.deb
#
# python
#
sudo chown -R $USER:$USER /mnt/D/* /mnt/E/* && sudo chmod -R u+rwX /mnt/D /mnt/E
# para que funcione la libreria python
     export PYTHONPATH=$PYTHONPATH:. alembic upgrade head
# zed editor
curl -f https://zed.dev/install.sh | sh
#
ssh beliaojeda@100.0.102.147 -> 16D06p20o25A*
pg_dump -h localhost -U beliaojeda -d db_diploma --schema=sie_fdw --no-owner --no-privileges > sie_fdw_backup.sql
#
docker run -d --name pg-local -e POSTGRES_DB=db_diploma -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:16
docker ps
docker cp db_diploma_dump.sql pg-local:/tmp/
docker exec pg-local psql -U postgres -d db_diploma -f /tmp/db_diploma_dump.sql
# 100.0.102.148:5437
# sie_produccion
# bojeda
# B0G3daP40La41iAg
pg_dump -h 100.0.102.148 -p 5437 -U bojeda -d sie_produccion -Fc -f ./sie_produccion_21012026.dump
watch -n 1 ls -lha sie_produccion_21012026.dump
watch -n 1 ls -la sie_produccion_21012026.dump
# next turbopack se vuelve loco y quiere indexar todo, causa carpeta .git en directorio padre o en home o solo se volvio loco y ya
ulimit -Hn && ulimit -Sn
# si limite bajo aumentar
# * soft nofile 1048576
# * hard nofile 1048576
sudo nano /etc/security/limits.conf
# DefaultLimitNOFILE=1048576
sudo nano /etc/systemd/user.conf
sudo nano /etc/systemd/system.conf
# reboot
# (si usas terminal personalizada)
# añade ulimit -n 1048576 a tu archivo .zshrc
# espacio libre en disco
df -h /
# Busca archivos que contengan "utils" y luego busca "Base58" dentro de ellos
fdfind "utils" -x rg "Base58"
#
fdfind "utils" -x rg "Base58" | xargs grep -H "Base58"
find . -name "*utils*" -exec grep -H "Base58" {} +
# imagenes
convert fullstack-merm.png -resize 800x600 fullstack-merm2.png
convert fullstack-merm.png -resize 1920x1080 fullstack-merm2.png
#
# pega este bloque al final de tu archivo ~/.zshrc
# ==========================================
# ALIAS DE NAVEGACIÓN Y BÚSQUEDA (CASA)
# ==========================================

# 1. Atajos de carpetas
alias ws='cd /mnt/E/Workspace'

# 2. Búsqueda de Archivos (fd)
alias fd='fdfind'
# Buscar archivo por nombre en el Workspace
alias ff='fdfind . /mnt/E/Workspace --type f -i'

# 3. Búsqueda de Contenido (ripgrep)
# Busca texto ignorando mayúsculas y carpetas ocultas/node_modules
alias bb='rg -i --hidden --glob "!.git/*" --glob "!node_modules/*"'

# 4. Gestión de Espacio
# Ver cuánto espacio queda en tus discos principales
alias discos='df -h | grep -E "Filesystem|sd|nvme"'
# Analizar visualmente qué carpeta pesa más en el Workspace
alias pesa='ncdu /mnt/E/Workspace'

# 5. Combo: Buscar archivo y luego buscar texto dentro de él
function find_and_grep() {
    fdfind "$1" /mnt/E/Workspace -x rg "$2"
}
alias ffg=find_and_grep

# ==========================================
# copia de disco completo para llevarme el servidor de desarrollo completo
# ==========================================
# 1. Backup de disco
alias backup='ssh -p9030 root@YOUR-IP "dd if=/dev/vda1 status=progress | gzip -1 -" | dd of=image.gz status=progress'
# 2. Restaurar backup de disco
alias restore='ssh -p9030 root@YOUR-IP "dd if=image.gz status=progress | gunzip -d - | dd of=/dev/vda1 status=progress"'
