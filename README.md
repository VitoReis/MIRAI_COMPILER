# MIRAI_COMPILER

### Description

This is a shell script I wrote to download prerequisites and compile MIRAI.

### Machine setup:

- Ubuntu 24.04 LTS
- Go 1.6.2 - Old version works better
- MySQL - Latest
- Git - Latest

### How to run:

On your terminal run this commands in order:

- chmod +x \*.sh
- ./presets.sh
- source ~/.bashrc
- ./compiler.sh

# TROUBLESHOTINGS

### DELETING PACKAGES AND THEIR CONFIGURATION {#Delete_Packages}

1. List packages to exclude:
   `sudo apt list --installed | grep <package>`

2. Delete packages and their configuration files:
   `sudo apt purge <package> -y`

3. Once everything is removed, run this code if necessary:
   `sudo rm -r /var/lib/<package>`

### MYSQL ROOT PASSWORD ISSUE

1. Follow this [section](#Delete_Packages)

2. - Terminal:
     `sudo apt-get install mysql-server mysql-client`
     `sudo systemctl enable mysql`
     `sudo mysql -u root mysql`

   - On MySQL terminal :

     > UPDATE user SET plugin='mysql_native_password' WHERE User='root';
     > FLUSH PRIVILEGES;
     > ALTER USER root@localhost IDENTIFIED BY 'password';

   - Terminal:
     `sudo mysql_secure_installation`
