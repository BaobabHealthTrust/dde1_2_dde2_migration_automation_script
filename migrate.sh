#!/usr/bin/env bash

ROOT=$(pwd);

OS=$(uname -m);

DIALOG=$(command -v dialog);

PV=$(command -v pv);

COUCHDB=$(command -v couchdb);

GIT=$(command -v git);

MYSQL=$(command -v mysql);

RVM=$(command -v rvm);

RUBY=$(command -v ruby);

VALIDATOR_PORT=3006;

FIREFOX=$(command -v firefox);

IP_ADDRESS=$(hostname -I | cut -d' ' -f1);
PROTOCOL="http";
HOST="$IP_ADDRESS";
COUCHDB_PORT="5984";
COUCHDB_HOST="$HOST";
	
getUserChecks()
{
	exec 3>&1
	
	declare -a ARR=("${!4}");
	
  RETVAL=$(dialog --clear --backtitle "$1" --title "$2" --checklist "$3" 20 51 4 "${ARR[@]}" 2>&1 1>&3)
  
  EXIT_CODE=$?
  
  if [ $EXIT_CODE == 1 ] || [ $EXIT_CODE == 255 ]; then
  
  	clear;
  
  	exit 1;
  
  fi
  
  exec 3>&-	
}

selectFile()
{
	exec 3>&1
	
  RETVAL=$(dialog --stdout --clear --backtitle "$1" --title "$2" --fselect $3 14 48) 
  
  EXIT_CODE=$?
  
  if [ $EXIT_CODE == 255 ]; then
  
  	clear;
  
  	exit 1;
  
  fi
  
  exec 3>&-	
}

showMessageBox() 
{
	exec 3>&1
	
  RETVAL=$(dialog --clear --backtitle "$1" --title "$2" --msgbox "$3" 8 51 2>&1 1>&3)
  
  EXIT_CODE=$?
  
  if [ $EXIT_CODE == 255 ]; then
  
  	clear;
  
  	exit 1;
  
  fi
  
  exec 3>&-	
}

getUserPassword() 
{
	exec 3>&1
	
  RETVAL=$(dialog --clear --backtitle "$1" --title "$2" --insecure --passwordbox "$3" 16 51 2>&1 1>&3)
  
  EXIT_CODE=$?
  
  if [ $EXIT_CODE == 1 ] || [ $EXIT_CODE == 255 ]; then
  
  	clear;
  
  	exit 1;
  
  fi
  
  exec 3>&-	
}

getUserData() 
{
	exec 3>&1
	
  RETVAL=$(dialog --clear --backtitle "$1" --title "$2" --inputbox "$3" 16 51 2>&1 1>&3)
  
  EXIT_CODE=$?
  
  if [ $EXIT_CODE == 1 ] || [ $EXIT_CODE == 255 ]; then
  
  	clear;
  
  	exit 1;
  
  fi
  
  exec 3>&-	
}

getUserConfirmation()
{
	exec 3>&1
	
  RETVAL=$(dialog --clear --backtitle "$1" --title "$2" --yesno "$3" 10 30 2>&1 1>&3)
  
  EXIT_CODE=$?
  
  if [ $EXIT_CODE == 255 ]; then
  
  	clear;
  
  	exit 1;
  
  fi
  
  exec 3>&-	
}

getUserOption()
{
	exec 3>&1
	
	declare -a ARR=("${!4}");
	
  RETVAL=$(dialog --clear --backtitle "$1" --title "$2" --menu "$3" 20 51 4 "${ARR[@]}" 2>&1 1>&3)
  
  EXIT_CODE=$?
  
  
  if [ $EXIT_CODE == 1 ] || [ $EXIT_CODE == 255 ]; then
  
  	clear;
  
  	exit 1;
  
  fi  
  
  exec 3>&-	
}

nc -z 8.8.8.8 53  >/dev/null 2>&1;
online=$?;

if [ ${#DIALOG} == 0 ]; then

	cd "$ROOT/dist/dialog";

	sudo dpkg -R --install .;

	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi

	cd "$ROOT";

	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi

fi

if [ ${#PV} == 0 ]; then

	cd "$ROOT/dist/pv";

	sudo dpkg -R --install .;

	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi

	cd "$ROOT";

	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi

fi

if [ ${#RVM} == 0 ]; then

	cd "$ROOT/dist/rvm-ruby/deps/";
	
	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi
	
	sudo dpkg -i --force-depends *.deb;

	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi
	
	cd "$ROOT/dist/rvm-ruby/rvm/";
	
	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi
		
	if [ ! -f "$ROOT/dist/rvm-ruby/rvm/install" ] && [ -f "$ROOT/dist/rvm-ruby/rvm/scripts/install" ]; then
	
		ln -s "$ROOT/dist/rvm-ruby/rvm/scripts/install" .;
	
	fi
	
	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi
		
	chmod +x "$ROOT/dist/rvm-ruby/rvm/install";
	
	./install --auto-dotfiles;
	
	source ~/.rvm/scripts/rvm;
	
	RVM=$(command -v rvm);

	if [ ${#RVM} == 0 ]; then
	
		exit 1;
	
	fi
	
	cd "$ROOT/dist/rvm-ruby";
	
	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi
		
	gem install bundler-1.6.2.gem;
	
	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi		
	
	cd "$ROOT";
	
fi

if [ ${#RVM} -gt 0 ] && [ ${#RUBY} == 0 ]; then

  showMessageBox "Environment Configuration" "Ruby Setup" "Ruby not found. Installing Ruby.";

	clear;
	
	cp "$ROOT/dist/rvm-ruby/ruby-2.1.2.tar.bz2" ~/.rvm/archives/;

	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi
		
	cp "$ROOT/dist/rvm-ruby/rubygems-2.2.2.tar.gz" ~/.rvm/archives/;

	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi
		
	cp "$ROOT/dist/rvm-ruby/yaml-0.1.6.tar.gz" ~/.rvm/archives/;

	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi
		
	rvm --verify-downloads 2 --disable-binary install 2.1.2 --rubygems 2.2.2;
		
fi

if [ ${#MYSQL} == 0 ]; then

  showMessageBox "Environment Configuration" "MySQL Setup" "MySQL not found. Installing MySQL.";

	clear;
	
	cd "$ROOT/dist/mysql";

	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi

	sudo dpkg -i --force-depends *.deb;

	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi

	cd "$ROOT";

	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi

	cd "$ROOT";

else

    showMessageBox "Environment Configuration" "MySQL Setup" "MySQL found: OK";

		clear;
		
fi

if [ ${#COUCHDB} == 0 ]; then

    showMessageBox "Environment Configuration" "CouchDB Setup" "CouchDB not found. Installing CouchDB.";

		clear;
		
		if [[ $online -eq 0 ]]; then

				sudo apt-get install software-properties-common -y;

				sudo add-apt-repository ppa:couchdb/stable -y;

				sudo apt-get update;

				sudo apt-get remove couchdb couchdb-bin couchdb-common -yf;

				sudo apt-get autoremove -yf;

				sudo apt-get install couchdb -y;

				if [ $? -ne 0 ]; then
	
					exit 1;
	
				fi

		else

			cd ./dist/couchdb;
			
			if [ $? -ne 0 ]; then
	
				exit 1;
	
			fi

			sudo dpkg -i --force-depends *.deb;
			
			if [ $? -ne 0 ]; then
	
				sudo service couchdb restart

				if [ $? -ne 0 ]; then
	
					exit 1;
	
				fi

				curl localhost:5984

				if [ $? -ne 0 ]; then
	
					# Wait a bit and retry
					sleep 10;

					curl localhost:5984

					if [ $? -ne 0 ]; then
							
						if [ $? -ne 0 ]; then
	
							# Wait a bit and retry
							sleep 10;

							curl localhost:5984

							if [ $? -ne 0 ]; then
	
								exit 1;
	
							fi

						fi				
	
					fi

				fi				

			fi

			cd "$ROOT";

			if [ $? -ne 0 ]; then
	
				exit 1;
	
			fi

		fi

		clear

	  getUserData "Environment Configuration" "CouchDB Setup" "Enter CouchDB database usename: ";
	  
	  COUCHDB_DATABASE_USERNAME=$RETVAL;
	  
	  clear
  
	  getUserPassword "Environment Configuration" "CouchDB Setup" "Enter CouchDB database password for '$COUCHDB_DATABASE_USERNAME': ";
	  
	  COUCHDB_DATABASE_PASSWORD=$RETVAL;

		clear

		curl -X PUT -H 'Content-Type: application/json' --data "\"$COUCHDB_DATABASE_PASSWORD\"" "http://localhost:5984/_config/admins/$COUCHDB_DATABASE_USERNAME"

		sudo sed -i 's/;port = 5984/port = '$COUCHDB_PORT'/g' /etc/couchdb/local.ini

		if [ $? -ne 0 ]; then
	
			exit 1;
	
		fi

		sudo sed -i 's/;bind_address = 127.0.0.1/bind_address = 0.0.0.0/g' /etc/couchdb/local.ini

		if [ $? -ne 0 ]; then
	
			exit 1;
	
		fi

		sudo service couchdb restart

		if [ $? -ne 0 ]; then
	
			exit 1;
	
		fi

		curl localhost:5984

		COUCHDB=$(command -v couchdb);

		echo
		
else
    
	  getUserData "Environment Configuration" "CouchDB Setup" "Enter CouchDB database usename: ";
	  
	  COUCHDB_DATABASE_USERNAME=$RETVAL;
	  
	  clear
  
	  getUserPassword "Environment Configuration" "CouchDB Setup" "Enter CouchDB database password for '$COUCHDB_DATABASE_USERNAME': ";
	  
	  COUCHDB_DATABASE_PASSWORD=$RETVAL;

		clear

	  getUserData "Environment Configuration" "CouchDB Setup" "Enter CouchDB database host [default: $HOST]: ";
	  
	  COUCHDB_HOST=$RETVAL;
	  
	  if [ ${#COUCHDB_HOST} == 0 ]; then
	  
	  	COUCHDB_HOST="$HOST";
	  
	  else
	  
	  	HOST=$COUCHDB_HOST;
	  
	  fi
	  
	  clear
  
	  getUserData "Environment Configuration" "CouchDB Setup" "Enter CouchDB database port [default: 5984]: ";
	  
	  COUCHDB_PORT=$RETVAL;
	  
	  if [ ${#COUCHDB_PORT} == 0 ]; then
	  
	  	COUCHDB_PORT=5984;
	  
	  fi
	  
	  clear
  
fi

if [ ! -d "$ROOT/sources" ]; then

	mkdir -p "$ROOT/sources";
	
	if [ $? -ne 0 ]; then
	
		exit 1;
	
	fi

fi

# If Git installed and tool source files not found, download else update if new 
# changes exist online 
if [ ${#GIT} -gt 0 ]; then

	if [ ! -d "$ROOT/sources/dde2_migration_tool" ]; then
	
		cd "$ROOT/sources";
		
		if [ $? -ne 0 ]; then
		
			exit 1;
			
		else
		
			git clone https://github.com/BaobabHealthTrust/dde2_migration_tool.git;						
		
		fi
	
	else
	
		cd "$ROOT/sources/dde2_migration_tool";
	
		git pull https://github.com/BaobabHealthTrust/dde2_migration_tool.git;
	
		cd "$ROOT";
	
	fi

	if [ ! -d "$ROOT/sources/dde2_migration_validator" ]; then
	
		cd "$ROOT/sources";
		
		if [ $? -ne 0 ]; then
		
			exit 1;
			
		else
		
			git clone https://github.com/BaobabHealthTrust/dde2_migration_validator.git;						
		
		fi
	
	else
	
		cd "$ROOT/sources/dde2_migration_validator";
	
		git pull https://github.com/BaobabHealthTrust/dde2_migration_validator.git;
	
		cd "$ROOT";
	
	fi

fi

# Select mode of master data migration
declare -a DDE1_MASTER_SOURCE=("1" "Dumped Data Copy" "2" "Existing MySQL Server Instance");

getUserOption "Environment Configuration" "DDE1 Master Database Configuration" "Please select what the source of DDE1 master data will be: " DDE1_MASTER_SOURCE[@]

case $RETVAL in
	1)
		DDE1_MASTER_SRC="dump";;
	2)
		DDE1_MASTER_SRC="server";;
esac
	  
clear

# Default DDE1 master database name
DDE1_MASTER_DATABASE="dde1_migration_master";

# If dump selected to be used for loading, get MySQL server IP address, username and password
if [ ${#DDE1_MASTER_SRC} -ne 0 ] && [ "$DDE1_MASTER_SRC" == "dump" ]; then

	getUserData "Environment Configuration" "DDE1 Master Database Configuration" "Enter DDE1 master SQL dump path: ";
	
	DDE1_MASTER_DUMP=$RETVAL;

	clear;
	
	getUserData "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL database host IP address to load data on [default: $HOST]: ";

	MYSQL_DDE1_MASTER_HOST=$RETVAL;

	clear			

	if [ ${#MYSQL_DDE1_MASTER_HOST} == 0 ]; then

		MYSQL_DDE1_MASTER_HOST="$HOST";

	fi

	clear

	if [ ${#MYSQL_DDE1_MASTER_HOST} == 0 ] && [ ${#HOST} != 0 ]; then

		MYSQL_DDE1_MASTER_HOST=$HOST;

	fi

	echo

	getUserData "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL username of the instance on '$MYSQL_DDE1_MASTER_HOST': ";

	MYSQL_DDE1_MASTER_USERNAME=$RETVAL;

	clear			

	getUserPassword "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL password for '$MYSQL_DDE1_MASTER_USERNAME' on '$MYSQL_DDE1_MASTER_HOST': ";

	MYSQL_DDE1_MASTER_PASSWORD=$RETVAL;

	clear

	clear			

	if [ ${#DDE1_MASTER_DUMP} -gt 0 ] && [ -f "$DDE1_MASTER_DUMP" ]; then
		
    showMessageBox "Environment Configuration" "DDE1 Master Setup" "Dropping '$DDE1_MASTER_DATABASE' database if it exists on target machine to load supplied dump";

		clear;				
		
		mysql -h $MYSQL_DDE1_MASTER_HOST -u $MYSQL_DDE1_MASTER_USERNAME -p$MYSQL_DDE1_MASTER_PASSWORD -e "DROP SCHEMA IF EXISTS $DDE1_MASTER_DATABASE";
				
		if [ $? -ne 0 ]; then
		
			exit 1;
			
		fi
			
		mysql -h $MYSQL_DDE1_MASTER_HOST -u $MYSQL_DDE1_MASTER_USERNAME -p$MYSQL_DDE1_MASTER_PASSWORD -e "CREATE SCHEMA $DDE1_MASTER_DATABASE";
				
		if [ $? -ne 0 ]; then
		
			exit 1;
			
		fi
			
    showMessageBox "Environment Configuration" "DDE1 Master Setup" "Loading provided dump into '$DDE1_MASTER_DATABASE' database";

		clear;	
			
		(pv -n $DDE1_MASTER_DUMP | mysql -h $MYSQL_DDE1_MASTER_HOST -u $MYSQL_DDE1_MASTER_USERNAME -p$MYSQL_DDE1_MASTER_PASSWORD $DDE1_MASTER_DATABASE) 2>&1 | dialog --gauge "Loading provided dump..." 6 50;
		
		if [ $? -ne 0 ]; then
		
			exit 1;
			
		fi
			
	fi

# Else if an existing server selected to be used for loading, get MySQL server IP address, username, password and database name to work with
elif [ ${#DDE1_MASTER_SRC} -ne 0 ] && [ "$DDE1_MASTER_SRC" == "server" ]; then

	getUserData "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL database host IP address to fetch data from [default: $HOST]: ";

	MYSQL_DDE1_MASTER_HOST=$RETVAL;

	clear			

	if [ ${#MYSQL_DDE1_MASTER_HOST} == 0 ]; then

		MYSQL_DDE1_MASTER_HOST="$HOST";

	fi

	clear

	if [ ${#MYSQL_DDE1_MASTER_HOST} == 0 ] && [ ${#HOST} != 0 ]; then

		MYSQL_DDE1_MASTER_HOST=$HOST;

	fi

	echo

	getUserData "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL username of the instance on '$MYSQL_DDE1_MASTER_HOST': ";

	MYSQL_DDE1_MASTER_USERNAME=$RETVAL;

	clear			

	getUserPassword "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL password for '$MYSQL_DDE1_MASTER_USERNAME' on '$MYSQL_DDE1_MASTER_HOST': ";

	MYSQL_DDE1_MASTER_PASSWORD=$RETVAL;

	clear

	getUserData "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL DDE1 master database name of the instance on '$MYSQL_DDE1_MASTER_HOST': ";

	DDE1_MASTER_DATABASE=$RETVAL;

	clear			

fi

# Select source of data for proxy data
declare -a DDE1_PROXY_SOURCE=("1" "Dumped Data Copy" "2" "Existing MySQL Server Instance");

getUserOption "Environment Configuration" "DDE1 Proxy Database" "Please select what the source of DDE1 proxy data will be: " DDE1_PROXY_SOURCE[@]

case $RETVAL in
	1)
		DDE1_PROXY_SRC="dump";;
	2)
		DDE1_PROXY_SRC="server";;
esac
	  
clear

# Default proxy database name in case it's not defined
DDE1_PROXY_DATABASE="dde1_migration_proxy";

# If dump selected, get MySQL server IP address, username and password
if [ ${#DDE1_PROXY_SRC} -ne 0 ] && [ "$DDE1_PROXY_SRC" == "dump" ]; then

	getUserData "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter DDE1 proxy SQL dump path: ";

	DDE1_PROXY_DUMP=$RETVAL;

	clear;
	
	getUserConfirmation "Environment Configuration" "DDE1 Proxy Database Configuration" "Are the database connection settings for the DDE1 proxy server the same as those for the DDE1 master server?";
		
	case $EXIT_CODE in
		0)
			PROXY_AND_MASTER_COEXIST="y";;
		1)
			PROXY_AND_MASTER_COEXIST="n";;
		255)
			exit 1;;
	esac

	clear		
	
	if [ ${#PROXY_AND_MASTER_COEXIST} -ne 0 ]; then
	
		MYSQL_DDE1_PROXY_HOST="$MYSQL_DDE1_MASTER_HOST";
	
		MYSQL_DDE1_PROXY_USERNAME="$MYSQL_DDE1_MASTER_USERNAME";
		
		MYSQL_DDE1_PROXY_PASSWORD="$MYSQL_DDE1_MASTER_PASSWORD";
	
	else
	
		getUserData "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL database host IP address to load proxy data on [default: $HOST]: ";

		MYSQL_DDE1_PROXY_HOST=$RETVAL;

		clear			

		if [ ${#MYSQL_DDE1_PROXY_HOST} == 0 ]; then

			MYSQL_DDE1_PROXY_HOST="$HOST";

		fi

		clear

		if [ ${#MYSQL_DDE1_PROXY_HOST} == 0 ] && [ ${#HOST} != 0 ]; then

			MYSQL_DDE1_PROXY_HOST=$HOST;

		fi

		echo

		getUserData "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL username of the instance on '$MYSQL_DDE1_PROXY_HOST': ";

		MYSQL_DDE1_PROXY_USERNAME=$RETVAL;

		clear			

		getUserPassword "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL password for '$MYSQL_DDE1_PROXY_USERNAME' on '$MYSQL_DDE1_PROXY_HOST': ";

		MYSQL_DDE1_PROXY_PASSWORD=$RETVAL;

		clear

	fi

	if [ ${#DDE1_PROXY_DUMP} -gt 0 ] && [ -f "$DDE1_PROXY_DUMP" ]; then
	
	  showMessageBox "Environment Configuration" "DDE1 Proxy Setup" "Dropping '$DDE1_PROXY_DATABASE' database if it exists on target machine to load supplied dump";

		clear;				
	
		mysql -h $MYSQL_DDE1_PROXY_HOST -u $MYSQL_DDE1_PROXY_USERNAME -p$MYSQL_DDE1_PROXY_PASSWORD -e "DROP SCHEMA IF EXISTS $DDE1_PROXY_DATABASE";
	
		if [ $? -ne 0 ]; then
		
			exit 1;
			
		fi
			
		mysql -h $MYSQL_DDE1_PROXY_HOST -u $MYSQL_DDE1_PROXY_USERNAME -p$MYSQL_DDE1_PROXY_PASSWORD -e "CREATE SCHEMA $DDE1_PROXY_DATABASE";
	
		if [ $? -ne 0 ]; then
		
			exit 1;
			
		fi
			
	  showMessageBox "Environment Configuration" "DDE1 Proxy Setup" "Loading provided dump into '$DDE1_PROXY_DATABASE' database";

		clear;	
		
		(pv -n $DDE1_PROXY_DUMP | mysql -h $MYSQL_DDE1_PROXY_HOST -u $MYSQL_DDE1_PROXY_USERNAME -p$MYSQL_DDE1_PROXY_PASSWORD $DDE1_PROXY_DATABASE) 2>&1 | dialog --gauge "Loading provided dump..." 6 50;
	
		if [ $? -ne 0 ]; then
		
			exit 1;
			
		fi
			
	fi

# Else if server selected, get MySQL server IP address, username, password and database name
elif [ ${#DDE1_PROXY_SRC} -ne 0 ] && [ "$DDE1_PROXY_SRC" == "server" ]; then

	getUserConfirmation "Environment Configuration" "DDE1 Proxy Database Configuration" "Are the database connection settings for the DDE1 proxy server the same as those for the DDE1 master server?";
		
	case $EXIT_CODE in
		0)
			PROXY_AND_MASTER_COEXIST="y";;
		1)
			PROXY_AND_MASTER_COEXIST="n";;
		255)
			exit 1;;
	esac

	clear		
	
	if [ ${#PROXY_AND_MASTER_COEXIST} -ne 0 ]; then
	
		MYSQL_DDE1_PROXY_HOST="$MYSQL_DDE1_MASTER_HOST";
	
		MYSQL_DDE1_PROXY_USERNAME="$MYSQL_DDE1_MASTER_USERNAME";
		
		MYSQL_DDE1_PROXY_PASSWORD="$MYSQL_DDE1_MASTER_PASSWORD";
	
	else
	
		getUserData "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL database host IP address to fetch proxy data from [default: $HOST]: ";

		MYSQL_DDE1_PROXY_HOST=$RETVAL;

		clear			

		if [ ${#MYSQL_DDE1_PROXY_HOST} == 0 ]; then

			MYSQL_DDE1_PROXY_HOST="$HOST";

		fi

		clear

		if [ ${#MYSQL_DDE1_PROXY_HOST} == 0 ] && [ ${#HOST} != 0 ]; then

			MYSQL_DDE1_PROXY_HOST=$HOST;

		fi

		echo

		getUserData "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL username of the instance on '$MYSQL_DDE1_PROXY_HOST': ";

		MYSQL_DDE1_PROXY_USERNAME=$RETVAL;

		clear			

		getUserPassword "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL password for '$MYSQL_DDE1_PROXY_USERNAME' on '$MYSQL_DDE1_PROXY_HOST': ";

		MYSQL_DDE1_PROXY_PASSWORD=$RETVAL;

		clear

	fi

	getUserData "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL DDE1 proxy database name of the instance on '$MYSQL_DDE1_PROXY_HOST': ";

	DDE1_PROXY_DATABASE=$RETVAL;

	clear			

fi

# Select source of data for OpenMRS application data
declare -a OPENMRS_SOURCE=("1" "Dumped Data Copy" "2" "Existing MySQL Server Instance");

getUserOption "Environment Configuration" "OpenMRS Application Database" "Please select what the source of OpenMRS application data will be: " OPENMRS_SOURCE[@]

case $RETVAL in
	1)
		OPENMRS_SRC="dump";;
	2)
		OPENMRS_SRC="server";;
esac
	  
clear

# Default OpenMRS database name in case it's not defined
OPENMRS_DATABASE="dde1_openmrs_production";

# If dump selected, get MySQL server IP address, username and password
if [ ${#OPENMRS_SRC} -ne 0 ] && [ "$OPENMRS_SRC" == "dump" ]; then

	getUserData "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter OpenMRS application SQL dump path: ";

	OPENMRS_DUMP=$RETVAL;

	clear;
	
	getUserConfirmation "Environment Configuration" "MySQL OpenMRS Database Configuration" "Are the database connection settings for the OpenMRS application server the same as those for the DDE1 master server?";
		
	case $EXIT_CODE in
		0)
			PROXY_AND_MASTER_COEXIST="y";;
		1)
			PROXY_AND_MASTER_COEXIST="n";;
		255)
			exit 1;;
	esac

	clear		
	
	if [ ${#PROXY_AND_MASTER_COEXIST} -ne 0 ]; then
	
		MYSQL_OPENMRS_HOST="$MYSQL_DDE1_MASTER_HOST";
	
		MYSQL_OPENMRS_USERNAME="$MYSQL_DDE1_MASTER_USERNAME";
		
		MYSQL_OPENMRS_PASSWORD="$MYSQL_DDE1_MASTER_PASSWORD";
	
	else
	
		getUserData "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL database host IP address to load OpenMRS application data on [default: $HOST]: ";

		MYSQL_OPENMRS_HOST=$RETVAL;

		clear			

		if [ ${#MYSQL_OPENMRS_HOST} == 0 ]; then

			MYSQL_OPENMRS_HOST="$HOST";

		fi

		clear

		if [ ${#MYSQL_OPENMRS_HOST} == 0 ] && [ ${#HOST} != 0 ]; then

			MYSQL_OPENMRS_HOST=$HOST;

		fi

		echo

		getUserData "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL username of the instance on '$MYSQL_OPENMRS_HOST': ";

		MYSQL_OPENMRS_USERNAME=$RETVAL;

		clear			

		getUserPassword "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL password for '$MYSQL_OPENMRS_USERNAME' on '$MYSQL_OPENMRS_HOST': ";

		MYSQL_OPENMRS_PASSWORD=$RETVAL;

		clear

	fi

	if [ ${#OPENMRS_DUMP} -gt 0 ] && [ -f "$OPENMRS_DUMP" ]; then
		
    showMessageBox "Environment Configuration" "MySQL Setup" "Dropping '$OPENMRS_DATABASE' database if it exists on target machine to load supplied dump";

		clear;				
		
		mysql -h $MYSQL_OPENMRS_HOST -u $MYSQL_OPENMRS_USERNAME -p$MYSQL_OPENMRS_PASSWORD -e "DROP SCHEMA IF EXISTS $OPENMRS_DATABASE";
		
		if [ $? -ne 0 ]; then
		
			exit 1;
			
		fi
			
		mysql -h $MYSQL_OPENMRS_HOST -u $MYSQL_OPENMRS_USERNAME -p$MYSQL_OPENMRS_PASSWORD -e "CREATE SCHEMA $OPENMRS_DATABASE";
		
		if [ $? -ne 0 ]; then
		
			exit 1;
			
		fi
			
    showMessageBox "Environment Configuration" "MySQL Setup" "Loading provided dump into '$OPENMRS_DATABASE' database";

		clear;	
			
		(pv -n $OPENMRS_DUMP | mysql -h $MYSQL_OPENMRS_HOST -u $MYSQL_OPENMRS_USERNAME -p$MYSQL_OPENMRS_PASSWORD $OPENMRS_DATABASE) 2>&1 | dialog --gauge "Loading provided dump..." 6 50;
		
		if [ $? -ne 0 ]; then
		
			exit 1;
			
		fi
			
	fi

# Else if server selected, get MySQL server IP address, username, password and database name
elif [ ${#OPENMRS_SRC} -ne 0 ] && [ "$OPENMRS_SRC" == "server" ]; then

	getUserConfirmation "Environment Configuration" "MySQL OpenMRS Database Configuration" "Are the database connection settings for the OpenMRS application server the same as those for the DDE1 master server?";
		
	case $EXIT_CODE in
		0)
			PROXY_AND_MASTER_COEXIST="y";;
		1)
			PROXY_AND_MASTER_COEXIST="n";;
		255)
			exit 1;;
	esac

	clear		
	
	if [ ${#PROXY_AND_MASTER_COEXIST} -ne 0 ]; then
	
		MYSQL_OPENMRS_HOST="$MYSQL_DDE1_MASTER_HOST";
	
		MYSQL_OPENMRS_USERNAME="$MYSQL_DDE1_MASTER_USERNAME";
		
		MYSQL_OPENMRS_PASSWORD="$MYSQL_DDE1_MASTER_PASSWORD";
	
	else
	
		getUserData "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL database host IP address to fetch OpenMRS application data from [default: $HOST]: ";

		MYSQL_OPENMRS_HOST=$RETVAL;

		clear			

		if [ ${#MYSQL_OPENMRS_HOST} == 0 ]; then

			MYSQL_OPENMRS_HOST="$HOST";

		fi

		clear

		if [ ${#MYSQL_OPENMRS_HOST} == 0 ] && [ ${#HOST} != 0 ]; then

			MYSQL_OPENMRS_HOST=$HOST;

		fi

		echo

		getUserData "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL username of the instance on '$MYSQL_OPENMRS_HOST': ";

		MYSQL_OPENMRS_USERNAME=$RETVAL;

		clear			

		getUserPassword "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL password for '$MYSQL_OPENMRS_USERNAME' on '$MYSQL_OPENMRS_HOST': ";

		MYSQL_OPENMRS_PASSWORD=$RETVAL;

		clear

	fi

	getUserData "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL OpenMRS database name of the instance on '$MYSQL_OPENMRS_HOST': ";

	OPENMRS_DATABASE=$RETVAL;

	clear			

fi

cd "$ROOT/sources/dde2_migration_tool/code";

if [ $? -ne 0 ]; then

	exit 1;

fi

bundle install --local;

clear;

cp "$ROOT/sources/dde2_migration_tool/code/databases.yml.example" "$ROOT/sources/dde2_migration_tool/code/databases.yml";

if [ $? -ne 0 ]; then

	exit 1;

fi

ruby -ryaml -e 'config = YAML.load_file("'$ROOT'/sources/dde2_migration_tool/code/databases.yml"); \
								config["npids_mysql_source"]["username"] = "'$MYSQL_DDE1_MASTER_USERNAME'"; \
								config["npids_mysql_source"]["password"] = "'$MYSQL_DDE1_MASTER_PASSWORD'"; \
								config["npids_mysql_source"]["host"] = "'$MYSQL_DDE1_MASTER_HOST'"; \
								config["npids_mysql_source"]["database"] = "'$DDE1_MASTER_DATABASE'"; \
								config["mysql"]["username"] = "'$MYSQL_OPENMRS_USERNAME'"; \
								config["mysql"]["password"] = "'$MYSQL_OPENMRS_PASSWORD'"; \
								config["mysql"]["host"] = "'$MYSQL_OPENMRS_HOST'"; \
								config["mysql"]["database"] = "'$OPENMRS_DATABASE'"; \
								config["couchdb"]= { \
																		"username" => "'$COUCHDB_DATABASE_USERNAME'", \
																		"password" => "'$COUCHDB_DATABASE_PASSWORD'", \
																		"host" => "'$COUCHDB_HOST'", \
																		"port" => '$COUCHDB_PORT'}; \
								config["target"]["databases"] = "openmrs_application"; \
								config["applications"] = {}; \
								config["applications"]["openmrs_application"] = { \
																		"username" => "'$MYSQL_DDE1_PROXY_USERNAME'", \
																		"password" => "'$MYSQL_DDE1_PROXY_PASSWORD'", \
																		"host" => "'$MYSQL_DDE1_PROXY_HOST'", \
																		"database" => "'$DDE1_PROXY_DATABASE'"}; \
								file = File.open("'$ROOT'/sources/dde2_migration_tool/code/databases.yml", "w"); \
								file.write(config.to_yaml); \
								file.close;'

if [ $? -ne 0 ]; then

	exit 1;

fi

cd "$ROOT/sources/dde2_migration_tool/code";

if [ $? -ne 0 ]; then

	exit 1;

fi

chmod +x main.rb;

if [ $? -ne 0 ]; then

	exit 1;

fi

./main.rb -i;

if [ $? -ne 0 ]; then

	exit 1;

fi

cd "$ROOT/sources/dde2_migration_validator";

if [ $? -ne 0 ]; then

	exit 1;

fi

bundle install --local;

cp "$ROOT/sources/dde2_migration_validator/config/secrets.yml.example" "$ROOT/sources/dde2_migration_validator/config/secrets.yml";

if [ $? -ne 0 ]; then

	exit 1;

fi

rake secret;

if [ $? -ne 0 ]; then

	exit 1;

fi

cp "$ROOT/sources/dde2_migration_validator/config/couchdb.yml.example" "$ROOT/sources/dde2_migration_validator/config/couchdb.yml";

if [ $? -ne 0 ]; then

	exit 1;

fi

DDE1_PROXY_PREFIX="";
DDE1_PROXY_SUFFIX="";

ARR=$(echo "$DDE1_PROXY_DATABASE" | tr "_" "\n");

j=0;

for i in $ARR; do

	if [ $j -eq 0 ]; then
	
		DDE1_PROXY_PREFIX="$i";
	
	else
	
		if [ ${#DDE1_PROXY_SUFFIX} -gt 0 ]; then
		
			DDE1_PROXY_SUFFIX="$DDE1_PROXY_SUFFIX""_""$i";
		
		else
		
			DDE1_PROXY_SUFFIX="$i";
		
		fi
	
	fi

done

ruby -ryaml -e 'config = YAML.load_file("'$ROOT'/sources/dde2_migration_validator/config/couchdb.yml"); \
								config["production"]["username"] = "'$MYSQL_DDE1_PROXY_USERNAME'"; \
								config["production"]["password"] = "'$MYSQL_DDE1_PROXY_PASSWORD'"; \
								config["production"]["host"] = "'$MYSQL_DDE1_PROXY_HOST'"; \
								config["production"]["prefix"] = "'$DDE1_PROXY_PREFIX'"; \
								config["production"]["suffix"] = "'$DDE1_PROXY_SUFFIX'"; \
								config["development"]["username"] = "'$MYSQL_DDE1_PROXY_USERNAME'"; \
								config["development"]["password"] = "'$MYSQL_DDE1_PROXY_PASSWORD'"; \
								config["development"]["host"] = "'$MYSQL_DDE1_PROXY_HOST'"; \
								config["development"]["prefix"] = "'$DDE1_PROXY_PREFIX'"; \
								config["development"]["suffix"] = "'$DDE1_PROXY_SUFFIX'"; \
								file = File.open("'$ROOT'/sources/dde2_migration_validator/config/couchdb.yml", "w"); \
								file.write(config.to_yaml); \
								file.close;'

if [ $? -ne 0 ]; then

	exit 1;

fi

cp "$ROOT/sources/dde2_migration_validator/config/database.yml.example" "$ROOT/sources/dde2_migration_validator/config/database.yml";

if [ $? -ne 0 ]; then

	exit 1;

fi

ruby -ryaml -e 'config = YAML.load_file("'$ROOT'/sources/dde2_migration_validator/config/database.yml"); \
								config["production"]["username"] = "'$MYSQL_DDE1_PROXY_USERNAME'"; \
								config["production"]["password"] = "'$MYSQL_DDE1_PROXY_PASSWORD'"; \
								config["production"]["host"] = "'$MYSQL_DDE1_PROXY_HOST'"; \
								config["production"]["database"] = "'$DDE1_PROXY_DATABASE'"; \
								config["development"]["username"] = "'$MYSQL_DDE1_PROXY_USERNAME'"; \
								config["development"]["password"] = "'$MYSQL_DDE1_PROXY_PASSWORD'"; \
								config["development"]["host"] = "'$MYSQL_DDE1_PROXY_HOST'"; \
								config["development"]["database"] = "'$DDE1_PROXY_DATABASE'"; \
								file = File.open("'$ROOT'/sources/dde2_migration_validator/config/database.yml", "w"); \
								file.write(config.to_yaml); \
								file.close;'

if [ $? -ne 0 ]; then

	exit 1;

fi

cp "$ROOT/sources/dde2_migration_validator/config/site_config.yml.example" "$ROOT/sources/dde2_migration_validator/config/site_config.yml";

if [ $? -ne 0 ]; then

	exit 1;

fi

getUserData "Environment Configuration" "DDE Connection" "Enter site code: ";

SITE_CODE=$RETVAL;

clear			

ruby -ryaml -e 'config = YAML.load_file("'$ROOT'/sources/dde2_migration_validator/config/site_config.yml"); \
								config["production"]["site_code"] = "'$SITE_CODE'"; \
								config["development"]["password"] = "'$SITE_CODE'"; \
								file = File.open("'$ROOT'/sources/dde2_migration_validator/config/site_config.yml", "w"); \
								file.write(config.to_yaml); \
								file.close;'

if [ $? -ne 0 ]; then

	exit 1;

fi

# getUserData "Environment Configuration" "Master CouchDB Connection Setup" "Enter Master CouchDB database name: ";

MASTER_COUCHDB_DATABASE="dde_production";

MASTER_COUCHDB_PERSON_DATABASE="dde_person_production";

clear

getUserData "Environment Configuration" "Master CouchDB Connection Setup" "Enter Master CouchDB database usename: ";

MASTER_COUCHDB_DATABASE_USERNAME=$RETVAL;

clear

getUserPassword "Environment Configuration" "Master CouchDB Connection Setup" "Enter Master CouchDB database password for '$MASTER_COUCHDB_DATABASE_USERNAME': ";

MASTER_COUCHDB_DATABASE_PASSWORD=$RETVAL;

clear

getUserData "Environment Configuration" "Master CouchDB Connection Setup" "Enter Master CouchDB database host [default: $HOST]: ";

MASTER_COUCHDB_HOST=$RETVAL;

if [ ${#MASTER_COUCHDB_HOST} == 0 ]; then

	MASTER_COUCHDB_HOST="$HOST";

else

	HOST=$MASTER_COUCHDB_HOST;

fi

clear

getUserData "Environment Configuration" "Master CouchDB Connection Setup" "Enter Master CouchDB database port [default: 5984]: ";

MASTER_COUCHDB_PORT=$RETVAL;

if [ ${#MASTER_COUCHDB_PORT} == 0 ]; then

	MASTER_COUCHDB_PORT=5984;

fi

clear
  
curl -H "Content-Type: application/json" -X POST --data "{\"target\":\"$DDE1_PROXY_DATABASE\",\"source\":\"http://$MASTER_COUCHDB_HOST:$MASTER_COUCHDB_PORT/$MASTER_COUCHDB_DATABASE\", \"create_target\": true}" "http://$COUCHDB_DATABASE_USERNAME:$COUCHDB_DATABASE_PASSWORD@$COUCHDB_HOST:$COUCHDB_PORT/_replicate";

if [ $? -ne 0 ]; then

	exit 1;

fi

curl -H "Content-Type: application/json" -X POST --data "{\"target\":\""$DDE1_PROXY_PREFIX"_person_$DDE1_PROXY_SUFFIX\",\"source\":\"http://$MASTER_COUCHDB_HOST:$MASTER_COUCHDB_PORT/$MASTER_COUCHDB_PERSON_DATABASE\", \"create_target\": true}" "http://$COUCHDB_DATABASE_USERNAME:$COUCHDB_DATABASE_PASSWORD@$COUCHDB_HOST:$COUCHDB_PORT/_replicate";

if [ $? -ne 0 ]; then

	exit 1;

fi

cd "$ROOT/sources/dde2_migration_validator";

if [ $? -ne 0 ]; then

	exit 1;

fi

fuser -k $VALIDATOR_PORT/tcp;

rails s -p $VALIDATOR_PORT -d;

if [ $? -ne 0 ]; then

	exit 1;

fi

if [ ${#FIREFOX} -gt 0 ]; then

	$FIREFOX http://$IP_ADDRESS:$VALIDATOR_PORT/people/premigration;
	
	if [ $? -ne 0 ]; then

		exit 1;

	fi

else

	showMessageBox "DDE1 to DDE2 Migration" "Pre-Migration Report" "In your browser, navigate to 'http://$IP_ADDRESS:$VALIDATOR_PORT/people/premigration' for the pre-migration report";

	clear;	
	
fi

showMessageBox "DDE1 to DDE2 Migration" "Migration Starting" "The actual migration will now start. Please note that this may take a while but progress will be shown on the way!";

clear;	

cd "$ROOT/sources/dde2_migration_tool/code";

if [ $? -ne 0 ]; then

	exit 1;

fi

./main.rb -m;

if [ $? -ne 0 ]; then

	exit 1;

fi

if [ ${#FIREFOX} -gt 0 ]; then

	$FIREFOX http://$IP_ADDRESS:$VALIDATOR_PORT/people/postmigration;
	
	if [ $? -ne 0 ]; then

		exit 1;

	fi

else

	showMessageBox "DDE1 to DDE2 Migration" "Post-Migration Report" "In your browser, navigate to 'http://$IP_ADDRESS:$VALIDATOR_PORT/people/postmigration' for the post-migration report";

	clear;	
	
fi

showMessageBox "DDE1 to DDE2 Migration" "Migration Pre-Merge Analysis" "An analysis of the progress so far will be done to ascertain the quality of the final migration. No changes will be made on the destination database in this step.";

clear;	

cd "$ROOT/sources/dde2_migration_tool/code";

if [ $? -ne 0 ]; then

	exit 1;

fi

./main.rb -p;

showMessageBox "DDE1 to DDE2 Migration" "Migration Final Data Merge" "The migrated data will now be merged for production.";

clear;	

cd "$ROOT/sources/dde2_migration_tool/code";

if [ $? -ne 0 ]; then

	exit 1;

fi

./main.rb -o;





