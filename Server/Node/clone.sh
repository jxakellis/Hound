#!/bin/bash

cd

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR}/.."
NODE_DIR="${PARENT_DIR}/Hound/Server/Node"

echo
echo "DIRECTORIES"
echo

echo "SCRIPT DIRECTORY: ${SCRIPT_DIR}"
echo "PARENT DIRECTORY: ${PARENT_DIR}"
echo "NODE DIRECTORY: ${NODE_DIR}"

echo
echo "DELETING"
echo

echo "CLONING FILES INSIDE '/Development/main/secrets' INTO 'developmentSecrets'"
cp -rf "${NODE_DIR}/Development/main/secrets/." "${SCRIPT_DIR}/developmentSecrets"

echo "CLONING FILES INSIDE '/Production/main/secrets' INTO 'productionSecrets'"
cp -rf "${NODE_DIR}/Production/main/secrets/." "${SCRIPT_DIR}/productionSecrets"

echo "DELETING 'Hound'"
rm -rf "${PARENT_DIR}/Hound"

echo
echo "CLONING"
echo

echo "CLONING UPDATED 'Hound' FROM GitHub"
git -C "${PARENT_DIR}" clone git@github.com:jxakellis/Hound.git

echo "GRANTING R & W PRIVILEGES ON 'Hound'"
chmod -R a+rwx "${PARENT_DIR}/Hound"

echo "INSTALLING node_modules INTO 'Development'"
npm --prefix "${NODE_DIR}/Development" i

echo "INSTALLING node_modules INTO 'Production'"
npm --prefix "${NODE_DIR}/Production" i

echo "GRANTING R & W PRIVILEGES ON 'Hound' (again)"
# Grant privileges AGAIN so that jxakellis has read/write privileges on node_modules folder
chmod -R a+rwx "${PARENT_DIR}/Hound"

echo "CLONING FILES INSIDE 'developmentSecrets' INTO '/Development/main/secrets'"
cp -rf "${SCRIPT_DIR}/developmentSecrets/." "${NODE_DIR}/Development/main/secrets"

echo "CLONING FILES INSIDE 'productionSecrets' INTO '/Production/main/secrets'"
cp -rf "${SCRIPT_DIR}/productionSecrets/." "${NODE_DIR}/Production/main/secrets"

echo "CLONING NEW BASH SCRIPT"
cp -rf "${NODE_DIR}/clone.sh" "${SCRIPT_DIR}/clone.sh"

echo
echo "PM2"
echo

echo "STOPPING ALL PROCESSES"
pm2 stop all

echo "DELETING ALL PROCESSES"
pm2 delete all

echo "STARTING 'developmentDatabas.config.js'"
pm2 start "${NODE_DIR}/developmentDatabase.config.js"

echo "STARTING 'productionDatabase.config.js'"
pm2 start "${NODE_DIR}/productionDatabase.config.js"

echo "SAVING PROCESSES"
pm2 save --force

echo "WAITING FIVE SECONDS"
sleep 5

echo "LISTING PROCESSES"
pm2 list

echo
echo "COMPLETE"
echo
