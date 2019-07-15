#!/bin/sh

# execute any pre-init scripts

 echo "[mysqld]
sql_mode =
" > /etc/mysql/my.cnf

  mkdir -p /run/mysqld
  chown -R mysql:mysql /run/mysqld

  chown -R mysql:mysql /var/lib/mysql

  mysql_install_db --user=mysql --ldata=/var/lib/mysql > /dev/null

  MYSQL_DATABASE=${MYSQL_DATABASE:-""}

  tfile=`mktemp`
  if [ ! -f "$tfile" ]; then
      return 1
  fi

  cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES ;
GRANT ALL ON *.* TO 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION ;
GRANT ALL ON *.* TO 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION ;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MYSQL_ROOT_PASSWORD}') ;
DROP DATABASE IF EXISTS test ;
FLUSH PRIVILEGES ;
EOF

  echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

  /usr/bin/mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < $tfile
  rm -f $tfile

  chmod 777 -R /www/assets

  mkdir -p /www/manager/includes/
  chmod 777 -R /www/manager/includes/
  touch /www/manager/includes/config.inc.php 
  chmod 777 -R /www/manager/includes/config.inc.php
  

  /usr/sbin/php-fpm7 
  sleep 5
  /usr/sbin/nginx
  /usr/bin/mysqld --user=mysql --console --skip-name-resolve --skip-networking=0 $@

