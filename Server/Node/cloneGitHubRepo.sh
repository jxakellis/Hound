#!/bin/bash
echo
echo "DELETING"
echo

echo "Deleting previously stored development secrets"
rm -rf /home/jxakellis/Documents/developmentSecrets/secrets
echo "Storing current development secrets"
cp -R /home/jxakellis/Documents/Hound/Server/Node/Development/main/secrets  /home/jxakellis/Documents/developmentSecrets

echo "Deleting previously stored production secrets"
rm -rf /home/jxakellis/Documents/productionSecrets/secrets
echo "Storing current production secrets"
cp -R /home/jxakellis/Documents/Hound/Server/Node/Production/main/secrets  /home/jxakellis/Documents/productionSecrets

echo "Deleting existing Hound GitHub repo clone"
rm -rf /home/jxakellis/Documents/Hound

echo
echo "CLONING"
echo

echo "Retrieving updated Hound GitHub repo clone"
git -C /home/jxakellis/Documents clone git@github.com:jxakellis/Hound.git

echo "Granting read/write privileges on /home/jxakellis/Documents for jxakellis"
chmod -R a+rwx /home/jxakellis/Documents

echo "Installing Development node_modules"
npm --prefix /home/jxakellis/Documents/Hound/Server/Node/Development i

echo "Installing Production node_modules"
npm --prefix /home/jxakellis/Documents/Hound/Server/Node/Production i

echo "Granting read/write privileges on /home/jxakellis/Documents for jxakellis (again)"
# Grant privileges AGAIN so that jxakellis has read/write privileges on node_modules folder
chmod -R a+rwx /home/jxakellis/Documents

echo "Copying stored development secrets back into place"
cp -R /home/jxakellis/Documents/developmentSecrets/secrets /home/jxakellis/Documents/Hound/Server/Node/Development/main 
echo "Deleting stored development secrets"
rm -rf /home/jxakellis/Documents/developmentSecrets/secrets 

echo "Copying stored production secrets back into place"
cp -R /home/jxakellis/Documents/productionSecrets/secrets /home/jxakellis/Documents/Hound/Server/Node/Production/main 
echo "Deleting stored production secrets"
rm -rf /home/jxakellis/Production/productionSecrets/secrets 

echo
echo "PM2"
echo

echo "Stopping All PM2 Processes"
pm2 stop all

echo "Deleting All PM2 Processes"
pm2 delete all

echo "Starting Development PM2"
pm2 start /home/jxakellis/Documents/Hound/Server/Node/development.config.js

echo "Starting Production PM2"
pm2 start /home/jxakellis/Documents/Hound/Server/Node/production.config.js

echo "Saving PM2 Processes"
pm2 save --force

echo "Listing PM2 Processes"
pm2 list

echo
echo "COMPLETE"
echo
