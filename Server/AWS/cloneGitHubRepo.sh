#!/bin/bash
echo "Deleting existing Hound GitHub repo clone"
rm -rf /home/jxakellis/Documents/Hound

echo "Retrieving updated Hound GitHub repo clone"
git -C /home/jxakellis/Documents clone git@github.com:jxakellis/Hound.git

echo "Granting privileges to jxakellis for Hound GitHub repo clone"
# Grant privileges on for new Hound GitHub repo clone so jxakellis user has read/write privileges
chmod -R a+rwx /home/jxakellis/Documents

echo "Installing updated node_modules"
# Use NPM to install node_modules in target folder (one with package.json)
npm --prefix /home/jxakellis/Documents/Hound/Server/Node install

# echo "CANNOT copy secrets folder, please do so manually"
# Copy 'secrets' folder from that shared RDP drive to new Hound GitHub repo clone
# cp -R /home/jxakellis/thinclient_drives /home/jxakellis/Documents/Hound/Server/Node/main
# Grant privileges AGAIN so that jxakellis has read/write privileges on node_modules folder
chmod -R a+rwx /home/jxakellis/Documents
echo "Completed Hound Github repo clone"
echo "Please manually copy the 'secret' folder into /home/jxakellis/Documents/Hound/Server/Node/main"