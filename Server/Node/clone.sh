#!/bin/bash
cd

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR}/.."
NODE_DIR="${PARENT_DIR}/Hound/Server/Node"

echo $SCRIPT_DIR
echo $PARENT_DIR
echo $NODE_DIR

echo
echo "DELETING"
echo

ls -a "${SCRIPT_DIR}/developmentSecrets"
ls -a "${SCRIPT_DIR}/productionSecrets"

echo "Cloning files inside /Development/main/secrets into developmentSecrets directory"
cp -rf "${NODE_DIR}/Development/main/secrets/." "${SCRIPT_DIR}/developmentSecrets"

echo "Cloning files inside /Production/main/secrets into productionSecrets directory"
cp -rf "${NODE_DIR}/Production/main/secrets/." "${SCRIPT_DIR}/productionSecrets"

ls -a "${SCRIPT_DIR}/developmentSecrets"
ls -a "${SCRIPT_DIR}/productionSecrets"

echo "Deleting Hound directory"
rm -rf "${PARENT_DIR}/Hound"

echo
echo "CLONING"
echo

echo "Cloning updated Hound directory from GitHub"
git -C "${PARENT_DIR}" clone git@github.com:jxakellis/Hound.git

echo "Granting read/write privileges on Hound directory"
chmod -R a+rwx "${PARENT_DIR}/Hound"

echo "Installing node_modules into Development directory"
npm --prefix "${NODE_DIR}/Development" i

echo "Installing node_modules into Production directory"
npm --prefix "${NODE_DIR}/Production" i

echo "Granting read/write privileges on Hound directory (again)"
# Grant privileges AGAIN so that jxakellis has read/write privileges on node_modules folder
chmod -R a+rwx "${PARENT_DIR}/Hound"

ls -a "${NODE_DIR}/Development/main/secrets"
ls -a "${NODE_DIR}/Production/main/secrets"

echo "Cloning files inside developmentSecrets into /Development/main/secrets"
cp -rf "${SCRIPT_DIR}/developmentSecrets/secrets/." "${NODE_DIR}/Development/main/secrets"

echo "Cloning files inside productionSecrets into /Production/main/secrets"
cp -rf "${SCRIPT_DIR}/productionSecrets/secrets/." "${NODE_DIR}/Production/main/secrets"

ls -a "${NODE_DIR}/Development/main/secrets"
ls -a "${NODE_DIR}/Production/main/secrets"

echo "Cloning new bash script"
cp -rf "${NODE_DIR}/clone.sh" "${SCRIPT_DIR}/clone.sh"

echo
echo "PM2"
echo

echo "Stopping all PM2 processes"
pm2 stop all

echo "Deleting all PM2 processes"
pm2 delete all

echo "Starting developmentDatabase PM2"
pm2 start "${NODE_DIR}/developmentDatabase.config.js"

echo "Starting productionDatabase PM2"
pm2 start "${NODE_DIR}/productionDatabase.config.js"

echo "Saving PM2 processes"
pm2 save --force

echo "Waiting 5 seconds"
sleep 5

echo "Listing PM2 processes"
pm2 list

echo
echo "COMPLETE"
echo
