#!/usr/bin/env bash

RELEASE=$(lsb_release -r | tr -d "Release:" | tr -d "[:space:]");

if [ "$RELEASE" != "14.04" ]; then

	echo "Only Ubuntu 14.04 currently supported. Aborting!";
	
	exit 1;

fi

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
	
VALIDATE_MIGRATION="n";
	
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

  if [ $4 -gt 0 ]; then

      RETVAL=$(dialog --clear --backtitle "$1" --defaultno --title "$2" --yesno "$3" 10 30 2>&1 1>&3)

  else

    RETVAL=$(dialog --clear --backtitle "$1" --title "$2" --yesno "$3" 10 30 2>&1 1>&3)

  fi
  
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

if [ ${#RUBY} == 0 ]; then

    showMessageBox "Environment Configuration" "Ruby Setup" "Ruby not found. Installing Ruby.";

    clear;

    cd "$ROOT/dist/ruby";

    ./setup.sh;

    if [ $? -ne 0 ]; then

        exit 1;

    fi

    cd "$ROOT";
	
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

    COUCHDB_USERNAME=$RETVAL;

    clear

    getUserPassword "Environment Configuration" "CouchDB Setup" "Enter CouchDB database password for '$COUCHDB_USERNAME': ";

    COUCHDB_PASSWORD=$RETVAL;

    clear

    curl -X PUT -H 'Content-Type: application/json' --data "\"$COUCHDB_PASSWORD\"" "http://localhost:5984/_config/admins/$COUCHDB_USERNAME"

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
	  
	  COUCHDB_USERNAME=$RETVAL;
	  
	  clear
  
	  getUserPassword "Environment Configuration" "CouchDB Setup" "Enter CouchDB database password for '$COUCHDB_USERNAME': ";
	  
	  COUCHDB_PASSWORD=$RETVAL;

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

getUserConfirmation "Environment Configuration" "Migration Validation Confirmation" "Would you want to validate the migration as well?" 1;
	
case $EXIT_CODE in
	0)
		VALIDATE_MIGRATION="y";;
	1)
		VALIDATE_MIGRATION="n";;
	255)
		VALIDATE_MIGRATION="n";;
esac

clear		

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
	
		# git pull https://github.com/BaobabHealthTrust/dde2_migration_tool.git;
	
		cd "$ROOT";
	
	fi

	if [ "$VALIDATE_MIGRATION" == "y" ]; then
	
		if [ ! -d "$ROOT/sources/dde2_migration_validator" ]; then
	
			cd "$ROOT/sources";
		
			if [ $? -ne 0 ]; then
		
				exit 1;
			
			else
		
				git clone https://github.com/BaobabHealthTrust/dde2_migration_validator.git;						
		
			fi
	
		else
	
			cd "$ROOT/sources/dde2_migration_validator";
	
			# git pull https://github.com/BaobabHealthTrust/dde2_migration_validator.git;
	
			cd "$ROOT";
	
		fi
	
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
NPIDS_MYSQL_SOURCE_DATABASE="dde1_migration_master";

# If dump selected to be used for loading, get MySQL server IP address, username and password
if [ ${#DDE1_MASTER_SRC} -ne 0 ] && [ "$DDE1_MASTER_SRC" == "dump" ]; then

	getUserData "Environment Configuration" "DDE1 Master Database Configuration" "Enter DDE1 master SQL dump path: ";
	
	DDE1_MASTER_DUMP=$RETVAL;

	clear;
	
	getUserData "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL database host IP address to load data on [default: $HOST]: ";

	NPIDS_MYSQL_SOURCE_HOST=$RETVAL;

	clear			

	if [ ${#NPIDS_MYSQL_SOURCE_HOST} == 0 ]; then

		NPIDS_MYSQL_SOURCE_HOST="$HOST";

	fi

	clear

	if [ ${#NPIDS_MYSQL_SOURCE_HOST} == 0 ] && [ ${#HOST} != 0 ]; then

		NPIDS_MYSQL_SOURCE_HOST=$HOST;

	fi

	echo

	getUserData "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL username of the instance on '$NPIDS_MYSQL_SOURCE_HOST': ";

	NPIDS_MYSQL_SOURCE_USERNAME=$RETVAL;

	clear			

	getUserPassword "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL password for '$NPIDS_MYSQL_SOURCE_USERNAME' on '$NPIDS_MYSQL_SOURCE_HOST': ";

	NPIDS_MYSQL_SOURCE_PASSWORD=$RETVAL;

	clear

	clear			

	if [ ${#DDE1_MASTER_DUMP} -gt 0 ] && [ -f "$DDE1_MASTER_DUMP" ]; then
		
		RESULT=`mysql -h $NPIDS_MYSQL_SOURCE_HOST -u $NPIDS_MYSQL_SOURCE_USERNAME -p$NPIDS_MYSQL_SOURCE_PASSWORD --skip-column-names -e "SHOW DATABASES LIKE '$NPIDS_MYSQL_SOURCE_DATABASE'"`
		
		if [ "$RESULT" == "$NPIDS_MYSQL_SOURCE_DATABASE" ]; then

			echo "Skipping database '$NPIDS_MYSQL_SOURCE_DATABASE' as it already exists!";
		
		else
		
			mysql -h $NPIDS_MYSQL_SOURCE_HOST -u $NPIDS_MYSQL_SOURCE_USERNAME -p$NPIDS_MYSQL_SOURCE_PASSWORD -e "CREATE SCHEMA $NPIDS_MYSQL_SOURCE_DATABASE";
				
			if [ $? -ne 0 ]; then
		
				exit 1;
			
			fi
			
		  showMessageBox "Environment Configuration" "DDE1 Master Setup" "Loading provided dump into '$NPIDS_MYSQL_SOURCE_DATABASE' database";

			clear;	
			
			(pv -n $DDE1_MASTER_DUMP | mysql -h $NPIDS_MYSQL_SOURCE_HOST -u $NPIDS_MYSQL_SOURCE_USERNAME -p$NPIDS_MYSQL_SOURCE_PASSWORD $NPIDS_MYSQL_SOURCE_DATABASE) 2>&1 | dialog --gauge "Loading provided dump..." 6 50;
		
			if [ $? -ne 0 ]; then
		
				exit 1;
			
			fi
			
		fi
			
	fi

# Else if an existing server selected to be used for loading, get MySQL server IP address, username, password and database name to work with
elif [ ${#DDE1_MASTER_SRC} -ne 0 ] && [ "$DDE1_MASTER_SRC" == "server" ]; then

	getUserData "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL database host IP address to fetch data from [default: $HOST]: ";

	NPIDS_MYSQL_SOURCE_HOST=$RETVAL;

	clear			

	if [ ${#NPIDS_MYSQL_SOURCE_HOST} == 0 ]; then

		NPIDS_MYSQL_SOURCE_HOST="$HOST";

	fi

	clear

	if [ ${#NPIDS_MYSQL_SOURCE_HOST} == 0 ] && [ ${#HOST} != 0 ]; then

		NPIDS_MYSQL_SOURCE_HOST=$HOST;

	fi

	echo

	getUserData "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL username of the instance on '$NPIDS_MYSQL_SOURCE_HOST': ";

	NPIDS_MYSQL_SOURCE_USERNAME=$RETVAL;

	clear			

	getUserPassword "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL password for '$NPIDS_MYSQL_SOURCE_USERNAME' on '$NPIDS_MYSQL_SOURCE_HOST': ";

	NPIDS_MYSQL_SOURCE_PASSWORD=$RETVAL;

	clear

	getUserData "Environment Configuration" "DDE1 Master Database Configuration" "Enter MySQL DDE1 master database name of the instance on '$NPIDS_MYSQL_SOURCE_HOST': ";

	NPIDS_MYSQL_SOURCE_DATABASE=$RETVAL;

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

# Default DDE1 master database name
TARGET_SITE_DATABASE="dde1_migration_proxy";

# Default proxy database name in case it's not defined
COUCHDB_NPIDS_DATABASE="dde1_migration_proxy";

# If dump selected, get MySQL server IP address, username and password
if [ ${#DDE1_PROXY_SRC} -ne 0 ] && [ "$DDE1_PROXY_SRC" == "dump" ]; then

	getUserData "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter DDE1 proxy SQL dump path: ";

	DDE1_PROXY_DUMP=$RETVAL;

	clear;
	
	getUserConfirmation "Environment Configuration" "DDE1 Proxy Database Configuration" "Are the database connection settings for the DDE1 proxy server the same as those for the DDE1 master server?" 0;
		
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
	
		TARGET_SITE_APP_HOST="$NPIDS_MYSQL_SOURCE_HOST";
	
		TARGET_SITE_APP_USERNAME="$NPIDS_MYSQL_SOURCE_USERNAME";
		
		TARGET_SITE_APP_PASSWORD="$NPIDS_MYSQL_SOURCE_PASSWORD";
	
	else
	
		getUserData "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL database host IP address to load proxy data on [default: $HOST]: ";

		TARGET_SITE_APP_HOST=$RETVAL;

		clear			

		if [ ${#TARGET_SITE_APP_HOST} == 0 ]; then

			TARGET_SITE_APP_HOST="$HOST";

		fi

		clear

		if [ ${#TARGET_SITE_APP_HOST} == 0 ] && [ ${#HOST} != 0 ]; then

			TARGET_SITE_APP_HOST=$HOST;

		fi

		echo

		getUserData "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL username of the instance on '$TARGET_SITE_APP_HOST': ";

		TARGET_SITE_APP_USERNAME=$RETVAL;

		clear			

		getUserPassword "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL password for '$TARGET_SITE_APP_USERNAME' on '$TARGET_SITE_APP_HOST': ";

		TARGET_SITE_APP_PASSWORD=$RETVAL;

		clear

	fi

	if [ ${#DDE1_PROXY_DUMP} -gt 0 ] && [ -f "$DDE1_PROXY_DUMP" ]; then
	
		RESULT=`mysql -h $TARGET_SITE_APP_HOST -u $TARGET_SITE_APP_USERNAME -p$TARGET_SITE_APP_PASSWORD --skip-column-names -e "SHOW DATABASES LIKE '$TARGET_SITE_DATABASE'"`
		
		if [ "$RESULT" == "$TARGET_SITE_DATABASE" ]; then

			echo "Skipping database '$TARGET_SITE_DATABASE' as it already exists!";
		
		else
		
			mysql -h $TARGET_SITE_APP_HOST -u $TARGET_SITE_APP_USERNAME -p$TARGET_SITE_APP_PASSWORD -e "CREATE SCHEMA $TARGET_SITE_DATABASE";
	
			if [ $? -ne 0 ]; then
		
				exit 1;
			
			fi
			
			showMessageBox "Environment Configuration" "DDE1 Proxy Setup" "Loading provided dump into '$TARGET_SITE_DATABASE' database";

			clear;	
		
			(pv -n $DDE1_PROXY_DUMP | mysql -h $TARGET_SITE_APP_HOST -u $TARGET_SITE_APP_USERNAME -p$TARGET_SITE_APP_PASSWORD $TARGET_SITE_DATABASE) 2>&1 | dialog --gauge "Loading provided dump..." 6 50;
	
			if [ $? -ne 0 ]; then
		
				exit 1;
			
			fi
			
		fi
			
	fi

# Else if server selected, get MySQL server IP address, username, password and database name
elif [ ${#DDE1_PROXY_SRC} -ne 0 ] && [ "$DDE1_PROXY_SRC" == "server" ]; then

	getUserConfirmation "Environment Configuration" "DDE1 Proxy Database Configuration" "Are the database connection settings for the DDE1 proxy server the same as those for the DDE1 master server?" 0;
		
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
	
		TARGET_SITE_APP_HOST="$NPIDS_MYSQL_SOURCE_HOST";
	
		TARGET_SITE_APP_USERNAME="$NPIDS_MYSQL_SOURCE_USERNAME";
		
		TARGET_SITE_APP_PASSWORD="$NPIDS_MYSQL_SOURCE_PASSWORD";
	
	else
	
		getUserData "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL database host IP address to fetch proxy data from [default: $HOST]: ";

		TARGET_SITE_APP_HOST=$RETVAL;

		clear			

		if [ ${#TARGET_SITE_APP_HOST} == 0 ]; then

			TARGET_SITE_APP_HOST="$HOST";

		fi

		clear

		if [ ${#TARGET_SITE_APP_HOST} == 0 ] && [ ${#HOST} != 0 ]; then

			TARGET_SITE_APP_HOST=$HOST;

		fi

		echo

		getUserData "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL username of the instance on '$TARGET_SITE_APP_HOST': ";

		TARGET_SITE_APP_USERNAME=$RETVAL;

		clear			

		getUserPassword "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL password for '$TARGET_SITE_APP_USERNAME' on '$TARGET_SITE_APP_HOST': ";

		TARGET_SITE_APP_PASSWORD=$RETVAL;

		clear

	fi

	getUserData "Environment Configuration" "DDE1 Proxy Database Configuration" "Enter MySQL DDE1 proxy database name of the instance on '$TARGET_SITE_APP_HOST': ";

	TARGET_SITE_DATABASE=$RETVAL;

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
TARGET_SITE_APP_DATABASE="dde1_openmrs_production";

# If dump selected, get MySQL server IP address, username and password
if [ ${#OPENMRS_SRC} -ne 0 ] && [ "$OPENMRS_SRC" == "dump" ]; then

	getUserData "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter OpenMRS application SQL dump path: ";

	OPENMRS_DUMP=$RETVAL;

	clear;
	
	getUserConfirmation "Environment Configuration" "MySQL OpenMRS Database Configuration" "Are the database connection settings for the OpenMRS application server the same as those for the DDE1 master server?" 0;
		
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
	
		MYSQL_HOST="$NPIDS_MYSQL_SOURCE_HOST";
	
		MYSQL_USERNAME="$NPIDS_MYSQL_SOURCE_USERNAME";
		
		MYSQL_PASSWORD="$NPIDS_MYSQL_SOURCE_PASSWORD";
	
	else
	
		getUserData "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL database host IP address to load OpenMRS application data on [default: $HOST]: ";

		MYSQL_HOST=$RETVAL;

		clear			

		if [ ${#MYSQL_HOST} == 0 ]; then

			MYSQL_HOST="$HOST";

		fi

		clear

		if [ ${#MYSQL_HOST} == 0 ] && [ ${#HOST} != 0 ]; then

			MYSQL_HOST=$HOST;

		fi

		echo

		getUserData "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL username of the instance on '$MYSQL_HOST': ";

		MYSQL_USERNAME=$RETVAL;

		clear			

		getUserPassword "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL password for '$MYSQL_USERNAME' on '$MYSQL_HOST': ";

		MYSQL_PASSWORD=$RETVAL;

		clear

	fi

	if [ ${#OPENMRS_DUMP} -gt 0 ] && [ -f "$OPENMRS_DUMP" ]; then
		
		RESULT=`mysql -h $MYSQL_HOST -u $MYSQL_USERNAME -p$MYSQL_PASSWORD --skip-column-names -e "SHOW DATABASES LIKE '$TARGET_SITE_APP_DATABASE'"`
		
		if [ "$RESULT" == "$TARGET_SITE_APP_DATABASE" ]; then

			echo "Skipping database '$TARGET_SITE_APP_DATABASE' as it already exists!";
		
		else
		
			mysql -h $MYSQL_HOST -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE SCHEMA $TARGET_SITE_APP_DATABASE";
		
			if [ $? -ne 0 ]; then
		
				exit 1;
			
			fi
			
		  showMessageBox "Environment Configuration" "MySQL Setup" "Loading provided dump into '$TARGET_SITE_APP_DATABASE' database";

			clear;	
			
			(pv -n $OPENMRS_DUMP | mysql -h $MYSQL_HOST -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $TARGET_SITE_APP_DATABASE) 2>&1 | dialog --gauge "Loading provided dump..." 6 50;
		
			if [ $? -ne 0 ]; then
		
				exit 1;
			
			fi
			
		fi
			
	fi

# Else if server selected, get MySQL server IP address, username, password and database name
elif [ ${#OPENMRS_SRC} -ne 0 ] && [ "$OPENMRS_SRC" == "server" ]; then

	getUserConfirmation "Environment Configuration" "MySQL OpenMRS Database Configuration" "Are the database connection settings for the OpenMRS application server the same as those for the DDE1 master server?" 0;
		
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
	
		MYSQL_HOST="$NPIDS_MYSQL_SOURCE_HOST";
	
		MYSQL_USERNAME="$NPIDS_MYSQL_SOURCE_USERNAME";
		
		MYSQL_PASSWORD="$NPIDS_MYSQL_SOURCE_PASSWORD";
	
	else
	
		getUserData "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL database host IP address to fetch OpenMRS application data from [default: $HOST]: ";

		MYSQL_HOST=$RETVAL;

		clear			

		if [ ${#MYSQL_HOST} == 0 ]; then

			MYSQL_HOST="$HOST";

		fi

		clear

		if [ ${#MYSQL_HOST} == 0 ] && [ ${#HOST} != 0 ]; then

			MYSQL_HOST=$HOST;

		fi

		echo

		getUserData "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL username of the instance on '$MYSQL_HOST': ";

		MYSQL_USERNAME=$RETVAL;

		clear			

		getUserPassword "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL password for '$MYSQL_USERNAME' on '$MYSQL_HOST': ";

		MYSQL_PASSWORD=$RETVAL;

		clear

	fi

	getUserData "Environment Configuration" "MySQL OpenMRS Database Configuration" "Enter MySQL OpenMRS database name of the instance on '$MYSQL_HOST': ";

	TARGET_SITE_APP_DATABASE=$RETVAL;

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

COUCHDB_NPIDS_PREFIX="";
COUCHDB_NPIDS_SUFFIX="";

ARR=$(echo "$COUCHDB_NPIDS_DATABASE" | tr "_" "\n");

j=0;

for i in $ARR; do

	if [ $j -eq 0 ]; then
	
		COUCHDB_NPIDS_PREFIX="$i";
	
	else
	
		if [ ${#COUCHDB_NPIDS_SUFFIX} -gt 0 ]; then
		
			COUCHDB_NPIDS_SUFFIX="$COUCHDB_NPIDS_SUFFIX""_""$i";
		
		else
		
			COUCHDB_NPIDS_SUFFIX="$i";
		
		fi
	
	fi

	r=$j;
	
	j=$((r + 1));

done

ruby -ryaml -e 'config = YAML.load_file("'$ROOT'/sources/dde2_migration_tool/code/databases.yml"); \
								config["npids_mysql_source"]["username"] = "'$NPIDS_MYSQL_SOURCE_USERNAME'"; \
								config["npids_mysql_source"]["password"] = "'$NPIDS_MYSQL_SOURCE_PASSWORD'"; \
								config["npids_mysql_source"]["host"] = "'$NPIDS_MYSQL_SOURCE_HOST'"; \
								config["npids_mysql_source"]["database"] = "'$NPIDS_MYSQL_SOURCE_DATABASE'"; \
								config["mysql"]["username"] = "'$MYSQL_USERNAME'"; \
								config["mysql"]["password"] = "'$MYSQL_PASSWORD'"; \
								config["mysql"]["host"] = "'$MYSQL_HOST'"; \
								config["couchdb"]= { \
                                            "npids_database" => "'$COUCHDB_NPIDS_DATABASE'", \
                                            "person_database" => "'$COUCHDB_NPIDS_PREFIX'_person_'$COUCHDB_NPIDS_SUFFIX'", \
                                            "username" => "'$COUCHDB_USERNAME'", \
                                            "password" => "'$COUCHDB_PASSWORD'", \
                                            "host" => "'$COUCHDB_HOST'", \
                                            "port" => '$COUCHDB_PORT'}; \
								config["target"]["databases"] = "'$TARGET_SITE_DATABASE'"; \
								config["applications"] = {}; \
								config["applications"]["'$TARGET_SITE_DATABASE'"] = { \
                                            "username" => "'$TARGET_SITE_APP_USERNAME'", \
                                            "password" => "'$TARGET_SITE_APP_PASSWORD'", \
                                            "host" => "'$TARGET_SITE_APP_HOST'", \
                                            "database" => "'$TARGET_SITE_APP_DATABASE'"}; \
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

read -p "Press enter to continue...";

if [ "$VALIDATE_MIGRATION" == "y" ]; then	

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

	ruby -ryaml -e 'config = YAML.load_file("'$ROOT'/sources/dde2_migration_validator/config/couchdb.yml"); \
									config["production"]["username"] = "'$TARGET_SITE_APP_USERNAME'"; \
									config["production"]["password"] = "'$TARGET_SITE_APP_PASSWORD'"; \
									config["production"]["host"] = "'$TARGET_SITE_APP_HOST'"; \
									config["production"]["prefix"] = "'$COUCHDB_NPIDS_PREFIX'"; \
									config["production"]["suffix"] = "'$COUCHDB_NPIDS_SUFFIX'"; \
									config["development"]["username"] = "'$TARGET_SITE_APP_USERNAME'"; \
									config["development"]["password"] = "'$TARGET_SITE_APP_PASSWORD'"; \
									config["development"]["host"] = "'$TARGET_SITE_APP_HOST'"; \
									config["development"]["prefix"] = "'$COUCHDB_NPIDS_PREFIX'"; \
									config["development"]["suffix"] = "'$COUCHDB_NPIDS_SUFFIX'"; \
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
									config["production"]["username"] = "'$TARGET_SITE_APP_USERNAME'"; \
									config["production"]["password"] = "'$TARGET_SITE_APP_PASSWORD'"; \
									config["production"]["host"] = "'$TARGET_SITE_APP_HOST'"; \
									config["production"]["database"] = "'$TARGET_SITE_DATABASE'"; \
									config["development"]["username"] = "'$TARGET_SITE_APP_USERNAME'"; \
									config["development"]["password"] = "'$TARGET_SITE_APP_PASSWORD'"; \
									config["development"]["host"] = "'$TARGET_SITE_APP_HOST'"; \
									config["development"]["database"] = "'$TARGET_SITE_DATABASE'"; \
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

fi

getUserConfirmation "Environment Configuration" "DDE2 Master Synchronization" "Would you like to synchronize with DDE2 Master Live Server before proceeding?" 0;
	
case $EXIT_CODE in
	0)
		SYNC_WITH_MASTER="y";;
	1)
		SYNC_WITH_MASTER="n";;
	255)
		SYNC_WITH_MASTER="n";;
esac

clear		
	
if [ "$SYNC_WITH_MASTER" == "y" ]; then	

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

	RESULT=$(mysql -h $TARGET_SITE_APP_HOST -u $TARGET_SITE_APP_USERNAME -p$TARGET_SITE_APP_PASSWORD $TARGET_SITE_DATABASE -e "SELECT COUNT(*) AS num FROM national_patient_identifiers");

	TMP=$(echo $RESULT | tr -d "num\ ");

	COUNT=$(echo "${TMP}" | tr -d '[:space:]');

	GROUPSIZE=200;

	TOTAL_GROUPS=$(echo $( expr $COUNT / $GROUPSIZE ));

	REMAINDER=$(($COUNT % $GROUPSIZE));

	if [ $REMAINDER -gt 0 ]; then

		TOTAL=$(expr $TOTAL_GROUPS + 1);

	else

		TOTAL=$TOTAL_GROUPS;

	fi

	ROUNDS=$(seq 0 1 $TOTAL_GROUPS);

	if [ -d ./data ]; then

		rm -rf ./data;

	fi

	mkdir -p "$ROOT/data";

	for ROUND in $ROUNDS; do

		echo "Round $( expr $ROUND + 1 ) of $( expr $TOTAL_GROUPS + 1 )";

		START=$((GROUPSIZE * ROUND));

		RESULT=$(mysql -h $TARGET_SITE_APP_HOST -u $TARGET_SITE_APP_USERNAME -p$TARGET_SITE_APP_PASSWORD $TARGET_SITE_DATABASE -e "SELECT value FROM national_patient_identifiers LIMIT $START, $GROUPSIZE");

		CHOPPED=$(echo $RESULT | tr "value\ " "\ ");

		ARR=$(echo $CHOPPED | tr "\ " "\n");

		JSON=$(printf %s\\n "${ARR[@]}"|sed 's/["\]/\\&/g;s/.*/"&"/;1s/^/[/;$s/$/]/;$!s/$/,/');

		URLENCODED=$(ruby -rcgi -e 'puts CGI.escape(ARGV[0])' "$JSON");
	
		curl -s "http://$MASTER_COUCHDB_HOST:$MASTER_COUCHDB_PORT/$MASTER_COUCHDB_DATABASE/_design/Npid/_view/by_national_id?reduce=false&include_docs=true&keys=$URLENCODED" -o "$ROOT/data/$ROUND.json"; 

		NPIDS=$(ruby -rjson -e "r = []; j = JSON.parse(File.open('$ROOT/data/$ROUND.json', 'r').read); j['rows'].map.each{|e| r << e['doc']['_id']}; puts r.to_json")

		curl -s -H "Content-Type: application/json" -X POST --data "{\"target\":\"$COUCHDB_NPIDS_DATABASE\",\"source\":\"http://$MASTER_COUCHDB_HOST:$MASTER_COUCHDB_PORT/$MASTER_COUCHDB_DATABASE\", \"create_target\": true, \"doc_ids\":$NPIDS}" "http://$COUCHDB_USERNAME:$COUCHDB_PASSWORD@$COUCHDB_HOST:$COUCHDB_PORT/_replicate" -o "$ROOT/data/n.$ROUND.json" &

		curl -s -H "Content-Type: application/json" -X POST --data "{\"target\":\""$COUCHDB_NPIDS_PREFIX"_person_$COUCHDB_NPIDS_SUFFIX\",\"source\":\"http://$MASTER_COUCHDB_HOST:$MASTER_COUCHDB_PORT/$MASTER_COUCHDB_PERSON_DATABASE\", \"create_target\": true, \"doc_ids\":$JSON}" "http://$COUCHDB_USERNAME:$COUCHDB_PASSWORD@$COUCHDB_HOST:$COUCHDB_PORT/_replicate" -o "$ROOT/data/p.$ROUND.json" &

	done

	while ps axg | grep -vw grep | grep -w curl > /dev/null; do

		sleep 1;
	
	done

	if [ -d ./data ]; then

		echo "Done. Can delete folder now";
		
		# rm -rf ./data;

	fi

	if [ $? -ne 0 ]; then

		exit 1;

	fi

fi

if [ "$VALIDATE_MIGRATION" == "y" ]; then	

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

fi

cd "$ROOT/sources/dde2_migration_tool/code";

if [ $? -ne 0 ]; then

	exit 1;

fi

./main.rb -m;

if [ $? -ne 0 ]; then

	exit 1;

fi

read -p "Press enter to continue...";

if [ "$VALIDATE_MIGRATION" == "y" ]; then	

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

fi

cd "$ROOT/sources/dde2_migration_tool/code";

if [ $? -ne 0 ]; then

	exit 1;

fi

./main.rb -p;

read -p "Press enter to continue...";

showMessageBox "DDE1 to DDE2 Migration" "Migration Final Data Merge" "The migrated data will now be merged for production.";

clear;	

cd "$ROOT/sources/dde2_migration_tool/code";

if [ $? -ne 0 ]; then

	exit 1;

fi

./main.rb -o;

read -p "Press enter to continue...";





