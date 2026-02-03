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
#
sudo apt update && sudo apt full-upgrade -y && flatpak update -y && sudo apt autoremove && sudo apt autoclean
sudo journalctl --vacuum-size=500M
flatpak uninstall --unused
docker system prune -a --volumes
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







