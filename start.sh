#!/bin/bash

_BASE_DIR=$(dirname $0)
_PERL_HOME=/usr/local/perl5
_MYSQL_HOME=/usr/local/mysql5
_MYSQL_DATA=/usr/local/var/mysql5
_MYSQL_ROOT_PASSWORD=okok3ok
_TIME_SLEEP=3
_INIT_FLG=false

#initialize mysql
Init_MySQL() {

    #echo "Init_MySQL"
    mkdir -p ${_MYSQL_DATA}/data/InnoDB/redoLogs
    mkdir ${_MYSQL_DATA}/logs
    mkdir ${_MYSQL_DATA}/tmp
    
    ${_PERL_HOME}/bin/perl ${_MYSQL_HOME}/scripts/mysql_install_db --basedir=${_MYSQL_HOME} --datadir=${_MYSQL_DATA}/data --user=mysql

}

#start mysql
Start_MySQL() {

    #echo "Start_MySQL"
    if [ ! -d ${_MYSQL_DATA}/data/mysql ]; then

        echo -e "MySQL is not initialized yet!!\nInitializing start..."
        _INIT_FLG=true
        Init_MySQL
        
    fi

    ${_MYSQL_HOME}/support-files/mysql.server start

    while [ ! -f ${_MYSQL_DATA}/tmp/mysqld.pid ]; do
        sleep ${_TIME_SLEEP} 
    done
    
    if [ ${_INIT_FLG} = true ]; then
        #set root password 
        ${_MYSQL_HOME}/bin/mysqladmin -u root password "${_MYSQL_ROOT_PASSWORD}"
    fi 
}

#exec trap and bash 
Trap_And_Bash() {

    #trap terminal signal when docker stop
    case $1 in
        exec)
         echo "trap '${_MYSQL_HOME}/support-files/mysql.server stop; sleep ${_TIME_SLEEP}; exit 0' TERM" >> /home/mysql/.bashrc
         exec /bin/bash
         ;;
        daemon)
         trap '${_MYSQL_HOME}/support-files/mysql.server stop; sleep ${_TIME_SLEEP}; exit 0' TERM
         #loop...
         while : ; do
             :
         done
         ;;
        *)
         Error
         ;;
    esac


}


Error() {
    echo -e "Usage: $0 [ exec | daemon ]\nexec is to start MySQL in bg\ndaemon is to start MySQL in daemon"
    exit 1
}


if [ $# -eq 0 ] || [ $1 != "exec" -a $1 != "daemon" ]; then
    Error
fi

Start_MySQL
Trap_And_Bash $1

exit $?
