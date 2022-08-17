#!/bin/bash
echo "Deleting existing Hound GitHub repo clone"
rm -rf /home/jxakellis/Documents/Hound

echo "Retrieving updated Hound GitHub repo clone"
git -C /home/jxakellis/Documents clone git@github.com:jxakellis/Hound.git

echo "Granting privileges on /home/jxakellis/Documents"
# Grant privileges on for new Hound GitHub repo clone so jxakellis user has read/write privileges
chmod -R a+rwx /home/jxakellis/Documents

echo "Installing Development node_modules"
# Use NPM to install node_modules in target folder (one with package.json)
npm --prefix /home/jxakellis/Documents/Hound/Server/Node/Development i

echo "Installing Production node_modules"
# Use NPM to install node_modules in target folder (one with package.json)
npm --prefix /home/jxakellis/Documents/Hound/Server/Node/Production i

echo "Granting privileges on /home/jxakellis/Documents (again)"
# Grant privileges AGAIN so that jxakellis has read/write privileges on node_modules folder
chmod -R a+rwx /home/jxakellis/Documents
echo "Completed Hound Github repo clone"
echo "Please manually copy the 'secret' folder into /home/jxakellis/Documents/Hound/Server/Development/Node/main"
echo "Please manually copy the 'secret' folder into /home/jxakellis/Documents/Hound/Server/Production/Node/main"
