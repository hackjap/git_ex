#sudo apt-get update
#sudo apt-get install -y libaio1 libaio-dev
#sudo apt-get install -y libncurses5

# 페쇠망 설치 

cd /var/cache/apt/archives  
dpkg -i *.deb

# 권한 및 그룹 추가 
sudo groupadd mysql
sudo useradd -g mysql mysql
sudo mkdir -p /var/log/mysql
sudo mkdir -p /etc/mysql
sudo touch /var/log/mysql/error.log
sudo chmod 660 /var/log/mysql/error.log
sudo chown -R mysql:mysql /var/log/mysql
sudo chown -R mysql:mysql /etc/mysql

# maria db 설치 
# sudo wget https://downloads.mariadb.com/MariaDB/mariadb-10.4.15/bintar-linux-x86_64/mariadb-10.4.15-linux-x86_64.tar.gz
# 바이너리 파일 
sudo mv mariadb-10.4.15-linux-x86_64.tar.gz /usr/local/ && cd /usr/local
sudo tar xzvf mariadb-10.4.15-linux-x86_64.tar.gz
sudo rm mariadb-10.4.15-linux-x86_64.tar.gz
sudo ln -s /usr/local/mariadb-10.4.15-linux-x86_64 mysql
cd mysql


sudo bash -c "cat << EOF > /etc/mysql/my.cnf
[client]
port		= 3306
socket		= /var/run/mysqld/mysqld.sock

# Here is entries for some specific programs
# The following values assume you have at least 32M ram

# This was formally known as [safe_mysqld]. Both versions are currently parsed.
[mysqld_safe]
socket		= /var/run/mysqld/mysqld.sock
nice		= 0

[mysqld]
#
# * Basic Settings
#
user		= mysql
pid-file	= /var/run/mysqld/mysqld.pid
socket		= /var/run/mysqld/mysqld.sock
port		= 3306
basedir		= /usr/local/mysql
datadir		= /usr/local/mysql/data
tmpdir		= /tmp
lc_messages_dir	= /usr/share/mysql
lc_messages	= en_US
skip-external-locking
skip-name-resolve
#
# Instead of skip-networking the default is now to listen only on
# localhost which is more compatible and is not less secure.
bind-address		= 0.0.0.0
#
# * Fine Tuning
#
max_connections		      = 10000
connect_timeout		      = 10
wait_timeout		        = 28800
interactive_timeout	    = 28800
max_allowed_packet	    = 16M
thread_cache_size       = 128
sort_buffer_size	      = 4M
bulk_insert_buffer_size	= 16M
tmp_table_size		      = 32M
max_heap_table_size	    = 32M
net_buffer_length	      = 8K
collation-server	      = utf8mb4_general_ci
init-connect		        = 'SET NAMES utf8mb4'
character-set-server 	  = utf8mb4
log_bin_trust_function_creators = 1
#
# * MyISAM
#
# This replaces the startup script and checks MyISAM tables if needed
# the first time they are touched. On error, make copy and try a repair.
myisam_recover_options = BACKUP
key_buffer_size		= 128M
#open-files-limit	= 64000
table_open_cache	= 32000
myisam_sort_buffer_size	= 512M
concurrent_insert	= 2
read_buffer_size	= 2M
read_rnd_buffer_size	= 1M
#
# * Query Cache Configuration
#
# Cache only tiny result sets, so we can fit more in the query cache.
query_cache_limit		= 128K
query_cache_size		= 64M
# for more write intensive setups, set to DEMAND or OFF
#query_cache_type		= DEMAND
#
# * Logging and Replication
#
# Both location gets rotated by the cronjob.
# Be aware that this log type is a performance killer.
# As of 5.1 you can enable the log at runtime!
#general_log_file        = /var/log/mysql/mysql.log
#general_log             = 1
#
# Error logging goes to syslog due to /etc/mysql/conf.d/mysqld_safe_syslog.cnf.
#
# we do want to know about network errors and such
log_warnings		= 2
log-error=/var/log/mysql/error.log
#
# Enable the slow query log to see queries with especially long duration
#slow_query_log = 1
slow_query_log_file	= /var/log/mysql/mariadb-slow.log
long_query_time = 10
#log_slow_rate_limit	= 1000
log_slow_verbosity	= query_plan

#log-queries-not-using-indexes
#log_slow_admin_statements
#
# The following can be used as easy to replay backup logs or for replication.
# note: if you are setting up a replication slave, see README.Debian about
#       other settings you may need to change.
#server-id		= 1
#report_host		= master1
#auto_increment_increment = 2
#auto_increment_offset	= 1
log_bin			= /var/log/mysql/mariadb-bin
log_bin_index		= /var/log/mysql/mariadb-bin.index
# not fab for performance, but safer
#sync_binlog		= 1
expire_logs_days	= 2
max_binlog_size         = 100M
# slaves
#relay_log		= /var/log/mysql/relay-bin
#relay_log_index	= /var/log/mysql/relay-bin.index
#relay_log_info_file	= /var/log/mysql/relay-bin.info
#log_slave_updates
#read_only
#
# If applications support it, this stricter sql_mode prevents some
# mistakes like inserting invalid dates etc.
#sql_mode		= NO_ENGINE_SUBSTITUTION,TRADITIONAL
#
# * InnoDB
#
# InnoDB is enabled by default with a 10MB datafile in /var/lib/mysql/.
# Read the manual for more InnoDB related options. There are many!
default_storage_engine	= InnoDB
innodb_buffer_pool_size	= 256M
innodb_log_buffer_size	= 8M
innodb_file_per_table	= 1
innodb_open_files	= 400
innodb_io_capacity	= 400
innodb_flush_method	= O_DIRECT
#
# * Security Features
#
# Read the manual, too, if you want chroot!
# chroot = /var/lib/mysql/
#
# For generating SSL certificates I recommend the OpenSSL GUI "tinyca".
#
# ssl-ca=/etc/mysql/cacert.pem
# ssl-cert=/etc/mysql/server-cert.pem
# ssl-key=/etc/mysql/server-key.pem

[mysqldump]
quick
quote-names
max_allowed_packet	= 16M

[mysql]
#no-auto-rehash	# faster start of mysql but no tab completion

[isamchk]
key_buffer		= 16M

EOF
"


# maria db 초기 셋팅 
sudo sh -c "echo export PATH=/usr/local/mysql/bin:\$PATH >> /etc/profile"
source /etc/profile

sudo cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
sudo update-rc.d mysqld defaults

sudo ./scripts/mysql_install_db --user=mysql --datadir=/usr/local/mysql/data --basedir=/usr/local/mysql --auth-root-authentication-method=normal  --defaults-file=/etc/mysql/my.cnf
#sudo ./bin/mysqld_safe --basedir=/usr/local/mysql --datadir='./data' &
sudo systemctl start mysqld

sudo mysql -e "CREATE USER 'sstauth'@'localhost' IDENTIFIED BY 'sstauth'"
sudo mysql -e "GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'sstauth'@'localhost'"
sudo mysql -e "FLUSH PRIVILEGES"


#repo ???? 
cd ~
#wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup
sudo ./mariadb_repo_setup --mariadb-server-version="mariadb-10.4.15"


sudo systemctl enable mysqld
sudo systemctl stop mysqld