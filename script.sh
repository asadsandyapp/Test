#! /bin/bash


#######################################################################################################
#  Copyright, All Rights Reserved, BlockAPT Limited @2020
#  BlockAPT Central Management Platform 
#  Automated Installation Script	
#  First Created v5 September 2019, by Marco Essomba (ME)	
#  Current version: installer_v123
########################################################################################################


########################################################################################################
# Instalation Dependencies:
#    -PHP 8.1.18 (cli) (built: Apr 14 2023 04:39:24) (NTS)
#    -Mongo: db version v6.0.2
#    -Linux:21~18.04.1-Ubuntu SMP Mon Jul 13 03:31:28 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
#    -Distribution ID: Ubuntu
#             Description: Ubuntu 20.04.5 LTS,
#             Release:  20.04, 
#             Codename: focal
########################################################################################################


########################################################################################################
#  Script Usage: 
#  	   1. Copy the install script to your home dir (example: /home/devops)
#      2. Goto the directory where the script is saved: example - cd /home/devops
#      3. Open two CLI screens; a) one to run the script b) the other to see the logs and installation progress (debug)
#      4. Speed options examples: 0 0 at the end = fastest debug | 5 0 = exec break 5 seconds, fastest debug | 5 5 = exec break 5 seconds slow with 5 seconds breaks

#      4. First CLI Window:
#        4a. Make the script executable & run it: chmod 755 ba_platform_ubuntu_20_installer_v128.sh
#        4b. Remove any special characters in the script:  sed -i -e 's/\r$//g' /blockapt/scripts/*.sh; chmod 755 /blockapt/scripts/*.sh;  ./ba_platform_ubuntu_20_installer_v128.sh master 0 0 focal
#        4c. Run the script with variables and send logs to file: 
# sed -i -e 's/\r$//g' /blockapt/scripts/*.sh; chmod 755 /blockapt/scripts/*.sh; ./ba_platform_ubuntu_20_installer_v128.sh master 0 0 focal  > /tmp/BA_install_debug.log 2>&1
# sed -i -e 's/\r$//g' *.sh; chmod 755 *.sh; ./ba_platform_ubuntu_20_installer_v128.sh master 0 0 focal

#     5. Second CLI Window:
#         5a. View the progress installation logs: tail -f /tmp/BA_install_debug.log
#         5b. Monitor the second CLI window (view logs) and the first CLI window (script input prompts). 
#         5c. When the script starts to run for code pull it will ask for the Git pull password. Splunk install will ask for password. Do check the prompts in 4c.
#    
# COMMANDS RECAP: 
# Data Input (4 parameters values): | <CODE_BRANCH (must|default develop|[$1]): | <GLOBAL_DEBUG (options|default 0|[$2]):> | <debug SLEEPER timer (optional|default 0|[$3]) | <UBUNTU_MONGO_CODENAME (options|default hirsute|[$4])"

# sed -i -e 's/\r$//g' /blockapt/scripts/*.sh; chmod 755 /blockapt/scripts/*.sh; /blockapt/scripts/ba_platform_ubuntu_20_installer_v128.sh master 0 0 focal

# tail -f /tmp/BA_install_debug.log

########################################################################################################



########################################################################################################
#  Updates Tracker:
#          ME: 21/06/20 Updated MONGO_VERSION check
#          ME: 21/06/20 Updated MONGO_VERSION & OS Version check for mongoDB repository pull - must match since [xenial] != [Bionic]
#          ME: 21/06/20 Updated Start services to avoid conflicts for apache, mysdql, etc
#          ME: 21/06/20 Updated sub routine orders & added routine for killing services
#          ME: 22/06/20 Updated functions exec orders - exit
#          ME: 23/06/20 Updated functions exec orders - bitnami
#          ME: 26/06/20 Updated seeding order
#          ME: 09/07/20 Updated rc.local to pipe to std error
#          ME: 25/08/20 Updated to add turn off PubKey authentication
#          ME: 27/08/20 Updated to add Zip & simplex package installation to fix Zip & simplex error on pull
#          ME: 28/08/20 Updated iptables to make it persistent and to lock down access after install
#          ME: 28/08/20 Updated NPM package installer for logger folder
#          ME: 31/08/20 Updated functionInstallPm2 package installer for logger folder and moved behind Compose Function
#          ME: 01/09/20 Updated updated to add sudo to zip tool install
#          ME: 07/09/20 Updated updated to fix pm2 install script issue 
#          ME: 09/09/20 Updated git pull origin $CODE_BRANCH
#          ME: 09/09/20 Updated google2fa for php full path
#          ME: 18/12/20 Disabled #npm install -g mongoose inside mongodb
#          ME/DEV-PK: 19/12/20 Updated functionComposerSetup logical git checkout flows
#          ME: 20/12/20 Added npm express packaged which is used by pm2
#          ME: 20/12/20 Updated and added manual timer for each function. Useful for global debug
#          ME: 20/12/20 Updated functionInstallPm2 to consistent packages including express package
#          ME: 22/12/20 added nginx killer in functionKillServices
#          ME/DEV-PK: 28/12/20 Updated seed function for migration
#          ME/DEV-PK: 28/12/20 Updated npm install for run dev
#          ME: 28/12/20 Updated npm install for mongoose and express to install globally and in selected folder
#          ME/DEV-PK: 28/12/20 Updated .env file to remove the // causing app key crash
#          ME: 04/01/21 Updated to add startup variables to control debug and git branch. Added Mongoose into its own function
#          ME: 21/01/21 Updated React folder cleanup and re-install
#          DEV-PK: 22/01/21 Update .env for CACHE_DRIVER, QUEUE_CONNECTION, SESSION_DRIVER to database
#          DEV-PK: 22/01/21 Added new SME Chat Module node package npm install
#          ME: 23/01/21 Added new SME Chat function  functionInstallChat into its own sub-routine
#          ME: 23/01/21 Remove all oldsleeper_db to a single SLEEPER
#          ME: 25/01/21 added node-gyp install required by npm
#          ME: 14/03/21 updates /var/lib/mongodb permissions 
#          ME: 30/03/21 updated git clone for marco 
#          ME: 27/05/21 updated mongo cleanup processes before install
#          ME: 29/05/21 updated line 1758 to upgrade nodesource curl -sL https://deb.nodesource.com/setup_14.x | bash - 
#          ME: 29/05/21 added npm update
#          ME: 11/06/21 added npm update and force fix for patches
#          ME: 13/06/21 added indexes creation for Splunk
#          ME: 21/06/21 remove all sudo to make it compatible with docker
#          ME: 05/08/21 Update to incude all packages in single function and clear package-lock.json causing errors
#          ME: 12/09/21 Update functionInstallPm2NpmNode as a single function
#          ME: 30/09/21 Update mongo remove and added PK dev items
#          ME: 04/10/21 Removed check Points
#          ME: 05/10/21 Fixed Mongo wipe out in functionInstallChat function...
#          ME: 05/10/21 Added force verify services in functionCheckApacheIsUp
#          ME: 10/10/21 Updated ntopng script
#          ME: 11/10/21 Updated ntopng script with auto remove clean up and clean start
#          ME: 10/01/22 Added OS selection check and options for user to select as needed
#          ME: 23/03/22 Added pip3 version installation for v3 - v4 is not working for MTE-API
#          ME: 01/05/22 tcp13521 splunk port adding index 
#          ME: 06/01/22 Updated codename as variable
#          ME: 06/01/22 Remove the mongo kill
#          ME: 02/08/22 Addedd functionLoadPhpModules execution and memory value to -1 for archive issue
#          DEV-PK: 10/11/22 updated mongo version added API_URL for ticket creation as well as remove npm run dev from icyber_loggers
#          DEV-PK: 09/12/22 added nagix installation for MTE
#          ME: 13/03/23 - De-activated functionInstallPm2NpmNode, functionInstallNodeJS, functionInstallMongoDB, functionInstallBitnami
#          ME: 23/03/23 - Remote the debug for aptiture & backup of packages slowing down the install
#          ME: 23/03/23 - Re-ordered install sequence functions, variables, web server, then MTE, etc.
#          ME: 23/03/23 - updated export COMPOSER_ALLOW_SUPERUSER="1" for that /usr/bin/php /usr/local/bin/composer can root as default
#          ME: 23/03/23 - updated NGINX missing certicates certs path and added created a default cert so avoid NGINX SSL errors
#          ME: 23/03/23 - updated mysql to fetch latest sudo apt install mysql-server -y;
#          ME: 23/03/23 - updated mysql to add test commands & self check
#          ME: 24/03/23 - ensure that composer runs after the files pull from git
#          ME: 25/03/23 - re-ordered the functions to match dependencies, for example env variables are needed for composer
#          ME: 25/03/23 - added dedicated function for PHP for stricker control of the version, current support is 7.3
#          ME: 26/03/23 - added Apache SSL and redirect from HTTP to HTTPS
#          ME: 26/03/23 - added variable php & mysql to ensure that all tools follow the same version for php & mysql
#          ME: 26/03/23 - added apache and nginx in the service check for status Web Console
#          DEV-PK: 10/05/23 - Upgraded PHP - MYSQL versions as well as added new REPO of Laravel V9 fixed folder structure
#          DEV-PK: 21/07/23 - Install new extension of PHP LDAP
#          DEV-PK: 24/08/23 - GUI Login issue fixed.
#          DEV-PK: 28/08/23 - SCOUT_DRIVER=database new package Scout for full text search for global search added.
#          DEV-PK: 07/09/23 - node js version is updated to 16.17.1.
#          DEV-PK: 22/09/23 - python dependencies updated.
#          DEV-PK: 22/09/23 - nginx time execution updated.
#          DEV-PK: 26/09/23 - PYTHON_PIP_WERKZEUG package version updated. 
#          DEV-PK: 05/10/23 - PHP Extension added for GCP php-bcmath
########################################################################################################


########################################################################################################
#  Last Deployed Successfully:
#  a) 10/05/2023 - Deployed on Ubuntu Server focal - v123.sh
#        a1) ScriptRun - Success, clean code pull, no errors 
#        a2) GUI Login - Success
#        a3) Monitor   - Failed with errors on starting Server Controls 
#        a4) Manage    - Success
#        a5) Automate  - Success 
#        a6) Response  - Success
#        a7) SME Pack  - Success
########################################################################################################


#####################################################
# Color Control Check
#####################################################
echo "-------------------------------------------------"
echo -e "\e[1;37m[\e[m\e[1;37mALLOWED\e[m\e[1;37m]\e[m [Color Calibration Check White]"
echo "-------------------------------------------------"
echo
echo "-------------------------------------------------"
echo -e "\e[1;37m[\e[m\e[1;31mBLOCKED\e[m\e[1;37m]\e[m [Color Calibration Check Red]"
echo "-------------------------------------------------"
echo 
echo "-------------------------------------------------"
echo -e "\e[1;37m[\e[m\e[1;32mALLOW\e[m\e[1;37m]\e[m [Color Calibration Check Green]"
echo "-------------------------------------------------"


#####################################################
# Input Variables via the argument given at CLI runtime
#####################################################
CODE_BRANCH=$1
GLOBAL_DEBUG=$2
SLEEPER=$3
UBUNTU_MONGO_CODENAME=$4


#####################################################
#script variable initialisation
#####################################################
functionScriptInit (){
 ID=2
 echo
 echo
 
 #installaton directory and files such as python replacer.py - see below. 
 #copy the script in a folder [/root/tmp_install], it will be called by the bash script
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionScriptInit			   "
 echo -e "\e[1;31m ############################################### \e[m"
 echo
 echo

 DIR_HTDOCS="/opt/bitnami/apache2/htdocs"
 DIR_ICYBER="/var/www/html/blockaptv9"
 
 NODE_VERSION="16.17.1"
 NODEJS_VERSION="16.17.1"
 NPM_VERSION="8.19.4"
 PM2_VERSION="5.1.1"
 NVM_VERSION="0.38.0"
 N_VERSION="7.5.0"

 MONGOD_VERSION="6.0.2"
 MONGOD_VERSION_REPO="6.0.2"
 MONGOD_VERSION_DB="6.0.2"
 MONGO_VERSION="6" 
 MYSYQL_VERSION="8.0*"
 PHP_VERSION="8.1"
 

 PYTHON_PIP3="3.12.0"
 PYTHON_PIP_WERKZEUG="2.0.2"
 
 UBUNTU_MONGO_CLI_KEYWORD="codename"

  UBUNTU_MONGO_CODENAME_CLI=`lsb_release -dc | grep -i $UBUNTU_MONGO_CLI_KEYWORD | awk -F ':' '{print $2}'`
 UBUNTU_MONGO_LSB=`lsb_release -dc | grep -i $UBUNTU_MONGO_CODENAME | wc -l`
 UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR=`lsb_release -dc | grep -i bionic |  wc -l`
 UBUNTU_MONGO_LSB_CODENAME_FOCAL_NBR=`lsb_release -dc  | grep -i focal  |  wc -l`

 INSTALL_HOME_DIR="/tmp/blockapt_install_logs"

 SERVICE_apache="apache"
 SERVICE_apached="apached"
 SERVICE_splunk="splunk"
 SERVICE_splunkd="splunkd"
 SERVICE_mysql="mysql"
 SERVICE_mysqld="mysqld"
 SERVICE_mongo="mongo"
 SERVICE_mongod="mongod"
 SERVICE_redisserver="redis"
 SERVICE_http="http"
 SERVICE_httpd="httpd"
 SERVICE_httpd_bin="httpd.bin"

 
              IS_UBUNTU=`cat /etc/lsb-release | grep -i ubuntu | wc -l`
         UBUNTU_RELEASE=`cat /etc/lsb-release | grep RELEASE   | awk -F '=' '{print $2}' | awk -F '.' '{print $1}'`
    UBUNTU_FULL_VERSION=`cat /etc/lsb-release | grep RELEASE   | awk -F '=' '{print $2}' | awk -F '=' '{print $1}'`
        UBUNTU_CODENAME=`cat /etc/lsb-release | grep CODENAME  | awk -F '=' '{print $2}'`
              UBUNTU_ID=`cat /etc/lsb-release | grep ID        | awk -F '=' '{print $2}'`

#GIT_URL="https://marcoessomba@bitbucket.org/icyber-iq/blockaptv9.git"
GIT_URL="https://icyber-iq@bitbucket.org/icyber-iq/blockaptv9.git"

 
 BITNAMI_FILE_RUN="bitnami-wordpress-5.9.3-1-linux-x64-installer.run" 
 DEBP_SPLUNK="splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb"
 BITNAMI_PREFIX="/opt/bitnami/"
 BITNAMI_INSTAL_LANG="en"
 BITNAMI_BASE_USERNAME="ba-admin"
 BITNAMI_BASE_MAIL="ba-admin@ba-admin.local"
 BITNAMI_BASE_USER="baadmin2020"
 BITNAMI_BASE_PWD="baadmin2020"
 BITNAMI_DEBUG_LEVEL="4"
 BITNAMI_DEBUG_TRACE="${INSTALL_HOME_DIR}/ba-bitnami-install-custom.log" 
 BITNAMI_ENABLE_PLUGINS="varnish,phpmyadmin" 
 BITNAMI_MYSQL_PWD="NTM0yaddasht"
 BITNAMI_WP_BLOGNAME="ba-admin-blog" 
 BITNAMI_MYPHP_ADM="NTM0yaddasht" 
 BITNAMI_LAUNCH_CLOUD="0" 
 BITNAMI_APACHE_SERVR_HTTP="80"
 BITNAMI_APACHE_SERVR_HTTPS="443"
 
      PYTHON_NAME_FILE="${INSTALL_HOME_DIR}/replacer.py"
 PREVIOUS_INSTALL_FILE="${INSTALL_HOME_DIR}/PREVIOUS_INSTALL_FILE" 
      DB_PASSWORD_FILE="${INSTALL_HOME_DIR}/DB_PASSWORD.txt"
 FUNCTION_ID_TRAC_FILE="${INSTALL_HOME_DIR}/function_exec_id_tracker"


  ###GIT_URL="https://icyber-iq@bitbucket.org/icyber-iq/blockaptv9.git"
 #WGET_URL_BITNAMI="https://bitnami.com/redirect/to/2105627/bitnami-wordpress-5.9.3-1-linux-x64-installer.run"
                  #https://bitnami.com/redirect/to/2105627/bitnami-wordpress-5.9.3-1-linux-x64-installer.run


 echo "ID_${ID}" > $PYTHON_NAME_FILE
 echo "ID_${ID}" > $PREVIOUS_INSTALL_FILE
 echo "ID_${ID}" > $DB_PASSWORD_FILE
 echo "ID_${ID}" > $FUNCTION_ID_TRAC_FILE
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo


   if [ ! "$CODE_BRANCH" == "" ]; then
        echo 
        echo
        echo "-------------------------------------------------"
        echo -e "\e[1;37m[\e[m\e[1;32mOK\e[m\e[1;37m]\e[m Mandatory fields provided..."
        echo "-------------------------------------------------"
        echo 
        echo
        echo "-------------------------------------------------"
        echo "Will use these provided values: [CODE_BRANCH]=[[1=$CODE_BRANCH]:[$CODE_BRANCH]; GLOBAL_DEBUG=[[2=$GLOBAL_DEBUG]:[$GLOBAL_DEBUG]; SLEEPER=[[3=$SLEEPER]:[$SLEEPER];....in [functionInit]"
        echo "-------------------------------------------------"
       sleep $SLEEPER
   else
        echo 
        echo
        echo "-------------------------------------------------"
        echo -e "\e[1;37m[\e[m\e[1;31mERROR\e[m\e[1;37m]\e[m Mandatory parameters not provided [CODE_BRANCH]=[[1=$CODE_BRANCH]:[$CODE_BRANCH]; GLOBAL_DEBUG=[[2=$GLOBAL_DEBUG]:[$GLOBAL_DEBUG]; SLEEPER=[[3=$SLEEPER]:[$SLEEPER];....in [functionInit]."
        echo "-------------------------------------------------"
        echo
        echo -e "-------------------------------------------------\e[1;37m[\e[m\e[1;32mFORMAT\e[m\e[1;37m]\e[m-------------------------------------------------"
        echo "Data Input (3 parameters values): | <CODE_BRANCH (must|default develop|[$CODE_BRANCH]): | <GLOBAL_DEBUG (options|default 0|[$GLOBAL_DEBUG]):> | <debug SLEEPER timer (optional|default 0|[$SLEEPER])>"
        echo "For example: sed -i -e 's/\r$//g' *.sh; chmod 755 *.sh; ./ba_platform_ubuntu_18_installer_v83sh master 0 0"
        echo "-------------------------------------------------"
        echo
        echo
        echo "Press Enter to continue with default values or CTRL+C to exit and re-run the script with the right parameters...[functionScriptInit]"
       #### read -r JUST_PAUSE
        CODE_BRANCH="develop"
        GLOBAL_DEBUG=0
        SLEEPER=0
        echo "-------------------------------------------------"
        echo "CTRC+C to Exit or will use these default values: [DSTIP]=[$DSTIP]; LOOPS=[$LOOPS]; SLEEPER=[$SLEEPER]; KILL PREVIOUS=[$isKillOthers]...in [functionInit]"
        echo "-------------------------------------------------"
       sleep $SLEEPER
   fi
      
 echo "CODE_BRANCH=[$CODE_BRANCH]"
 echo "GLOBAL_DEBUG=[$GLOBAL_DEBUG]"
 echo "SLEEPER=[$SLEEPER]"
 


 if [ -z "$UBUNTU_MONGO_CODENAME" ]; then
    ####UBUNTU_MONGO_CODENAME="bionic"
    echo
    echo
    echo "--------------------------------------------------"
    echo "UBUNTU_MONGO_CODENAME=[$UBUNTU_MONGO_CODENAME] NOT SET, variable from CLI=[$4]: Enter the OS Code Name: CLI: [lsb_release -dc  |grep Codename]"
    read -r UBUNTU_MONGO_CODENAME
    echo "UBUNTU_MONGO_CODENAME=[$UBUNTU_MONGO_CODENAME] now SET, OS CodeName Int is: [`lsb_release -dc | grep -i $UBUNTU_MONGO_CODENAME | wc -l`]"
    echo "--------------------------------------------------"
    echo
    echo "Press a key to continue..."
    read -r JUST_PAUSE
    sleep $SLEEPER
 else
    echo
    echo
    echo "--------------------------------------------------"
    echo "UBUNTU_MONGO_CODENAME is set via CLI=[$UBUNTU_MONGO_CODENAME], variable from CLI=[$4]"
    echo "UBUNTU_MONGO_CODENAME=[$UBUNTU_MONGO_CODENAME] now SET, OS CodeName Int is: [`cat /etc/lsb-release | grep -i $UBUNTU_MONGO_CODENAME | wc -l`]"
    echo "--------------------------------------------------"
    sleep $SLEEPER
    echo
    echo
    echo
    echo "Press a key to continue..."
    read -r JUST_PAUSE
    sleep $SLEEPER
 fi



 echo "-------------------Folder creation [STARTS]----------------"
 mkdir -v -p ${INSTALL_HOME_DIR} 
 echo "-------------------Folder creation [ENDS]------------------"
 echo
 echo


sleep $SLEEPER
 echo "-------------------VARIABLE Initilisation LIST 1----------------"
 echo "IS_UBUNTU=$IS_UBUNTU"
 echo "UBUNTU_RELEASE=$UBUNTU_RELEASE"
 echo "UBUNTU_FULL_VERSION=$UBUNTU_FULL_VERSION"
 echo "UBUNTU_CODENAME=$UBUNTU_CODENAME"    
 echo "UBUNTU_ID=$UBUNTU_ID"
 echo "UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR=$UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR"
 echo "UBUNTU_MONGO_LSB_CODENAME_FOCAL_NBR=$UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR"
 echo "MYSYQL_VERSION=$MYSYQL_VERSION"
 echo "PHP_VERSION=${PHP_VERSION}"
 echo "-------------------VARIABLE Initilisation LIST 1----------------"
 echo
 echo
 
sleep $SLEEPER
 echo "-------------------VARIABLE Initilisation LIST 2----------------"
 echo "Checking FILE PYTHON_NAME_FILE with cat: [`cat $PYTHON_NAME_FILE`]"
 echo "Checking FILE PREVIOUS_INSTALL_FILE with cat: [`cat $PREVIOUS_INSTALL_FILE`]"
 echo "Checking FILE DB_PASSWORD_FILE with cat: [`cat $DB_PASSWORD_FILE`]"
 echo "Checking FILE FUNCTION_ID_TRAC_FILE with cat: [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------VARIABLE Initilisation LIST ID----------------"
 echo
 echo
 
sleep $SLEEPER
 echo "------------------VARIABLE Initilisation LIST ID----------------"
 echo "SLEEPER=$SLEEPER"
 echo "MONGOD_VERSION=$MONGOD_VERSION"
 echo "MONGOD_VERSION_REPO=$MONGOD_VERSION_REPO"
 echo "MONGOD_VERSION_DB=$MONGOD_VERSION_DB"
 echo "MONGO_VERSION=$MONGO_VERSION"
 echo "UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR=$UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR"
 echo "UBUNTU_MONGO_LSB_CODENAME_FOCAL_NBR=$UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR"
 echo "-------------------VARIABLE Initilisation LIST ID----------------"
 echo
 echo
 
sleep $SLEEPER
 echo "CODE_BRANCH=$CODE_BRANCH"
 echo "{INSTALL_HOME_DIR}=${INSTALL_HOME_DIR}"
 echo "PYTHON_NAME_FILE=$PYTHON_NAME_FILE"
 echo "PREVIOUS_INSTALL_FILE=$PREVIOUS_INSTALL_FILE"
 echo "DB_PASSWORD_FILE=$DB_PASSWORD_FILE"
 echo "PREVIOUS_INSTALL_FILE{ID}=$PREVIOUS_INSTALL_FILE_${ID}"
 echo "{INSTALL_HOME_DIR}/function_exec_id_tracker=[$FUNCTION_ID_TRAC_FILE]'"
 echo "-------------------VARIABLE Initilisation LIST ID----------------"
 echo
 echo
 
sleep $SLEEPER
 echo "BITNAMI_FILE_RUN=$BITNAMI_FILE_RUN"
 echo "BITNAMI_PREFIX=$BITNAMI_PREFIX"
 echo "BITNAMI_INSTAL_LANG=$BITNAMI_INSTAL_LANG"
 echo "BITNAMI_BASE_USERNAME=$BITNAMI_BASE_USERNAME"
 echo "BITNAMI_BASE_MAIL=$BITNAMI_BASE_MAIL"
 echo "BITNAMI_BASE_USER=$BITNAMI_BASE_USER"
 echo "BITNAMI_BASE_PWD=$BITNAMI_BASE_PWD"
 echo "BITNAMI_DEBUG_LEVEL=$BITNAMI_DEBUG_LEVEL"
 echo "BITNAMI_DEBUG_TRACE=$BITNAMI_DEBUG_TRACE"
 echo "BITNAMI_ENABLE_PLUGINS=$BITNAMI_ENABLE_PLUGINS"
 echo "BITNAMI_MYSQL_PWD=$BITNAMI_MYSQL_PWD"
 echo "BITNAMI_WP_BLOGNAME=$BITNAMI_WP_BLOGNAME"
 echo "BITNAMI_MYPHP_ADM=$BITNAMI_MYPHP_ADM"
 echo "BITNAMI_LAUNCH_CLOUD=$BITNAMI_LAUNCH_CLOUD"
 echo "BITNAMI_APACHE_SERVR_HTTP=$BITNAMI_APACHE_SERVR_HTTP"
 echo "BITNAMI_APACHE_SERVR_HTTPS=$BITNAMI_APACHE_SERVR_HTTPS"
 echo "-------------------VARIABLE Initilisation LIST----------------"
 echo
 echo

sleep $SLEEPER	
 echo "--------------Initilisation completed...files below created--------------"
 echo "" > $DB_PASSWORD_FILE
 echo "" > $PREVIOUS_INSTALL_FILE
 echo "--------------------------------------------------"
 echo
 echo

sleep $SLEEPER	
 echo "--------------------------------------------------"
 echo "PYTHON_NAME_FILE=$PYTHON_NAME_FILE"
 echo "DB_PASSWORD_FILE=$DB_PASSWORD_FILE"
 echo "PREVIOUS_INSTALL_FILE=$PREVIOUS_INSTALL_FILE"
 echo "Please wait..."
 echo "--------------------------------------------------"
 echo
 echo

sleep $SLEEPER
 echo "--------------------------------------------------"
 #echo "WGET_URL_BITNAMI=$WGET_URL_BITNAMI"
 #echo "GIT_URL=$GIT_URL"
 echo "Please wait..."
 echo "--------------------------------------------------"
 echo
 echo

sleep $SLEEPER
 echo "--------------------------------------------------"
 ls -l ${INSTALL_HOME_DIR}
 ls -l $DB_PASSWORD_FILE
 echo "Please wait..."
 echo "--------------------------------------------------"
 echo
 echo

sleep $SLEEPER
 
 mkdir -p ${INSTALL_HOME_DIR}
 if [ $? -eq 0 ]; then
    echo "--------------------------------------------------"
    echo "Creation of install temp folder ${INSTALL_HOME_DIR} was successful. OK to continue..."
    echo "--------------------------------------------------"
   sleep $SLEEPER
 else
    echo "--------------------------------------------------"
    echo -e "Creation of install temp folder ${INSTALL_HOME_DIR} [\e[1;37m[\e[m\e[1;31m[FAILED]\e[m\e[1;37m]\e[m. Ensure that you run the script as root. Aborting..."
    echo "--------------------------------------------------"
    sleep $SLEEPER
    functionCleanUpOnExit
 fi

 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo
 echo
 echo
}




#####################################################
# Installation packages and tools - ALL Single Place
#####################################################

functionInstallAllToolSingleFile () {

echo "---------[apt-get install aptitude -y]-----0----------------"
apt-get install aptitude -y
echo "---------[apt-get install aptitude -y]-----0----------------"
echo
echo
echo "---------[mkdir -p /cache/apt/archives/]-----1----------------"
apt-get -y update
mkdir -p /cache/apt/archives/
#cp -r /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get update -y
echo "----------[mkdir -p /cache/apt/archives/]----1----------------"
echo
echo
echo "---------[apt-get install software-properties-common -y]-----2----------------"
#aptitude --download-only install software-properties-common -y
apt-get install software-properties-common -y
#cp -r /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get update -y
echo "--------[apt-get install software-properties-common -y]------2----------------"
echo
echo
echo "---------[apt-get install python3 -y]-----3----------------"
#aptitude --download-only install python3 -y & apt-get install python-is-python3 -y
apt-get install python3 -y
apt-get install python-is-python3 -y
#cp -r /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get update -y
echo "----------[apt-get install python3 -y]----3----------------"
echo
echo
echo "----------[sudo apt-get install python-virtualenv python-pip -y]----3a----------------"
#aptitude --download-only install python-virtualenv python-pip -y
sudo apt-get install python-virtualenv python-pip -y
#cp -r /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get update -y
echo "----------[sudo apt-get install python-virtualenv python-pip -y]----3a----------------"
echo
echo
echo "--------------4----------------"
#aptitude --download-only install python3-pip -y
apt-get install python3-pip -y
#cp -r /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get update -y
echo "--------------4----------------"
echo
echo
echo "--------------4a----------------"
pip3 install 'pymongo[srv]'==$PYTHON_PIP3
apt-get update -y
echo "--------------4a----------------"
echo
echo
echo "--------------1a----------------"
#aptitude --download-only install ntp -y
apt-get install -y ntp
#cp -r /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get update -y
echo "--------------1a----------------"
echo
echo
echo "--------------1b----------------"
#aptitude --download-only install ntpdate -y
apt-get install -y ntpdate
#cp -r /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get update -y
echo "--------------1b----------------"
echo
echo
echo "--------------1c----------------"
#aptitude --download-only install ntpsec -y
apt-get install -y ntpsec
#cp -r /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get update -y
echo "--------------1c----------------"
echo
echo
echo "--------------2----------------"
systemctl restart ntp
systemctl status ntp
echo "--------------2----------------"
echo
echo
#aptitude clean
##aptitude --download-only install <your_package_here>
#cp /var/cache/apt/archives/*.deb <your_directory_here>
#apt-get remove keyutils -y
#apt-get remove libevent-2 -y
#apt-get remove libnfsidmap2 -y
#apt-get remove libtirpc3 -y
#apt-get remove rpcbind -y
#apt-get remove nfs-common -y
#cp /var/cache/apt/archives/ /blockapt/scripts/deb

echo "-------------5-----------------"
##apt-get -y update
#apt-get install aptitude -y
#apt-get install apt-rdepends -y
#apt-get -y update
#ls -l /cache/apt/archives/*
echo "-------------5-----------------"
echo
echo
echo "-------------6-----------------"
apt-get -y update
apt-get install curl -y
echo "-------------6-----------------"
curl -V
echo "-------------7-----------------"
echo
echo
echo "-------------8-----------------"
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install keyutils -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install keyutils -y
echo "-------------------------------------"
echo
echo
echo "-------------------------------------"
#aptitude --download-only install aptitude -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
#apt-get install aptitude -y
echo "------------5------------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install libevent-2 -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install libevent-2 -y
echo "-------------------------------------"
echo
echo
echo "------------5------------------"
#aptitude --download-only install libnfsidmap2 -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install libnfsidmap2 -y
echo "-------------------------------------"
echo
echo
sleep $SLEEPER
echo "------------5------------------"
#aptitude --download-only install libtirpc3 -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install libtirpc3 -y
echo "-------------------------------------"
echo
echo
sleep $SLEEPER
echo "------------5------------------"
#aptitude --download-only install rpcbind -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install rpcbind -y
echo "-------------------------------------"
echo
echo
sleep $SLEEPER
echo "------------5------------------"
#aptitude --download-only install nfs-common -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install  nfs-common -y
echo "-------------------------------------"
echo
echo
sleep $SLEEPER
echo "------------5------------------"
#aptitude --download-only install gdebi -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install gdebi -y
echo "-------------------------------------"
echo
echo
echo
sleep $SLEEPER
echo "------------5------------------"


echo "-------------------4-----------"
#aptitude --download-only install net-tools -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install net-tools -y
#ls -l /cache/apt/archives/*
echo "----------------4--------------"
echo
echo
sleep $SLEEPER
echo "------------5------------------"
#aptitude --download-only install cron -y
#ls -l /cache/apt/archives/*
apt-get install cron -y
#ls -l /cache/apt/archives/*
echo "------------5------------------"
echo
echo
sleep $SLEEPER
echo "------------5------------------"
#aptitude --download-only install aptitude -y
#ls -l /cache/apt/archives/*
#apt-get install aptitude -y
#ls -l /cache/apt/archives/*
echo "------------5------------------"
echo
echo
sleep $SLEEPER
#aptitude --download-only install apt-rdepends -y
#ls -l /cache/apt/archives/*
#apt-get install apt-rdepends -y
#ls -l /cache/apt/archives/*
echo "-------------5-----------------"
echo
echo
sleep $SLEEPER
echo "-----------7-------------------"
#aptitude --download-only install -y gdebi
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install gdebi -y
#ls -l /cache/apt/archives/*
echo "------------8------------------"
echo
echo
sleep $SLEEPER
echo "-------------9-----------------"
#aptitude --download-only install -y curl
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#apt-get install curl -y
#ls -l /cache/apt/archives/*
echo
echo
echo "-------------5-----------------"
apt-get -y update
echo "-------------5-----------------"
echo
echo
echo "-------------5-----------------"
curl -V
echo "-------------5-----------------"
echo
echo
echo "-------------------------------------"
sleep $SLEEPER
#aptitude --download-only install -y libcurl4-gnutls-dev
#ls -l /cache/apt/archives/*
apt-get install libcurl4-gnutls-dev -y 
#ls -l /cache/apt/archives/*
echo "-------------------------------------"
echo
echo
sleep $SLEEPER
#aptitude --download-only install -y  libcurl4-nss-dev
#ls -l /cache/apt/archives/*
apt-get install libcurl4-nss-dev -y 
#ls -l /cache/apt/archives/*
echo "-------------------------------------"
echoecho
echo
sleep $SLEEPER
#aptitude --download-only install -y libcurl4-openssl-dev
#ls -l /cache/apt/archives/*
apt-get install libcurl4-openssl-dev -y 
#ls -l /cache/apt/archives/*
echo "-------------------------------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y libcurl-openssl1.0-dev
#ls -l /cache/apt/archives/*
apt-get install libcurl-openssl1.0-dev -y 
#ls -l /cache/apt/archives/*
echo "-------------10-----------------"
echo "-------------------------------------"
echo
echo
sleep $SLEEPER
echo "-------------14-----------------"
#aptitude --download-only install -y curl
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y curl
#ls -l /cache/apt/archives/*
echo "------------15------------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y libcurl3
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install libcurl3 -y
#ls -l /cache/apt/archives/*
echo "-------------29-----------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y libcurl4
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install libcurl4 -y
#ls -l /cache/apt/archives/*
echo "------------30------------------"
echo
echo
sleep $SLEEPER
echo "-------------32-----------------"
apt-get -y update 
echo "-------------33-----------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install tree -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install tree -y
#ls -l /cache/apt/archives/*
echo "-------------34-----------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install libncurses5 -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install libncurses5 -y
#ls -l /cache/apt/archives/*
echo "-------------35-----------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install libcurl4 -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install libcurl4 -y
#ls -l /cache/apt/archives/*
echo "-----------36-------------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
#ls -l /cache/apt/archives/*
echo "-------------37-----------------"
apt-get -y update
echo "--------------38----------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y inetutils-traceroute
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install inetutils-traceroute -y
#ls -l /cache/apt/archives/*
echo "--------------39----------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y net-tools
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install net-tools -y
#ls -l /cache/apt/archives/*
echo "------------40------------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y openssh-server
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y openssh-server
#ls -l /cache/apt/archives/*
/etc/init.d/ssh restart
echo "-------------41-------------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ba.bak
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "--------------42----------------"
/etc/init.d/ssh restart
echo "--------------43----------------"
echo
echo
cat /etc/ssh/sshd_config | grep PermitRootLogin
echo "---------------44---------------"
cat /etc/ssh/sshd_config | grep PubkeyAuthentication
echo "----------------45--------------"
cat /etc/ssh/sshd_config | grep PasswordAuthentication
/etc/init.d/ssh restart
echo "----------------46--------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
echo
echo
 echo "--------------48----------------"
#aptitude --download-only install -y openssl
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y openssl
echo "--------------48----------------"
echo
echo
sleep $SLEEPER
echo "---------------49-----------------------"
#aptitude --download-only install -y inetutils-ping 
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y inetutils-ping 
#ls -l /cache/apt/archives/*
echo "--------------49----------------"
echo
echo
sleep $SLEEPER
echo "---------------50-----------------------"
#aptitude --download-only install -y vim
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y vim
echo "--------------50----------------"
echo
echo
sleep $SLEEPER
echo "--------------51-----------------------"
#aptitude --download-only install -y iptables
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y iptables
#ls -l /cache/apt/archives/*
echo "------------51------------------"

sleep $SLEEPER
echo "-------------52-----------------"
echo
echo
echo "----------------53---------------------"
#aptitude --download-only install iptables-persistent -y
#ls -l /cache/apt/archives/*
apt-get install iptables-persistent -y
#ls -l /cache/apt/archives/*
echo iptables-persistent iptables-persistent/autosave_v4 boolean true |debconf-set-selections
echo "-------------53-----------------"
sleep $SLEEPER
echo
echo
echo "---------------55-----------------------"
#aptitude --download-only install iptables-persistent -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install iptables-persistent -y
#ls -l /cache/apt/archives/*
echo "--------------55----------------"
echo
echo
sleep $SLEEPER
echo "-----------------56---------------------"
#aptitude --download-only nano -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get -y install nano
#ls -l /cache/apt/archives/*
echo "-------------56-----------------"
echo
echo
sleep $SLEEPER
echo "--------------57------------------------"
#aptitude --download-only install -y socat
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y socat
#ls -l /cache/apt/archives/*
echo "-------------57-----------------"
echo
echo
sleep $SLEEPER
echo "---------------58------------------------"
#aptitude --download-only install -y telnet
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y telnet
#ls -l /cache/apt/archives/*
echo "-------------58-----------------"
echo
echo
sleep $SLEEPER
echo "----------------59------------------------"
#aptitude --download-only install -y dpkg
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y dpkg
#ls -l /cache/apt/archives/*
echo "-------------59-----------------"
echo
echo
sleep $SLEEPER
echo "---------------60------------------------"
#aptitude --download-only install -y htop
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y htop
#ls -l /cache/apt/archives/*
echo "-------------60-----------------"
echo
echo
sleep $SLEEPER
echo "--------------61------------------------"
#aptitude --download-only install -y wget
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y wget
#ls -l /cache/apt/archives/*
echo "-----------61-------------------"
echo
echo
sleep $SLEEPER
echo "--------------62------------------------"
#aptitude --download-only install -y python
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y python
#ls -l /cache/apt/archives/*
echo "-----------62-------------------"
echo
echo
sleep $SLEEPER
echo "---------------63----------------------"
#aptitude --download-only install net-tools -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install net-tools -y
#ls -l /cache/apt/archives/*
echo "-------------63-----------------"
echo
echo
sleep $SLEEPER
echo "----------------64-----------------------"
#aptitude --download-only install -y git
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get -y install git-y
#ls -l /cache/apt/archives/*
echo "------------64------------------"
echo
echo
sleep $SLEEPER
echo "--------------65-----------------------"
#aptitude --download-only install -y software-properties-common
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get -y install software-properties-common
#ls -l /cache/apt/archives/*
echo "-----------65-------------------"
apt-get -y update
echo "----------66--------------------"
echo
echo
sleep $SLEEPER
echo "--------------69------------------------"
#aptitude --download-only install -y sysstat
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y sysstat
#ls -l /cache/apt/archives/*
echo "----------69--------------------"
echo
echo
sleep $SLEEPER
echo "----------------70----------------------"
#aptitude --download-only install -y iotop
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y iotop
#ls -l /cache/apt/archives/*
echo "-------------70-----------------"
echo
echo
sleep $SLEEPER
echo "----------------71----------------------"
#aptitude --download-only install -y iptraf
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y iptraf
#ls -l /cache/apt/archives/*
echo "---------------71---------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y acct
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y acct
#ls -l /cache/apt/archives/*
echo "-------------72-----------------"
echo
echo
sleep $SLEEPER
echo "--------------73-----------------------"
#aptitude --download-onlyinstall -y nethogs
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y nethogs
#ls -l /cache/apt/archives/*
echo "------------73------------------"
echo
echo
sleep $SLEEPER
echo "----------------74----------------------"
#aptitude --download-only install -y iftop
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y iftop
#ls -l /cache/apt/archives/*
echo "-------------74-----------------"
echo
echo
sleep $SLEEPER
echo "----------------75-----------------------"
#aptitude --download-only install -y arpwatch
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y arpwatch
#ls -l /cache/apt/archives/*
echo "--------------75----------------"
echo
echo
sleep $SLEEPER
echo "----------------76-----------------------"
#aptitude --download-only install -y tcpdump
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y tcpdump
#ls -l /cache/apt/archives/*
echo "-------------76-----------------"
echo
echo
sleep $SLEEPER
echo "----------------77-----------------------"
#aptitude --download-only install -y suricata
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y suricata
#ls -l /cache/apt/archives/*
echo "------------77------------------"
echo
echo
sleep $SLEEPER
echo "----------------78-----------------------"
#aptitude --download-only install -y suricata-hyperscan
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y suricata-hyperscan
echo "------------78------------------"
echo
echo
sleep $SLEEPER
echo "---------------79-----------------------"
#aptitude --download-onlyinstall -y nmon
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y nmon
#ls -l /cache/apt/archives/*
echo "------------79------------------"
echo
echo
sleep $SLEEPER
echo "----------------80-----------------------"
#aptitude --download-only install -y syslog-ng
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y syslog-ng
#ls -l /cache/apt/archives/*
echo "------------80------------------"
echo
echo
sleep $SLEEPER
echo "---------------81-----------------------"
#aptitude --download-only install -y clamav
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y clamav
#ls -l /cache/apt/archives/*
echo "-----------81-------------------"
echo
echo
echo
sleep $SLEEPER
echo "-----------------82-----------------------"
#aptitude --download-only install -y clamav-daemon
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y clamav-daemon
#ls -l /cache/apt/archives/*
echo "--------------82----------------"
echo
echo
sleep $SLEEPER
echo "-------------83------------------------"
#aptitude --download-only install -y libclamunrar6
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y libclamunrar6
#ls -l /cache/apt/archives/*
echo "-------------83-----------------"
apt-get -y update
echo "--------------84----------------"
echo
echo
sleep $SLEEPER
echo "---------------85------------------------"
#aptitude --download-only install -y cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev
#ls -l /cache/apt/archives/*
echo "--------------85----------------"
echo
echo
sleep $SLEEPER
echo "--------------86------------------------"
#aptitude --download-only -y install node-gyp
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get -y install node-gyp
#ls -l /cache/apt/archives/*
echo "-----------86-------------------"
echo
echo
sleep $SLEEPER
echo "--------------87-------------------------"
#aptitude --download-only -y install git
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get -y install git
#ls -l /cache/apt/archives/*
echo "--------------87----------------"
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only -y install libmaxminddb-dev
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get -y install libmaxminddb-dev
#ls -l /cache/apt/archives/*
echo "-------------88-----------------"
echo
echo
sleep $SLEEPER
echo "-----------------89-----------------------"
#aptitude --download-only -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python3 python3-dev swig zlib1g-dev
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python3 python3-dev python-is-python3  swig zlib1g-dev -y
#ls -l /cache/apt/archives/*
echo "-------------89-----------------"
echo
echo
sleep $SLEEPER
echo "-----------------90----------------------"
#aptitude --download-only -y install python3-git python3-semantic-version
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get -y install python3-git python3-semantic-version
#ls -l /cache/apt/archives/*
echo "------------90------------------"
apt-get -y update	
echo "----------91--------------------"
echo
echo
sleep $SLEEPER
echo "---------------92-----------------------"
#aptitude --download-only install git -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get -y install git
#ls -l /cache/apt/archives/*
apt-get -y update	
echo "------------92------------------"
sleep $SLEEPER
echo
echo
sleep $SLEEPER
echo "----------------95-----------------------"
#aptitude --download-only install -y curl
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*c
apt-get install -y curl
#ls -l /cache/apt/archives/*	 
echo "------------95------------------"
echo
echo
echo "-------------96-----------------"
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get update -y
echo "-------------96-----------------"
echo
echo
sleep $SLEEPER
echo "---------------97------------------------"
#aptitude --download-only install -y gcc g++ make
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y gcc g++ make
#ls -l /cache/apt/archives/*
echo "------------97------------------"
echo
echo
sleep $SLEEPER
echo "--------------98-------------------------"
#aptitude --download-only install -y yarn
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "-----------98-------------------"
echo
echo
echo "------------99------------------"
apt-get update -y && apt-get install -y yarn
#ls -l /cache/apt/archives/*
echo "------------99------------------"
echo
echo
sleep $SLEEPER
echo "-----------100-------------------"
#aptitude --download-only install curl -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install curl -y
#ls -l /cache/apt/archives/*
echo "-----------100-------------------"
echo
echo
sleep $SLEEPER
echo "-------------101-----------------"
#aptitude --download-only install libcurl3 -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
apt-get install libcurl3 -y
#ls -l /cache/apt/archives/*
echo "-------------102-----------------"
echo
echo
sleep $SLEEPER
echo "--------------103----------------"
apt-get -y update
echo "------------103------------------"
echo
echo
sleep $SLEEPER
echo "---------------105------------------------"
#aptitude --download-only install libcurl3 -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install libcurl3 -y
#ls -l /cache/apt/archives/*
echo "-----------105-------------------"
echo
echo
sleep $SLEEPER
echo "--------------106-------------------------"
#aptitude --download-only install libcurl4 -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install libcurl4 -y
#ls -l /cache/apt/archives/*
echo "-----------106-------------------"
echo
echo
sleep $SLEEPER
echo "----------------108-----------------------"
#aptitude --download-only install node-gyp -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get -y install node-gyp -y
#ls -l /cache/apt/archives/*
echo "--------------108----------------"
echo
echo
sleep $SLEEPER
 echo "---------------114a-----------------------"
#aptitude --download-only install -y npm
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y npm
#ls -l /cache/apt/archives/*
echo "-------------114a-----------------"
echo
echo

  sleep $SLEEPER
  echo "------------115a--------------------"
  apt-get update -y
  echo "Doing apt-get install apt update"
  echo "------------115a--------------------"
echo
echo
  sleep $SLEEPER
  echo "-------116a----[apt-get install -y openssh-server]---------------------"
  apt-get install -y openssh-server
  echo "----------116a----------------------"
echo
echo

  echo "--------117a------[cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ba.bak]-------------------"
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ba.bak
  echo "----------117a-----------------------"
  echo
echo
  sleep $SLEEPER
  echo "--------118a------[cp /etc/ssh/ssh_config /etc/ssh/sshd_config.ba.bak]-------------------"
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/sshd_config
  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sed -i 's/ UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
  sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
  echo "--------118a------[cp /etc/ssh/ssh_config /etc/ssh/sshd_config.ba.bak]-------------------"
 echo
echo 
  sleep $SLEEPER
  echo "--------119a------[cp /etc/ssh/ssh_config /etc/ssh/sshd_config.ba.bak]-------------------"
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/ssh_config
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/ssh_config
  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/ssh_config
  sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/ssh_config
  sed -i 's/ UsePAM yes/UsePAM no/' /etc/ssh/ssh_config
  echo "--------119a------[cp /etc/ssh/ssh_config /etc/ssh/sshd_config.ba.bak]-------------------"
  /etc/init.d/ss[h restart
  echo "------------[ /etc/init.d/ssh restart]--------------------"
echo
echo
  sleep $SLEEPER
  echo "-----120a-----[cat /etc/ssh/sshd_config | grep PermitRootLogin]-----------------------"
  cat /etc/ssh/sshd_config | grep PermitRootLogin
  cat /etc/ssh/sshd_config | grep PubkeyAuthentication
  cat /etc/ssh/sshd_config | grep PasswordAuthentication
  echo "-----120a----[cat /etc/ssh/sshd_config | grep PermitRootLogin]----------------------"
echo
echo
  sleep $SLEEPER
  echo "-------121a---[cat /etc/ssh/ssh_config | grep PermitRootLogin]-----------------------"
  cat /etc/ssh/ssh_config | grep PermitRootLogin
  cat /etc/ssh/ssh_config | grep PubkeyAuthentication
  cat /etc/ssh/ssh_config | grep PasswordAuthentication
  echo "------121a----[cat /etc/ssh/ssh_config | grep PermitRootLogin]-----------------------"
echo
echo
  sleep $SLEEPER
  echo "-------122a----[/etc/init.d/ssh restart]----------------------"
  echo "Please wait..."
  /etc/init.d/ssh restart
  echo "-----122a----------------------------"
  cat /etc/ssh/ssh_config |grep PermitRootLogin
  cat /etc/ssh/ssh_config |grep PubkeyAuthentication
  cat /etc/ssh/ssh_config |grep PasswordAuthentication
  cat /etc/ssh/ssh_config |grep UsePAM
  echo "------122b---------------------------"
echo
echo
sleep $SLEEPER
}








#####################################################
# Installation packages and tools
#####################################################
functionInstallCriticalTools () {
  ID=23
  echo
  echo
  #installation of all critical the tools required and packages
  echo -e "\e[1;31m ############################################### \e[m"
  echo "        Starting functionInstallCriticalTools			   "
  echo -e "\e[1;31m ############################################### \e[m"
  echo
  echo
  echo "--------------------------------------------------"
  echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
  echo "--------------------------------------------------"
  echo
  echo

 sleep $SLEEPER
  echo "-------[running... add-apt-repository ppa:ondrej/php]-------------------------"

 #aptitude clean
 ##aptitude --download-only install <your_package_here>
 #cp /var/cache/apt/archives/*.deb <your_directory_here>

#apt-get remove keyutils -y
#apt-get remove libevent-2 -y
#apt-get remove libnfsidmap2 -y
#apt-get remove libtirpc3 -y
#apt-get remove rpcbind -y
#apt-get remove nfs-common -y
#cp /var/cache/apt/archives/ /blockapt/scripts/deb

##aptitude --download-only install  keyutils -y
##aptitude --download-only install libevent-2 -y
##aptitude --download-only install  libnfsidmap2 -y
##aptitude --download-only install  libtirpc3 -y
##aptitude --download-only install rpcbind -y
##aptitude --download-only install nfs-common -y
#cp /var/cache/apt/archives/ /blockapt/scripts/deb

  echo "--------------------------------"
  apt-get -y update
  echo "Please wait..."
  echo "--------------------------------"

  echo "--------------------------------"
  #aptitude --download-only install apt-rdepends -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install apt-rdepends -y
  echo "Please wait..."
  echo "--------------------------------"

  echo "--------------------------------"
  apt-get install aptitude -y
  apt-get install curl -y
   #add-apt-repository ppa:ondrej/php -y
  apt-get -y update
  echo "Please wait..."
  echo "--------------------------------"
 sleep $SLEEPER
  echo 
  echo 
  echo "---------[  apt-get  update -y]-----------------------"
  apt-get update -y
  echo "--------------------------------"
 sleep $SLEEPER
  echo 
  echo 
 sleep $SLEEPER
  echo "---------[running...  apt-get install -y curl]-----------------------"
  #aptitude --download-only install cron -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install cron -y
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 
  echo "---------[running...   apt-get install lsof -y]-----------------------"
  #aptitude --download-only install lsof -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install lsof -y
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 
 sleep $SLEEPER
  echo "---------[running...  apt-get install -y curl]-----------------------"
  #aptitude --download-only -y install -y curl
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y curl
  echo "Please wait..."
  echo "--------------------------------"
  echo 
 
 
  echo "Please wait..."
  echo "----------[apt-get install libcurl3/4]----------------------"
  #aptitude --download-only install libcurl3 -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install libcurl3 -y
  sleep $SLEEPER
  echo 
  echo "Please wait..."
  echo "----------[apt-get install libcurl3/4]----------------------"
  #aptitude --download-only install libcurl4 -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install libcurl4 -y
  sleep $SLEEPER

  echo "----------[apt-get install software-properties-common -y]-----------"
  #aptitude --download-only install software-properties-common -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install software-properties-common -y
  sleep $SLEEPER

  echo "----------[apt-get install  python3 -y]----------------------"
  #aptitude --download-only install python3 -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install python3 -y
  sleep $SLEEPER

  echo "----------[apt-get install python3-pip -y]----------------------"
  #aptitude --download-only install python3-pip -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install python3-pip -y
  sleep $SLEEPER

  echo 
  echo "Please wait..."
  echo "--------------------------------"
 sleep $SLEEPER
  echo 
  echo 
  echo "---------[  apt-get  update -y]-----------------------"
  apt-get update -y
  echo "--------------------------------"
 sleep $SLEEPER
  echo 
  echo 
}



#####################################################
# Installation packages and tools
#####################################################
functionInstalltools () {
  ID=8
  echo
  echo
 
  #installation of all the tools required and packages
  echo -e "\e[1;31m ############################################### \e[m"
  echo "        Starting functionInstalltools			   "
  echo -e "\e[1;31m ############################################### \e[m"
  echo
  echo
 sleep $SLEEPER
  echo "--------------------------------------------------"
  echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
  echo "--------------------------------------------------"
  echo
  echo
 sleep $SLEEPER
  echo "Installing docker and related tool... will continue in [$SLEEPER] seconds..."
  echo "--------------------------------------------------"
  apt-get -y update 
  apt-get install aptitude -y
  echo "--------------------------------------------------"
  echo 
  echo 
 sleep $SLEEPER
  echo "Installing install tree and related tool... will continue in [$SLEEPER] seconds..."
  echo "--------------------------------------------------"
  #aptitude --download-only  install tree -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get  install tree -y
  echo "--------------------------------------------------"
  echo 
  echo 
  echo "Installing install  apt-get install libncurses5 and related tool for mysql... will continue in [$SLEEPER] seconds..."
  echo "--------------------------------------------------"
  #aptitude --download-only install libncurses5 -y 
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install libncurses5 -y
  apt-get update
  apt-get install libssl1.0.0
  ############ For mySQL failures echo "" > /opt/bitnami/mysql/data/binlog.index
  echo "--------------------------------------------------"


  echo "--------------------------------------------------"
  #aptitude --download-only install libcurl4 -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install libcurl4 -y
  echo "--------------------------------------------------"
  echo 
  echo 
  sleep $SLEEPER
  echo "--------------------------------------------------"
  #aptitude --download-only install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install curl -y
  apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
  echo "--------------------------------------------------"
  echo 
  echo 
  sleep $SLEEPER
  echo "--------------------------------------------------"
  apt-get install curl -y
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  echo "--------------------------------------------------"
  echo 
  echo 
  sleep $SLEEPER
  echo "--------------------------------------------------"
  apt-key fingerprint 0EBFCD88 -y
  echo "--------------------------------------------------"
  echo 
  echo 
  sleep $SLEEPER
  echo "--------------------------------------------------"
  add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  echo "--------------------------------------------------"
  echo 
  echo 
  sleep $SLEEPER
  echo "--------------------------------------------------"
  apt-get -y update
  echo "--------------------------------------------------"
  echo 
  echo 
 sleep $SLEEPER
  echo "--------------------------------------------------"
  #aptitude --download-only  install docker-ce docker-ce-cli containerd.io -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install docker-ce docker-ce-cli containerd.io -y
  echo "--------------------------------------------------"
  echo 
  echo 
  echo "--------------------------------"
  docker run hello-world
  echo "--------------------------------"
  echo 
  echo "Installing docker completed..."
 sleep $SLEEPER
  ######################DOCKER OPTIONAL PREREQUISITES#####################################  


  ######################ESSENTIALS & CRITICAL PREREQUISITES###############################
  echo "--------------Installing pre-requisites critical tools sysstat iotop iptraf acct nethogs iftop arpwatch suricata nmon collectl----------------"

 sleep $SLEEPER
  
  echo "---------[running...apt-get -y update -y]------------"
  apt-get -y update
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------[running...sudo install inetutils-traceroute/net-tools -y -y]------------------------"
  #aptitude --download-only  inetutils-traceroute -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install inetutils-traceroute -y

  echo "--------[running...sudo install inetutils-traceroute/net-tools -y -y]------------------------"
  #aptitude --download-only install net-tools -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install net-tools -y
  
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "-------[running...sudo apt install traceroute -y]-------------------------"
  #aptitude --download-only install traceroute -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install traceroute -y
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------------------------------"
  #aptitude --download-only build-essential -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install build-essential -y
  echo "running...sudo apt install build-essential"
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------------------------------"
  #aptitude --download-only install debconf-utils -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get  install debconf-utils -y
  echo "running...sudo apt-get install debconf-utils -y"
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------------------------------"
  #aptitude --download-only -y install whois
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get -y install whois
  echo "running...apt-get -y install whois"
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 
  echo 
  echo 
 sleep $SLEEPER
  echo "-----------[apt-get install -y openssh-server]---------------------"
  #aptitude --download-only install -y openssh-server
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y openssh-server
  echo "--------------------------------"
  echo 
  echo 
  echo 
  echo "-------------[cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ba.bak]-------------------"
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ba.bak
  echo "--------------------------------"
  echo 
  echo 
  echo 
  echo "-------------[cp /etc/ssh/ssh_config /etc/ssh/sshd_config.ba.bak]-------------------"
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/sshd_config
  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sed -i 's/ UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
  echo "-------------[cp /etc/ssh/ssh_config /etc/ssh/sshd_config.ba.bak]-------------------"
  echo 
  echo 
  echo 
  echo "-------------[cp /etc/ssh/ssh_config /etc/ssh/sshd_config.ba.bak]-------------------"
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/ssh_config
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/ssh_config
  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/ssh_config
  sed -i 's/ UsePAM yes/UsePAM no/' /etc/ssh/ssh_config
  echo "-------------[cp /etc/ssh/ssh_config /etc/ssh/sshd_config.ba.bak]-------------------"
  /etc/init.d/ssh restart
  echo "--------------------------------"
  echo 
  echo 
  echo 
  echo "---------[/etc/init.d/ssh restart - /etc/ssh/sshd_config]-----------------------"
  cat /etc/ssh/sshd_config | grep PermitRootLogin
  cat /etc/ssh/sshd_config | grep PubkeyAuthentication
  cat /etc/ssh/sshd_config | grep PasswordAuthentication
  echo "---------[/etc/init.d/ssh restart - /etc/ssh/sshd_config]-----------------------"
  echo 
  echo 
  echo 
  echo "---------[/etc/init.d/ssh restart - /etc/ssh/ssh_config]-----------------------"
  cat /etc/ssh/ssh_config | grep PermitRootLogin
  cat /etc/ssh/ssh_config | grep PubkeyAuthentication
  cat /etc/ssh/ssh_config | grep PasswordAuthentication
  echo "---------[/etc/init.d/ssh restart - /etc/ssh/ssh_config]-----------------------"
  echo 
  echo 
  echo 
  echo "Please wait..."
 /etc/init.d/ssh restart
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "------------------------Installing pre-requisites critical tools openssl-----------------------"
  #aptitude --download-only install -y openssl
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y openssl
  echo "running...apt-get install openssl -y"
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------------------------------"
  #aptitude --download-only -y inetutils-ping 
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y inetutils-ping 
  echo "running...apt-get inetutils-ping -y"
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------------------------------"
  #aptitude --download-only  install -y vim
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y vim
  echo "running...apt-get install -y vim"
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo   

 sleep $SLEEPER
  echo "--------------------------------"
  #aptitude --download-only install -y iptables
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y iptables
  echo "running...apt-get iptables -y"
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "---------[running...apt-get install iptables-persistent -y]-----------------------"
  echo iptables-persistent iptables-persistent/autosave_v4 boolean true |  debconf-set-selections
  #####echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections

  echo "-------------[running...install iptables-persistent -y]-------------------"
  #aptitude --download-only install iptables-persistent -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install iptables-persistent -y
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "-------[running...apt-get nano -y]-------------------------"
  #aptitude --download-only -y install nano
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get -y install nano
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "---------[running...apt-get socat -y]-----------------------"
  #aptitude --download-only install -y socat
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y socat
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "-----------[running...apt-get telnet -y]---------------------"
  #aptitude --download-only install -y telnet
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y telnet
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "---------[running...apt-get dpkg -y]-----------------------"
  #aptitude --download-only  install -y dpkg
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y dpkg
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "------------[running...apt-get install -y htop]--------------------"
  #aptitude --download-only  install -y htop
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y htop
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------[running...apt-get install -y wget]------------------------"
  #aptitude --download-only  install -y wget
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y wget
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "----------[running...apt-get install -y python]----------------------"
  #aptitude --download-only install -y python
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y python
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "---------[running...apt-get install net-tools]-----------------------"
  #aptitude --download-only install net-tools -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install net-tools -y
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------[running... apt-get -y install git]------------------------"
  #aptitude --download-only  -y install git
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get -y install git
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "-----------[running... install software-properties-common]---------------------"
  #aptitude --download-only -y install software-properties-common
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get -y install software-properties-common
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 


  echo "--------------------------------------------------"
  apt-get -y update	
  echo "----------Done Installing pre-requisites critical tools sysstat iotop iptraf acct nethogs iftop arpwatch suricata nmon collectl--------------"
 sleep $SLEEPER
  ########################################ESSENTIALS PREREQUISITES###############################
  

  ######################OPTIONAL PREREQUISITES INSTALLATION STARTS###############################
  echo "-----------Installing pre-requisites optional tools sysstat iotop iptraf acct nethogs iftop arpwatch suricata nmon collectl-----------"

 sleep $SLEEPER
  echo "-----------[running...apt-get install -y sysstat]---------------------"
  #aptitude --download-only install -y sysstat
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y sysstat
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------[running...apt-get install -y iotop]------------------------"
  #aptitude --download-only install -y iotop
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y iotop
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------[running...apt-get install -y iptraf]------------------------"
  #aptitude --download-only install -y iptraf
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y iptraf
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "---------[running...apt-get install -y acct]-----------------------"
  #aptitude --download-only install -y acct
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y acct
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------[running...apt-get install -y nethogs]------------------------"
  #aptitude --download-only install -y nethogs
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y nethogs
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo

 sleep $SLEEPER
  echo "----------[running...  apt-get install -y iftop]----------------------"
  #aptitude --download-only install -y iftop
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y iftop
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------[running...  apt-get install -y arpwatch]------------------------"
  #aptitude --download-only install -y arpwatch
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y arpwatch
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------[running...apt-get install -y tcpdump]------------------------"
  #aptitude --download-only install -y tcpdump
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y tcpdump
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "------[running...apt-get install -y suricata]--------------------------"
  #aptitude --download-only  install -y suricata
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y suricata
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "------[running...apt-get install -y suricata-hyperscan]--------------------------"
  #aptitude --download-only  install -y suricata-hyperscan
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y suricata-hyperscan
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "-------[running...apt-get install -y nmon]-------------------------"
  #aptitude --download-only  install -y nmon
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y nmon
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "-------[running...apt-get install -y syslog-ng]-------------------------"
  #aptitude --download-only install -y syslog-ng
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y syslog-ng
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "----------[running... apt-get install -y clamav]----------------------"
  #aptitude --download-only  install -y clamav
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y clamav
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "--------[running...apt-get install -y clamav-daemon]------------------------"
  #aptitude --download-only install -y clamav-daemon
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y clamav-daemon
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 

 sleep $SLEEPER
  echo "---------[running...apt-get -y update -y]-----------------------"
  #aptitude --download-only install -y libclamunrar6
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y libclamunrar6
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 


 sleep $SLEEPER
  echo "----------[running...apt-get -y update -y]----------------------"
  #aptitude --download-only -y cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 


 sleep $SLEEPER
  echo "----------[running... apt-get -y install  node-gyp]----------------------"
  #aptitude --download-only  -y install  node-gyp
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get -y install  node-gyp
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 


 sleep $SLEEPER
  echo "----------[running...  apt-get -y install git]----------------------"
  #aptitude --download-only  -y install git
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get -y install git
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 


 sleep $SLEEPER
  echo "----------[running...apt-get -y install libmaxminddb-dev]----------------------"
  #aptitude --download-only -y install libmaxminddb-dev
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get -y install libmaxminddb-dev
  echo "----------[running...apt-get -y install libmaxminddb-dev]----------------------"
  echo 
  echo 
 sleep $SLEEPER
  echo "----------[running...apt-get -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python3 python3-dev swig zlib1g-dev]----------------------"
  #aptitude --download-only -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python3 python3-dev swig zlib1g-dev
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python3 python3-dev swig zlib1g-dev
  echo "----------[running...apt-get -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python3 python3-dev swig zlib1g-dev]----------------------"
  echo 
  echo 
 sleep $SLEEPER
  echo "----------[running...apt-get -y install python3-git python3-semantic-version]----------------------"
  #aptitude --download-only -y install python3-git python3-semantic-version
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get -y install python3-git python3-semantic-version
  ##echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_18.04/ /' | tee /etc/apt/sources.list.d/security:zeek.list
  ##aecho 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_18.04/ /' | sudo tee /etc/apt/sources.list.d/security:zeek.list
  ##curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_18.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null
  ##apt update -y
  ##apt install zeek -y
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 
  ##apt-get -y update -y
  ##apt-get install -y wget
  ##apt-get install -y sysstat
  ##apt-get install -y iotop
  ##apt-get install -y iptraf
  ##apt-get install -y acct
  ##apt-get install -y nethogs
  ##apt-get install -y iftop
  ##apt-get install -y arpwatch
  ##apt-get install -y suricata
  ##apt-get install -y suricata-hyperscan
  ##apt-get install -y nmon
  ##apt-get install -y syslog-ng
  echo "----------Done Installing pre-requisites optional tools sysstat iotop iptraf acct nethogs iftop arpwatch suricata nmon collectl--------"
 sleep $SLEEPER
  ######################COMPLETED OPTIONAL PREREQUISITES###############################
 }




#####################################################
#script Find & Kill Selected Services
#####################################################
functionKillServices (){ 
 ID=1
 ##########echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 #script Find & Kill Selected Services based on the service name
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionKillServices			   "
 echo -e "\e[1;31m ############################################### \e[m"

 echo "--------------------------------------------------"
 ##########echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 ##########echo "[functionKillServices] -[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "--------------------------------------------------"
 echo
 echo
 echo
sleep $SLEEPER
 echo "-----------killing mission: [apache apached apache2 nginx tomcat httpd]-------------"
 kill -9 $(ps ax | grep apache  | fgrep -v grep | awk '{ print $1 }')
 kill -9 $(ps ax | grep apached | fgrep -v grep | awk '{ print $1 }')
 kill -9 $(ps ax | grep apache2 | fgrep -v grep | awk '{ print $1 }')
 kill -9 $(ps ax | grep nginx   | fgrep -v grep | awk '{ print $1 }')
 kill -9 $(ps ax | grep tomcat  | fgrep -v grep | awk '{ print $1 }')
 kill -9 $(ps ax | grep httpd   | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------"
 /etc/init.d/apache2 stop
 /opt/bitnami/ctlscript.sh stop
 /etc/init.d/apache2 stop
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------"
 echo "Stopping Apache services [  apache] [apached]..."
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------------------------"
 kill -9 $(ps ax | grep  splunk  | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------"
 echo "Stopping SERVICE_splunk services  [splunk]..."
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------------------------"
 kill -9 $(ps ax | grep splunkd  | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------"
 echo "Stopping SERVICE_splunkd services  [splunkd]..."
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------------------------"
 kill -9 $(ps ax | grep mysql  | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------"
 echo "Stopping SERVICE_mysql services  [mysql]..."
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------------------------"
 kill -9 $(ps ax | grep mysqld  | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------"
 echo "Stopping SERVICE_mysqld services [mysqld]..."
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------------------------"
 kill -9 $(ps ax | grep mongo  | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------"
 echo "Stopping SERVICE_mongo services [mongo]..."
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------------------------"
 kill -9 $(ps ax | grep mongod | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------"
 echo "Stopping SERVICE_mongod services [mongod]..."
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------------------------"
 kill -9 $(ps ax | grep redis | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------"
 echo "Stopping SERVICE_redisserver services [redisserver]..."
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------------------------"
 kill -9 $(ps ax | grep http | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------"
 echo "Stopping SERVICE_http services [http]..."
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------------------------"
 kill -9 $(ps ax | grep httpd | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------"
 echo "Stopping SERVICE_httpd services [httpd]..."
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------------------------"
 kill -9 $(ps ax | grep httpd.bin | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------"
 echo "Stopping SERVICE_httpd.bin services [httpd.bin]..."
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
 echo "--------------------------------------------------"
 kill -9 $(ps ax | grep nginx | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------"
 echo "Stopping SERVICE_nginx services [nginx]..."
 echo "--------------------------------"
sleep $SLEEPER
 echo  
 echo 
 echo "--------------------------------------------------"
 kill -9 $(ps ax | grep ntopng | fgrep -v grep | awk '{ print $1 }')
 echo "--------------------------------"
 echo "Stopping SERVICE_ntopng services [ntopng]..."
 echo "--------------------------------"
 echo  
 echo 
sleep $SLEEPER
}




#####################################################
#string replacer function for text replacement used for password replace and htdocs update
#####################################################
functionLoadReplacerString (){
 ID=4
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "         Starting functionLoadReplacerString 			   "
 echo -e "\e[1;31m ############################################### \e[m"
 
 echo "--------------------------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "--------------------------------------------------"
 echo
 echo
 echo
sleep $SLEEPER

 echo "#############################################" > $PYTHON_NAME_FILE
 echo "#!/usr/bin/python " >> $PYTHON_NAME_FILE
 echo "# replace.py" >> $PYTHON_NAME_FILE
 echo "import sys" >> $PYTHON_NAME_FILE
 echo "#Replace string in a file (in place)" >> $PYTHON_NAME_FILE
 echo "match=sys.argv[1]" >> $PYTHON_NAME_FILE
 echo "replace=sys.argv[2]" >> $PYTHON_NAME_FILE
 echo "filename=sys.argv[3]" >> $PYTHON_NAME_FILE
 echo "print \"Replacing strings in\",filename" >> $PYTHON_NAME_FILE
 echo "with open(filename,\"r\") as f:" >> $PYTHON_NAME_FILE
 echo "  data = f.read().replace(match,replace)" >> $PYTHON_NAME_FILE
 echo "with open(filename,\"w\") as f:" >> $PYTHON_NAME_FILE
 echo "  f.write(data) " >> $PYTHON_NAME_FILE
 echo "#############################################" >> $PYTHON_NAME_FILE

 echo "----------------- chmod 755 $PYTHON_NAME_FILE---------------------------------"
 chmod 755 $PYTHON_NAME_FILE
 echo "---------------- chmod 755 $PYTHON_NAME_FILE----------------------------------"
 echo
 echo
 echo
sleep $SLEEPER
}




#####################################################
#string replacer function for text replacement used for password replace and htdocs update
#####################################################
functionReplaceString (){
 ID=2
 echo
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "         Starting functionReplaceString			   "
 echo -e "\e[1;31m ############################################### \e[m"

 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 repfromstring=$1
 reptostring=$2
 reptofile=$3

 echo "--------[ python $PYTHON_NAME_FILE $repfromstring $reptostring $reptofile]-----------"
 echo "replacement string started for: repfromstring=$repfromstring reptostring=$reptostring reptofile=$reptofile"
 python $PYTHON_NAME_FILE $repfromstring $reptostring $reptofile
 echo "replacement completed...[FILE content post replacement: `cat $reptofile`]"
 echo "---------[ python $PYTHON_NAME_FILE $repfromstring $reptostring $reptofile]-----------"
sleep $SLEEPER
 echo
 echo
} 




#####################################################
#setting the path before starting the install - important to ensure usage of right libraries
#####################################################
functionSetPath () {
 ID=5
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionSetPath				   "
 echo -e "\e[1;31m ############################################### \e[m"


  echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo
 echo
 echo
sleep $SLEEPER

 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo "------------------------------"
 echo "Start: setting path..."
 echo "------------------------------"
 echo "PATH=/usr/local/bin/:/usr/bin/:/opt/bitnami/php/bin:/usr/bin/:/bin/:/sbin/:/usr/local/bin/:/opt/bitnami/mysql/bin:/opt/bitnami/varnish/bin:$PATH" >> ~/.bashrc
 echo "------------------------------"
 
 PATH="/opt/bitnami/php/bin:/usr/bin/:/bin/:/sbin/:/usr/local/bin/:/opt/bitnami/mysql/bin:/opt/bitnami/varnish/bin:$PATH"
 export PATH
 
 echo "------------------------------"
 echo "path set completed..."
 echo "------------------------------"
 echo "echo PATH=[$PATH];"
 echo "------------------------------"
 echo "Please wait..."
sleep $SLEEPER
 echo
 echo
 echo "------------------------------==="
 echo "bashrc=[`cat ~/.bashrc | grep bitnami`]"
 echo "------------------------------==="
 echo
 echo
 echo "------------------------------==="
 echo "env=[`env | grep bitnami`]"
 echo "------------------------------==="
 echo
 echo
 echo "Please wait..."
sleep $SLEEPER
}



#####################################################
#Checking the path before starting the install - important to ensure usage of right libraries
#####################################################
functionCheckPath () {
 ID=6
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 
 echo -e "\e[1;31m ############################################### \e[m"
 echo "         Starting functionCheckPath 			 	  "
 echo -e "\e[1;31m ############################################### \e[m"

 
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo
 echo
 echo
sleep $SLEEPER

 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo "------------------------------"
 echo "echo PATH=[$PATH];"
 echo "------------------------------"
 echo
 echo
 echo "------------------------------==="
 echo "bashrc=[`cat ~/.bashrc | grep bitnami`]"
 echo "------------------------------==="
 echo
 echo
 echo "------------------------------==="
 echo "env=[`env | grep bitnami`]"
 echo "------------------------------==="
 echo
 echo
 PATH_VALUE1=`env | grep bitnami | wc -l`
  if [ $PATH_VALUE1 -eq 0 ]; then
    echo "1" > $PREVIOUS_INSTALL_FILE
    echo -e "\e[1;31m ############################################### \e[m"
    echo "LOGOUT AND LOGIN AGAIN TO INITIALISE ENV VARIABLES"
    echo -e "\e[1;31m ############################################### \e[m"
    echo "Please wait..."
   sleep $SLEEPER
 else
   echo "------------------------------"
   echo "echo PATH=[$PATH];"
   echo "------------------------------"
   echo
   echo
   echo "------------------------------==="
   echo "bashrc=[`cat ~/.bashrc | grep bitnami`]"
   echo "------------------------------==="
   echo
   echo
   echo "------------------------------==="
   echo "env=[`env | grep bitnami`]"
   echo "------------------------------==="
   echo
   echo 
   echo "SUCCESS SETTING PATH: env path is set and good to go!"
   echo "Please wait..."
  sleep $SLEEPER
fi
}




#####################################################
#Bitnami framework installation - LAMP
#####################################################
functionInstallBitnami () {
 ID=13
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo 
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionInstallBitnami               "
 echo -e "\e[1;31m ############################################### \e[m"

 echo "----------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[functionInstallBitnami] - [{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "----------------------"
sleep $SLEEPER
 echo
 echo
 echo

 echo "----------------------"
 echo "Downloading bitnami LAMP framework.... please wait..."
 #cd ${INSTALL_HOME_DIR}
 #wget $WGET_URL_BITNAMI
 echo "----------------------"

 
sleep $SLEEPER
 echo "--------------------BITNAMI QUESTIONS & ANSWERS AUTOMATED/UNATTENDED INSTALLATION--------------------"
 echo " Language: Select [1] - English"
 echo " Varnish [Y/n] :Y"
 echo " WordPress : Y"
 echo " PhpMyAdmin [Y/n] :Y"
 echo " Is the selection above correct? [Y/n]: Y"
 echo " Select a folder [/opt/wordpress-6.1.1-43]: /opt/bitnami/"
 echo " Your real name [User Name]: admin"
 echo " Email Address [user@example.com]:"
 echo " Login [user]: admin"
 echo " Blog name [admin's Blog!]: admin"
 echo " Configure SMTP Settings: N"
 echo " Do you want to continue? [Y/n]: Y"
 echo " Do you want to continue? [Y/n]: Y"
 echo "---------------------------------------------------------------------------------------------------"
sleep $SLEEPER
 echo "---------------------------------------"
 echo "Running the Bitnami installation script... Stopping all conflicting services...please wait..."
 echo "---------------------------------------"
sleep $SLEEPER
 echo
 echo
 echo "---------------[functionKillServices]------------------------"
 functionKillServices
 echo "---------------------------------------"
 echo
 echo
sleep $SLEEPER
 echo "--------------------------------" 
 echo "Running the installation script... please wait...executing ...[ ${INSTALL_HOME_DIR}/bitnami-wordpress-5.9.3-1-linux-x64-installer.run]"
 echo "--------------------------------"
 echo
 echo
 echo "----------------------"
 echo "Updating file permission...[chmod 755 ${INSTALL_HOME_DIR}/bitnami-wordpress-5.9.3-1-linux-x64-installer.run]"
 ###chmod 755 ${INSTALL_HOME_DIR}/bitnami-wordpress-5.2.2-3-linux-x64-installer.run
 echo "----------------------"
 echo
 echo
sleep $SLEEPER
 echo "----------------------"
 echo "Updating file permission...for [{INSTALL_HOME_DIR}/{BITNAMI_FILE_RUN}=${INSTALL_HOME_DIR}/${BITNAMI_FILE_RUN}]"
 chmod 755 ${INSTALL_HOME_DIR}/${BITNAMI_FILE_RUN} 
 echo "----------------------"
 echo
 echo "-----------[/opt/bitnami/ctlscript.sh stop]---------------------"
 /opt/bitnami/ctlscript.sh stop
 echo "--------------------------------"
sleep $SLEEPER
 echo
 echo
 ####${INSTALL_HOME_DIR}/bitnami-wordpress-5.2.2-3-linux-x64-installer.run
 ###${INSTALL_HOME_DIR}/${BITNAMI_FILE_RUN}
 #/tmp/blockapt_install_logs/bitnami-wordpress-5.2.2-3-linux-x64-installer.run --mode unattended --prefix /opt/bitnami/ --installer-language en --base_user_name ba-admin --base_mail ba-admin@ba-admin.local --base_user baadmin2020 --base_password baadmin2020 --debuglevel 4 --debugtrace /tmp/bitnami-install-custom.log --enable-components varnish,phpmyadmin --mysql_password NTM0yaddasht --wordpress_blog_name ba-admin-blog --phpmyadmin_password NTM0yaddasht --launch_cloud 0 --apache_server_port 80 --apache_server_ssl_port 443
 #/tmp/blockapt_install_logs/bitnami-wordpress-5.2.2-3-linux-x64-installer.run --mode unattended --prefix /opt/bitnami/ --installer-language en --base_user_name ba-admin --base_mail ba-admin@ba-admin.local --base_user baadmin2020 --base_password baadmin2020 --debuglevel 4 --debugtrace /tmp/bitnami-install-custom.log --enable-components varnish,phpmyadmin --wordpress_blog_name ba-admin-blog --launch_cloud 0 --apache_server_port 80 --apache_server_ssl_port 443
 echo "Installing Bitnami. Be patient. It's a good time to have your tea break :) This may take up to 5mins..." 
 #${INSTALL_HOME_DIR}/${BITNAMI_FILE_RUN} --mode unattended --prefix $BITNAMI_PREFIX --installer-language $BITNAMI_INSTAL_LANG --base_user_name $BITNAMI_BASE_USERNAME --base_mail $BITNAMI_BASE_MAIL --base_user $BITNAMI_BASE_USER --base_password $BITNAMI_BASE_PWD --debuglevel $BITNAMI_DEBUG_LEVEL --debugtrace $BITNAMI_DEBUG_TRACE --enable-components $BITNAMI_ENABLE_PLUGINS --mysql_password $BITNAMI_MYSQL_PWD --wordpress_blog_name $BITNAMI_WP_BLOGNAME --phpmyadmin_password $BITNAMI_MYPHP_ADM --launch_cloud $BITNAMI_LAUNCH_CLOUD --apache_server_port $BITNAMI_APACHE_SERVR_HTTP --apache_server_ssl_port $BITNAMI_APACHE_SERVR_HTTPS
 #${INSTALL_HOME_DIR}/${BITNAMI_FILE_RUN} --mode unattended --prefix $BITNAMI_PREFIX --installer-language $BITNAMI_INSTAL_LANG --base_user_name $BITNAMI_BASE_USERNAME --base_mail $BITNAMI_BASE_MAIL --base_user $BITNAMI_BASE_USER --base_password $BITNAMI_BASE_PWD --debuglevel $BITNAMI_DEBUG_LEVEL --debugtrace $BITNAMI_DEBUG_TRACE --enable-components $BITNAMI_ENABLE_PLUGINS --wordpress_blog_name $BITNAMI_WP_BLOGNAME --launch_cloud $BITNAMI_LAUNCH_CLOUD --apache_server_port $BITNAMI_APACHE_SERVR_HTTP --apache_server_ssl_port $BITNAMI_APACHE_SERVR_HTTPS
 #echo "${INSTALL_HOME_DIR}/${BITNAMI_FILE_RUN} --mode unattended --prefix $BITNAMI_PREFIX --installer-language $BITNAMI_INSTAL_LANG --base_user_name $BITNAMI_BASE_USERNAME --base_mail $BITNAMI_BASE_MAIL --base_user $BITNAMI_BASE_USER --base_password $BITNAMI_BASE_PWD --debuglevel $BITNAMI_DEBUG_LEVEL --debugtrace $BITNAMI_DEBUG_TRACE --enable-components $BITNAMI_ENABLE_PLUGINS --wordpress_blog_name $BITNAMI_WP_BLOGNAME --launch_cloud $BITNAMI_LAUNCH_CLOUD --apache_server_ssl_port $BITNAMI_APACHE_SERVR_HTTPS"
       #${INSTALL_HOME_DIR}/${BITNAMI_FILE_RUN} --mode unattended --prefix $BITNAMI_PREFIX --installer-language $BITNAMI_INSTAL_LANG --base_user_name $BITNAMI_BASE_USERNAME --base_mail $BITNAMI_BASE_MAIL --base_user $BITNAMI_BASE_USER --base_password $BITNAMI_BASE_PWD --debuglevel $BITNAMI_DEBUG_LEVEL --debugtrace $BITNAMI_DEBUG_TRACE --enable-components $BITNAMI_ENABLE_PLUGINS --wordpress_blog_name $BITNAMI_WP_BLOGNAME --launch_cloud $BITNAMI_LAUNCH_CLOUD --apache_server_ssl_port $BITNAMI_APACHE_SERVR_HTTPS
 echo "--------------------------------"
 sleep $SLEEPER
 echo
 echo
 echo
}


#####################################################
#Bitnami framework installation - Checking Apache2
#####################################################
functionCheckApacheIsUp () {
 ID=36.1
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}

 echo
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionCheckApacheIsUp			   "
 echo -e "\e[1;31m ############################################### \e[m"
 
 echo "--------------------------------" 
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "--------------------------------" 
 echo
 echo
 echo
 #/opt/bitnami/ctlscript.sh restart
 echo "---------[ service nginx restart]---------"
 service nginx restart
 echo "------[ service apache2 restart]------------"
 service apache2 restart
 echo "------[ service apache2 restart]------------"
 echo
 CMD_VALUE1=`netstat -na | grep :443 | wc -l`
if [ $CMD_VALUE1 -ge 1 ]; then
    echo
    echo
    echo
    echo "-------------[  apt-get install -y curl]-------------------" 
    apt-get install -y curl
    echo "-------------[   curl -kvs https://127.0.0.1/login | grep login-v2.demo.min.js | wc -l]-------------------"
    curl -kvs https://127.0.0.1/login | grep login-v2.demo.min.js | wc -l
    echo "-------------[  apt-get install -y curl]-------------------"
    echo
    echo
    echo
    TEST_IS_LOGIN=`curl -kvs https://127.0.0.1/login | grep login-v2.demo.js | wc -l`
    TEST_IS_MONGO=`netstat -nape | grep mongo | grep LIST | grep :27017 | wc -l`
    TEST_IS_WEBSERVER_APACHE=`netstat -nape | grep apache | grep LIST | grep :443 | wc -l`
    TEST_IS_WEBSERVER_NGINX=`netstat -nape | grep nginx | grep LIST | wc -l`

    
    if [ $TEST_IS_LOGIN -ge 1 ]; then
            echo
            echo
            echo "-----------[curl -kvs https://127.0.0.1/login | grep login-v2.demo.min.js | wc -l]--------------" 
            apt-get install -y curl
            curl -kvs https://127.0.0.1/login | grep login-v2.demo.min.js | wc -l
            echo "------------------------------------------------------------------------" 
            echo
            echo
            echo "-------------[1]-------------------" 
            echo -e "\e[1;37m[\e[m\e[1;32m BlockAPT Web Console Login Page OK \e[m\e[1;37m]\e[m : [Expected Login Check Count [>=1] = [ TEST_IS_LOGIN=$TEST_IS_LOGIN ] = [ `curl -ks https://127.0.0.1/login | grep login-v2.demo.min.js | wc -l` ]"
            echo "-------------[1]-------------------" 
            echo
            echo
            sleep $SLEEPER
    else
            echo "------------Check  GUI Login--------------------" 
            echo -e "Houston, I have a feeling something \e[1;37m[\e[m\e[1;31m WENT WRONG with GUI Login [ TEST_IS_LOGIN=$TEST_IS_LOGIN ] \e[m\e[1;37m]\e[m with the install and login page is \e[1;37m[\e[m\e[1;31mNOT RIGHT\e[m\e[1;37m]\e[m. Check logs for [Apache Service]"
            echo "------------Check  GUI Login--------------------" 
            sleep $SLEEPER
            echo "Press a key to continue.... No clean up will be executed."
            read -r JUST_PAUSE
            functionCleanUpOnExit
            sleep $SLEEPER
    fi



    if [ $TEST_IS_MONGO -ge 1 ]; then

            echo "-------------[2]-------------------" 
            echo -e "\e[1;37m[\e[m\e[1;32m BlockAPT Web Console MongoDB Service OK \e[m\e[1;37m]\e[m : [Expected Mongo Check Count [>=1] = [ TEST_IS_MONGO=$TEST_IS_MONGO ] = [ `netstat -nape | grep mongo | grep LIST | grep :27017 | wc -l` ]"
            echo "-------------[2]-------------------" 
            echo
            echo
            sleep $SLEEPER
    else
            echo "------------Check Mongo--------------------" 
            echo -e "Houston, I have a feeling something \e[1;37m[\e[m\e[1;31m WENT WRONG with MONGO [ TEST_IS_MONGO=$TEST_IS_MONGO ] \e[m\e[1;37m]\e[m with the install and login page is \e[1;37m[\e[m\e[1;31mNOT RIGHT\e[m\e[1;37m]\e[m. Check logs for [MongoDB Service]"
            echo "------------Check Mongo--------------------" 
            sleep $SLEEPER
            echo "Press a key to continue.... No clean up will be executed."
            read -r JUST_PAUSE
            functionCleanUpOnExit
            sleep $SLEEPER
    fi



    if [ $TEST_IS_WEBSERVER_APACHE -ge 1 ]; then
    
            echo "-------------[3]-------------------" 
            echo -e "\e[1;37m[\e[m\e[1;32m BlockAPT Web Console Service OK \e[m\e[1;37m]\e[m : [Expected Httpd Check Count [>=1] = [ TEST_IS_WEBSERVER_APACHE=$TEST_IS_WEBSERVER_APACHE ] = [ `netstat -nape | grep httpd | grep LIST | grep :443 | wc -l` ]"
            echo "-------------[3]-------------------" 
            echo
            echo
            echo
    else

            echo "------------Check Apache Httpd--------------------" 
            echo -e "Houston, I have a feeling something \e[1;37m[\e[m\e[1;31m WENT WRONG with APACHE2 [ TEST_IS_WEBSERVER_APACHE=$TEST_IS_WEBSERVER_APACHE ] \e[m\e[1;37m]\e[m with the install and login page is \e[1;37m[\e[m\e[1;31mNOT RIGHT\e[m\e[1;37m]\e[m. Check logs for [Apache Service]"
            echo "------------Check Apache Httpd--------------------" 
            sleep $SLEEPER
            echo "Press a key to continue.... No clean up will be executed."
            read -r JUST_PAUSE
            functionCleanUpOnExit
            sleep $SLEEPER

    fi



    if [ $TEST_IS_WEBSERVER_NGINX -ge 1 ]; then
    
            echo "-------------[3]-------------------" 
            echo -e "\e[1;37m[\e[m\e[1;32m BlockAPT Web Console Service OK \e[m\e[1;37m]\e[m : [Expected Httpd Check Count [>=1] = [ TEST_IS_WEBSERVER_NGINX=$TEST_IS_WEBSERVER_NGINX ] = [ `netstat -nape | grep httpd | grep LIST | grep :443 | wc -l` ]"
            echo "-------------[3]-------------------" 
            echo
            echo
            echo
    else

            echo "------------Check Apache Httpd--------------------" 
            echo -e "Houston, I have a feeling something \e[1;37m[\e[m\e[1;31m WENT WRONG with NGINX [ TEST_IS_WEBSERVER_NGINX=$TEST_IS_WEBSERVER_NGINX ] \e[m\e[1;37m]\e[m with the install and login page is \e[1;37m[\e[m\e[1;31mNOT RIGHT\e[m\e[1;37m]\e[m. Check logs for [Nginx Service]"
            echo "------------Check Apache Httpd--------------------" 
            sleep $SLEEPER
            echo "Press a key to continue.... No clean up will be executed."
            read -r JUST_PAUSE
            functionCleanUpOnExit
            sleep $SLEEPER

    fi



else
    echo
    echo
    echo
    echo "-------------Check BAP Web Console Check--------------" 
    echo -e "Houston, I have a feeling something \e[1;37m[\e[m\e[1;31m WENT WRONG with [BAP Web Console Service]\e[m\e[1;37m]\e[m with the install and login page is \e[1;37m[\e[m\e[1;31mNOT RIGHT\e[m\e[1;37m]\e[m. Check logs for [NGINX Service] & [Apache Service] & [MongoDB Service]"
    echo "-------------Check BAP Web Console Check--------------"
    netstat -na | grep :443
    echo "-------------Check BAP Web Console Check-------------"
    echo "Press a key to continue.... No clean up will be executed."
    read -r JUST_PAUSE
    functionCleanUpOnExit
    sleep $SLEEPER
 fi

}




#####################################################
#Git Intsallation via ubuntu updates
#####################################################
functionIntsallGit () {
 ID=9
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionIntsallGit 				   "
 echo -e "\e[1;31m ############################################### \e[m"

 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo
 echo
 echo
sleep $SLEEPER

 echo
 echo
 echo "--------------------------------" 
 echo "Installing git...Please wait..."
 apt-get -y update	
 echo "--------------------------------" 
 apt-get -y install git
 echo "Git installating completed..."
 echo "--------------------------------" 
 echo
 echo
 echo "Please wait..."
sleep $SLEEPER
}





#####################################################
#PHP Composer Intsallation via ubuntu updates
#####################################################
functionComposerSetup () {
 ID=25
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionComposerSetup 				   "
 echo -e "\e[1;31m ############################################### \e[m"

 
 echo "--------------------------------" 
  export COMPOSER_ALLOW_SUPERUSER="1"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "--------------------------------" 
 echo
 echo
 echo
sleep $SLEEPER
 echo
 echo
 echo "--------------------------------" 
 echo "Setting up composer..."
 apt-get -y update	
 echo "--------------------------------" 
 echo
 echo
 echo
sleep $SLEEPER

 ##/opt/bitnami/php/bin/composer.phar self-update
 ##echo "-------------------------------"
 ##cd /var/www/html/
 ##ls -l /var/www/html/
 ##echo "folder is now: [`pwd`] ---> Expected to be in: [/var/www/html/]"
 ##echo "-------------------------------"
 ##echo
 ##echo
 ##echo

sleep $SLEEPER
 echo "-------------------------------"
 cd /var/www/html/blockaptv9	
 ls -l /var/www/html/blockaptv9
 echo "folder is now: [`pwd`] ---> Expected to be in:/var/www/html/blockaptv9"
 echo "Please wait..."
 echo "-------------------------------"
 echo


sleep $SLEEPER

 echo "------------------PHP VERSION---------------"
 /usr/bin/php -v;    /usr/bin/php -v;
 echo "------------------PHP VERSION---------------"
 echo
 echo
 echo
sleep $SLEEPER
 echo "--------------------------------" 
 export COMPOSER_ALLOW_SUPERUSER="1"
 /usr/bin/php -r  "copy('https://getcomposer.org/installer', 'composer-setup.php');"	

 HASH="$(wget -q -O - https://composer.github.io/installer.sig)"	  
 
 /usr/bin/php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
 
 /usr/bin/php composer-setup.php --install-dir=/usr/local/bin --filename=composer
 echo "--------------------------------" 
 echo
 echo
 echo "-----[/usr/bin/php /usr/local/bin/composer -n | grep version]----" 
 /usr/bin/php /usr/local/bin/composer -n | grep version
 echo "--------------------------------" 
 echo "Please wait..."
 echo
 echo
sleep $SLEEPER
 ##echo "----------[php /usr/local/bin/composer update]---------------------"
 ##/usr/bin/php /usr/local/bin/composer -n update	  
 ##echo "----------[php /usr/local/bin/composer update]---------------------"
 echo
 echo
 ##sleep $SLEEPER
 ##echo "----------[php /usr/local/bin/composer upgrade]---------------------"
 ##/usr/bin/php /usr/local/bin/composer -n upgrade	  
 ##echo "----------[php /usr/local/bin/composer upgrade]---------------------"
 echo
 echo
sleep $SLEEPER
 echo
 echo
 echo "Composer setup completed..."
 echo
 echo
 echo "Please wait..."
 echo "--------------------------------" 
sleep $SLEEPER
}




#####################################################
#PHP Modules activation - requires the right PHP Path set
#####################################################
functionLoadPhpModules () {
 ID=14
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionLoadPhpModules 		  	 "
 echo -e "\e[1;31m ############################################### \e[m"

 
 echo "--------------------------------" 
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "--------------------------------" 
 echo
 echo
 echo
sleep $SLEEPER

 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo "--------------------------------" 
 echo "Updating PHP modules libraries...."
 cp /etc/php/8.1/apache2/php.ini	 /etc/php/8.1/apache2/php.ini.BACKUP
 sed -i  's/;extension=mbstring/extension=mbstring/g' /etc/php/8.1/apache2/php.ini	 
 sed -i  's/;extension=soap/extension=soap/g' /etc/php/8.1/apache2/php.ini	 
 sed -i  's/;extension=php_bz2.dll/extension=php_bz2.dll/g' /etc/php/8.1/apache2/php.ini	 
 sed -i  's/;extension=php_curl.dll/extension=php_curl.dll/g' /etc/php/8.1/apache2/php.ini	 
 sed -i  's/;extension=php_mysqli.dll/extension=php_mysqli.dll/g' /etc/php/8.1/apache2/php.ini	 
 sed -i  's/;extension=php_pdo_mysq/extension=php_pdo_mysq/g' /etc/php/8.1/apache2/php.ini	 
 sed -i  's/;extension=php_pdo_sqlite.dll/extension=php_pdo_sqlite.dll/g' /etc/php/8.1/apache2/php.ini	 
 sed -i  's/expose_php = On/expose_php = off/g' /etc/php/8.1/apache2/php.ini	
 sed -i  's/;extension=imagick.so/extension=imagick.so/g' /etc/php/8.1/apache2/php.ini
 echo "extension=mongodb.so" >> /etc/php/8.1/apache2/php.ini
 echo "extension=ldap" >> /etc/php/8.1/apache2/php.ini
 echo "extension=bcmath" >> /etc/php/8.1/apache2/php.ini
 echo "--------------------------------" 
sleep $SLEEPER	
 echo
 echo
 echo "------------------------------PHP modules loaded....------------------------------"
 cat /etc/php/8.1/apache2/php.ini | grep ^extension=
 echo "------------------------------PHP modules loaded....------------------------------"
 echo
 echo
 echo
sleep $SLEEPER
 echo "-------------------PHP MEMORY SETUP-------[/etc/php/${PHP_VERSION}/apache2/php.ini] [/etc/php/8.1/apache2/php.ini]------" 
 sed -i  's/memory_limit = 128M/memory_limit = -1/g' /etc/php/8.1/apache2/php.ini
 sed -i  's/max_execution_time = 300/ max_execution_time = 0/g' /etc/php/8.1/apache2/php.ini
 sed -i  's/memory_limit = 128M/memory_limit = -1/g' /etc/php/${PHP_VERSION}/apache2/php.ini
 sed -i  's/max_execution_time = 300/ max_execution_time = 0/g' /etc/php/${PHP_VERSION}/apache2/php.ini
 sed -i  's/;max_input_vars = 1000/max_input_vars = 5000/g' /etc/php/8.1/apache2/php.ini 
 echo "-------------------PHP MEMORY SETUP-------[/etc/php/${PHP_VERSION}/apache2/php.ini] [/etc/php/8.1/apache2/php.ini]------"
 echo
 echo
 echo
sleep $SLEEPER	
 echo
 echo
 echo "------------------------------PHP modules loaded....[memory_limit & max_execution_time]------------------------------"
 cat /etc/php/8.1/apache2/php.ini | grep memory_limit
 cat /etc/php/8.1/apache2/php.ini | grep max_execution_time
 cat /etc/php/${PHP_VERSION}/apache2/php.ini | grep memory_limit
 cat /etc/php/${PHP_VERSION}/apache2/php.ini| grep max_execution_time
 echo "------------------------------PHP modules loaded....[memory_limit & max_execution_time]------------------------------"
 echo
 echo
 echo "Please wait..."
sleep $SLEEPER
}




#####################################################
#Curl Modules activation - requires the right PHP Path set
#####################################################
functionInstallCurl () {
 ID=10
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 
 echo -e "\e[1;31m ############################################### \e[m"
 echo "       Starting functionInstallCurl 			    "
 echo -e "\e[1;31m ############################################### \e[m"

 
 echo "--------------------------------" 
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "--------------------------------" 
 echo
 echo
 echo
sleep $SLEEPER

 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo 
 echo
 echo "-----------------------------------------"
 echo "Installing curl..."
 apt-get -y update	
 echo "-----------------------------------------"
sleep $SLEEPER
 echo 
 echo
 echo "-----------------------------------------"
 apt-get install -y curl	 
 echo "-----------------------------------------"
sleep $SLEEPER
 echo 
 echo
 echo "-----------------------------------------"
 apt-get install -y gcc g++ make
 echo "-----------------------------------------"
sleep $SLEEPER
 echo 
 echo
 ## To install the Yarn package manager, run:
 echo "-----------------------------------------"
 curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
 echo "-----------------------------------------"
sleep $SLEEPER
 echo 
 echo
 echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
 echo "-----------------------------------------"
 apt-get update -y && apt-get install -y yarn
 echo "-----------------------------------------"
sleep $SLEEPER
 echo 
 echo
 echo "Curl installation completed..."
 echo
 echo
 echo "Please wait..."
sleep $SLEEPER
}





#####################################################
#NodeJS Modules activation - requires the right PHP Path set
#####################################################
functionInstallNodeJS () {
 ID=24
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionInstallNodeJS	    "
 echo -e "\e[1;31m ############################################### \e[m"

 
 echo "--------------------------------" 
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "--------------------------------" 
 echo
 echo
 echo
sleep $SLEEPER

 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo 
 echo "--------------------------------" 
 echo "NodeJS installation started..."
 cd /var/www/html/blockaptv9/icyber_loggers
 apt-get -y update	

sleep $SLEEPER
  echo "--------[running...  apt-get install -y nodejs]------------------------"
  echo 
  echo
  echo "-----------------------------------------"
  #curl -sL https://deb.nodesource.com/setup_10.x | bash -	
  #curl https://deb.nodesource.com/setup_12.x — Node.js 12 LTS "Erbium"
  #curl https://deb.nodesource.com/setup_14.x — Node.js 14 LTS "Fermium" (recommended)
  #curl https://deb.nodesource.com/setup_16.x — Node.js 16 "Gallium"
  #curl -sL https://deb.nodesource.com/setup_14.x | bash -
  ## Run `apt-get install -y nodejs` to install Node.js 10.x and npm
  ## You may also need development tools to build native addons:
  echo "-----------------------------------------"
 sleep $SLEEPER


sleep $SLEEPER
echo "--------------[apt-get install -y nodejs]-----------------------"
#aptitude --download-only install -y nodejs
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y nodejs	
#ls -l /cache/apt/archives/*
echo "------------[ apt-get -y install  node-gyp]-------------------------"
#aptitude --download-only install -y node-gyp
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y node-gyp
echo "-------------114a-----------------"

echo "----------67--------------------"
apt-get -y update	
echo "-----------68-------------------"
echo
echo
echo
 echo 
 echo
 echo "----------[ nodejs --version]--------------------"
 cd /var/www/html/blockaptv9/icyber_loggers
 nodejs --version
 echo "----------[ nodejs --version]------------------"
 
 echo "----------[node --version]---------------------"
 node --version
 echo "----------[node --version]--------------------"
 
 echo "----------[ npm -v]--------------------"
 npm -v
 echo "----------[ npm -v]--------------------"
sleep $SLEEPER
 echo 
 echo
 echo "Please wait..."
sleep $SLEEPER
}




#####################################################
#MondoDB Modules STARIC activation - requires the right PHP Path set
#systemctl restart mongod; systemctl status mongod; systemctl status mongod;
#mongod --version; systemctl restart mongod; systemctl status mongod;
#systemctl status mongod; mongod --version;
#####################################################

functionStaticInstallMongoDB () {

 ID=20a
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo

 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionStaticInstallMongoDB	  	            	   "
 echo -e "\e[1;31m ############################################### \e[m"

echo "--------------------------------" 
echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
echo "--------------------------------" 
echo
echo 
echo  
echo "--------------------UBUNTU VARIABLE SETUP-----------------------------"
echo "MONGOD_VERSION=$MONGOD_VERSION"
echo "MONGOD_VERSION_REPO=$MONGOD_VERSION_REPO"
echo "MONGOD_VERSION_DB=$MONGOD_VERSION_DB"
echo "MONGO_VERSION=$MONGO_VERSION"
echo "UBUNTU_MONGO_CLI_KEYWORD=$UBUNTU_MONGO_CLI_KEYWORD"
echo "UBUNTU_MONGO_CODENAME_CLI=$UBUNTU_MONGO_CODENAME_CLI"
echo "UBUNTU_MONGO_LSB=$UBUNTU_MONGO_LSB"
echo "SLEEPER=$SLEEPER"
echo "UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR=$UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR"
echo "UBUNTU_MONGO_LSB_CODENAME_FOCAL_NBR=$UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR"
echo "--------------------UBUNTU VARIABLE SETUP-----------------------------"
echo "Press a key to continue..."
read -r JUST_PAUSE
sleep $SLEEPER
echo 
echo 


 if [ $UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR -ge 1 ]; then
    echo "--------------------UBUNTU VARIABLE SETUP [bionic]-----------------------------"
    echo "bionic: UBUNTU_MONGO_LSB=$UBUNTU_MONGO_LSB"
    echo "bionic: UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR=$UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR"
    echo "bionic: UBUNTU_MONGO_CLI_KEYWORD=$UBUNTU_MONGO_CLI_KEYWORD"
    echo "bionic: UBUNTU_MONGO_CODENAME_CLI=$UBUNTU_MONGO_CODENAME_CLI"
    echo "--------------------UBUNTU VARIABLE SETUP [bionic]-----------------------------"
    echo "Press a key to continue..."
    read -r JUST_PAUSE
    echo 
    echo 
    echo "--------------------Starting Static Installation [bionic]-----------------------------"
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
    apt-get install gnupg -y
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc |  apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/6.0 multiverse" |  tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    apt-get update -y
    apt-get install -y mongodb-org
    echo "mongodb-org hold" |  dpkg --set-selections
    echo "mongodb-org-database hold" |  dpkg --set-selections
    echo "mongodb-org-server hold" |  dpkg --set-selections
    echo "mongodb-mongosh hold" |  dpkg --set-selections
    echo "mongodb-org-mongos hold" |  dpkg --set-selections
    echo "mongodb-org-tools hold" |  dpkg --set-selections
    mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log --replSet rs0 --bind_ip localhost,localhost.local &
    echo "--------------------Completed Static Installation [bionic]-----------------------------"

 else
    echo "--------------------UBUNTU VARIABLE SETUP [focal]-----------------------------"
    echo "focal: UBUNTU_MONGO_LSB=$UBUNTU_MONGO_LSB"
    echo "focal: UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR=$UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR"
    echo "focal: UBUNTU_MONGO_CLI_KEYWORD=$UBUNTU_MONGO_CLI_KEYWORD"
    echo "focal: UBUNTU_MONGO_CODENAME_CLI=$UBUNTU_MONGO_CODENAME_CLI"
    echo "--------------------UBUNTU VARIABLE SETUP [focal]-----------------------------"
    echo "Press a key to continue..."
    read -r JUST_PAUSE

    echo 
    echo "--------------------Starting Static Installation----[focal]-------------------------"
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
    apt-get install gnupg -y
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc |  apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" |  tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    apt-get update -y
    apt-get install -y mongodb-org
    echo "mongodb-org hold" |  dpkg --set-selections
    echo "mongodb-org-database hold" |  dpkg --set-selections
    echo "mongodb-org-server hold" |  dpkg --set-selections
    echo "mongodb-mongosh hold" |  dpkg --set-selections
    echo "mongodb-org-mongos hold" |  dpkg --set-selections
    echo "mongodb-org-tools hold" |  dpkg --set-selections
    mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log --replSet rs0 --bind_ip localhost,localhost.local &
   
    echo "--------------------Completed Static Installation -[focal]-----------------------------"
 fi
 echo 
 echo
 echo "Please wait..."
sleep $SLEEPER
}




#####################################################
#MondoDB Modules activation - requires the right PHP Path set
#systemctl restart mongod; systemctl status mongod; systemctl status mongod;
#mongod --version; systemctl restart mongod; systemctl status mongod;
#systemctl status mongod; mongod --version;
#####################################################
functionInstallMongoDB () {
 ID=20
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo

 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionInstallMongoDB	  	            	   "
 echo -e "\e[1;31m ############################################### \e[m"

 echo "--------------------------------" 
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "--------------------------------" 
 echo
 echo
 echo
echo 
echo  
echo "--------------------UBUNTU VARIABLE SETUP-----------------------------"
echo "MONGOD_VERSION=$MONGOD_VERSION"
echo "MONGOD_VERSION_REPO=$MONGOD_VERSION_REPO"
echo "MONGOD_VERSION_DB=$MONGOD_VERSION_DB"
echo "MONGO_VERSION=$MONGO_VERSION"
echo "UBUNTU_MONGO_CLI_KEYWORD=$UBUNTU_MONGO_CLI_KEYWORD"
echo "UBUNTU_MONGO_CODENAME_CLI=$UBUNTU_MONGO_CODENAME_CLI"
echo "UBUNTU_MONGO_LSB=$UBUNTU_MONGO_LSB"
echo "--------------------UBUNTU VARIABLE SETUP-----------------------------"
echo "Press a key to continue..."
read -r JUST_PAUSE
sleep $SLEEPER
echo 
echo 

 echo
 echo
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo "-----------[ apt-get purge mongodb-org* -y]---------------------" 
 apt-get remove mongodb-org -y
 apt-get remove mongodb -y
 apt-get remove mongo -y 
 apt-get -y purge mongo
 apt-get -y purge mongodb
 apt-get -y purge mongo*
 apt-get -y purge mongodb*
 apt-get -y purge mongod*
 echo "-----------[ apt-get purge mongodb-org* -y]---------------------" 
 echo
 echo
 sleep $SLEEPER
 echo "----------[Removing old version if any...rm /tmp/mongodb-27017.sock;] [mongod --version] [systemctl status mongod] [systemctl start mongod] [systemctl status mongod]----------------------" 
 systemctl stop mongod
 rm -vf /tmp/mongodb-27017.sock  
 ###sudo kill -9 $(ps ax | grep mongo | fgrep -v grep | awk '{ print $1 }')
 rm -vf /var/lib/mongodb/mongod.lock 
 rm -rfv /var/log/mongodb
 rm -rfv /var/lib/mongodb
 echo "----------[Removing old version if any...rm /tmp/mongodb-27017.sock;] [mongod --version] [systemctl status mongod] [systemctl start mongod] [systemctl status mongod]----------------------" 
 echo
 echo
 echo "----------------[libcurl3][libcurl4]----------------" 
 apt-get install libcurl3 -y
 apt-get install libcurl4 -y
 echo "----------------[libcurl3][libcurl4]----------------" 
 sleep $SLEEPER
 echo
 echo
 echo "--------Doing apt-get install gnupg------------------------" 
 apt-get install -y gnupg
 apt-get install wget -y
 apt-get install gnupg -y
 apt-get install curl -y
 echo "--------Doing apt-get install gnupg------------------------" 
 sleep $SLEEPER
 echo
 echo
 ###apt-get -y update
 echo "--------------------------------" 
 
 echo "---------[systemctl stop mongod] [systemctl status mongod ] [mongod --version - ERROR EXPECTED]----------------------" 
 systemctl stop mongod
 systemctl status mongod 
 mongod --version
 echo "---------[systemctl stop mongod] [systemctl status mongod ] [mongod --version - ERROR EXPECTED]----------------------" 
 sleep $SLEEPER
 echo
 echo
 echo "-----------[ systemctl stop mongod & chmod  -R 775 /var/lib/mongodb]-----[1]--------------" 
 mkdir -p /var/log/mongodb/
 mkdir -p /var/lib/mongodb
 touch /var/log/mongodb/mongod.log
 echo "" >> /var/log/mongodb/mongod.log
 echo "-----------[ systemctl stop mongod & chmod  -R 775 /var/lib/mongodb]-----[1]--------------" 
 sleep $SLEEPER
 echo
 echo
  echo "-----------[ chmod  -R 775 /var/lib/mongodb]-----[2]--------------"
 chown -R mongodb /var/log/mongodb/
 chown -R mongodb /var/lib/mongodb/
 chgrp -R mongodb /var/log/mongodb/
 chgrp -R mongodb /var/lib/mongodb/
 chmod -R 775 /var/lib/mongodb
 chmod -R 775 /var/log/mongodb/mongod.log
 echo "-----------[ chmod  -R 775 /var/lib/mongodb]---------[2]-----------"
 sleep $SLEEPER
 echo
 echo
###sudo service mongod stop
###sudo rm /var/lib/mongodb/mongod.lock
###sudo mongod --repair
###sudo mongod --fork --logpath /var/lib/mongodb/mongodb.log --dbpath /var/lib/mongodb --replSet rs0
###sudo service mongod start
###mongo --eval "rs.initiate()"
 sleep $SLEEPER
 echo
 echo
 echo

 if [ $UBUNTU_MONGO_LSB -ge 1 ]; then
        echo
        echo
        echo "---------------------------------[cat /etc/apt/sources.list] [ UBUNTU_MONGO_CODENAME=$UBUNTU_MONGO_CODENAME]-----------------"
        cat /etc/apt/sources.list | grep $UBUNTU_MONGO_CODENAME
        echo "---------------------------------[cat /etc/apt/sources.list]-----------------"
        sleep $SLEEPER
        echo
        echo
        echo "--------------------------------"
        echo "[$UBUNTU_MONGO_CODENAME] - Version for MongoDB expected for [MONGOD_VERSION_DB=$MONGOD_VERSION_DB]<>[{MONGOD_VERSION_REPO}=${MONGOD_VERSION_REPO}]<>[UBUNTU_MONGO_CODENAME=$UBUNTU_MONGO_CODENAME]<>[UBUNTU_MONGO_LSB=$UBUNTU_MONGO_LSB]<>[UBUNTU_MONGO_CODENAME_CLI=$UBUNTU_MONGO_CODENAME_CLI]"
        echo "--------------------------------"
        echo
        echo
        sleep $SLEEPER
        echo "--------------------------------"
        echo "deb http://security.ubuntu.com/ubuntu ${UBUNTU_MONGO_CODENAME}-security main" >> /etc/apt/sources.list
        echo "--------------------------------"
        echo
        echo
        sleep $SLEEPER
        echo "-----------   apt-get -y update---------------------"
        apt-get -y update
        echo "------------   apt-get -y update--------------------"
        sleep $SLEEPER
        echo
        echo
        echo "--------------------------------"
       # wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add -
       # apt-get -y update
       # echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu ${UBUNTU_MONGO_CODENAME}/mongodb-org/4.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.2.list
       # apt-get -y update
       # apt-get install -y mongodb-org=4.2.8 mongodb-org-server=4.2.8 mongodb-org-shell=4.2.8 mongodb-org-mongos=4.2.8 mongodb-org-tools=4.2.8
       # apt-get -y update
        echo "--------------------------------" 
        echo
        echo
        sleep $SLEEPER

        # echo "---------MANUAL INSTALL COMMANDS-----------------------"
        # wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add -
        # echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu ${UBUNTU_MONGO_CODENAME}/mongodb-org/4.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.2.list
        # apt-get install -y mongodb-org=4.2.8 mongodb-org-server=4.2.8 mongodb-org-shell=4.2.8 mongodb-org-mongos=4.2.8 mongodb-org-tools=4.2.8
        # echo "---------MANUAL INSTALL COMMANDS-----------------------"
       echo "-----------------[apt-get install -y mongodb-org=${MONGOD_VERSION_REPO} - START]---------------"
        echo "------Doing wget -qO - https://www.mongodb.org/static/pgp/server-${MONGOD_VERSION_REPO}.asc | apt-key add ---------"
        # wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add -
         wget -qO - https://www.mongodb.org/static/pgp/server-${MONGOD_VERSION_REPO}.asc | apt-key add -
        echo "------Doing wget -qO - https://www.mongodb.org/static/pgp/server-${MONGOD_VERSION_REPO}.asc | apt-key add ---------"
        sleep $SLEEPER
        echo
        echo
        echo "-----------   apt-get -y update---------------------"
        apt-get -y update
        echo "------------   apt-get -y update--------------------"
        sleep $SLEEPER
        echo
        echo

        echo "------------deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu ${UBUNTU_MONGO_CODENAME}/mongodb-org/${MONGOD_VERSION_REPO} multiverse > /etc/apt/sources.list.d/mongodb-org-${MONGOD_VERSION_REPO}.list--------------------"
        # echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu ${UBUNTU_MONGO_CODENAME}/mongodb-org/4.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.2.list
         echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu ${UBUNTU_MONGO_CODENAME}/mongodb-org/${MONGOD_VERSION_REPO} multiverse" > /etc/apt/sources.list.d/mongodb-org-${MONGOD_VERSION_REPO}.list
        echo "------------deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu ${UBUNTU_MONGO_CODENAME}/mongodb-org/${MONGOD_VERSION_REPO} multiverse > /etc/apt/sources.list.d/mongodb-org-${MONGOD_VERSION_REPO}.list--------------------"
        sleep $SLEEPER
        echo
        echo
        echo "-----------apt-get -y update---------------------"
        apt-get -y update
        echo "------------apt-get -y update--------------------"
        sleep $SLEEPER  
        echo
        echo

        echo "-------[ mongodb-org=$MONGOD_VERSION_DB mongodb-org-server=$MONGOD_VERSION_DB mongodb-org-shell=$MONGOD_VERSION_DB mongodb-org-mongos=$MONGOD_VERSION_DB mongodb-org-tools=$MONGOD_VERSION_DB]-------"
        # apt-get install -y mongodb-org=4.2.8 mongodb-org-server=4.2.8 mongodb-org-shell=4.2.8 mongodb-org-mongos=4.2.8 mongodb-org-tools=4.2.8
        apt-get install -y mongodb-org=$MONGOD_VERSION_DB mongodb-org-server=$MONGOD_VERSION_DB mongodb-org-shell=$MONGOD_VERSION_DB mongodb-org-mongos=$MONGOD_VERSION_DB mongodb-org-tools=$MONGOD_VERSION_DB
        echo "-------[ mongodb-org=$MONGOD_VERSION_DB mongodb-org-server=$MONGOD_VERSION_DB mongodb-org-shell=$MONGOD_VERSION_DB mongodb-org-mongos=$MONGOD_VERSION_DB mongodb-org-tools=$MONGOD_VERSION_DB]-------"
        sleep $SLEEPER  
        echo
        echo      
    
        echo "-----------apt-get -y update---------------------"
        apt-get -y update
        echo "------------apt-get -y update--------------------"
        sleep $SLEEPER  
        echo
        echo    

        echo "-------------163x-----[   systemctl enable mongod]------------"
        systemctl enable mongod
        echo "-------------163x-----[   systemctl enable mongod]------------"
        echo
        echo
        sleep $SLEEPER
        echo "-------------[ chmod  -R 775 /var/lib/mongodb]-------------------" 
        mkdir -p /var/log/mongodb/
        mkdir -p /var/lib/mongodb
        touch /var/log/mongodb/mongod.log
        echo >> /var/log/mongodb/mongod.log
        echo "-------------[ chmod  -R 775 /var/lib/mongodb]-------------------" 
        chown -R mongodb /var/log/mongodb/
        chown -R mongodb /var/lib/mongodb/
        chgrp -R mongodb /var/log/mongodb/
        chgrp -R mongodb /var/lib/mongodb/
        chmod -R 775 /var/lib/mongodb
        chmod -R 775 /var/log/mongodb/mongod.log
        echo "-------------[ chmod  -R 775 /var/lib/mongodb]-------------------"
        echo
        echo
        echo
        echo "-----------------[apt-get install -y mongodb-org=${MONGOD_VERSION_REPO} - END]---------------"
        sleep $SLEEPER
        echo
        echo
        echo "-----------apt-get -y update---------------------"
        apt-get -y update
        echo "------------apt-get -y update--------------------"
        sleep $SLEEPER  
        echo
        echo  

       sleep $SLEEPER
       echo "-------------163y [systemctl start mongod]-----------------" 
       sudo kill -9 $(ps ax | grep mongo | fgrep -v grep | awk '{ print $1 }')
       systemctl stop mongod
       rm -vf /tmp/mongodb-27017.sock  
       systemctl stop mongod
       systemctl start mongod
       echo "-------------163y [systemctl start]-----------------"
       echo
       echo
       echo
       sleep $SLEEPER
       echo "-------------163z- [  systemctl daemon-reload ]----------------"
       systemctl daemon-reload 
       echo "-------------163z- [  systemctl daemon-reload ]----------------"
       echo
       echo
       echo
       sleep $SLEEPER
       echo "-------------163z1----[systemctl stop mongod]-------------"
       systemctl stop mongod
       echo "-------------163z1----[systemctl stop mongod]-------------"
       echo
       echo
       echo
       sleep $SLEEPER
       echo "-------------163x1-------[  systemctl restart mongod]----------"
       rm -f /tmp/mongodb-27017.sock
       systemctl restart mongod
       echo "-------------163x1-------[  systemctl restart mongod]----------"
       echo
       echo
       echo
       sleep $SLEEPER
       echo "-------------163x2-----[ps -ef | grep mongo |grep conf]------------" 
       ps -ef | grep mongo 
       netstat -nape | grep mongo | grep :27017
       echo "-------------163x2------[/usr/bin/mongod --config /etc/mongod.conf]--------"
       echo
       echo
       echo
       echo "-------------163x3--[Start CLI mongosh]------------"
       /usr/bin/mongod --config /etc/mongod.conf &
       ps -ef | grep mongod  | grep config
       echo "-------------163x3--[Start CLI mongosh]------------"
       echo
       echo
       echo
       sleep $SLEEPER
       echo "-------------163x3--[ systemctl status mongod]---------------"
       systemctl status mongod
       echo "-------------163x3--[ systemctl status mongod]---------------"
       echo
       echo
       echo
       echo "Press a key to continue...."
       read -r JUST_PAUSE
       sleep $SLEEPER
 
 else 

      echo "-----------------163x5--------------"
      echo -e "\e[1;37m[\e[m\e[1;31mERROR - HOUSTON WE HAVE A MONGO PROBLEM! FIRST ATTEMPT  - \e[m\e[1;37m]\e[m OS FOR MONGO NOT = [$UBUNTU_MONGO_LSB] [$UBUNTU_MONGO_CODENAME] \e[1;37m[\e[m\e[1;31mNOT\e[m\e[1;37m]\e[m"  
      sleep $SLEEPER
      echo
      echo
      echo
      echo "Current [MongoDB $MONGO_VERSION][MONGO_VERSION_CLI=$MONGO_VERSION_CLI] NOT installed & compatible [MONGO_VERSION=$MONGO_VERSION]"
      echo -e "Please wait...\e[1;37m[\e[m\e[1;31mCANNOT\e[m\e[1;37m]\e[m continue...make sure OS version is at least [$UBUNTU_MONGO_LSB][$UBUNTU_MONGO_CODENAME]... will exit in [$SLEEPER] seconds"
      echo
      echo
      echo
      echo "Press a key to continue....will try static install with [functionStaticInstallMongoDB]..."
      read -r JUST_PAUSE
      sleep $SLEEPER
      echo
      echo
      ####functionInstallMongoDB
      functionStaticInstallMongoDB
      read -r JUST_PAUSE
      sleep $SLEEPER

      echo "-----------------163x5a--------------"
      echo -e "\e[1;37m[\e[m\e[1;31mERROR - HOUSTON WE HAVE A MONGO PROBLEM! SECOND ATTEMPT - \e[m\e[1;37m]\e[m OS FOR MONGO NOT = [$UBUNTU_MONGO_LSB] [$UBUNTU_MONGO_CODENAME] \e[1;37m[\e[m\e[1;31mNOT\e[m\e[1;37m]\e[m"  
      echo
      echo "Press a key to continue....will try static install with [functionStaticInstallMongoDB]..."
      sleep $SLEEPER
      read -r JUST_PAUSE
      sleep $SLEEPER
      ####functionCleanUpOnExit
     functionStaticInstallMongoDB

 fi


 ####Make sure Mongo is healthly and at the right version
 MONGO_VERSION_CLI=`mongod --version | grep version | grep -i db | grep $MONGO_VERSION | wc -l`
 if [ $MONGO_VERSION_CLI -ge 1 ]; then
       echo -e "\e[1;37m[\e[m\e[1;32mOK\e[m\e[1;37m]\e[m - MONGO_VERSION_CLI OK = [$MONGO_VERSION_CLI][$MONGO_VERSION][$UBUNTU_MONGO_CODENAME]"
       sleep $SLEEPER
       echo "-------------163x5 [systemctl start mongod]-----------------" 
       rm -vf /tmp/mongodb-27017.sock  
       sudo kill -9 $(ps ax | grep mongo | fgrep -v grep | awk '{ print $1 }')
       systemctl stop mongod
       systemctl start mongod
       echo "-------------163x6 [systemctl start]-----------------"
       echo
       echo
       echo
       sleep $SLEEPER
       echo "-------------163x7- [  systemctl daemon-reload ]----------------"
       systemctl daemon-reload 
       echo "-------------163x7- [  systemctl daemon-reload ]----------------"
       echo
       echo
       echo
       sleep $SLEEPER
       echo "-------------163x8----[systemctl stop mongod]-------------"
       systemctl stop mongod
       echo "-------------163x8----[systemctl stop mongod]-------------"
       echo
       echo
       echo
       sleep $SLEEPER
       echo "-------------163x9-------[  systemctl restart mongod]----------"
       rm -f /tmp/mongodb-27017.sock
       systemctl restart mongod
       echo "-------------163x9-------[  systemctl restart mongod]----------"
       echo
       echo
       echo
       sleep $SLEEPER
       echo "-------------163x10-----[ps -ef | grep mongo |grep conf]------------" 
       ps -ef | grep mongo 
       netstat -nape | grep mongo | grep :27017
       echo "-------------163x10-----[ps -ef | grep mongo |grep conf]------------" 
       echo
       echo
       echo
       echo "-------------163x10------[/usr/bin/mongod --config /etc/mongod.conf]--------"
       /usr/bin/mongod --config /etc/mongod.conf &
       ps -ef | grep mongod  | grep config
       echo "-------------163x10---------------------"
       echo
       echo
       echo
       sleep $SLEEPER
       echo "-------------163x11--[ systemctl status mongod]---------------"
       systemctl status mongod
       echo "-------------163x11--[ systemctl status mongod]---------------"
       echo
       echo
       echo
       echo "-------------------------------------------------"
       echo -e "\e[1;37m[\e[m\e[1;32mMONGO - OK - SUCCESS\e[m\e[1;37m]\e[m [163x12--[CLI mongo Installed]]"
       mongod --version
       echo -e "\e[1;37m[\e[m\e[1;32mMONGO - OK - SUCCESS\e[m\e[1;37m]\e[m [163x12--[CLI mongo Installed]]"
   
       echo "Press a key to continue...."
       read -r JUST_PAUSE
       sleep $SLEEPER
 
 else
      echo "-------------------------------"
      echo -e "\e[1;37m[\e[m\e[1;31mERROR - HOUSTON WE HAVE A MONGO PROBLEM! - \e[m\e[1;37m]\e[m MONGO_VERSION_CLI is NOT =[$MONGO_VERSION_CLI][$MONGO_VERSION][$UBUNTU_MONGO_CODENAME] \e[1;37m[\e[m\e[1;31mNOT\e[m\e[1;37m]\e[m"  
      sleep $SLEEPER
      echo
      echo
      echo
      echo "Current [MongoDB $MONGO_VERSION][MONGO_VERSION_CLI=$MONGO_VERSION_CLI] NOT installed & NOT compatible with [MONGO_VERSION=$MONGO_VERSION]"
      echo -e "Please wait...\e[1;37m[\e[m\e[1;31m[CANNOT]\e[m\e[1;37m]\e[m continue...make sure mongoDB version is at least [$MONGO_VERSION]... will exit in [$SLEEPER] seconds"
      echo "-------------------------------"
      sleep $SLEEPER
      echo "Press a key to continue....will try static install with [functionStaticInstallMongoDB]..."
      read -r JUST_PAUSE
      functionStaticInstallMongoDB
      ##functionCleanUpOnExit

 fi
}



#####################################################
# Install Moogose and related services
# npm install -g express@latest
# npm install -g express@latest
#####################################################
functionInstallMongooseAndOthers () {
 ID=31.1
        echo "-------------------------------"
        echo "Current [MongoDB $MONGO_VERSION][MONGO_VERSION_CLI=$MONGO_VERSION_CLI][MONGO_VERSION=$MONGO_VERSION]"
        echo "-----------[   npm install -g express@latest] [functionInstallMongooseAndOthers]---------------------"

        echo "------------[functionCreateiCSDir]----------------------"
        functionCreateiCSDir
        echo "------------[functionCreateiCSDir]----------------------"

        echo "------------[apt-get install -y build-essential python]--------------------"
        cd /var/www/html/blockaptv9/icyber_loggers
        apt-get install g++
        sleep $SLEEPER        
        echo "------------[apt-get install -y build-essential python]--------------------"
        apt-get install -y build-essential python
        apt-get install python -y
        sleep $SLEEPER         
        echo "------------[npm install --unsafe-perm --allow-root]--------------------"
        npm install --unsafe-perm --allow-root
        sleep $SLEEPER                 
        echo "------------[npm install -g node-gyp]--------------------"
        npm install -g node-gyp
        sleep $SLEEPER  
        echo "--------------[npm install -g node-gyp]------------------"
        
        echo "--------------------------------"
        cd /var/www/html/blockaptv9/icyber_loggers
        echo "----------------[ cd /var/www/html/blockaptv9/icyber_loggers]- [ npm i --package-lock-only]---------------"
        mv /var/www/html/blockaptv9/icyber_loggers/package-lock.json /var/www/html/blockaptv9/icyber_loggers/package-lock.json.OLD
        npm i --package-lock-only
        echo "---------------[mv /var/www/html/blockaptv9/icyber_loggers/package-lock.json]--[npm audit fix]---[npm audit fix --force]------------"
        npm audit fix
        cd /var/www/html/blockaptv9/icyber_loggers
        npm audit fix --force
        npm install -g express@latest
        npm install express@latest
        echo "-------------[ npm audit fix]--[ npm install express@latest]---[npm install -g express@latest]--------------"
        echo "--------------------------------"
        sleep $SLEEPER
        echo 
        echo
        echo "-----------[   sudo  npm install -g mongoose@latest] [functionInstallMongooseAndOthers]---------------------"
        cd /var/www/html/blockaptv9/icyber_loggers
        npm install -g mongoose@latest
        npm install mongoose@latest
        echo "--------------------------------"
        ###echo "------------[functionStartMongoDB]--------------------"
        ###functionStartMongoDB
        sleep $SLEEPER
        echo "--------------------------------"
        echo   
}




#####################################################
#MondoDB Startup script - force it to start properly
#rm /tmp/mongodb-27017.sock; 
#systemctl restart mongod; systemctl status mongod; systemctl status mongod;
#mongod --version; systemctl restart mongod; systemctl status mongod;
#systemctl status mongod; mongod --version;
#####################################################
functionStartMongoDB () {
 ID=30
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo "------------[functionCreateiCSDir]----------------------"
 functionCreateiCSDir
  echo "------------[functionCreateiCSDir]----------------------"
 echo
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionStartMongoDB	  		   "
 echo -e "\e[1;31m ############################################### \e[m"
 echo
 echo
 
 echo "-------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------------------"
 echo
 echo
 echo
 sleep $SLEEPER

 echo "MongoDB services testing & starting... after install OK. systemctl stop mongod; systemctl status mongod; mongod --version; ...Please wait..."
 systemctl stop mongod
 rm -vf /tmp/mongodb-27017.sock 
 systemctl stop mongod
 systemctl status mongod
 ###sudo kill -9 $(ps ax | grep mongo | fgrep -v grep | awk '{ print $1 }')
 echo "-------------remove lock sock--------" 
 echo
 echo
 echo
 echo "-----------systemctl restart mongod--------[EXPECTED OK STATUS]--------------" 
 rm -f /tmp/mongodb-27017.sock
 systemctl restart mongod
 sleep $SLEEPER
 echo "----------systemctl restart mongod----------------------" 
 echo
 echo "------------- mongod --version -------[EXPECTED OK STATUS]-----------" 
 mongod --version 
 sleep $SLEEPER
 echo "------------- mongod --version -----------------"
 echo
 echo "----------- systemctl status mongod---[EXPECTED OK STATUS]------------------" 
 systemctl status mongod 
 sleep $SLEEPER
 echo "----------- systemctl status mongod---------------------"
 echo
 echo "----------systemctl start mongod----------------------" 
 echo
 echo "-----------systemctl restart mongod--------[EXPECTED OK STATUS]--------------" 
 systemctl start mongod
 sleep $SLEEPER
 echo "----------systemctl restart mongod----------------------" 
 echo
 echo "----------- systemctl status mongod---[EXPECTED OK STATUS]------------------" 
 systemctl status mongod 
 sleep $SLEEPER
 echo "----------- systemctl status mongod---------------------"
 echo
 echo "---------- systemctl status mongod-------------------" 
 echo
 sleep $SLEEPER

 MONGO_VERSION_CLI=`mongod --version | grep version | grep -i db | grep $MONGO_VERSION | wc -l`
 if [ $MONGO_VERSION_CLI -ge 1 ]; then
    echo "-------------------------------"
    echo "Current [MongoDB $MONGO_VERSION][MONGO_VERSION_CLI=$MONGO_VERSION_CLI] successfully installed & compatible [MONGO_VERSION=$MONGO_VERSION]"
   sleep $SLEEPER
    echo "-----------ENTERING... [functionInstallMongooseAndOthers][   sudo  npm install -g mongoose@latest] [functionInstallMongooseAndOthers]--------------------"
    echo "[functionStartMongoDB] - MongoDB All Set. OK to continue. [Press a key for the next step]... "
    read JUST_PAUSE
    ###functionInstallMongooseAndOthers
    echo "--------------------------------"
 else
    echo "-------------------------------"
    echo "Current [MongoDB $MONGO_VERSION][MONGO_VERSION_CLI=$MONGO_VERSION_CLI] NOT installed & compatible [MONGO_VERSION=$MONGO_VERSION]"
    echo "Please wait...\e[1;37m[\e[m\e[1;31m[CANNOT]\e[m\e[1;37m]\e[m continue...make sure mongoDB version is at least [$MONGO_VERSION]... will exit in [$SLEEPER] seconds"
    echo "-------------------------------"
    echo "[functionStartMongoDB] - You may encounter MongoDB Dabases issues later due to this installation failure. Continue only if you know what you are doing. [Press a key to continue]... "
    read JUST_PAUSE
    sleep $SLEEPER
    functionCleanUpOnExit
 fi
}








#####################################################
#PM2 & NPM Modules activation - requires the right PHP Path set
#####################################################
functionInstallPm2NpmNode () {
 ID=21

#####################################################
# TESTED VERSIONS - WORKS OK - 12/09/2021
#####################################################

#node -v; nodejs -v; npm -v; pm2 -v; nvm -v
#NODE_VERSION="14.17.6"
#NODEJS_VERSION="14.17.6"
#NPM_VERSION="7.20.1"
#PM2_VERSION="5.1.1"
#NVM_VERSION="0.38.0"

echo "---------------@start: functionInstallPm2NpmNode-----114a [node -v; nodejs -v; npm -v;  nvm -v] EXPECTED FAILURE-----------------"
node -v; nodejs -v; npm -v; nvm -v;  mongod --version 
echo "---------------------------114a [node -v; nodejs -v; npm -v;  nvm -v]-----------------"

 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 echo -e "\e[1;31""m ############################################### \e[0m"
 echo "        Starting functionInstallPm2NpmNode 	  	   "
 echo -e "\e[1;31""m ############################################### \e[0m"

 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 echo
 echo "--------[mkdir /etc/.pm2] & [chmod  -R 0777 /etc/.pm2] [ ls -l /etc/.pm2]-----------------------"
 mkdir /etc/.pm2	 
 chmod  -R 0777 /etc/.pm2	
 ls -l /etc/.pm2	
 echo "-------------------------------"
 sleep $SLEEPER

 echo "-------------------------------"
 cd /var/www/html/blockaptv9/icyber_loggers
 echo "--------------------------------"
 echo "Folder is now: [ cd /var/www/html/blockaptv9/icyber_loggers]=[`pwd`]"
 echo "--------------------------------"
 sleep $SLEEPER
 
 echo "-------------------------------"
 echo "PM2 & npm &node-gyp installation started..."


echo "-------------114a-----------------"
###sudo apt-get -y purge npm 
###sudo apt-get -y purge pm2 
###sudo apt-get -y purge nvm 
###sudo apt-get -y purge nodejs
###sudo apt-get -y purge node 
echo "-------------114a-----------------"
echo
echo
echo
echo "-------------114b-----------------"
####aptitude --download-only install libnode72 -y
####cp -vr /var/cache/apt/archives/ /cache/apt/archives/
####ls -l /cache/apt/archives/*
###apt-get install libnode72 -y
####ls -l /cache/apt/archives/*
echo "-------------114b-----------------"
sleep $SLEEPER
echo
echo
echo
echo "-------------114c-----------------"
#aptitude --download-only install -y npm
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y npm
#ls -l /cache/apt/archives/*
echo "-------------114c-----------------"
echo
echo
echo
sleep $SLEEPER
echo "-------------114d-----------------"
#aptitude --download-only install -y pm2
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y pm2
#ls -l /cache/apt/archives/*
echo "-------------114d-----------------"
echo
echo
echo
sleep $SLEEPER
echo "--------------[apt-get install -y nodejs]-----------------------"
#aptitude --download-only install -y nodejs
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y nodejs	
#ls -l /cache/apt/archives/*
echo "------------[ apt-get -y install  node-gyp]-------------------------"
echo
echo
echo
echo "-------------114e-----------------"
sleep $SLEEPER
#aptitude --download-only install -y node-gyp
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y node-gyp
echo "-------------114e-----------------"



echo "-------------114f---[Install NodeJS [functionInstallNodeJS]----------------"
sleep $SLEEPER
 echo 
 echo "-----------------114f---------------" 
 echo "NodeJS installation started..."
 cd /var/www/html/blockaptv9/icyber_loggers
 apt-get -y update	
  echo 
  echo
  echo "----------------114g-------------------------"
  #curl -sL https://deb.nodesource.com/setup_10.x | bash -	
  #curl https://deb.nodesource.com/setup_12.x — Node.js 12 LTS "Erbium"
  #curl https://deb.nodesource.com/setup_14.x — Node.js 14 LTS "Fermium" (recommended)
  #curl https://deb.nodesource.com/setup_16.x — Node.js 16 "Gallium"
  #curl -sL https://deb.nodesource.com/setup_14.x | bash -
  ## Run `apt-get install -y nodejs` to install Node.js 10.x and npm
  ## You may also need development tools to build native addons:
  echo "--------------114g---------------------------"
 sleep $SLEEPER


 echo "----------[ node -v; nodejs -v; npm -v; pm2 -v; nvm -v]--------------------"
cd /var/www/html/blockaptv9/icyber_loggers
#npm install -g npm@7.20.1
npm install -g pm2@latest
echo "------------------114h-----------------------"
npm audit fix --force
apt-get install -y pm2
node -v; nodejs -v; npm -v; pm2 -v;  n -V
echo "----------[ node -v; nodejs -v; npm -v; pm2 -v; nvm -v]------------------"
echo "Press a key to continue..."
 ##read JUST_PAUSE
echo
echo
echo
echo "-------------114h [installing curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash] -----------------"
cd /var/www/html/blockaptv9/icyber_loggers
apt-get install curl -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 

echo "-------------114e------[n -V]---[POST NVM, PM2, NPM INSTALL]--------"
n -V
echo "-------------114e------[/usr/local/bin/n -V]--[POST NVM, PM2, NPM INSTALL]---------"
/usr/local/bin/n -V
echo "-------------114j----[nvm -v]-------------"
nvm -v
echo "-------------114j-----------------"
echo
echo
echo
echo "-------------114k-----------------"
echo "Press a key to continue..."
#read JUST_PAUSE
echo
echo
echo
echo "-------------114k- [npm install]----------------"
cd /var/www/html/blockaptv9/icyber_loggers
npm install
echo "-------------114l---[n 10.24.1]--------------"
echo "Press a key to continue..."
#read JUST_PAUSE
echo
echo
echo "---------------------------114l [node -v; nodejs -v; npm -v; pm2 -v; nvm -v]-----[POST NVM, PM2, NPM INSTALL]------------"
#NODE_VERSION="14.17.6"
#NODEJS_VERSION="14.17.6"
#NPM_VERSION="7.20.1"
#PM2_VERSION="5.1.1"
#NVM_VERSION="0.38.0"

cd /var/www/html/blockaptv9/icyber_loggers
#apt-get install -y pm2
node -v; nodejs -v; npm -v; pm2 -v;  n -V
echo "------------[expected: v10.24.1 v10.24.1 7.14.0 OR FAILURE SINCE not INSTALLED]------------"
echo "Press a key to continue..."
#read JUST_PAUSE
echo
echo
echo "-------------114m------[npm install -g npm@7.14.0]-----[NODE_VERSION=$NODE_VERSION][NODEJS_VERSION=$NODEJS_VERSION][NPM_VERSION=$NPM_VERSION][NVM_VERSION=$NVM_VERSION][PM2_VERSION=$PM2_VERSION]------"
cd /var/www/html/blockaptv9/icyber_loggers
#npm install -g npm@7.20.1
npm install -g npm@${NPM_VERSION}
npm audit fix --force
echo "-------------114m-------[NODE_VERSION=$NODE_VERSION][NODEJS_VERSION=$NODEJS_VERSION][NPM_VERSION=$NPM_VERSION][NVM_VERSION=$NVM_VERSION][PM2_VERSION=$PM2_VERSION]-------"
echo "Press a key to continue..."
#read JUST_PAUSE
echo
echo
echo "-------------114n------[n 10.24.1]----[NODE_VERSION=$NODE_VERSION][NODEJS_VERSION=$NODEJS_VERSION][NPM_VERSION=$NPM_VERSION][NVM_VERSION=$NVM_VERSION][PM2_VERSION=$PM2_VERSION]-------"
cd /var/www/html/blockaptv9/icyber_loggers
echo "-------------114n----[NODE_VERSION=$NODE_VERSION][NODEJS_VERSION=$NODEJS_VERSION][NPM_VERSION=$NPM_VERSION][NVM_VERSION=$NVM_VERSION][PM2_VERSION=$PM2_VERSION]----------"

#curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
#source ~/.bashrc
#n 14.17.6
#nvm install 14.17.6
#nvm use 14.17.6
#node -v; nodejs -v; npm -v; pm2 -v; nvm -v 

echo "------------Installing [node -v; nodejs -v; npm -v; pm2 -v; nvm -v]---------------------------"
n $NODE_VERSION
/usr/local/bin/n $NODE_VERSION
echo "-----------------[n $NODE_VERSION]---------------------------"
n install $NODE_VERSION
/usr/local/bin/n install $NODE_VERSION
echo "-----------------[n install $NODE_VERSION]-------------------"
nvm install $NODE_VERSION
nvm use $NODE_VERSION
echo "-----------------[nvm use $NODE_VERSION]---------------------"
echo
echo
echo "-------------[node -v; nodejs -v; npm -v; pm2 -v; nvm -v]-----[POST NVM, PM2, NPM INSTALL]---------"
node -v; nodejs -v; npm -v; pm2 -v; nvm -v 
echo "------------[node -v; nodejs -v; npm -v; pm2 -v; nvm -v]---------------"
echo
echo
echo "Press a key to continue..."
#read JUST_PAUSE
echo
echo

#echo "-------------114a--------[apt-get install libnode72 -y]---------"
#dpkg -i /var/cache/apt/archives/nodejs_12.21.0~dfsg-3ubuntu1_amd64.deb
#echo "-------------114a-----------------"
echo
echo
echo
echo "------------[ node -v; nodejs -v; npm -v; pm2 -v; nvm -v]------------"
cd /var/www/html/blockaptv9/icyber_loggers
node -v; nodejs -v; npm -v; pm2 -v;  n -V
echo "------------[expected: v10.24.1 v10.24.1 7.14.0]------------"
echo "Press a key to continue..."
#read JUST_PAUSE
echo 
echo
echo "----------[npm audit fix for fix vulnerabilities]----------------------"
cd /var/www/html/blockaptv9/icyber_loggers
npm audit fix
npm audit fix --force
npm update
echo "--------------------------------"
echo "Press a key to continue..."
#read JUST_PAUSE
echo 
echo
echo "------------[ node -v; nodejs -v; npm -v; pm2 -v; nvm -v]------------"
cd /var/www/html/blockaptv9/icyber_loggers
node -v; nodejs -v; npm -v; pm2 -v;  n -V
echo "------------[expected: v10.24.1 v10.24.1 7.14.0]------------"
echo "Press a key to continue..."
#read JUST_PAUSE
echo 
echo
sleep $SLEEPER

echo "Computing npm install && npm run dev.  Press a key to continue..."
#read JUST_PAUSE
echo
echo
echo "-----------[ npm install] [ npm install -g pm2@latest]---------------------"
cd /var/www/html/blockaptv9/icyber_loggers
npm install -g pm2@latest	
echo "--------------------------------"
sleep $SLEEPER

echo
echo
echo "-----------[  npm install [cd /var/www/html/blockaptv9/icyber_loggers] ]--------------------"
cd /var/www/html/blockaptv9/icyber_loggers
npm install
echo "--------------------------------"
sleep $SLEEPER
echo 
echo
echo "Computing npm install && npm run dev.  Press a key to continue..."
#read JUST_PAUSE

 ##echo "-----------[   npm install -g npm@latest]---------------------"
 ##cd /var/www/html/blockaptv9/icyber_loggers
 ##npm install -g npm@latest	
 ##echo "--------------------------------"
 ##sleep $SLEEPER
 ##echo 
 ##echo

 echo "-----------[  SME Chat Server Node Instalation Started ]--------------------"
 echo
 echo
 echo "-----------[  npm install [cd /var/www/html/blockaptv9/icyber_loggers/sme_chat_module] ]--------------------"
 cd /var/www/html/blockaptv9/icyber_loggers/sme_chat_module
 npm install
 echo "--------------------------------"
 sleep $SLEEPER
 echo
 echo
 echo "-----------[  SME Chat Server Node Instalation Completed ]--------------------"

 echo "-----------[  Compile React Build Start ]--------------------"
 echo
 echo
 echo "-----------[  npm install && npm run dev] [ cd /var/www/html/blockaptv9]--------------------"
 cd /var/www/html/blockaptv9
 npm install && npm run dev
 echo "--------------------------------"
 sleep $SLEEPER
 echo
 echo
 echo "-----------[  Compile React Build End ]--------------------"
 
 echo "-----------[   npm install -g express@latest]---------------------"
 cd /var/www/html/blockaptv9/icyber_loggers
 npm install -g express@latest
 echo "--------------------------------"
 sleep $SLEEPER
 echo 
 
 echo "----------[ nodejs --version]--------------------"
 cd /var/www/html/blockaptv9/icyber_loggers
 nodejs --version
 echo "----------[ nodejs --version]------------------"
 
 echo "----------[node --version]---------------------"
 node --version
 echo "----------[node --version]--------------------"
 
 echo "----------[ npm -v]--------------------"
 npm -v
 echo "----------[ npm -v]--------------------"
 sleep $SLEEPER

 ###echo "-----------ENTERING... [functionInstallMongooseAndOthers][   sudo  npm install -g mongoose@latest] [functionInstallMongooseAndOthers]--------------------"
 ###echo "Computing functionInstallMongooseAndOthers.  Press a key to continue..."
 ###read JUST_PAUSE
 ###functionInstallMongooseAndOthers
 ###echo "--------------------------------"
 ###sleep $SLEEPER
 echo   
 echo  
 echo
 echo
 echo "----------------[ node -v; nodejs -v; npm -v; pm2 -v;  nvm -V] installation completed----------------" 
 echo   
 echo
 echo "------------- node -v-----[EXPECTED NODE_VERSION=$NODE_VERSION]------------"
 node -v
 echo "------------- nodejs -v----[EXPECTED NODEJS_VERSION=$NODEJS_VERSION]-----------"
 nodejs -v
 echo "--------------- npm -v----[EXPECTED NPM_VERSION=$NPM_VERSION]------------"
 npm -v
 echo "----------------- pm2 -v--[EXPECTED PM2_VERSION=$PM2_VERSION]------------"
 pm2 -v
 echo "----------------[EXPECTED NVM_VERSION=$NVM_VERSION]---------------"
 nvm --version
 echo "--------------- n -V-------[EXPECTED N_VERSION=$NVM_VERSION-----------"
 n -V
 echo "--------------------------------------"
 echo   
 echo "-------------EXPECTED >=------------------"
 echo "  NODE_VERSION=$NODE_VERSION"
 echo "NODEJS_VERSION=$NODEJS_VERSION"
 echo "   NPM_VERSION=$NPM_VERSION"
 echo "   PM2_VERSION=$PM2_VERSION"
 echo "   NVM_VERSION=$NVM_VERSION"
 echo "     N_VERSION=$N_VERSION"
 echo "------------------------------------------"
 echo   
 echo
 echo "Press a key to continue..."
 read -r JUST_PAUSE

}




#####################################################
#PHP Modules Imagick Installation - requires for google 2FA
#####################################################
functionInstallImagick () {
 ID=22
 echo
 echo
	
    echo -e "\e[1;31m ############################################### \e[m"
	echo "        Starting functionInstallImagick 		  	 "
	echo -e "\e[1;31m ############################################### \e[m"


     echo "---------Installing LDAP PHP extension---------------------------------"
     apt-get install php${PHP_VERSION}-ldap -y
    echo "--------completed: Installing LDAP PHP extension----------------------"

	echo "---------Installing Imagick PHP extension---------------------------------"
	apt-get install php${PHP_VERSION}-imagick -y
    #apt-get install php-imagick -y
    echo "--------completed: Installing Imagick PHP extension----------------------"	

	echo "----------Installing Mbstring PHP extension------------------------------"
	apt-get install php${PHP_VERSION}-mbstring -y
    #apt-get install php-mbstring -y
    echo "--------completed: apt-get install php${PHP_VERSION}-mbstring -y---------------"

	echo "--------------Installing Soap PHP extension------------------------------"
	apt-get install php${PHP_VERSION}-soap -y
    #apt-get install php-soap -y
    echo "--------completed: apt-get install php${PHP_VERSION}-soap -y-------------------"
	
	echo "-------------Installing MongoDb PHP extension----------------------------"
	apt-get install php${PHP_VERSION}-mongodb -y
    #apt-get install php-mongodb -y
    echo "--------completed: apt-get install php${PHP_VERSION}-mongodb -y------------------"

	echo "--------[/usr/bin/php -m | grep imagick]---------------------------"
	/usr/bin/php -m | grep imagick
    echo "--------[/usr/bin/php -m | grep imagick]---------------------------"

	echo "-----------------Restarting the bitnami---------------"
 	###/opt/bitnami/ctlscript.sh restart
   echo "---------[ service nginx restart]---------"
   service nginx restart
   echo "------[ service apache2 restart]------------"
   service apache2 restart
   echo "------[ service apache2 restart]------------"
   echo
   echo "-------------------completed: ------------------------"
 	 
	echo "Please wait..."
	echo
	echo
	echo
	sleep $SLEEPER
	echo "Imagick Installed Successfully"
}




#####################################################
#PHP Modules Imagick Installation - requires for google 2FA
#####################################################
functionInstallImagick () {
 ID=22
 echo
 echo
	
    echo -e "\e[1;31m ############################################### \e[m"
	echo "        Starting functionLoadPhpModules 		  	 "
	echo -e "\e[1;31m ############################################### \e[m"


     echo "---------Installing LDAP PHP extension---------------------------------"
     apt-get install php${PHP_VERSION}-ldap -y
    echo "--------completed: Installing LDAP PHP extension----------------------"

	echo "---------Installing Imagick PHP extension---------------------------------"
	apt-get install php${PHP_VERSION}-imagick -y
    echo "--------completed: Installing Imagick PHP extension----------------------"	

	echo "----------Installing Mbstring PHP extension------------------------------"
	apt-get install php${PHP_VERSION}-mbstring -y
    echo "--------completed: apt-get install php${PHP_VERSION}-mbstring -y---------------"

	echo "--------------Installing Soap PHP extension------------------------------"
	apt-get install php${PHP_VERSION}-soap -y
    echo "--------completed: apt-get install php${PHP_VERSION}-soap -y-------------------"
	
	echo "-------------Installing MongoDb PHP extension----------------------------"
	apt-get install php${PHP_VERSION}-mongodb -y
    echo "--------completed: apt-get install php${PHP_VERSION}-mongodb -y------------------"

	echo "--------[/usr/bin/php -m | grep imagick]---------------------------"
	/usr/bin/php -m | grep imagick
    echo "--------[/usr/bin/php -m | grep imagick]---------------------------"

	echo "-----------------Restarting the [nginx] [apache2] [systemctl status nginx]---------------"
 	###/opt/bitnami/ctlscript.sh restart
   echo "---------[ service nginx restart ]---------"
   service nginx restart
   echo "------[ service apache2 restart ]------------"
   service apache2 restart
   echo "------[ service apache2 restart ]------------"
   systemctl status nginx
   echo "------[ systemctl status apache2 ]------------"
   systemctl status apache2
   echo "-------------------[service apache2 restart] [systemctl status nginx]------------------------"

   echo "-------------------completed: ------------------------" 
	echo "Please wait..."
	echo
	echo
	echo
	echo "Imagick Installed Successfully"
   sleep $SLEEPER
}




#####################################################
#Clearing HTTP DOCS folder before iCS Files load
#####################################################
functionClearHttpDocs () {
 ID=15
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "       Starting functionClearHttpDocs		 	   "
 echo -e "\e[1;31m ############################################### \e[m"

 
 echo "-------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------------------"
 echo
 echo
 echo
sleep $SLEEPER

 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo 
 echo "-------------------------------"
 echo "Clearing htdocs folders...."
 cd /opt/bitnami/apache2/htdocs	 
 rm -rfv /var/www/html/*.*	
 echo "-------------------------------" 
 echo
 echo
 echo
 echo "------------------------------ /var/www/html/ clean------------------------------"
 cd /opt/bitnami/apache2/htdocs	 
 ls -l /var/www/html/
 echo "------------------------------ /var/www/html/ clean------------------------------"

 echo "Please wait..."
 echo "-------------------------------"
sleep $SLEEPER
}




#####################################################
#Getting iCS Platform core files
#####################################################
functionGetGitFolders () {
 ID=16
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionGetGitFolders			 	   "
 echo -e "\e[1;31m ############################################### \e[m"

 echo "-------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------------------"
sleep $SLEEPER
 echo
 echo
 echo
 echo "-----------[cd /var/www/html/]--------------------"
 cd /var/www/html/
  echo "--------------[ls -l /var/www/html/]-----------------"
 ls -l /var/www/html/
 #echo "------------[ ls -l /opt/bitnami/apache2/htdocs]-------------------"
 #ls -l /opt/bitnami/apache2/htdocs
 echo "folder is now: [`pwd`] ---> Expected to be in: [cd /var/www/html/]"
 echo "-------------------------------"
 echo
 echo
 echo
 echo "------------------------------ Downloaded the Git Core files - [git init 1]------------------------------"
 git init
 echo "------------------------------ Downloaded the Git Core files - [git init 1]------------------------------"
sleep $SLEEPER
 echo
 echo
 echo
 echo "##########################INPUT REQUIRED##################################################"
 echo "[ ENTER THE GIT CLONE PASSWORD FOR [$GIT_URL], CODE_BRANCH=[$CODE_BRANCH], then press <ENTER> ]"
 echo "##########################INPUT REQUIRED##################################################"
 echo        
 git clone $GIT_URL
 if [ $? -gt 0 ]; then
    echo "-------------------------------"
    echo "Git Clone FAILED for: $GIT_URL Password or Connectivity or Git Folder must be deleted...Try again in [$SLEEPER] seconds..."
    echo "Please wait...[1]"
    echo "-------------------------------"
    echo "Press a key to continue...[second chance]"
    read PAUSE
    sleep $SLEEPER
    echo "-------------------------------"
    
    echo "--------Deleting OLD FILE------[rm -vrf /var/www/html/blockaptv9 -1]-----------------"
    rm -vrf /var/www/html/blockaptv9
    echo "--------Deleting OLD FILE------[rm -vrf /var/www/html/blockaptv9 -1]-----------------"
    git clone $GIT_URL
    while [ $? -gt 0 ]
    do
        echo "############################################INPUT REQUIRED###############################################"
        echo "[PASSWORD INCORRECT [LAST ATTEMPT]: ENTER THE GIT CLONE PASSWORD AGAIN FOR [$GIT_URL], then press <ENTER> ]"
        echo "############################################INPUT REQUIRED###############################################"

        echo "-----------[cd /var/www/html/]--------------------"
        cd /var/www/html/
        echo "--------------[ls -l /var/www/html/]-----------------"
        ls -l /var/www/html/
        echo "folder is now: [`pwd`] ---> Expected to be in: [cd /var/www/html/]"
        echo "-------------------------------"
        echo

        echo "------------------------------ Downloaded the Git Core files - [git init 1]------------------------------"
        git init
        echo "------------------------------ Downloaded the Git Core files - [git init 1]------------------------------"
        echo
        echo "--------Deleting OLD FILE------[rm -vrf /var/www/html/blockaptv9 -1]-----------------"
        rm -vrf /var/www/html/blockaptv9
        echo "--------Deleting OLD FILE------[rm -vrf /var/www/html/blockaptv9 -1]-----------------"
        echo
        git clone $GIT_URL
        echo "-----------[cd /var/www/html/]--------------------"
        cd /var/www/html/
        echo "--------------[ls -l /var/www/html/]-----------------"
        ls -l /var/www/html/
        echo "--------------[ls -l /var/www/html/blockaptv9]-----------------"
        cd /var/www/html/blockaptv9
        ls -l /var/www/html/blockaptv9
        #echo "------------[ ls -l /opt/bitnami/apache2/htdocs]-------------------"
        #ls -l /opt/bitnami/apache2/htdocs
        echo "folder is now: [`pwd`] ---> Expected to be in: [cd /var/www/html/blockaptv9]"
        echo "-------------------------------"
        echo "Press a key to continue..."
        read PAUSE
        sleep $SLEEPER

        echo
        echo "------------------------------ Downloaded the Git Core files - [git init 2]------------------------------"
        git init
        echo "------------------------------ Downloaded the Git Core files - [git init 2]------------------------------"
        echo "Press a key to continue..."
        read PAUSE
        sleep $SLEEPER
        echo
    done


else 
   echo "---------------------------------------------"
   echo "Git Clone SUCCESS for: [$GIT_URL] Continuing..."
   echo "---------------------------------------------"
   echo
   echo "-----------[cd /var/www/html/]--------------------"
   cd /var/www/html/
   echo "--------------[ls -l /var/www/html/]-----------------"
   ls -l /var/www/html/
   echo "--------------[ls -l /var/www/html/blockaptv9]-----------------"
   cd /var/www/html/blockaptv9
   ls -l /var/www/html/blockaptv9
   #echo "------------[ ls -l /opt/bitnami/apache2/htdocs]-------------------"
   #ls -l /opt/bitnami/apache2/htdocs
   echo "folder is now: [`pwd`] ---> Expected to be in: [cd /var/www/html/]"
   echo "-------------------------------"
   echo "Press a key to continue..."
   read PAUSE
   sleep $SLEEPER
   echo
   echo
fi


###########--------------- updated by Dev Team Start ---------------
sleep $SLEEPER
echo "---------[cd /var/www/html/blockaptv9] [ls -l /var/www/html/blockaptv9]----------------------"
cd /var/www/html/blockaptv9
ls -l /var/www/html/blockaptv9
echo "-------------------------------"
echo
echo 
echo "-------- Here is the list of active branch [git branch] [Press Q[uit] to continue]--------------------" 
git branch
####read -r JUST_PAUSE
echo "Press enter to continue...[functionGetGitFolders]"
echo "-------------------------------"
sleep $SLEEPER
echo
echo 

echo "-------- Switch Branch [git branch -r]----------------------" 
git branch -r
####read -r JUST_PAUSE
echo "Press enter to continue...[functionGetGitFolders]"
echo "-------------------------------"
sleep $SLEEPER
echo
echo

echo "--------[git checkout $CODE_BRANCH]....Current Branch [$CODE_BRANCH] must match the below branch or else errors------------"
git checkout $CODE_BRANCH
git branch
####read -r JUST_PAUSE
echo "Press enter to continue...[functionGetGitFolders]"
echo "-------------------------------"
sleep $SLEEPER
###########--------------- updated by Dev Team End -----------------
}





#####################################################
#Get DB PWD Part of the Bitnami default installation
####################################################
functionGetDBPassword () {
 ID=18
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionGetDBPassword 			 	   "
 echo -e "\e[1;31m ############################################### \e[m"

 
 echo "-------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------------------"
 echo
 echo
 echo
sleep $SLEEPER

 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 #DB_PASSWORD=`cat /opt/bitnami/apps/wordpress/htdocs/wp-config.php | grep DB_PASSWORD | awk -F ',' '{print $2}' | sed 's/);//g' | sed 's/ //g'`
 #echo "DB_PASSWORD=$DB_PASSWORD"

 echo "------------------------------------------------------------=="
 cat /opt/bitnami/apps/wordpress/htdocs/wp-config.php | grep DB_PASSWORD | awk -F ',' '{print $2}' | sed 's/);//g' | sed 's/ //g' > $DB_PASSWORD_FILE
 echo "before replacement DB_PASSWORD: `cat $DB_PASSWORD_FILE`"
 echo "------------------------------------------------------------=="

 functionReplaceString "'" "-" $DB_PASSWORD_FILE

 echo "------------------------------------------------------------=="
 DB_PASSWORD_TEMP=`cat $DB_PASSWORD_FILE`
 echo "after replacement DB PASSWORD: CATFILE=`cat $DB_PASSWORD_FILE` | VARIABLE=$DB_PASSWORD_TEMP"
 DB_PASSWORD=`echo $DB_PASSWORD_TEMP | sed 's/-//g'`
 echo "after replacement FINAL DB PASSWORD: $DB_PASSWORD"
 echo "------------------------------------------------------------=="
 echo "Please wait..."
  echo "-------------------------------"
sleep $SLEEPER
}






#####################################################
#Get DB PWD Part of the Bitnami default installation
####################################################
functionGetDBPassword () {
 ID=18
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 
 echo -e "\e[1;31""m ############################################### \e[0m"
 echo "        Starting functionGetDBPassword 			 	   "
 echo -e "\e[1;31""m ############################################### \e[0m"

 
 echo "-------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------------------"
 echo
 echo
 echo
sleep $SLEEPER

 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 #DB_PASSWORD=`cat /opt/bitnami/apps/wordpress/htdocs/wp-config.php | grep DB_PASSWORD | awk -F ',' '{print $2}' | sed 's/);//g' | sed 's/ //g'`
 #echo "DB_PASSWORD=$DB_PASSWORD"

 echo "------------------------------------------------------------=="
 cat /opt/bitnami/apps/wordpress/htdocs/wp-config.php | grep DB_PASSWORD | awk -F ',' '{print $2}' | sed 's/);//g' | sed 's/ //g' > $DB_PASSWORD_FILE
 echo "before replacement DB_PASSWORD: `cat $DB_PASSWORD_FILE`"
 echo "------------------------------------------------------------=="

 functionReplaceString "'" "-" $DB_PASSWORD_FILE

 echo "------------------------------------------------------------=="
 DB_PASSWORD_TEMP=`cat $DB_PASSWORD_FILE`
 echo "after replacement DB PASSWORD: CATFILE=`cat $DB_PASSWORD_FILE` | VARIABLE=$DB_PASSWORD_TEMP"
 DB_PASSWORD=`echo $DB_PASSWORD_TEMP | sed 's/-//g'`
 echo "after replacement FINAL DB PASSWORD: $DB_PASSWORD"
 echo "------------------------------------------------------------=="
 echo "Please wait..."
  echo "-------------------------------"
sleep $SLEEPER
}





#####################################################
#Setting ENV Variables
#####################################################
functionSetEnvVariables () {
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 ID=19
 mkdir -p /var/www/html/blockaptv9/
 echo
 echo
 echo
 echo -e "\e[1;31""m ############################################### \e[0m"
 echo "        Starting functionSetEnvVariables		    "
 echo -e "\e[1;31""m ############################################### \e[0m"

 
 echo "----------------------------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "----------------------------------------------------"
 echo
 echo
 echo
sleep $SLEEPER

 echo "-------------------------------"
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 #DB_PASSWORD=`cat /opt/bitnami/apps/wordpress/htdocs/wp-config.php | grep DB_PASSWORD | awk -F ',' '{print $2}' | sed 's/);//g' | sed 's/ //g'`
 echo "DB_PASSWORD to use is: [$DB_PASSWORD]"
 echo "-------------------------------"
 echo "Please wait..."
sleep $SLEEPER
 echo
 echo
 echo
 echo "----------------------------------------FILE CONTENT ADDED------------------------------"
 echo "COMPOSER_ALLOW_SUPERUSER=1" > /var/www/html/blockaptv9/.env
 echo "APP_ENV=local" > /var/www/html/blockaptv9/.env
 echo "APP_HOST=0.0.0.0" >> /var/www/html/blockaptv9/.env
 echo "APP_KEY=" >> /var/www/html/blockaptv9/.env	 
 echo "APP_DEBUG=true" >> /var/www/html/blockaptv9/.env	 
 echo "APP_LOG_LEVEL=debug" >> /var/www/html/blockaptv9/.env	 
 echo "APP_URL=http://localhost" >> /var/www/html/blockaptv9/.env
 echo "APP_API_URL=http://localhost" >> /var/www/html/blockaptv9/.env
 echo "DB_CONNECTION=mongodb" >> /var/www/html/blockaptv9/.env	 
 echo "DB_HOST_MONGO=127.0.0.1" >> /var/www/html/blockaptv9/.env
 echo "DB_PORT_MONGO=27017" >> /var/www/html/blockaptv9/.env
 echo "DB_DATABASE_MONGO=icyber_logger_db" >> /var/www/html/blockaptv9/.env	 
 echo "DB_USERNAME_USER_MONGO=" >> /var/www/html/blockaptv9/.env	 
 echo "DB_PASSWORD_MONGO=" >> /var/www/html/blockaptv9/.env
 echo "DB_CONNECTION=mysql" >> /var/www/html/blockaptv9/.env
 echo "DB_HOST=127.0.0.1" >> /var/www/html/blockaptv9/.env
 echo "DB_PORT=3306" >> /var/www/html/blockaptv9/.env
 echo "DB_DATABASE=blockaptdb" >> /var/www/html/blockaptv9/.env
 echo "DB_USERNAME=blockaptdbuser" >> /var/www/html/blockaptv9/.env
 echo "DB_PASSWORD=NTM0yaddasht" >> /var/www/html/blockaptv9/.env
 echo "BROADCAST_DRIVER=log" >> /var/www/html/blockaptv9/.env	 
 echo "CACHE_DRIVER=database" >> /var/www/html/blockaptv9/.env
 echo "SESSION_DRIVER=database" >> /var/www/html/blockaptv9/.env
 echo "QUEUE_DRIVER=database" >> /var/www/html/blockaptv9/.env
 echo "REDIS_HOST=127.0.0.1" >> /var/www/html/blockaptv9/.env	 
 echo "REDIS_PASSWORD=null" >> /var/www/html/blockaptv9/.env	 
 echo "REDIS_PORT=6379" >> /var/www/html/blockaptv9/.env	 
 #echo "MAIL_DRIVER=smtp" >> /var/www/html/blockaptv9/.env	 
 #echo "MAIL_HOST=mailtrap.io" >> /var/www/html/blockaptv9/.env	 
 #echo "MAIL_PORT=  " >> /var/www/html/blockaptv9/.env	 
 #echo "MAIL_USERNAME=null" >> /var/www/html/blockaptv9/.env	 
 #echo "MAIL_PASSWORD=null" >> /var/www/html/blockaptv9/.env	 
 #echo "MAIL_ENCRYPTION=null" >> /var/www/html/blockaptv9/.env	 
 echo "MAIL_FROM_ADDRESS=" >> /var/www/html/blockaptv9/.env	 
 echo "MAIL_FROM_NAME=''" >> /var/www/html/blockaptv9/.env	 
 echo "EMAIL_EXCEPTION_ENABLED=false" >> /var/www/html/blockaptv9/.env	 
 echo "EMAIL_EXCEPTION_FROM=email#email.com" >> /var/www/html/blockaptv9/.env	 
 echo "EMAIL_EXCEPTION_TO='email1@gmail.com, email2@rubicon.com'" >> /var/www/html/blockaptv9/.env	 
 echo "EMAIL_EXCEPTION_CC=''" >> /var/www/html/blockaptv9/.env	 
 echo "EMAIL_EXCEPTION_BCC=''" >> /var/www/html/blockaptv9/.env	 
 echo "EMAIL_EXCEPTION_SUBJECT=''" >> /var/www/html/blockaptv9/.env	 
 echo "PUSHER_APP_ID=" >> /var/www/html/blockaptv9/.env	 
 echo "PUSHER_APP_KEY=" >> /var/www/html/blockaptv9/.env	 
 echo "PUSHER_APP_SECRET=" >> /var/www/html/blockaptv9/.env	 
 echo "ACTIVATION=true" >> /var/www/html/blockaptv9/.env	 
 echo "ACTIVATION_LIMIT_TIME_PERIOD= " >> /var/www/html/blockaptv9/.env	 
 echo "ACTIVATION_LIMIT_MAX_ATTEMPTS=3" >> /var/www/html/blockaptv9/.env	 
 echo "NULL_IP_ADDRESS=0.0.0.0" >> /var/www/html/blockaptv9/.env	 
 echo "DEBUG_BAR_ENVIRONMENT=local" >> /var/www/html/blockaptv9/.env	 
 echo "USER_RESTORE_CUTOFF_DAYS= " >> /var/www/html/blockaptv9/.env	 
 echo "USER_RESTORE_ENCRYPTION_KEY=" >> /var/www/html/blockaptv9/.env	 
 echo "DEFAULT_GRAVATAR_SIZE=80" >> /var/www/html/blockaptv9/.env	 
 echo "DEFAULT_GRAVATAR_FALLBACK=http://c1940652.r52.cf0.rackcdn.com/51ce28d0fb4f442061000000/Screen-Shot-2013-06-28-at-5.22.23-PM.png" >> /var/www/html/blockaptv9/.env
 echo "DEFAULT_GRAVATAR_SECURE=false" >> /var/www/html/blockaptv9/.env	 
 echo "DEFAULT_GRAVATAR_MAX_RATING=g" >> /var/www/html/blockaptv9/.env	 
 echo "DEFAULT_GRAVATAR_FORCE_DEFAULT=false" >> /var/www/html/blockaptv9/.env	 
 echo "DEFAULT_GRAVATAR_FORCE_EXTENSION=jpg" >> /var/www/html/blockaptv9/.env
 echo "SCOUT_DRIVER=database" >> /var/www/html/blockaptv9/.env	 
 #echo "// NOTE: YOU CAN REMOVE THE KEY CALL IN app.blade.php IF YOU GET A POP UP AND DO NOT WANT TO SETUP A KEY FOR DEV" >> /var/www/html/blockaptv9/.env	 
 #echo "# Google Maps API v3 Key - https://developers.google.com/maps/documentation/javascript/get-api-key#get-an-api-key" >> /var/www/html/blockaptv9/.env
 #echo "GOOGLEMAPS_API_KEY=YOURGOOGLEMAPSkeyHERE" >> /var/www/html/blockaptv9/.env
 #echo "# https://console.developers.google.com/ - NEED OAUTH CREDS" >> /var/www/html/blockaptv9/.env
 #echo "GOOGLE_ID=YOURGOOGLEPLUSidHERE" >> /var/www/html/blockaptv9/.env
 #echo "GOOGLE_SECRET=YOURGOOGLEPLUSsecretHERE" >> /var/www/html/blockaptv9/.env
 #echo "GOOGLE_REDIRECT=http://yourwebsiteURLhere.com/social/handle/google" >> /var/www/html/blockaptv9/.env
 #echo "# https://www.google.com/recaptcha/admin#list" >> /var/www/html/blockaptv9/.env
 #echo "ENABLE_RECAPTCHA=true" >> /var/www/html/blockaptv9/.env
 #echo "RE_CAP_SITE=YOURGOOGLECAPTCHAsitekeyHERE" >> /var/www/html/blockaptv9/.env
 #echo "RE_CAP_SECRET=YOURGOOGLECAPTCHAsecretHERE" >> /var/www/html/blockaptv9/.env
 #echo "# https://developers.facebook.com/" >> /var/www/html/blockaptv9/.env
 #echo "FB_ID=YOURFACEBOOKidHERE" >> /var/www/html/blockaptv9/.env
 #echo "FB_SECRET=YOURFACEBOOKsecretHERE" >> /var/www/html/blockaptv9/.env
 #echo "FB_REDIRECT=http://yourwebsiteURLhere.com/social/handle/facebook" >> /var/www/html/blockaptv9/.env
 #echo "# https://apps.twitter.com/" >> /var/www/html/blockaptv9/.env
 #echo "TW_ID=YOURTWITTERidHERE" >> /var/www/html/blockaptv9/.env
 #echo "TW_SECRET=YOURTWITTERkeyHERE" >> /var/www/html/blockaptv9/.env
 #echo "TW_REDIRECT=http://yourwebsiteURLhere.com/social/handle/twitter" >> /var/www/html/blockaptv9/.env
 #echo "# https://github.com/settings/applications/new" >> /var/www/html/blockaptv9/.env
 #echo "GITHUB_ID=YOURIDHERE" >> /var/www/html/blockaptv9/.env
 #echo "GITHUB_SECRET=YOURSECRETHERE" >> /var/www/html/blockaptv9/.env
 #echo "GITHUB_URL=https://larablog.io/social/handle/github" >> /var/www/html/blockaptv9/.env
 #echo "# https://developers.google.com/youtube/v3/getting-started" >> /var/www/html/blockaptv9/.env
 #echo "YOUTUBE_KEY=YOURKEYHERE" >> /var/www/html/blockaptv9/.env
 #echo "YOUTUBE_SECRET=YOURSECRETHERE" >> /var/www/html/blockaptv9/.env
 #echo "YOUTUBE_REDIRECT_URI=https://larablog.io/social/handle/youtube" >> /var/www/html/blockaptv9/.env
 #echo "# http://www.twitch.tv/kraken/oauth2/clients/new" >> /var/www/html/blockaptv9/.env
 #echo "TWITCH_KEY=YOURKEYHERE" >> /var/www/html/blockaptv9/.env
 #echo "TWITCH_SECRET=YOURSECRETHERE" >> /var/www/html/blockaptv9/.env
 #echo "TWITCH_REDIRECT_URI=http://laravel-authentication.local/social/handle/twitch" >> /var/www/html/blockaptv9/.env
 #echo "# https://instagram.com/developer/register/" >> /var/www/html/blockaptv9/.env
 #echo "INSTAGRAM_KEY=YOURKEYHERE" >> /var/www/html/blockaptv9/.env
 #echo "INSTAGRAM_SECRET=YOURSECRETHERE" >> /var/www/html/blockaptv9/.env
 #echo "INSTAGRAM_REDIRECT_URI=http://laravel-authentication.local/social/handle/instagram" >> /var/www/html/blockaptv9/.env
 #echo "# https://basecamp.com/" >> /var/www/html/blockaptv9/.env
 #echo "# https://github.com/basecamp/basecamp-classic-api" >> /var/www/html/blockaptv9/.env
 #echo "SIGNALS_KEY=YOURKEYHERE" >> /var/www/html/blockaptv9/.env
 #echo "SIGNALS_SECRET=YOURSECRETHERE" >> /var/www/html/blockaptv9/.env
 #echo "SIGNALS_REDIRECT_URI=http://laravel-authentication.local/social/handle/37signals" >> /var/www/html/blockaptv9/.env
 echo "----------------------------------------FILE CONTENT ADDED------------------------------"


 echo "--------[ls -l /var/www/html/blockaptv9/.env]-----------------------"
 ls -l /var/www/html/blockaptv9/.env
 echo "-------------------------------"
sleep $SLEEPER


 echo "------------[cat /var/www/html/blockaptv9/.env]-------------------"
 cat /var/www/html/blockaptv9/.env
 echo "-------------------------------"
sleep $SLEEPER



 echo 
 echo
 ######echo "opening text editor so you can check env file...please wait..."
 echo
 echo
 echo "Please wait..."
 ######sleep $SLEEPER
 ######nano /var/www/html/blockaptv9/.env
 echo "------------------------------DB_PASSWORD is currently set to:------------------------------------------------------------"
 cat /var/www/html/blockaptv9/.env | grep DB_PASSWORD
 echo "----------------------------------------===FILE CONTENT ADDED------------------------------===="
 echo "Please wait..."
sleep $SLEEPER
}



#####################################################
#Creating DIR for iCS Core systems
#####################################################
functionCreateiCSDir () {
 ID=31
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 echo "-------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------------------"
 echo
 echo
 echo
sleep $SLEEPER

 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionCreateiCSDir 			      "
 echo -e "\e[1;31m ############################################### \e[m"

 echo "Creating Directories if they do not exist...Please wait."
 echo "---------------functionCreateiCSDir----------------"
 mkdir -p /var/www/html/blockaptv9/icyber_loggers
 mkdir -p /var/www/html/blockaptv9/storage	 
 mkdir -p /var/www/html/blockaptv9/storage/framework	 
 mkdir -p /var/www/html/blockaptv9/storage/framework/cache	 
 mkdir -p /var/www/html/blockaptv9/storage/framework/sessions	 
 mkdir -p /var/www/html/blockaptv9/storage/framework/views	 
 mkdir -p /var/www/html/blockaptv9/bootstrap/cache	 
 mkdir -p /var/www/html/blockaptv9/public/profileImage	
 mkdir -p /var/www/html/blockaptv9/public/generated_reports
 mkdir -p /var/www/html/blockaptv9/public/pdf_html	
 mkdir -p /var/www/html/blockaptv9/public/pdf_reports		
 echo "----------------------[mkdir -p]--------------------"
 mkdir -p /blockapt/logs
 mkdir -p /blockapt/scripts
 mkdir -p /blockapt/templates
 mkdir -p /blockapt/tools
 echo "----------------------[mkdir -p]--------------------"

echo "-------------[ chmod  -R 775 /var/lib/mongodb]-------------------" 
mkdir -p /var/log/mongodb/
mkdir -p /var/lib/mongodb
echo "-------------[ chmod  -R 775 /var/lib/mongodb]-------------------" 
echo
echo
sleep $SLEEPER
echo "-------------[ touch /var/log/mongodb/mongod.log]-------------------" 
touch /var/log/mongodb/mongod.log
echo >> /var/log/mongodb/mongod.log
echo "-------------[ touch /var/log/mongodb/mongod.log]-------------------" 
echo
echo
sleep $SLEEPER
echo "-------------[ chmod  -R 775 /var/lib/mongodb]-------------------"
chown -R mongodb /var/log/mongodb/
chown -R mongodb /var/lib/mongodb/
echo "-------------[ chmod  -R 775 /var/lib/mongodb]-------------------"
echo
echo
sleep $SLEEPER
echo "-------------[ chmod  -R 775 /var/lib/mongodb]-------------------"
chgrp -R mongodb /var/log/mongodb/
chgrp -R mongodb /var/lib/mongodb/
echo "-------------[ chmod  -R 775 /var/lib/mongodb]-------------------"
echo
echo
sleep $SLEEPER
echo "-------------[ chmod  -R 775 /var/lib/mongodb]-------------------"
chmod -R 775 /var/lib/mongodb
chmod -R 775 /var/log/mongodb/mongod.log
echo "-------------[ chmod  -R 775 /var/lib/mongodb]-------------------"
echo
echo
sleep $SLEEPER

 echo "--------------functionCreateiCSDir-----------------"
 echo
 echo
 echo
 echo "Setting Directories persmission if they do not exist...Please wait..."
 echo "------------[ chmod  -R 0777]-------------------"
 chmod  -R 0777 /var/www/html/blockaptv9/storage	 
 chmod  -R 0777 /var/www/html/blockaptv9/bootstrap	 
 chmod  -R 0777 /var/www/html/blockaptv9/public
 chmod  -R 0777 /var/www/html/blockaptv9/public/generated_reports	
 echo
 echo
 sleep $SLEEPER

 echo "-------------------------------------------------"
 echo
 echo
 echo
 echo "-------------[ chmod  -R 755]-------------------"
 chmod  -R 755 /blockapt/logs
 chmod  -R 755 /blockapt/scripts
 chmod  -R 755 /blockapt/templates
 chmod  -R 755 /blockapt/tools
 chmod  -R 775 /var/lib/mongodb
 echo "-----------------------------------------------"	 
 echo
 echo
 sleep $SLEEPER
 echo
 echo
 echo

 sleep $SLEEPER
 echo "----------=Folder and permissions set...see below----------="
 ls -l /var/www/html/blockaptv9/
 echo "----------=Folder and permissions set...----------="
 echo
 echo
 echo
 sleep $SLEEPER
 echo "------------------------------Folder and permissions set...Storage folders list----------="
 ls -l /var/www/html/blockaptv9/storage		 
 ls -l /var/www/html/blockaptv9/bootstrap	 
 ls -l /var/www/html/blockaptv9/public	 
 echo "------------------------------Folder and permissions set...Storage folders list----------="

 echo "Please wait...Setting folder permissions...completed"
 echo
 echo
 echo
 sleep $SLEEPER
}




#####################################################
#Setting up composer files
#####################################################
functionComposerUpdate () {
 ID=26
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 export COMPOSER_ALLOW_SUPERUSER="1"
 echo
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionComposerUpdate				    "
 echo -e "\e[1;31m ############################################### \e[m"

 echo "-------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------------------"
 echo
 echo
 echo
 echo "--------------------------------------------------------------------"
 functionCreateiCSDir 
 echo "--------------------------------------------------------------------"
 echo
sleep $SLEEPER


 echo "-------------------------------"
 cd /var/www/html/blockaptv9	 
 echo "folder is now: [`pwd`] ---> Expected to be in:/var/www/html/blockaptv9"
 echo "Please wait..."
 echo "-------------------------------"

 echo
 echo
 echo "--------PHP default VERSION [php -v;    /usr/bin/php -v;]----------------------"
 php -v;    /usr/bin/php -v;
 echo "--------PHP default VERSION [php -v;    /usr/bin/php -v;]----------------------"
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo "---------- [cd /var/www/html/blockaptv9]---1----"
 cd /var/www/html/blockaptv9
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 cd /var/www/html/blockaptv9
 export COMPOSER_ALLOW_SUPERUSER="1"
 echo "----------[ /usr/bin/php /usr/local/bin/composer -n update	]---------------------"
 /usr/bin/php /usr/local/bin/composer -n update	  
 echo "----------[ /usr/bin/php /usr/local/bin/composer -n update	]---------------------"
 echo
 echo
 echo "----------[ /usr/bin/php artisan cache:clear ]---1-----"
 /usr/bin/php artisan cache:clear 
 echo "Press a key to continue..."
 read PAUSE
 echo "----------[ /usr/bin/php artisan config:clear ]-----1---"
 /usr/bin/php artisan config:clear 
 echo "Press a key to continue..."
 read PAUSE
 echo "----------[ /usr/bin/php artisan view:clear]-----1---"
 /usr/bin/php artisan view:clear
 echo "----------[ /usr/bin/php artisan view:clear]---1-----"
 echo "Press a key to continue..."
 read PAUSE
 ###archives command 
 ###php artisan queue:listen
 ###php artisan queue:work
 echo
 echo
 cd /var/www/html/blockaptv9
  export COMPOSER_ALLOW_SUPERUSER="1"
 echo "----------------[ /usr/bin/php /usr/local/bin/composer -n dump-autoload	]-----------------"
 /usr/bin/php /usr/local/bin/composer -n dump-autoload	 
 echo "----------------[ /usr/bin/php /usr/local/bin/composer -n dump-autoload	]-----------------"
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
sleep $SLEEPER	 
 echo
 echo "---------- [cd /var/www/html/blockaptv9]---2----"
 cd /var/www/html/blockaptv9
 echo "Press a key to continue..."
 read PAUSE
 echo "----------[ /usr/bin/php artisan cache:clear ]---2-----"
 /usr/bin/php artisan cache:clear 
 echo "Press a key to continue..."
 read PAUSE
 echo "----------[ /usr/bin/php artisan config:clear ]----2----"
 /usr/bin/php artisan config:clear 
 echo "Press a key to continue..."
 read PAUSE
 echo "----------[ /usr/bin/php artisan view:clear]----2----"
 /usr/bin/php artisan view:clear
 echo "----------[ /usr/bin/php artisan view:clear]---2-----"
 echo "Press a key to continue..."
 read PAUSE
 ###archives command 
 ###php artisan queue:listen
 ###php artisan queue:work
 #echo "Press a key to continue..."
 #read PAUSE
 echo
 echo
 cd /var/www/html/blockaptv9
  export COMPOSER_ALLOW_SUPERUSER="1"
   echo "----------[ /usr/bin/php /usr/local/bin/composer -n update	]---------------------"
 /usr/bin/php /usr/local/bin/composer -n update	  
 echo "----------[ /usr/bin/php /usr/local/bin/composer -n update	]---------------------"
 echo
 echo
 sleep $SLEEPER
 echo
 echo "------Clearing configuration and forcing update again... please wait--------"
 echo
 echo "---------- [cd /var/www/html/blockaptv9]---3----"
 cd /var/www/html/blockaptv9
 echo "Press a key to continue..."
 read PAUSE
 echo "----------[ /usr/bin/php artisan cache:clear ]---3-----"
 /usr/bin/php artisan cache:clear 
 echo "Press a key to continue..."
 read PAUSE
 echo "----------[ /usr/bin/php artisan config:clear ]---3-----"
 /usr/bin/php artisan config:clear 
 echo "Press a key to continue..."
 read PAUSE
 echo "----------[ /usr/bin/php artisan view:clear]---3-----"
 /usr/bin/php artisan view:clear
 echo "----------[ /usr/bin/php artisan view:clear]----3----"
 echo "Press a key to continue..."
 read PAUSE
 echo "--------Clearing configuration and forcing update again... please wait-------"
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo
sleep $SLEEPER
 echo "---------------------------[ /usr/bin/php /usr/local/bin/composer -n require pragmarx/google2fa-laravel]---------------------------------------"
 cd /var/www/html/blockaptv9
export COMPOSER_ALLOW_SUPERUSER="1"
 /usr/bin/php /usr/local/bin/composer -n require pragmarx/google2fa-laravel
 echo "----------[ composer require pragmarx/google2fa-laravel - Google 2FA]---------------------"
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo "---------[ /usr/bin/php /usr/local/bin/composer -n show ]---------------------"
 export COMPOSER_ALLOW_SUPERUSER="1"
 /usr/bin/php /usr/local/bin/composer -n show 
 echo "---------[ /usr/bin/php /usr/local/bin/composer -n show ]---------------------"
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo "Composer updated completed..."
sleep $SLEEPER
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
}



#####################################################
#Generating Key for PHP modules
#####################################################
functionKeyGenerate (){
 ID=28
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionKeyGenerate			     "
 echo -e "\e[1;31m ############################################### \e[m"

 echo "-------------------- [functionCreateiCSDir]-------------------------"
 functionCreateiCSDir 
 echo "-----------------------[functionCreateiCSDir]----------------------"
 
 echo "-------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------------------"
 echo
 echo
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo "-------------------------------"
 cd /var/www/html/blockaptv9	 
 echo "folder is now: [`pwd`] ---> Expected to be in:/var/www/html/blockaptv9"
 echo "Please wait..."
 echo "-------------------------------"
 echo
 echo
 echo "-----[functionGetSeed]-----------[ mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log --replSet rs0 --bind_ip localhost,localhost.local &]---------------"
 mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log --replSet rs0 --bind_ip localhost,localhost.local &
 echo "--------[functionGetSeed]--------[ mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log --replSet rs0 --bind_ip localhost,localhost.local &]---------------"
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo "Here is the PHP version used..."
 php -v;    /usr/bin/php -v;
 echo "Here is the PHP version used..."
 echo
 echo
 echo "-------------------[ cat  /var/www/html/blockaptv9/.env | grep ^APP_KEY=]-----------[usr/bin/php artisan key:generate]--------------------------------------"
 /usr/bin/php artisan key:generate	 
 echo "-------------------[ cat  /var/www/html/blockaptv9/.env | grep ^APP_KEY=]-------------------------------------------------"
 cat  /var/www/html/blockaptv9/.env | grep APP_KEY
 echo "-------------------------key generated---------------[functionKeyGenerate]-----------"
 echo "Check this APP_KEY, if not present, expect trouble ahead! Press a key to continue..."
 read PAUSE
 echo
 echo
 sleep $SLEEPER
}




#####################################################
#Migrating Database files
#####################################################
functionInitMigration () {
 ID=29
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionInitMigration			     "
 echo -e "\e[1;31m ############################################### \e[m"
 echo
 echo
 echo "--------------------[calling functionCreateiCSDir]---------------------------------------------"
 functionCreateiCSDir 
 echo "--------------------------------------------------------------------"
sleep $SLEEPER
 echo "Press a key to continue..."
 read PAUSE

 echo "-------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------------------"
 echo
 echo
 echo
 echo "-------------------------------"
 cd /var/www/html/blockaptv9	 
 echo "folder is now: [`pwd`] ---> Expected to be in:/var/www/html/blockaptv9"
 echo "-------------------------------"
 echo
 echo
 echo "------[functionInitMigration]----------[ mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log --replSet rs0 --bind_ip localhost,localhost.local &]---------------"
 mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log --replSet rs0 --bind_ip localhost,localhost.local &
 echo "-------[functionInitMigration]---------[ mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log --replSet rs0 --bind_ip localhost,localhost.local &]---------------"
 
 echo
 echo "--------PHP VERSION [php -v;    /usr/bin/php -v;]----------------------"
 php -v;    /usr/bin/php -v;
 echo "--------PHP VERSION [php -v;    /usr/bin/php -v;]----------------------"
 echo
 echo
 echo "--------PHP VERSION [ /usr/bin/php]------------------------"
 /usr/bin/php -v;    /usr/bin/php -v;
 echo "--------PHP VERSION [ /usr/bin/php]-------------------------"
sleep $SLEEPER
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo
 echo 
 echo "-----------[ /usr/bin/php artisan cache:clear]-----[functionInitMigration]---------------"
 /usr/bin/php artisan cache:clear
 echo "-------------------------------"
sleep $SLEEPER
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo "----------[ /usr/bin/php artisan config:clear]------[functionInitMigration]---------------"
 /usr/bin/php artisan config:clear
 echo "-------------------------------"
sleep $SLEEPER
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo "----------[database migrated [ /usr/bin/php artisan migrate]---[functionInitMigration]-------"
 /usr/bin/php migrate:fresh
 /usr/bin/php artisan migrate
 echo "-------------------------------" 
sleep $SLEEPER
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo "----------[database migrated database list [ /usr/bin/php artisan migrate:status ]----[functionInitMigration]------"
 /usr/bin/php artisan migrate:status  
 echo "----------[database migrated database list----------"
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 sleep $SLEEPER 
}




#####################################################
#Getting DB Seed 
#####################################################
functionGetSeed () {
 ID=27
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionGetSeed 				     "
 echo -e "\e[1;31m ############################################### \e[m"

 echo "-------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------------------"
 echo
 echo
###################################################################
#                   Code Pull & Seeding database                  #
###################################################################

 echo "--------[functionCreateiCSDir]------------------------" 
 functionCreateiCSDir 
 echo "running...functionCreateiCSDir.. Please wait... "
 echo
 echo
sleep $SLEEPER
 echo "-------------------------------"
 cd /var/www/html/blockaptv9
 ls -l /var/www/html/blockaptv9
 echo "folder is now: [`pwd`] ---> Expected to be in: [/var/www/html/blockaptv9]"
 echo
 echo
 echo
 echo
 echo "--------PHP bitnami VERSION [ /usr/bin/php]------------------------"
 /usr/bin/php -v;    /usr/bin/php -v;
 echo "--------PHP bitnami VERSION [ /usr/bin/php]-------------------------"
sleep $SLEEPER
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo "-------- Here is the list of active branch [git branch] [Press Q[uit] to continue]--------------------" 
 git branch
 echo "-------------------------------"
 echo
 echo 
 echo "-------- Switch Branch [git branch -r]--------[functionGetSeed]--------------" 
 git branch -r
 echo "-------------------------------"
sleep $SLEEPER
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo "##########################INPUT REQUIRED##################################################"
 echo "[ ENTER THE GIT PULL PASSWORD FOR [$GIT_URL] CODE_BRANCH=[$CODE_BRANCH] then press <ENTER>]"
 echo "##########################INPUT REQUIRED##################################################"
 echo
 git checkout $CODE_BRANCH
 echo "--------Current Branch [ git branch]-------[functionGetSeed]---------------"
 git branch
 echo "-------------------------------"
 echo

sleep $SLEEPER
 echo "-----------[ /usr/bin/php artisan cache:clear]------[functionGetSeed]--------------"
 /usr/bin/php artisan cache:clear
 echo "-------------------------------"
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo
sleep $SLEEPER
 echo "----------[ /usr/bin/php artisan config:clear]-----------[functionGetSeed]----------"
 /usr/bin/php artisan config:clear
 echo "-------------------------------"
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo
 #echo "------------php artisan db:seed-------------------"
 #/usr/bin/php artisan  db:seed
 echo "-----[functionGetSeed]-----------[ mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log --replSet rs0 --bind_ip localhost,localhost.local &]---------------"
 mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log --replSet rs0 --bind_ip localhost,localhost.local &
 echo "--------[functionGetSeed]--------[ mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log --replSet rs0 --bind_ip localhost,localhost.local &]---------------"
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
 echo
 echo "------------[php artisan migrate --seed]-----------[functionGetSeed]--------"
 /usr/bin/php artisan migrate --seed
 echo "-------------------------------"
sleep $SLEEPER
 echo
 echo
 echo "----------[database migrated database list [ /usr/bin/php artisan migrate:status ]---[functionGetSeed]-------"
 /usr/bin/php artisan migrate:status  
 echo "----------[database migrated database list----------"
 echo
 echo
 echo "functionGetSeed completed..."
 sleep $SLEEPER
 echo "Press a key to continue..."
 read PAUSE
 echo
 echo
}





#####################################################
#Setting Apache public path root
#####################################################
functionSetApacheRootDir (){
 ID=17
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionSetApacheRootDir		     "
 echo -e "\e[1;31m ############################################### \e[m"
 
 echo "-------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------------------"
 sleep $SLEEPER
 echo
 echo 
 echo "-----------------------------------------------"
 cd /opt/bitnami/apache2/conf	 
 time_stamp=`date | sed 's/[ :]/_/g'`
 echo "folder is now: [`pwd`] ---> Expected to be in:/opt/bitnami/apache2/conf"
 echo "-----------------------------------------------"
 sleep $SLEEPER
 echo
 echo
 echo "-----------------------------------------------"
 cp /opt/bitnami/apache2/conf/httpd.conf  /opt/bitnami/apache2/conf/httpd.conf.BACKUP.$time_stamp
 echo "-----------------------------------------------"
 sleep $SLEEPER
 echo
 echo
 echo "-----------------------------------------------"
 cp /opt/bitnami/apache2/conf/bitnami/bitnami.conf /opt/bitnami/apache2/conf/bitnami/bitnami.conf.BACKUP.$time_stamp
 echo "-----------------------------------------------"
 sleep $SLEEPER
 echo
 echo
 echo "----------[sed -i  's/htdocs/htdocs\/blockaptv9\/public/g' /opt/bitnami/apache2/conf/httpd.conf]-----------------------"
 sed -i  's/htdocs/htdocs\/blockaptv9\/public/g' /opt/bitnami/apache2/conf/httpd.conf
                 ######sed -i  's/Listen 80/Listen 443/g' /opt/bitnami/apache2/conf/httpd.conf
 echo "-----------------------------------------------"
 sleep $SLEEPER
 echo
 echo
 echo "-----------------[cat /opt/bitnami/apache2/conf/httpd.conf | grep blockaptv9]-----------------"
 cat /opt/bitnami/apache2/conf/httpd.conf | grep blockaptv9 
 echo "-----------------[cat /opt/bitnami/apache2/conf/httpd.conf | grep blockaptv9]-----------------"
 echo "Please wait..."
 sleep $SLEEPER
 echo
 echo
 echo "-----------------[cat /opt/bitnami/apache2/conf/httpd.conf | grep Listen]-----------------"
 cat /opt/bitnami/apache2/conf/httpd.conf | grep Listen
 echo "-----------------[cat /opt/bitnami/apache2/conf/httpd.conf | grep Listen]-----------------"
 echo "Please wait..."
 sleep $SLEEPER
 echo
 echo
 echo "---------------[sed -i  's/htdocs/htdocs\/blockaptv9\/public/g' /opt/bitnami/apache2/conf/bitnami/bitnami.conf]--------------"
 cd /opt/bitnami/apache2/conf/bitnami	 
 echo "folder is now: [`pwd`] ---> Expected to be in:/opt/bitnami/apache2/conf/bitnami"
 sed -i  's/htdocs/htdocs\/blockaptv9\/public/g' /opt/bitnami/apache2/conf/bitnami/bitnami.conf
 echo "---------------[sed -i  's/htdocs/htdocs\/blockaptv9\/public/g' /opt/bitnami/apache2/conf/bitnami/bitnami.conf]----------------"
 sleep $SLEEPER 
 echo
 echo
 echo "---------------[ cat /opt/bitnami/apache2/conf/bitnami/bitnami.conf | grep blockaptv9 ]---------------"
 cat /opt/bitnami/apache2/conf/bitnami/bitnami.conf | grep blockaptv9  
 echo "---------------[ cat /opt/bitnami/apache2/conf/bitnami/bitnami.conf | grep blockaptv9 ]---------------"
 echo "Please wait..."
 sleep $SLEEPER
}




#####################################################
#Function Install NGINX
#####################################################
functionInstallNginx(){

   nginx_conf_path="/var/www/html/blockaptv9/MTE-API/scripts/mteapi-ngnix.conf" 
   nginx_dest_path="/etc/nginx/sites-available/mteapi.conf"

   echo "" > /etc/nginx/sites-available/ssl/private/nginx-selfsigned.key 
   echo "" > /etc/nginx/sites-available/ssl/certs/nginx-selfsigned.crt  
   
   openssl_rand_base64_32_pass=`openssl rand -base64 32` 

    echo "-------------Installing NGINX------------------"
    apt-get -y update
    echo "Starting.... Please wait..."
    echo "-------------------------------"
    functionCreateiCSDir
    echo "-------------------------------"
    echo
    echo
    echo "-------[apt-get -y install nginx -y]---[ufw app list]-----[ufw allow 'Nginx HTTPS']----------------"
    apt-get -y install nginx -y
    echo "-----------[ ufw app list]--------------------"
    ufw app list
    echo "-------------[ufw allow 'Nginx HTTPS']------------------"
    ufw allow 'Nginx HTTPS'
    echo "-------------------------------"
    echo "[apt-get -y install nginx -y][ufw app list][ufw allow 'Nginx HTTPS'] completed. Press a key to continue..."
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------Creating NGINX DIRS------------------"
    mkdir -p /var/www/html/blockaptv9/MTE-API/scripts/
    touch /var/www/html/blockaptv9/MTE-API/scripts/mteapi-ngnix.conf 
    touch /etc/nginx/sites-available/mteapi.conf
    echo "-------------------------------"
    echo "[mkdir -p /var/www/html][touch /etc/nginx/] completed. Press a key to continue..."
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------------------------"
    mkdir -p /etc/nginx/sites-available/ssl/private/
    mkdir -p /etc/nginx/sites-available/ssl/certs/
    touch /etc/nginx/sites-available/ssl/private/nginx-selfsigned.key
    touch /etc/nginx/sites-available/ssl/certs/nginx-selfsigned.crt
    echo "-------------------------------"
    echo "[mkdir -p /etc/nginx][touch /etc/nginx/] completed. Press a key to continue..."
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------------------------"


   #CREATE THE CERTIFICATE SIGNING REQUEST (CSR) non interactive mode
   echo "-----------[CREATE openssl_rand_base64_32_pass]-----------------"
   echo "openssl_rand_base64_32_pass=[ $openssl_rand_base64_32_pass ]"
   echo "[ $openssl_rand_base64_32_pass ]" > /etc/nginx/sites-available/ssl/certs/nginx-openssl_rand_base64_32_pass
   cat /etc/nginx/sites-available/ssl/certs/nginx-openssl_rand_base64_32_pass
   echo "-----------[CREATE openssl_rand_base64_32_pass]-----------------"
   echo
   echo

   echo "-----------[CREATE THE CERTIFICATE SIGNING REQUEST (CSR)]-----------------"
 openssl req                                                                    \
    -new                                                                        \
    -newkey rsa:4096                                                            \
    -days 365                                                                   \
    -nodes -x509                                                                \
    -subj "/C=GB/ST=BK/L=London/O=BlockAPT/CN=blockapt.local"                   \
    -keyout /etc/nginx/sites-available/ssl/private/nginx-selfsigned.key         \
    -out /etc/nginx/sites-available/ssl/certs/nginx-selfsigned.crt              \
    -passin pass:$openssl_rand_base64_32_pass                                   \
    -passout pass:$openssl_rand_base64_32_pass
   echo "-----------[CREATE THE CERTIFICATE SIGNING REQUEST (CSR)]-----------------"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo


 #CONVERT TO PKCS12 non interactive mode
    echo "----------------[CONVERT TO PKCS12]-----------------------------------"
     openssl pkcs12                                                            \
    -inkey /etc/nginx/sites-available/ssl/private/nginx-selfsigned.key         \
    -in /etc/nginx/sites-available/ssl/certs/nginx-selfsigned.crt              \
    -export                                                                    \
    -out /etc/nginx/sites-available/ssl/certs/nginx-selfsigned.pkcs12          \
    -passin pass:$openssl_rand_base64_32_pass                                  \
    -passout pass:$openssl_rand_base64_32_pass
    echo "--------------------[CONVERT TO PKCS12]-------------------------------"  
    echo "Press a key to continue..."
    read PAUSE


    #CREATE THE CERTIFICATE SIGNING REQUEST (CSR) interactive manual mode
    #openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/sites-available/ssl/private/nginx-selfsigned.key -out /etc/nginx/sites-available/ssl/certs/nginx-selfsigned.crt
    ls -l /etc/nginx/sites-available/ssl/private/nginx-selfsigned.key
    ls -l /etc/nginx/sites-available/ssl/certs/nginx-selfsigned.crt
    echo "--------------[ls -l /etc/nginx/sites-available/ssl/private/nginx-selfsigned.key]----[ ls -l /etc/nginx/sites-available/ssl/certs/nginx-selfsigned.crt]-------------"
    echo "[openssl req] completed. Press a key to continue..."
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------------------------"
    cat /etc/nginx/sites-available/ssl/private/nginx-selfsigned.key
    cat /etc/nginx/sites-available/ssl/certs/nginx-selfsigned.crt
    echo "-------------------------------"
   echo "[cat /etc/nginx/] completed. Press a key to continue..."
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------Creating NGINX DIRS------------------"
    echo
    echo "---------------[cp [$nginx_conf_path] ---> []$nginx_dest_path]----------------"
    echo "[*] Got nginx_conf_path: $nginx_conf_path\n[*]"
    echo "[*] Got destpath $nginx_dest_path"
    cp $nginx_conf_path $nginx_dest_path
    sudo ln -s $nginx_dest_path /etc/nginx/sites-enabled/
    echo "" > /etc/nginx/sites-available/default
    echo "-------------------------------"
    echo "Check the NGINX file conf & Press a key to continue if OK..."
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------Creating mteapi Conf file------------------"
    echo "server {"                                                                           >  /etc/nginx/sites-available/mteapi.conf
    echo "  listen 9001 ssl;"                                                                     >> /etc/nginx/sites-available/mteapi.conf
    echo "  #server_name mteapi;"                                                             >> /etc/nginx/sites-available/mteapi.conf
    echo "  #server_name mteapi;"                                                             >> /etc/nginx/sites-available/mteapi.conf
    echo "  proxy_read_timeout 3600;"                                                         >> /etc/nginx/sites-available/mteapi.conf
    echo "  proxy_connect_timeout 3600;"                                                      >> /etc/nginx/sites-available/mteapi.conf
    echo "  proxy_send_timeout 3600;"                                                         >> /etc/nginx/sites-available/mteapi.conf
    echo "  #ssl on;"                                                                          >> /etc/nginx/sites-available/mteapi.conf
    echo "  ssl_certificate /etc/nginx/sites-available/ssl/certs/nginx-selfsigned.crt;"       >> /etc/nginx/sites-available/mteapi.conf
    echo "  ssl_certificate_key /etc/nginx/sites-available/ssl/private/nginx-selfsigned.key;" >> /etc/nginx/sites-available/mteapi.conf
    echo "  access_log /var/log/nginx/mteapi.access.log;"                                     >> /etc/nginx/sites-available/mteapi.conf
    echo "  error_log /var/log/nginx/mteapi.error.log;"                                       >> /etc/nginx/sites-available/mteapi.conf
    echo "  location / {"                                                                     >> /etc/nginx/sites-available/mteapi.conf
    echo "    proxy_pass http://127.0.0.1:9002;"                                              >> /etc/nginx/sites-available/mteapi.conf
    echo "  }"                                                                                >> /etc/nginx/sites-available/mteapi.conf
    echo "}"                                                                                  >> /etc/nginx/sites-available/mteapi.conf
    echo "-------------Creating mteapi Conf file------------------"
    echo "Check the NGINX file conf & Press a key to continue if OK..."
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------[NGINX FILE CONF FILE:  /etc/nginx/sites-available/mteapi.conf]------------------"
    cat /etc/nginx/sites-available/mteapi.conf
   echo "-------------[NGINX FILE CONF FILE:  /etc/nginx/sites-available/mteapi.conf]------------------"
    echo "Press a key to continue..."
    read PAUSE
    echo "Check the NGINX file conf & Press a key to continue if OK..."
    echo
    echo
    echo "---------------[sudo service nginx restart]----------------"
    service nginx restart
    echo "---------------[systemctl status nginx]----------------"
    systemctl status nginx
    echo "-------------[netstat -nape |grep nginx | grep :443]------------------"
    netstat -nape |grep nginx | grep :443
    echo "-------------[netstat -nape |grep nginx | grep :80]------------------"
    netstat -nape |grep nginx | grep :80
    echo "---------------------------------------------------------------------------------"
    echo
    echo
    echo "-------------NGINX Completed------------------"
    sleep $SLEEPER
}



#####################################################
#Function Install MySQL Laravel (LAMP)
#####################################################
functionInstallMySQLLaravel(){

    apache_conf_path_http_src_file="/var/www/html/blockaptv9/000-default.conf"
    apache_conf_path_http_dst_dir="/etc/apache2/sites-available/"

    apache_conf_path_https_src_file="/var/www/html/blockaptv9/default-ssl.conf"
    apache_conf_path_https_dst_dir="/etc/apache2/sites-available/"

    apache_conf_path_sslparams_src_file="/var/www/html/blockaptv9/ssl-params.conf"
    apache_conf_path_sslparams_dst_dir="/etc/apache2/conf-available/"



#enabling ssl parameters
echo "SSLCipherSuite EECDH+AESGCM:EDH+AESGCM"> /var/www/html/blockaptv9/ssl-params.conf
echo "# Requires Apache 2.4.36 & OpenSSL 1.1.1" >> /var/www/html/blockaptv9/ssl-params.conf
echo "SSLProtocol -all +TLSv1.3 +TLSv1.2" >> /var/www/html/blockaptv9/ssl-params.conf
echo "SSLOpenSSLConfCmd Curves X25519:secp521r1:secp384r1:prime256v1"> /var/www/html/blockaptv9/ssl-params.conf
echo "# Older versions" >>  /var/www/html/blockaptv9/ssl-params.conf
echo "# SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1" >>  /var/www/html/blockaptv9/ssl-params.conf
echo "SSLHonorCipherOrder On" >>  /var/www/html/blockaptv9/ssl-params.conf
echo "# Disable preloading HSTS for now.  You can use the commented out header line that includes" >>  /var/www/html/blockaptv9/ssl-params.conf 
echo "# the \"preload\" directive if you understand the implications." >> /var/www/html/blockaptv9/ssl-params.conf
echo "# Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"" >>  /var/www/html/blockaptv9/ssl-params.conf
echo "Header always set X-Frame-Options DENY" >>  /var/www/html/blockaptv9/ssl-params.conf
echo "Header always set X-Content-Type-Options nosniff" >>  /var/www/html/blockaptv9/ssl-params.conf
echo "# Requires Apache >= 2.4" >>  /var/www/html/blockaptv9/ssl-params.conf
echo "SSLCompression off" >>  /var/www/html/blockaptv9/ssl-params.conf
echo "SSLUseStapling on" >>  /var/www/html/blockaptv9/ssl-params.conf
echo "SSLStaplingCache \"shmcb:logs/stapling-cache(150000)\"" >>  /var/www/html/blockaptv9/ssl-params.conf
echo "# Requires Apache >= 2.4.11" >>  /var/www/html/blockaptv9/ssl-params.conf
echo "SSLSessionTickets Off" >>  /var/www/html/blockaptv9/ssl-params.conf

#enabling ssl modules & folders
echo "<IfModule mod_ssl.c> " > /var/www/html/blockaptv9/default-ssl.conf
        echo "<VirtualHost _default_:443> " >> /var/www/html/blockaptv9/default-ssl.conf
                
               echo "ServerName localhost " >> /var/www/html/blockaptv9/default-ssl.conf
               echo "ServerAdmin webmaster@localhost " >> /var/www/html/blockaptv9/default-ssl.conf
               echo "DocumentRoot /var/www/html/blockaptv9/public " >> /var/www/html/blockaptv9/default-ssl.conf

               echo "# Available loglevels: trace8, ..., trace1, debug, info, notice, warn, " >> /var/www/html/blockaptv9/default-ssl.conf
               echo "# error, crit, alert, emerg"  >> /var/www/html/blockaptv9/default-ssl.conf
               echo "# It is also possible to configure the loglevel for particular" >> /var/www/html/blockaptv9/default-ssl.conf
               echo "# modules, e.g." >> /var/www/html/blockaptv9/default-ssl.conf
               echo "#LogLevel info ssl:warn" >> /var/www/html/blockaptv9/default-ssl.conf
               echo "<Directory /var/www/html/blockaptv9/public>" >> /var/www/html/blockaptv9/default-ssl.conf
               echo "   AllowOverride All" >> /var/www/html/blockaptv9/default-ssl.conf
               echo " </Directory>" >> /var/www/html/blockaptv9/default-ssl.conf

              echo "  ErrorLog ${APACHE_LOG_DIR}/error.log" >> /var/www/html/blockaptv9/default-ssl.conf
              echo "  CustomLog ${APACHE_LOG_DIR}/access.log combined" >> /var/www/html/blockaptv9/default-ssl.conf

              echo "  SSLEngine on" >> /var/www/html/blockaptv9/default-ssl.conf
              echo "  SSLCertificateKeyFile /etc/nginx/sites-available/ssl/private/nginx-selfsigned.key" >> /var/www/html/blockaptv9/default-ssl.conf
              echo "  SSLCertificateFile /etc/nginx/sites-available/ssl/certs/nginx-selfsigned.crt" >> /var/www/html/blockaptv9/default-ssl.conf

              echo "  <FilesMatch \"\.(cgi|shtml|phtml|php)$\">" >> /var/www/html/blockaptv9/default-ssl.conf
                                echo "SSLOptions +StdEnvVars" >> /var/www/html/blockaptv9/default-ssl.conf
              echo "  </FilesMatch>" >> /var/www/html/blockaptv9/default-ssl.conf
              echo "  <Directory /usr/lib/cgi-bin>" >> /var/www/html/blockaptv9/default-ssl.conf
                                echo "SSLOptions +StdEnvVars" >> /var/www/html/blockaptv9/default-ssl.conf
              echo "  </Directory>" >> /var/www/html/blockaptv9/default-ssl.conf

        echo "</VirtualHost>" >> /var/www/html/blockaptv9/default-ssl.conf
echo "</IfModule>" >> /var/www/html/blockaptv9/default-ssl.conf


    echo "-------------CORE apache2 Instalation------------------"
    apt-get -y update
    echo "Starting.... Please wait..."
    echo "--------------[functionCreateiCSDir]-----------------"
    functionCreateiCSDir
    echo "--------------[functionCreateiCSDir]-----------------"
    echo
    echo
    echo "-------------apache2 started-------------------"
    
    
    echo "-------------[ /etc/apache2/sites-available/000-default.conf ]---[/etc/apache2/sites-available/default-ssl.conf]---------------"
    rm -rf /etc/apache2/sites-available/000-default.conf
    rm -rf /etc/apache2/sites-available/default-ssl.conf
    echo "-------------[ /etc/apache2/sites-available/000-default.conf ]---[/etc/apache2/sites-available/default-ssl.conf]---------------"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------[ $apache_conf_path_http]---[$apache_conf_path_http_src_file] [ $apache_conf_path_http_dst_dir]---[$apache_conf_path_https_src_file] [$apache_conf_path_https_dst_dir]---[$apache_conf_path_sslparams_src_file]---[$apache_conf_path_sslparams_dst_dir]"
    
    echo "[*] Got [ $apache_conf_path_http_src_file ]  destpath to ---> [ $apache_conf_path_http_dst_dir ]"
    cp $apache_conf_path_http_src_file $apache_conf_path_http_dst_dir

    echo "[*] Got [  $apache_conf_path_https_src_file ]  destpath to ---> [ $apache_conf_path_https_dst_dir ]"
    cp $apache_conf_path_https_src_file $apache_conf_path_https_dst_dir

    echo "[*] Got [ $apache_conf_path_sslparams_src_file ]  destpath to ---> [ $apache_conf_path_sslparams_dst_dir ]"
    cp $apache_conf_path_sslparams_src_file  $apache_conf_path_sslparams_dst_dir

    echo "-------------[  $apache_conf_path_http]---[$apache_conf_path_http_src_file] [ $apache_conf_path_http_dst_dir]---[$apache_conf_path_https_src_file] [$apache_conf_path_https_dst_dir]---[$apache_conf_path_sslparams_src_file]---[$apache_conf_path_sslparams_dst_dir]"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------[a2enconf ssl-params ~ sudo a2enmod ssl ~  sudo a2enmod headers ~ sudo a2ensite default-ssl ~ sudo apache2ctl configtest ~ sudo systemctl restart apache2 ]------------------"
    #Next, enable your SSL Virtual Host with the a2ensite command: 
    #You’ll also need to enable your ssl-params.conf file, to read in the values you set:
    #At this point, your site and the necessary modules are enabled. 
    #Check to make sure that there are no syntax errors in your files with a test:
    sudo a2enconf ssl-params
    sudo a2enmod ssl   
    sudo a2enmod headers
    sudo a2ensite default-ssl
    sudo a2enmod rewrite
    sudo apache2ctl configtest
    sudo systemctl restart apache2
    echo "-------------[ sudo systemctl restart apache2 ]------------------"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------CORE MySQL Instalation------------------"
    echo
    echo
    echo "------------MySQL started-[sudo apt install mysql-server -y;]-------------------"

    #wget https://dev.mysql.com/get/mysql-apt-config_0.8.12-1_all.deb
    #sudo dpkg -i mysql-apt-config_0.8.12-1_all.deb
    #sudo apt update
    #sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29
    #sudo apt update
    #sudo apt-cache policy mysql-server
    #sudo apt install -f mysql-client=5.7* mysql-community-server=5.7* mysql-server=5.7*
    #sudo mysql_secure_installation
    #mysql -u root -p 
    #SELECT VERSION();
    #SELECT user FROM mysql.user;
    #sudo systemctl status mysql

    #PHP_VERSION="7.3"
    #MYSYQL_VERSION="5.7*"
    #sudo apt install mysql-server -y;
    #sudo apt install mysql-server=5.7* -y;
    echo
    echo
    echo "------[ mysql --version : removal ]------"
    #PHP_VERSION="7.3"
    #MYSYQL_VERSION="5.7*"
    sudo systemctl stop mysql
    sudo killall -9 mysql
    sudo killall -9 mysqld
    sudo apt-get -y remove –purge mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*
    sudo rm -rf /var/log/mysql
    sudo rm -rf /etc/mysql
    sudo rm -rf /usr/bin/mysql
    sudo deluser -f mysql
    sudo apt autoremove -y
    sudo apt autoclean -y
    echo "------[ mysql --version : removal ]------"
    echo
    echo
    echo
    echo
    echo "------[ mysql --version : post removal - expected be clean/fail]------"
    mysql --version
    echo "------[ mysql --version : post removal - expected be clean/fail]------"
    echo
    echo
    echo
    echo
    echo "------[ mysql --version]------"
    #PHP_VERSION="7.3"
    #MYSYQL_VERSION="5.7*"
    sudo apt install php${PHP_VERSION} libapache2-mod-php${PHP_VERSION} php${PHP_VERSION}-mysql -y
    sudo apt install mysql-server=${MYSYQL_VERSION} -y
    #apt install mysql-client-core-{PHP_VERSION}   
    #apt install mariadb-client-core-10.1
    echo "------[ mysql --version]------"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------[    php  --version;    mysql --version;    php -v;    /usr/bin/php -v; ]--"
    php  --version;   php -v;    /usr/bin/php -v;   mysql --version
    echo "-------[    php  --version;    mysql --version;    php -v;    /usr/bin/php -v; ]--"
    echo
    echo
    echo "Check these versions before you continue, otherwise trouble ahead! [EXPECTED mysql<=5.7] [EXPECTED php<=7.3]. Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------MySQL started [mysql -u root -e create database blockaptdb;]-------------------"
    mysql -u root -e "create database blockaptdb";
    echo "-------------MySQL started [mysql -u root -e create database blockaptdb;]-------------------"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------MySQL started [ mysql -u root -e show databases;]-------------------"
    mysql -u root -e "show databases";
    echo "-------------MySQL started [ mysql -u root -e show databases;]-------------------"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------MySQL started [mysql -u root -e SHOW TABLES;]-------------------"
    mysql -u root -e "USE blockaptdb; SHOW TABLES";
    echo "-------------MySQL started [mysql -u root -e SHOW TABLES;]-------------------"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------MySQL started [mysql -u root -e CREATE USER '*****'@'localhost' IDENTIFIED BY '*****';]-------------------"
    mysql -u root -e "CREATE USER 'blockaptdbuser'@'localhost' IDENTIFIED BY 'NTM0yaddasht'";
    echo "-------------MySQL started [mysql -u root -e CREATE USER '*****'@'localhost' IDENTIFIED BY '*****';]-------------------"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------MySQL started [ mysql -u root -e GRANT ALL ON blockaptdb.* TO 'blockaptdbuser'@'localhost';]-------------------"
    mysql -u root -e "GRANT ALL ON blockaptdb.* TO 'blockaptdbuser'@'localhost'";
    echo "-------------MySQL started [ mysql -u root -e GRANT ALL ON blockaptdb.* TO 'blockaptdbuser'@'localhost';]-------------------"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo "-------------[mysql -u root -e SHOW GRANTS FOR 'blockaptdbuser'@'localhost';]-------------------"
    mysql -u root -e "SHOW GRANTS FOR 'blockaptdbuser'@'localhost'";
    echo "-------------[mysql -u root -e SHOW GRANTS FOR 'blockaptdbuser'@'localhost';]-------------------"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------  mysql -u root -e FLUSH PRIVILEGES;-------------------"
    mysql -u root -e "FLUSH PRIVILEGES";
    echo "-------------  mysql -u root -e FLUSH PRIVILEGES;-------------------"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo
    echo "-------------composer in [functionInstallMySQLLaravel] update started------------------"
    sudo apt-get install php${PHP_VERSION}-curl
    #sudo apt-get install php-curl -y
    echo "-------------composer update started [sudo systemctl restart apache2]------------------"
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo "-------------composer [functionInstallMySQLLaravel] update  [cd /var/www/html/blockaptv9] [/usr/bin/php /usr/local/bin/composer update]------------------"
    cd /var/www/html/blockaptv9
    export COMPOSER_ALLOW_SUPERUSER="1"
    
    echo "Here is the PHP version used..."
    php -v;    /usr/bin/php -v;
    echo "Here is the PHP version used..."
    echo
    echo
    /usr/bin/php /usr/local/bin/composer update
    #chown -R www-data:www-data /var/www/html/blockaptv9/storage/
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------composer update started [/usr/bin/php artisan key:generate]------------------"
    echo "Here is the PHP version used..."
    php -v;    /usr/bin/php -v;
    echo "Here is the PHP version used..."
    /usr/bin/php artisan key:generate
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------composer update started [/usr/bin/php artisan config:clear]------------------"
    echo "Here is the PHP version used..."
    php -v;    /usr/bin/php -v;
    echo "Here is the PHP version used..."
    /usr/bin/php artisan config:clear
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------composer update started [/usr/bin/php artisan migrate --seed]------------------"
    echo "Here is the PHP version used..."
    php -v;    /usr/bin/php -v;
    echo "Here is the PHP version used..."
    /usr/bin/php artisan migrate --seed
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------composer update started [/usr/bin/php artisan cache:clear ]------------------"
    echo "Here is the PHP version used..."
    php -v;    /usr/bin/php -v;
    echo "Here is the PHP version used..."
    /usr/bin/php artisan cache:clear 
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------composer update started [  /usr/bin/php artisan view:clear]------------------"
    echo "Here is the PHP version used..."
    php -v;    /usr/bin/php -v;
    echo "Here is the PHP version used..."
    /usr/bin/php artisan view:clear
    #/usr/bin/php migrate:fresh
    #/usr/bin/php artisan migrate
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    echo "-------------composer update started [   sudo a2enmod rewrite]------------------"
    sudo a2enmod rewrite
    sudo systemctl restart apache2
    systemctl status apache2
     echo "-------------composer update started [  sudo service restart nginx]------------------"
    sudo service restart nginx
    echo "-------------composer update started [   systemctl status nginx]----[  systemctl status nginx]--------------"
    systemctl status nginx
    echo "Press a key to continue..."
    read PAUSE
    echo "-------------composer update Completed------------------"
    echo
    echo
    echo "-------------sudoers started------------------"
    echo "daemon ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 
    echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 
    echo "-------------[cat /etc/sudoers]------------------"
    cat /etc/sudoers
    echo "-------------sudoers Completed------------------"  
    echo "Press a key to continue..."
    read PAUSE
    echo
    echo
    sleep $SLEEPER
}




#####################################################
#Restart BA Services
#####################################################
functionRestartAllServices () {
 ID=35
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionRestartAllServices		    "
 echo -e "\e[1;31m ############################################### \e[m"

 echo "----------------------------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "----------------------------------------------------"
 echo
 echo
 echo
 sleep $SLEEPER

 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}

 echo "-------------------------------"
 apt-get -y update
 echo "Starting core services.... Please wait..."
 echo "-------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "--------------ctlscript--------------------------"
 	###/opt/bitnami/ctlscript.sh restart
   echo "---------[ service nginx restart ]---------"
   service nginx restart
   echo "------[ service apache2 restart ]------------"
   service apache2 restart
   echo "------[ service apache2 restart ]------------"
   systemctl status nginx
   echo "------[ systemctl status apache2 ]------------"
   systemctl status apache2
   echo "-------------------[service apache2 restart] [systemctl status nginx]------------------------"
 echo "--------------ctlscript--------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "--------------nginx restart--------------------------"
 sudo service nginx restart  
 systemctl status nginx
 echo "--------------nginx restart--------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "-----------systemctl enable mongod---------------"
 systemctl enable mongod
 echo "-------------------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "-------- systemctl enable ntopng-----------------"
 systemctl enable ntopng
 echo "-------------------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "-------------- systemctl restart mongod----------"
 rm -f /tmp/mongodb-27017.sock
 systemctl restart mongod
 sudo service mongod stop
 sudo rm /var/lib/mongodb/mongod.lock
 echo "-------------- systemctl restart mongod----------"
 #sudo mongod --repair
 #sudo mongod --fork --logpath /var/lib/mongodb/mongodb.log --dbpath /var/lib/mongodb --replSet rs0
  echo "----------------[mongod --repair ]------[mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log  --replSet rs0 --bind_ip localhost,localhost.local]---------------------------"
 mongod --repair 
 mongod --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongod.log  --replSet rs0 --bind_ip localhost,localhost.local
 echo "-----------------[ sudo service mongod start--------------------------------"
 sudo service mongod start
 mongosh --eval "rs.initiate()"
 echo "-------------------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "----------------systemctl restart ntopng---------"
 systemctl restart ntopng
 echo "-------------------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "-------------- systemctl status mongod-----------"
 systemctl status mongod
 echo "-------------------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "-------------systemctl status ntopng-------------"
 systemctl status ntopng
 echo "-------------------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "----------------netstat -nape | grep LIST | grep mongo----------------------"
 netstat -nape | grep LIST | grep mongo
 echo "--------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "---------------netstat -nape | grep LIST | grep nginx-----------------------"
 netstat -nape | grep LIST | grep nginx
 echo "--------------------------------------"
 echo
 echo
  sleep $SLEEPER
 echo "---------------netstat -nape | grep LIST | grep apache-----------------------"
 netstat -nape | grep LIST | grep apache
 echo "--------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "----------netstat -nape | grep LIST | grep mysql----------------------------"
 netstat -nape | grep LIST | grep mysql
 echo "--------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "------------- netstat -nape | grep LIST | grep node-------------------------"
 netstat -nape | grep LIST | grep node
 echo "--------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "-------------netstat -nape | grep LIST | grep pm2-------------------------"
 netstat -nape | grep LIST | grep pm2
 echo "--------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "-------------netstat -nape | grep LIST | grep ntopng-------------------------"
 netstat -nape | grep LIST | grep ntopng
 echo "--------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "-------------netstat -nape | grep LIST | grep nginx-------------------------"
 netstat -nape | grep LIST | grep nginx
 echo "--------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "-------------netstat -nape | grep LIST | grep apache2-------------------------"
 netstat -nape | grep LIST | grep apache2
 echo "--------------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "--------------------------------------"
 #echo "/opt/bitnami/ctlscript.sh restart" >> /etc/rc.local
 #cp -f /opt/bitnami/ctlscript.sh /etc/init.d/ctlscript.sh 
 echo "--------------------------------------"
 echo
 echo
 sleep $SLEEPER
 #echo "--------------------------Setting services to auto start--------------------------------"
 #update-rc.d ctlscript.sh  defaults
 #echo "--------------------------Setting services to auto start--------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "------------------------------Services Started and ready--------------------------------"
 netstat -nape | grep LIST | grep :
 echo "------------------------------Services Started and ready--------------------------------"
 echo
 echo
 sleep $SLEEPER
 echo "------------------------------ALL SERVICES STARTS BUNDLE-------------------------------"

 sleep $SLEEPER
 echo "----------[chmod +x /etc/rc.d/rc.local]---------------------"
 touch /etc/rc.d/rc.local
 echo "" >> /etc/rc.d/rc.local
 chmod +x /etc/rc.d/rc.local
 echo "------------------------------------------------------------" 
 echo
 echo
 echo
 sleep $SLEEPER
 echo "--------[/opt/bitnami/ctlscript.sh start >> /etc/rc.d/rc.local]-----------------------" 

 #echo "/etc/init.d/apache2 stop" >> /etc/rc.d/rc.local
 #echo "/opt/splunk/bin/splunk stop" >> /etc/rc.d/rc.local
 #echo "/opt/bitnami/ctlscript.sh stop" >> /etc/rc.d/rc.local
 #echo "systemctl stop mongod"  >> /etc/rc.d/rc.local
 
 #echo "/opt/bitnami/ctlscript.sh restart" >> /etc/rc.d/rc.local
 #echo "systemctl restart mongod" >> /etc/rc.d/rc.local
 #echo "/opt/splunk/bin/splunk restart"  >> /etc/rc.d/rc.local

 echo "rc.local start up script executed...at [`date`]" >> /etc/rc.d/rc.local.log
 echo "---------------------------------------------------------------------------------------"
 echo
 echo
 echo
 sleep $SLEEPER
 echo "-------------------------------"
 cat /etc/rc.d/rc.local
 echo "-------------------------------"
 echo
 echo
 echo
 sleep $SLEEPER
 echo "--------------[ netstat -nape | grep :443]-----------------"
 #/etc/init.d/apache2 stop
 #/opt/bitnami/ctlscript.sh start
 netstat -nape | grep :443
 echo "-------------[ netstat -nape | grep :443]------------------"
 echo
 echo
 echo "-----------[/opt/bitnami/ctlscript.sh start]-[/opt/splunk/bin/splunk stop -f] [systemctl start mongod]-------------------" 
 	###/opt/bitnami/ctlscript.sh restart
   echo "---------[ service nginx restart ]---------"
   service nginx restart
   echo "------[ service apache2 restart ]------------"
   service apache2 restart
   echo "------[ service apache2 restart ]------------"
   systemctl status nginx
   echo "------[ systemctl status apache2 ]------------"
   systemctl status apache2
   echo "-------------------[service apache2 restart] [systemctl status nginx]------------------------"
 echo "-----------[ /opt/splunk/bin/splunk restart]--------------------"
 /opt/splunk/bin/splunk restart
 echo "----------------[systemctl restart mongod]---------------"
 rm -f /tmp/mongodb-27017.sock
 systemctl restart mongod
 echo "----------[ systemctl restart ntopng]---------------------"
 systemctl restart ntopng
 echo "---------------------------------------------------------------------------------------------" 
 echo
 echo
 echo
 echo "------------------------------ALL SERVICES STARTS BUNDLE COMPLETED-------------------------------"
 sleep $SLEEPER
}




#####################################################
#Check if script already executed and tmp value set
#####################################################
functionCheckIfLogout () {
 ID=7
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionCheckIfLogout			    "
 echo -e "\e[1;31m ############################################### \e[m"
 
 echo "-------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "-------------------------------"
 echo
 echo
 echo
 sleep $SLEEPER

 if [ -f $PREVIOUS_INSTALL_FILE ]; then
    echo "-------------------------------"
    echo "Install file [$PREVIOUS_INSTALL_FILE] exist from previous logout...continue..."
    echo "Please wait..."
    echo "-------------------------------"
    sleep $SLEEPER
 else 
   echo "-------------------------------"
   echo "Install file [$PREVIOUS_INSTALL_FILE] doe \e[1;37m[\e[m\e[1;31m[NOT]\e[m\e[1;37m]\e[m exist. Exit the shell and run the script again..."
   echo "-------------------------------"
   echo "Please wait..."
   sleep $SLEEPER
   functionCleanUpOnExit
 fi
 echo "-------------------------------"
 echo "Exiting functionCheckIfLogout...Please wait..."
 echo "-------------------------------"
 sleep $SLEEPER
}




#####################################################
# Remove files and exits 
#####################################################
functionCleanUpOnExit () {
 ID=36
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo " Starting  functionCleanUpOnExit      "
 echo -e "\e[1;31m ############################################## \e[m"
 echo
 echo
 echo "----------------------------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo -e "[\e[1;37m[\e[m\e[1;31m[functionCleanUpOnExit]\e[m\e[1;37m]\e[m - [{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "----------------------------------------------------"
 echo
 echo
 echo "-------------VARIABLES ON EXIT FAILURES--------------"
 echo "SLEEPER=$SLEEPER"
 echo "MONGOD_VERSION=$MONGOD_VERSION"
 echo "MONGOD_VERSION_REPO=$MONGOD_VERSION_REPO"
 echo "MONGOD_VERSION_DB=$MONGOD_VERSION_DB"
 echo "MONGO_VERSION=$MONGO_VERSION"
 echo "CODE_BRANCH=$CODE_BRANCH"
 echo "{INSTALL_HOME_DIR}=${INSTALL_HOME_DIR}"
 echo "PYTHON_NAME_FILE=$PYTHON_NAME_FILE"
 echo "PREVIOUS_INSTALL_FILE=$PREVIOUS_INSTALL_FILE"
 echo "DB_PASSWORD_FILE=$DB_PASSWORD_FILE"
 echo "PREVIOUS_INSTALL_FILE{ID}=$PREVIOUS_INSTALL_FILE_${ID}"
 echo "-----------------VARIABLES ON EXIT FAILURES------------"
 echo
 echo
 echo "[functionCleanUpOnExit] completed..."
 echo "-------------------------------------------------------"
 echo
 echo
sleep $SLEEPER
}





#####################################################
# Check that the platform is compatible before installating 
#####################################################
functionCheckPlatformCompa () {
 ID=3
 echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
 echo
 echo
 echo  
 
 echo -e "\e[1;31m ############################################### \e[m"
 echo "Starting  functionCheckPlatformCompa "
 echo -e "\e[1;31m ############################################## \e[m"

 
 echo "----------------------------------------------------"
 echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
 echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
 echo "----------------------------------------------------"
 echo
 echo
 echo
sleep $SLEEPER

 echo
 echo
 echo
 if [ $IS_UBUNTU -ge 1 ]; then
  echo "-------------------------------------------"
  echo "Current platform is compatible: [UBUNTU_RELEASE=$UBUNTU_RELEASE][UBUNTU_CODENAME=$UBUNTU_CODENAME][UBUNTU_ID=$UBUNTU_ID]"
  echo "Please wait..."
  echo "-------------------------------------------"
 sleep $SLEEPER
 else
  echo "-------------------------------------------"
  echo -e "Current platform is [\e[1;37m[\e[m\e[1;31m[NOT]\e[m\e[1;37m]\e[m compatible. Aborting... Current Platform is: [UBUNTU_RELEASE=$UBUNTU_RELEASE][UBUNTU_CODENAME=$UBUNTU_CODENAME][UBUNTU_ID=$UBUNTU_ID]"
  echo "Please wait..."
  echo "-------------------------------------------"
 sleep $SLEEPER
  functionCleanUpOnExit
 fi

 echo
 echo
 echo

  php -v;    /usr/bin/php -v;
 if [ $? -eq 0 ]; then
  echo "-------------------------------------------"
  echo -e "PHP is installed... [\e[1;37m[\e[m\e[1;31m[ABORING]\e[m\e[1;37m]\e[m...Current Platform is: [UBUNTU_RELEASE=$UBUNTU_RELEASE][UBUNTU_CODENAME=$UBUNTU_CODENAME][UBUNTU_ID=$UBUNTU_ID]"
  functionCleanUpOnExit
  echo "-------------------------------------------"
else
  echo "-------------------------------"
  echo "PHP is not already installed. OK to continue.. Current Platform is: [UBUNTU_RELEASE=$UBUNTU_RELEASE][UBUNTU_CODENAME=$UBUNTU_CODENAME][UBUNTU_ID=$UBUNTU_ID]"
  echo "-------------------------------"
fi
 
 echo
 echo
 echo
 
 ENV_CURRENT=`env | grep bitnami | wc -l`
 if [ $ENV_CURRENT -ge 1 ]; then
  echo "-------------------------------------------"
  echo -e "Bitnami path is already set. [\e[1;37m[\e[m\e[1;31m[ABORTING]\e[m\e[1;37m]\e[m... Current Platform is: [UBUNTU_RELEASE=$UBUNTU_RELEASE][UBUNTU_CODENAME=$UBUNTU_CODENAME][UBUNTU_ID=$UBUNTU_ID]"
  functionCleanUpOnExit
  echo "-------------------------------------------"
 else
  echo "-------------------------------------------"
  echo "Bitnami path is NOT set. Continuing with install...Platform is: [UBUNTU_RELEASE=$UBUNTU_RELEASE][UBUNTU_CODENAME=$UBUNTU_CODENAME][UBUNTU_ID=$UBUNTU_ID]"
  echo "-------------------------------------------" 
 fi


 CURRENT_USER=`whoami | grep root | wc -l`
 if [ $CURRENT_USER -ge 1 ]; then
  echo "-------------------------------------------"
  echo "CURRENT_USER=$CURRENT_USER is set. OK to continue... Current Platform is: [UBUNTU_RELEASE=$UBUNTU_RELEASE][UBUNTU_CODENAME=$UBUNTU_CODENAME][UBUNTU_ID=$UBUNTU_ID]"
  echo "-------------------------------------------"
 else
  echo "-------------------------------------------"
  echo -e "CURRENT_USER=$CURRENT_USER is [\e[1;37m[\e[m\e[1;31m[NOT]\e[m\e[1;37m]\e[m set. Aborting... Current Platform is:[UBUNTU_RELEASE=$UBUNTU_RELEASE][UBUNTU_CODENAME=$UBUNTU_CODENAME][UBUNTU_ID=$UBUNTU_ID]"
  functionCleanUpOnExit
  echo "-------------------------------------------"

 fi
 echo "Please wait..."
sleep $SLEEPER
}




#####################################################
# create cront entries for IP block and archives...
#####################################################
functionAddCrons () {
  ID=32
  echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
  echo
  echo
  echo
 
  echo -e "\e[1;31m ############################################### \e[m"
  echo "Starting  functionAddCrons "
  echo -e "\e[1;31m ############################################## \e[m"

 
  echo "-------------------------------"
  echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
  echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
  echo "-------------------------------"
  echo
  echo
  echo
 sleep $SLEEPER
   echo "-------------------------------"   
   mkdir -v -p /etc/rc.d/
   touch /etc/rc.d/rc.local
   echo '#!/bin/bash' >> /etc/rc.d/rc.local
   echo 'systemctl stop mongod' >> /etc/rc.d/rc.local
   echo 'systemctl restart mongod' >> /etc/rc.d/rc.local
   echo '/opt/splunk/bin/splunk stop -f' >> /etc/rc.d/rc.local
   echo '/opt/splunk/bin/splunk clean eventdata -f' >> /etc/rc.d/rc.local
   echo '/opt/splunk/bin/splunk start' >> /etc/rc.d/rc.local
   echo '/opt/splunk/bin/splunk start -f' >> /etc/rc.d/rc.local
   chmod +x /etc/rc.d/rc.local
   echo "-------------------------------"
   echo
   echo
   echo "-------------------------------"
   cat /etc/rc.d/rc.local
   echo "-------------------------------"
   echo
   echo
   echo
  sleep $SLEEPER
   echo "---------------------[crons /opt/splunk/bin/splunk & scripts]----------------------"
   { crontab -l -u root; echo '00 23 * * *  /opt/splunk/bin/splunk stop -f'; } | crontab -u root -
   { crontab -l -u root; echo '10 23 * * *  /opt/splunk/bin/splunk clean eventdata -f'; } | crontab -u root -
   { crontab -l -u root; echo '15 23 * * *  /opt/splunk/bin/splunk start -f'; } | crontab -u root -
   { crontab -l -u root; echo '@reboot     /bin/bash /etc/rc.d/rc.local > /etc/rc.d/rc.local.log 2>&1'; } | crontab -u root -
   echo "---------------------[crons /opt/splunk/bin/splunk & scripts]-----------------------"
   echo
   echo
   echo
   echo "------------------------------=Crontab content--------------------="
   crontab -l
   echo "--------------------Cron updates completed...----------====="
  sleep $SLEEPER
}





#####################################################
# Installalling Splunk SIEM as local
#####################################################
functionInstallSplunk () {
  ID=33
  echo
  echo
  echo
  echo -e "\e[1;31m ############################################### \e[m"
  echo "Starting  functionInstallSplunk  "
  echo -e "\e[1;31m ############################################## \e[m"
 
 
  echo "-------------------------------------------"
  echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
  echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
  echo "-------------------------------------------"
  echo
  echo
  echo
 sleep $SLEEPER
  echo "------------------------------Starting splunk installation...----------====="
   
  cd ${INSTALL_HOME_DIR}
  echo
  echo
  echo
 sleep $SLEEPER
  echo "-------------------------------------------"
  WGET_SPLUNK="'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.3.0&product=splunk&filename=splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb&wget=true'"
  echo "-------------------------------------------"
  echo
  echo
  echo
 sleep $SLEEPER
  cd $INSTALL_HOME_DIR
  echo "-----[DEBP_SPLUNK=[$DEBP_SPLUNK] <<>> [WGET_SPLUNK=[$WGET_SPLUNK]]------------"
  echo "------------[wget -O $DEBP_SPLUNK $WGET_SPLUNK]-------------------------------"
 sleep $SLEEPER
  echo "------------------------------------------------------------------------------" 
    ########wget -O splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb "$DEBP_SPLUNK $WGET_SPLUNK"
  echo "------------------------------------------------------------------------------" 
 sleep $SLEEPER
  echo "------------------------------------------------------------------------------" 
  ########dpkg -i "$DEBP_SPLUNK"
  echo "------------------------------------------------------------------------------" 
  echo
  echo
  echo
 sleep $SLEEPER
  ########-----[DEBP_SPLUNK=[splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb] <<>> [WGET_SPLUNK=['https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.3.0&product=splunk&filename=splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb&wget=true']]
  ########----------[wget -O splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.3.0&product=splunk&filename=splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb&wget=true']-------------------------------
  ########------------------------------------------------------------------------------
  ########'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.3.0&product=splunk&filename=splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb&wget=true': Scheme missing.
  ########------------------------------------------------------------------------------
  ########sleep  100
  echo "------------------------------------WGET COMMANDS------------------------------------------" 
  echo "wget -O splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.3.0&product=splunk&filename=splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb&wget=true'"
  echo "dpkg -i splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb"
  echo "/opt/splunk/bin/splunk start -f"
  echo "------------------------------------WGET COMMANDS------------------------------------------" 
  echo
  echo
  echo
 sleep $SLEEPER
  echo "------------------------------------[wget -O splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb]-------------------" 
  wget -O splunk-8.2.4-87e2dda940d1-linux-2.6-amd64.deb 'https://download.splunk.com/products/splunk/releases/8.2.4/linux/splunk-8.2.4-87e2dda940d1-linux-2.6-amd64.deb'
  echo "------------------------------------[wget -O splunk-7.3.0-657388c7a488-linux-2.6-amd64.deb]-------------------" 
  echo
  echo
  echo
 sleep $SLEEPER
  echo "-------------------[sudo kill -9 $(ps ax | grep dpkg | fgrep -v grep | awk '{ print $1 }')]------------------------------------------" 
  kill -9 $(ps ax | grep dpkg | fgrep -v grep | awk '{ print $1 }')  
  kill -9 $(ps ax | grep dpkg | fgrep -v grep | awk '{ print $2 }')
  echo "-------------------[sudo kill -9 $(ps ax | grep dpkg | fgrep -v grep | awk '{ print $1 }')]------------------------------------------" 
  echo
  echo
  echo
 sleep $SLEEPER
  dpkg -i splunk-8.2.4-87e2dda940d1-linux-2.6-amd64.deb
  echo "------------------------------------------------------------------------------" 
  echo
  echo
  echo
 sleep $SLEEPER
  echo "-------------------- [/opt/splunk/bin/splunk start -f]-----------------------"
  /opt/splunk/bin/splunk start
  echo "-------------------- [/opt/splunk/bin/splunk start -f]-----------------------"
  echo
  echo  
  echo "---------------------[Creating Source Ports /opt/splunk/bin/splunk add tcp]-----------------------" 
   /opt/splunk/bin/splunk add tcp 13001 -sourcetype generic_single_line -index tcp13001
   /opt/splunk/bin/splunk add tcp 13002 -sourcetype generic_single_line -index tcp13002
   /opt/splunk/bin/splunk add tcp 13003 -sourcetype generic_single_line -index tcp13003
   /opt/splunk/bin/splunk add tcp 13004 -sourcetype generic_single_line -index tcp13004
   /opt/splunk/bin/splunk add tcp 13005 -sourcetype generic_single_line -index tcp13005
   /opt/splunk/bin/splunk add tcp 13889 -sourcetype generic_single_line -index tcp13889
   /opt/splunk/bin/splunk add tcp 13670 -sourcetype generic_single_line -index tcp13670
   /opt/splunk/bin/splunk add tcp 13901 -sourcetype generic_single_line -index tcp13901
   /opt/splunk/bin/splunk add tcp 13991 -sourcetype generic_single_line -index tcp13991
   /opt/splunk/bin/splunk add tcp 13992 -sourcetype generic_single_line -index tcp13992
   /opt/splunk/bin/splunk add tcp 13995 -sourcetype generic_single_line -index tcp13995
   /opt/splunk/bin/splunk add tcp 13996 -sourcetype cisco:asa           -index tcp13996
   /opt/splunk/bin/splunk add tcp 13998 -sourcetype generic_single_line -index tcp13998
   /opt/splunk/bin/splunk add tcp 13999 -sourcetype generic_single_line -index tcp13999
   /opt/splunk/bin/splunk add tcp 13161 -sourcetype generic_single_line -index tcp13161
   /opt/splunk/bin/splunk add tcp 13162 -sourcetype generic_single_line -index tcp13162
   /opt/splunk/bin/splunk add tcp 13990 -sourcetype generic_single_line -index tcp13990
   /opt/splunk/bin/splunk add tcp 13988 -sourcetype generic_single_line -index tcp13988
   /opt/splunk/bin/splunk add tcp 13989 -sourcetype generic_single_line -index tcp13989
   /opt/splunk/bin/splunk add tcp 13990 -sourcetype generic_single_line -index tcp13990
   /opt/splunk/bin/splunk add tcp 13991 -sourcetype generic_single_line -index tcp13991
   /opt/splunk/bin/splunk add tcp 13989 -sourcetype generic_single_line -index tcp13989
   /opt/splunk/bin/splunk add tcp 13511 -sourcetype generic_single_line -index tcp13511
   /opt/splunk/bin/splunk add tcp 13993 -sourcetype generic_single_line -index tcp13993
   /opt/splunk/bin/splunk add tcp 13536 -sourcetype generic_single_line -index tcp13536
   /opt/splunk/bin/splunk add tcp 13561 -sourcetype generic_single_line -index tcp13561
   /opt/splunk/bin/splunk add tcp 13521 -sourcetype generic_single_line -index tcp13521
   /opt/splunk/bin/splunk add tcp 13535 -sourcetype generic_single_line -index tcp13535
   /opt/splunk/bin/splunk add tcp 13512 -sourcetype generic_single_line -index tcp13512
   /opt/splunk/bin/splunk add tcp 13513 -sourcetype generic_single_line -index tcp13513
  echo "------------------------------------------------------------------------------" 
  echo
  echo
  echo "---------------------[Creating Source Ports /opt/splunk/bin/splunk add tcp]--------------------------" 
   /opt/splunk/bin/splunk add tcp 23001 -sourcetype generic_single_line -index tcp23001
   /opt/splunk/bin/splunk add tcp 23002 -sourcetype generic_single_line -index tcp23002
   /opt/splunk/bin/splunk add tcp 23003 -sourcetype generic_single_line -index tcp23003
   /opt/splunk/bin/splunk add tcp 23004 -sourcetype generic_single_line -index tcp23004
   /opt/splunk/bin/splunk add tcp 23005 -sourcetype generic_single_line -index tcp23005
   /opt/splunk/bin/splunk add tcp 23889 -sourcetype generic_single_line -index tcp23889
   /opt/splunk/bin/splunk add tcp 23670 -sourcetype generic_single_line -index tcp23670
   /opt/splunk/bin/splunk add tcp 23901 -sourcetype generic_single_line -index tcp23901
   /opt/splunk/bin/splunk add tcp 23991 -sourcetype generic_single_line -index tcp23991
   /opt/splunk/bin/splunk add tcp 23992 -sourcetype generic_single_line -index tcp23992
   /opt/splunk/bin/splunk add tcp 23995 -sourcetype generic_single_line -index tcp23995
   /opt/splunk/bin/splunk add tcp 23996 -sourcetype cisco:asa           -index tcp23996
   /opt/splunk/bin/splunk add tcp 23998 -sourcetype generic_single_line -index tcp23998
   /opt/splunk/bin/splunk add tcp 23999 -sourcetype generic_single_line -index tcp23999
   /opt/splunk/bin/splunk add tcp 23161 -sourcetype generic_single_line -index tcp23161
   /opt/splunk/bin/splunk add tcp 23162 -sourcetype generic_single_line -index tcp23162
   /opt/splunk/bin/splunk add tcp 23990 -sourcetype generic_single_line -index tcp23990
   /opt/splunk/bin/splunk add tcp 23988 -sourcetype generic_single_line -index tcp23988
   /opt/splunk/bin/splunk add tcp 23989 -sourcetype generic_single_line -index tcp23989
   /opt/splunk/bin/splunk add tcp 23990 -sourcetype generic_single_line -index tcp23990
   /opt/splunk/bin/splunk add tcp 23991 -sourcetype generic_single_line -index tcp23991
   /opt/splunk/bin/splunk add tcp 23989 -sourcetype generic_single_line -index tcp23989
   /opt/splunk/bin/splunk add tcp 23511 -sourcetype generic_single_line -index tcp23511
   /opt/splunk/bin/splunk add tcp 23993 -sourcetype generic_single_line -index tcp23993
   /opt/splunk/bin/splunk add tcp 23536 -sourcetype generic_single_line -index tcp23536
   /opt/splunk/bin/splunk add tcp 23561 -sourcetype generic_single_line -index tcp23561
   /opt/splunk/bin/splunk add tcp 23521 -sourcetype generic_single_line -index tcp23521
   /opt/splunk/bin/splunk add tcp 23535 -sourcetype generic_single_line -index tcp23535
   /opt/splunk/bin/splunk add tcp 23512 -sourcetype generic_single_line -index tcp23512
   /opt/splunk/bin/splunk add tcp 23513 -sourcetype generic_single_line -index tcp23513
   

   echo "------------------------------------------------------------------------------"
  echo
  echo

  echo "---------------------[Creating Source Index /opt/splunk/bin/splunk add tcp]-----------------------" 
   /opt/splunk/bin/splunk add index tcp13001
   /opt/splunk/bin/splunk add index tcp13002
   /opt/splunk/bin/splunk add index tcp13003
   /opt/splunk/bin/splunk add index tcp13004
   /opt/splunk/bin/splunk add index tcp13005
   /opt/splunk/bin/splunk add index tcp13889
   /opt/splunk/bin/splunk add index tcp13670
   /opt/splunk/bin/splunk add index tcp13901
   /opt/splunk/bin/splunk add index tcp13991
   /opt/splunk/bin/splunk add index tcp13992
   /opt/splunk/bin/splunk add index tcp13995
   /opt/splunk/bin/splunk add index tcp13996
   /opt/splunk/bin/splunk add index tcp13998
   /opt/splunk/bin/splunk add index tcp13999
   /opt/splunk/bin/splunk add index tcp13161
   /opt/splunk/bin/splunk add index tcp13162
   /opt/splunk/bin/splunk add index tcp13990
   /opt/splunk/bin/splunk add index tcp13988
   /opt/splunk/bin/splunk add index tcp13989
   /opt/splunk/bin/splunk add index tcp13990
   /opt/splunk/bin/splunk add index tcp13991
   /opt/splunk/bin/splunk add index tcp13989
   /opt/splunk/bin/splunk add index tcp13511
   /opt/splunk/bin/splunk add index tcp13521
   /opt/splunk/bin/splunk add index tcp13993
   /opt/splunk/bin/splunk add index tcp13536
   /opt/splunk/bin/splunk add index tcp13556
   /opt/splunk/bin/splunk add index tcp13535
   /opt/splunk/bin/splunk add index tcp13561
   /opt/splunk/bin/splunk add index tcp13512
   /opt/splunk/bin/splunk add index tcp13513
  
  echo "------------------------------------------------------------------------------" 
  echo
  echo
  echo "---------------------[Creating Source Index /opt/splunk/bin/splunk add tcp]--------------------------" 
   /opt/splunk/bin/splunk add index tcp23001
   /opt/splunk/bin/splunk add index tcp23002
   /opt/splunk/bin/splunk add index tcp23003
   /opt/splunk/bin/splunk add index tcp23004
   /opt/splunk/bin/splunk add index tcp23005
   /opt/splunk/bin/splunk add index tcp23889
   /opt/splunk/bin/splunk add index tcp23670
   /opt/splunk/bin/splunk add index tcp23901
   /opt/splunk/bin/splunk add index tcp23991
   /opt/splunk/bin/splunk add index tcp23992
   /opt/splunk/bin/splunk add index tcp23995
   /opt/splunk/bin/splunk add index tcp23996
   /opt/splunk/bin/splunk add index tcp23998
   /opt/splunk/bin/splunk add index tcp23999
   /opt/splunk/bin/splunk add index tcp23161
   /opt/splunk/bin/splunk add index tcp23162
   /opt/splunk/bin/splunk add index tcp23990
   /opt/splunk/bin/splunk add index tcp23988
   /opt/splunk/bin/splunk add index tcp23989
   /opt/splunk/bin/splunk add index tcp23990
   /opt/splunk/bin/splunk add index tcp23991
   /opt/splunk/bin/splunk add index tcp23989
   /opt/splunk/bin/splunk add index tcp23511
   /opt/splunk/bin/splunk add index tcp23993
   /opt/splunk/bin/splunk add index tcp23536
   /opt/splunk/bin/splunk add index tcp23556
   /opt/splunk/bin/splunk add index tcp23535
   /opt/splunk/bin/splunk add index tcp23561
   /opt/splunk/bin/splunk add index tcp23512
   /opt/splunk/bin/splunk add index tcp23513
  echo "------------------------------------------------------------------------------"
  echo
  echo
  sleep $SLEEPER
}




#####################################################
# Installing ntopng Stats Server
#####################################################
functionInstallNtopng () {
 ID=23
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "        Starting functionInstallNtop			   "
 echo -e "\e[1;31m ############################################### \e[m"
 echo
 echo "--------------[sudo apt-get -y remove --auto-remove ntopng]-----------------"
 apt-get remove ntopng -y
 apt-get remove ntopng-data -y
 apt-get remove pfring -y 
 apt-get remove ndpi -y
 apt-get remove redis-server -y
 apt-get remove pfring -y
 apt-get remove pfring-dkms -y
 apt-get remove nprobe -y
 apt-get remove n2disk -y
 apt-get remove cento -y

 rm -rfv /usr/share/ntopng 
 rm -rfv /etc/ntopng 
 rm -rfv /usr/bin/ntopng
 rm -fv /usr/bin/ntopng
 rm -fv /usr/share/man/man8/ntopng.8
 rm -fv /run/ntopng.pid
 rm -fv /run/ntopng.conf
 rm -fv /run/ntopng.conf.raw
 rm -fv /usr/bin/ntopctl
 rm -fv /usr/bin/ntopng-utils-manage-config
 rm -fv /usr/bin/ntopng-utils-manage-updates
 rm -fv /usr/bin/ntopng-config
 rm -fv /var/tmp/ntopng
 rm -fv /usr/local/share/ntopng/

 apt-get remove ntopng -y
 apt-get remove ntopng-data -y
 apt-get remove pfring -y 
 apt-get remove ndpi -y
 apt-get remove redis-server -y
 apt-get remove pfring -y
 apt-get remove pfring-dkms -y
 apt-get remove nprobe -y
 apt-get remove n2disk -y
 apt-get remove cento -y
 echo "--------------[sudo apt-get -y remove --auto-remove ntopng]-----------------"
 echo
 echo
 sleep $SLEEPER
 echo
 echo

 echo "---------------[ wget http://apt.ntop.org/18.04/all/apt-ntop.deb]-------------------------"


#######Add the necessary dependencies.
echo "----------------------------------------"  
sudo apt install wget gnupg software-properties-common -y
echo "----------------------------------------"  

#######Download and install the Ntopng repository package.
echo "-------------------[http://apt.ntop.org/18.04/all/apt-ntop.deb]---------------------"  

wget http://apt.ntop.org/18.04/all/apt-ntop.deb
dpkg -i apt-ntop.deb
apt-get update

mkdir /var/lib/ntopng
chown -R ntopng:ntopng /var/lib/ntopng
systemctl restart ntopng
service ntopng restart

#######Install Ntopng.
echo "----------------------------------------"  
apt-get install pfring-dkms nprobe ntopng n2disk cento -y
echo "----------------------------------------"  
echo
echo
echo "----------------------------------------" 
systemctl start ntopng
systemctl enable ntopng
systemctl restart ntopng
echo "----------------------------------------"  
sleep $SLEEPER
echo "----------------------------------------"  
echo
echo
echo
#######Update the repository.
echo "----------------------------------------"  
apt-get update -y
echo "----------------------------------------"  
echo
echo
echo
echo
interfaceID=`ifconfig | grep ^e | awk -F ':' '{print $1}'`

     echo "-------------[G=/var/run/ntopng.pid >> /etc/ntopng/ntopng.conf]---------------------------"
                                     cp -v /etc/ntopng/ntopng.conf /etc/ntopng/ntopng.conf.OLD
           echo "-G=/var/run/ntopng.pid" >> /etc/ntopng/ntopng.conf		   
						  echo "-i=$interfaceID" >> /etc/ntopng/ntopng.conf
                          echo "-w=3000" >> /etc/ntopng/ntopng.conf
     echo "----------------------------------------"
sleep $SLEEPER
echo
echo
echo
echo "----------------------------------------"
           cp -v /run/ntopng.conf /run/ntopng.conf.OLD
           echo "-G=/var/run/ntopng.pid" >>  /run/ntopng.conf
                          echo "-i=$interfaceID" >>  /run/ntopng.conf
                          echo "-w=3000" >>  /run/ntopng.conf
echo "----------------------------------------"
sleep $SLEEPER
echo
echo
echo
echo "-----------------[/etc/ntopng/ntopng.start]-----------------------"     
     echo "--local-networks 10.0.0.0/8"  >> /etc/ntopng/ntopng.start
                    echo "--interface 1" >> /etc/ntopng/ntopng.start   
     echo "----------------------------------------"
sleep $SLEEPER
echo
echo
echo
echo "-----------------[ /etc/redis/redis.conf ][sed -i s/bind .*/bind 127.0.0.1/g /etc/redis/redis.conf]-----------------------"  
cp -v /etc/redis/redis.conf /etc/redis/redis.conf.OLD
sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf   
echo "-----------------[/etc/init.d/redis-server restart]-----------------------"
sleep $SLEEPER
echo
echo
echo
echo "----------------[systemctl restart restart]------------------------"
/etc/init.d/redis-server restart
echo "----------------[systemctl restart restart]------------------------"
sleep $SLEEPER
echo
echo
echo
echo "-----------------[systemctl restart redis-server]-----------------------"
systemctl restart redis-server
echo "----------------------------------------"
sleep $SLEEPER
echo
echo
echo
echo "------------------[cat /etc/ntopng/ntopng.conf | grep 3000]----------------------"
cat /etc/ntopng/ntopng.conf | grep 3000
echo "----------------------------------------"
sleep $SLEEPER
echo
echo
echo
echo "--------------[ cat /etc/ntopng/ntopng.conf | grep $interfaceID]--------------------------"
cat /etc/ntopng/ntopng.conf | grep $interfaceID
echo "----------------------------------------"
sleep $SLEEPER
echo
echo
echo
echo "---------------[ cat /etc/ntopng/ntopng.conf | grep $interfaceID]-------------------------"
cat /etc/ntopng/ntopng.conf | grep $interfaceID
echo "----------------------------------------"
sleep $SLEEPER
echo
echo
echo
echo
echo "--------[ sudo systemctl start ntopng]--------------------------------"
systemctl restart ntopng
systemctl enable ntopng
systemctl restart ntopng
echo "--------[ sudo systemctl start ntopng]--------------------------------"
echo
echo
echo
sleep $SLEEPER
echo
echo
echo
echo "--------------------------------ntop installed version [ntopng -V]----------------------------------"
ntopng -V 
echo "--------------------------------ntop install [ntopng -V]--------------------------------------------" 
sleep $SLEEPER
echo
echo
echo
echo
echo "-------------[ netstat -nape | grep :3000 | grep LIST]---------------------------"
netstat -nape | grep :3000 | grep LIST
echo "-------------[ netstat -nape | grep :3000 | grep LIST]---------------------------"
sleep $SLEEPER
echo
echo
echo
echo "# GeoIP.conf file for \`geoipupdate\` program, for versions < 3.1.1. " > /etc/GeoIP.conf
echo "# Used to update GeoIP databases from https://www.maxmind.com." >> /etc/GeoIP.conf
echo "# For more information about this config file, visit the docs at" >> /etc/GeoIP.conf
echo "# https://dev.maxmind.com/geoip/geoipupdate/." >> /etc/GeoIP.conf
echo "# \`UserId\` is from your MaxMind account." >> /etc/GeoIP.conf
echo "UserId 306884" >> /etc/GeoIP.conf
echo "# `LicenseKey` is from your MaxMind account" >> /etc/GeoIP.conf
echo "LicenseKey WPdnpwnpNd06" >> /etc/GeoIP.conf
echo "# `ProductIds` is from your MaxMind account." >> /etc/GeoIP.conf
echo "ProductIds GeoLite2-ASN GeoLite2-City GeoLite2-Country" >> /etc/GeoIP.con
echo "---------------------------------------ntogeoipupdate installation [STARTS]------------------------"
sleep $SLEEPER
echo
echo
echo
echo "----------------------------------------"
apt-get install geoipupdate -y  
apt-get update -y
geoipupdate -v
geoipupdate
sleep $SLEEPER
echo
echo
echo
echo "----------------------------------------ntogeoipupdate installation [STARTS]------------------------"
sleep $SLEEPER
echo
echo
echo 
echo "-------------[cat /etc/GeoIP.conf---------------------------" 
cat /etc/GeoIP.conf
echo "-------------[sudo apt-get update -y---------------------------" 
sudo apt-get update -y
echo "----------------[apt-get install ntopng-data -y------------------------" 
apt-get install ntopng-data -y
echo "---------------[geoipupdate -V-------------------------" 
geoipupdate -V
sudo geoipupdate
#/usr/local/bin/ntopng /run/ntopng.conf &
echo "----------------------------------------"
sleep $SLEEPER
echo
echo
echo
echo "--------------[systemctl stop ntopng]--------------------------"
systemctl enable ntopng
echo "--------------[systemctl stop ntopng]--------------------------"
systemctl stop ntopng
echo "--------------[systemctl stop ntopng]--------------------------"
systemctl start ntopng
echo "--------------[systemctl stop ntopng]--------------------------"
systemctl restart ntopng
echo "--------------------------------ntop installed version [ntopng -V]----------------------------------"
sleep $SLEEPER
echo
echo
echo
echo "--------------------------------ntop install [ntopng -V]--------------------------------------------" 
ntopng -V 
echo "--------------------------------ntop install [ntopng -V]--------------------------------------------" 
sleep $SLEEPER
echo
echo
echo
echo "-----------------[ps -ef | grep ntopng]-----------------------"
ps -ef | grep ntopng
echo "-----------------ps -ef | grep ntopng]-----------------------"
sleep $SLEEPER
echo
echo
echo
echo "---------------[ps -ef | grep  redis-server]-------------------------"
ps -ef | grep  redis-server
echo "---------------[ps -ef | grep  redis-server]-------------------------"
sleep $SLEEPER
echo
echo
echo
echo "---------------[netstat -nape | grep redis-server | grep LIST]-------------------------"
netstat -nape | grep redis-server | grep LIST
echo "----------------------------------------"
echo
echo
echo
echo "----------[netstat -na | grep :3000]------------------------------"
netstat -nape | grep :3000 | grep LIST
echo "----------[netstat -na | grep :3000]------------------------------"
sleep $SLEEPER
echo
echo
echo
}




#####################################################
# Hardenned the iCS Platform - Server
#####################################################
functionServerHardening () {
  ID=36
  echo "1" > $PREVIOUS_INSTALL_FILE_${ID}
  echo
  echo
  echo
 
  echo -e "\e[1;31m ############################################### \e[m"
  echo "Starting functionServerHardening  "
  echo -e "\e[1;31m ############################################## \e[m"

 
  echo "------------------------------"
  echo "$ID" >> $FUNCTION_ID_TRAC_FILE 
  echo "[{INSTALL_HOME_DIR}/function_exec_id_tracker=$FUNCTION_ID_TRAC_FILE]<>[] = [`cat $FUNCTION_ID_TRAC_FILE`]"
  echo "------------------------------"
  echo
  echo
  echo
  sleep $SLEEPER

  echo "------------------------------=Starting server hardening IPTABLES updates...------------------------------===="
 sleep $SLEEPER
 iptables -F 

 echo "----------------------------------------ONLY ALLOW LOCAL TRUSTED NETS------------------------------==="
 iptables -I INPUT -s 127.0.0.0/8                         -m comment --comment "BAP-IN-Allow 127.0.0.0/8     allports  -  allow-all-local-127-net"         -j ACCEPT
 iptables -A INPUT -i lo                                  -m comment --comment "BAP-IN-Allow loopback-net    allports  -  allow-all-local-loop-net"        -j ACCEPT
 
 iptables -I INPUT -s 192.168.0.0/16 -p tcp --dport 22    -m comment --comment "BAP-IN-Allow 192.168.0.0/16  port22    -  allow-sshd-localonly-net"        -j ACCEPT
 iptables -I INPUT -s 172.16.0.0/12  -p tcp --dport 22    -m comment --comment "BAP-IN-Allow 172.16.0.0/12   port22    -  allow-sshd-localonly-net"        -j ACCEPT
 iptables -I INPUT -s 10.0.0.0/8     -p tcp --dport 22    -m comment --comment "BAP-IN-Allow 10.0.0.0/8      port22    -  allow-sshd-localonly-net"        -j ACCEPT

 iptables -I INPUT -s 192.168.0.0/16 -p tcp --dport 443   -m comment --comment "BAP-IN-Allow 192.168.0.0/16  port443   -  allow-https-localonly-net"       -j ACCEPT
 iptables -I INPUT -s 172.16.0.0/12  -p tcp --dport 443   -m comment --comment "BAP-IN-Allow 172.16.0.0/12   port443   -  allow-https-localonly-net"       -j ACCEPT
 iptables -I INPUT -s 10.0.0.0/8     -p tcp --dport 443   -m comment --comment "BAP-IN-Allow 10.0.0.0/8      port443   -  allow-https-localonly-net"       -j ACCEPT
 echo "----------------------------------------ONLY ALLOW LOCAL TRUSTED NETS------------------------------==="
 sleep $SLEEPER
 echo
 echo
 echo
 echo "----------------------------------------DROP ALL OUTSIDE ACCESS TO SYSTEM SERVICES------------------------------==="
 iptables -I INPUT -s 192.168.0.0/16 -p tcp --dport 3306  -m comment --comment "BAP-Drop-IN 192.168.0.0/16   port3306  -  dropped-mysql-localonly"         -j DROP
 iptables -I INPUT -s 172.16.0.0/12  -p tcp --dport 3306  -m comment --comment "BAP-Drop-IN 172.16.0.0/12    port3306  -  dropped-mysql-localonly"         -j DROP
 iptables -I INPUT -s 10.0.0.0/8     -p tcp --dport 3306  -m comment --comment "BAP-Drop-IN 10.0.0.0/8       port3306  -  dropped-mysql-localonly"         -j DROP

 iptables -I INPUT -s 192.168.0.0/16 -p tcp --dport 27017 -m comment --comment "BAP-Drop-IN 192.168.0.0/16   port27017 -  dropped-mongodb27017-localonly"  -j DROP
 iptables -I INPUT -s 172.16.0.0/12  -p tcp --dport 27017 -m comment --comment "BAP-Drop-IN 172.16.0.0/12    port27017 -  dropped-mongodb27017-localonly"  -j DROP
 iptables -I INPUT -s 10.0.0.0/8     -p tcp --dport 27017 -m comment --comment "BAP-Drop-IN 10.0.0.0/8       port27017 -  dropped-mongodb27017-localonly"  -j DROP

 iptables -I INPUT -s 192.168.0.0/16 -p tcp --dport 53    -m comment --comment "BAP-Drop-IN 192.168.0.0/16   port53    -  dropped-dns-localonly"           -j DROP
 iptables -I INPUT -s 172.16.0.0/12  -p tcp --dport 53    -m comment --comment "BAP-Drop-IN 172.16.0.0/12    port53    -  dropped-dns-localonly"           -j DROP
 iptables -I INPUT -s 10.0.0.0/8     -p tcp --dport 53    -m comment --comment "BAP-Drop-IN 10.0.0.0/8       port53    -  dropped-dns-localonly"           -j DROP

 iptables -I INPUT -s 192.168.0.0/16 -p tcp --dport 8089  -m comment --comment "BAP-Drop-IN 192.168.0.0/16   port8089  -  dropped-splunkapi-localonly"     -j DROP
 iptables -I INPUT -s 172.16.0.0/12  -p tcp --dport 8089  -m comment --comment "BAP-Drop-IN 172.16.0.0/12    port8089  -  dropped-splunkapi-localonly"     -j DROP
 iptables -I INPUT -s 10.0.0.0/8     -p tcp --dport 8089  -m comment --comment "BAP-Drop-IN 10.0.0.0/8       port8089  -  dropped-splunkapi-localonly"     -j DROP

 iptables -I INPUT -s 192.168.0.0/16 -p tcp --dport 8000  -m comment --comment "BAP-Drop-IN 192.168.0.0/16   port8000  -  dropped-splunkgui-localonly"     -j DROP
 iptables -I INPUT -s 172.16.0.0/12  -p tcp --dport 8000  -m comment --comment "BAP-Drop-IN 172.16.0.0/12    port8000  -  dropped-splunkgui-localonly"     -j DROP
 iptables -I INPUT -s 10.0.0.0/8     -p tcp --dport 8000  -m comment --comment "BAP-Drop-IN 10.0.0.0/8       port8000  -  dropped-splunkgui-localonly"     -j DROP

 iptables -I INPUT -s 192.168.0.0/16 -p tcp --dport 8191  -m comment --comment "BAP-Drop-IN 192.168.0.0/16   port8191  -  dropped-mongodb8191-localonly"   -j DROP
 iptables -I INPUT -s 172.16.0.0/12  -p tcp --dport 8191  -m comment --comment "BAP-Drop-IN 172.16.0.0/12    port8191  -  dropped-mongodb8191-localonly"   -j DROP
 iptables -I INPUT -s 10.0.0.0/8     -p tcp --dport 8191  -m comment --comment "BAP-Drop-IN 10.0.0.0/8       port8191  -  dropped-mongodb8191-localonly"   -j DROP

 iptables -I INPUT -s 192.168.0.0/16 -p tcp --dport 3000  -m comment --comment "BAP-Drop-IN 192.168.0.0/16   port3000  -  dropped-ntopng-localonly"        -j DROP
 iptables -I INPUT -s 172.16.0.0/12  -p tcp --dport 3000  -m comment --comment "BAP-Drop-IN 172.16.0.0/12    port3000  -  dropped-ntopng-localonly"        -j DROP
 iptables -I INPUT -s 10.0.0.0/8     -p tcp --dport 3000  -m comment --comment "BAP-Drop-IN 10.0.0.0/8       port3000  -  dropped-ntopng-localonly"        -j DROP

 iptables -I INPUT -s 192.168.0.0/16 -p tcp --dport 6379  -m comment --comment "BAP-Drop-IN 192.168.0.0/16   port6379  -  dropped-redis-localonly"         -j DROP
 iptables -I INPUT -s 172.16.0.0/12  -p tcp --dport 6379  -m comment --comment "BAP-Drop-IN 172.16.0.0/12    port6379  -  dropped-redis-localonly"         -j DROP
 iptables -I INPUT -s 10.0.0.0/8     -p tcp --dport 6379  -m comment --comment "BAP-Drop-IN 10.0.0.0/8       port6379  -  dropped-redis-localonly"         -j DROP

 iptables -I INPUT -s 192.168.0.0/16 -p tcp --dport 8065  -m comment --comment "BAP-Drop-IN 192.168.0.0/16   port8065  -  dropped-python-localonly"        -j DROP
 iptables -I INPUT -s 172.16.0.0/12  -p tcp --dport 8065  -m comment --comment "BAP-Drop-IN 172.16.0.0/12    port8065  -  dropped-python-localonly"        -j DROP
 iptables -I INPUT -s 10.0.0.0/8     -p tcp --dport 8065  -m comment --comment "BAP-Drop-IN 10.0.0.0/8       port8065  -  dropped-python-localonly"        -j DROP
 echo "----------------------------------------DROP ALL OUTSIDE ACCESS TO SYSTEM SERVICES------------------------------==="
sleep $SLEEPER
 echo
 echo
 echo
 echo "--------------------------------------------------SYSTEMS RULES------------------------------==="
 iptables -A INPUT   -m limit --limit 5/min -j LOG --log-prefix "BAP-IN-INPUT_denied:"    --log-level 7
 iptables -A INPUT   -m state --state ESTABLISHED,RELATED -j ACCEPT
 iptables -P INPUT DROP

 iptables -A FORWARD -m limit --limit 5/min -j LOG --log-prefix "BAP-FORWARD_denied:"  --log-level 7
 iptables -P FORWARD DROP
 echo "--------------------------------------------------SYSTEMS RULES------------------------------==="
sleep $SLEEPER
 echo
 echo
 echo
 echo "----------------------------------------IPTABLES INSTALLED------------------------------==="
 iptables -L -nv
 echo "----------------------------------------IPTABLES INSTALLED------------------------------==="
sleep $SLEEPER
 echo
 echo
 echo
 echo "------------------------------=IPTABLES INSTALLED & SAVED AFTER REBOOT----------====="
 iptables-save
 cat /etc/iptables/rules.v4
 echo "------------------------------=IPTABLES INSTALLED & SAVED AFTER REBOOT----------====="
sleep $SLEEPER
 echo
 echo
 echo
 echo "------------------------------===Completed server hardenning updates...----------===="
 echo "Please wait..."
}



#####################################################
# Removing All Previous installation - CLEAN!
#####################################################
functionCleanAllPreviousInstall () {
 ID=1.1
 echo
 echo
 echo
 echo -e "\e[1;31m ############################################### \e[m"
 echo "Starting functionCleanAllPreviousInstall"
 echo -e "\e[1;31m ############################################## \e[m"
 echo  
 echo "---------------[functionCleanAllPreviousInstall]------------------------"
 functionKillServices
 echo "---------------------------------------"
sleep $SLEEPER
 echo  
 echo "-----------------------[ rm -rfv /opt/bitnami/ ]-----------------"
 rm -rfv /opt/bitnami/
 echo "-------------------------------------------------"
sleep $SLEEPER
 echo  
 echo "--------------------[ rm -rfv /opt/splunk ]--------------------"
 rm -rfv /opt/splunk
 echo "-------------------------------------------------"
sleep $SLEEPER
 echo
 echo "--------------------[  rm -rfv  /usr/bin/ntopng /etc/ntopng /usr/share/ntopng  ]--------------------"
 rm -rfv  /usr/bin/ntopng /etc/ntopng /usr/share/ntopng 
 echo "-------------------------------------------------"
 echo
 echo "---------------------------[ rm -rfv /tmp/blockapt_install_logs/ ]----------------"
 rm -rfv /tmp/blockapt_install_logs/
 echo "---------------completed [functionCleanAllPreviousInstall]------------------------"
sleep $SLEEPER
}




#####################################################
# Removing all logs files from installation
#####################################################
functionRemovePostInstallLogs () {
 ID=32
 echo
 echo

 echo -e "\e[1;31m ############################################### \e[m"
 echo "Starting functionRemovePostInstallLogs  "
 echo -e "\e[1;31m ############################################## \e[m"

 echo "------------------------------"
 rm -rfv /tmp/blockapt_install_logs/
 echo "------------------------------"
sleep $SLEEPER
}






#####################################################
# Activating SSH Login GCLOUD
#####################################################
functionActiveSSH () {
 ID=33
 echo
 echo

 sleep $SLEEPER
  echo "--------------------------------"
  apt-get update -y
  echo "Doing apt-get install apt update"
  echo "Please wait..."
  echo "--------------------------------"
  echo 
  echo 
 sleep $SLEEPER
  echo "-----------[apt-get install -y openssh-server]---------------------"
  apt-get install -y openssh-server
  echo "--------------------------------"
  echo 
  echo 
  echo 
  echo "-------------[cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ba.bak]-------------------"
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ba.bak
  echo "--------------------------------" 
  echo 
  echo "-------------[cp /etc/ssh/ssh_config /etc/ssh/sshd_config.ba.bak]-------------------"
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/sshd_config
  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
  cat /etc/ssh/sshd_config | grep UsePAM
  echo "-------------[cp /etc/ssh/ssh_config /etc/ssh/sshd_config.ba.bak]-------------------"
  echo 
  echo "-------------[cp /etc/ssh/ssh_config /etc/ssh/sshd_config.ba.bak]-------------------"
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/ssh_config
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/ssh_config
  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/ssh_config
  sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/ssh_config
  cat /etc/ssh/ssh_config | grep UsePAM
  echo "-------------[cp /etc/ssh/ssh_config /etc/ssh/sshd_config.ba.bak]-------------------"
  /etc/init.d/ssh restart
  echo "--------------------------------"
  echo 
  echo "---------[/etc/init.d/ssh restart - /etc/ssh/sshd_config]-----------------------"
  cat /etc/ssh/sshd_config | grep PermitRootLogin
  cat /etc/ssh/sshd_config | grep PubkeyAuthentication
  cat /etc/ssh/sshd_config | grep PasswordAuthentication
  echo "---------[/etc/init.d/ssh restart - /etc/ssh/sshd_config]-----------------------"
  echo 
  echo "---------[/etc/init.d/ssh restart - /etc/ssh/ssh_config]-----------------------"
  cat /etc/ssh/ssh_config | grep PermitRootLogin
  cat /etc/ssh/ssh_config | grep PubkeyAuthentication
  cat /etc/ssh/ssh_config | grep PasswordAuthentication
  echo "---------[/etc/init.d/ssh restart - /etc/ssh/ssh_config]-----------------------"
  echo 
  echo "Please wait..."
 /etc/init.d/ssh restart
  echo "--------------------------------"
  echo 
  echo 
sleep $SLEEPER
}




#####################################################
# Chat Modules functionInstallChat Installation
#####################################################
functionInstallChat  () {
    ID=34
    echo
    echo
    echo -e "\e[1;31""m ############################################### \e[0m"
    echo "        Starting functionInstallChat 	  	                         "
    echo -e "\e[1;31""m ############################################### \e[0m"
    echo
    echo
    echo "--------------------------------------------------"
    echo "Starting React App"
    echo "--------------------------------------------------"
    echo
    echo
    echo "-------------[ cd /var/www/html/blockaptv9]------------------"
    cd /var/www/html/blockaptv9
    echo "-------------------------------"
    echo
    echo
    echo "-------------------------------"
    echo "folder is: [ cd /var/www/html/blockaptv9]" 
    echo "-------------------------------"
    echo
    echo
    echo "-----------[pwd]-------------------"
    pwd
    echo "-----------[pwd]-------------------"
    echo
    echo
    echo "-------------[ls -l /var/www/html/blockaptv9]------------------"
    ls -l /var/www/html/blockaptv9
    echo "-------------------------------"
    echo
    echo
    echo "----------[ nodejs --version]--------------------"
    cd /var/www/html/blockaptv9/icyber_loggers
    nodejs --version
    echo "----------[ nodejs --version]------------------"
    echo
    echo
    echo "----------[node --version]---------------------"
    node --version
    echo "----------[node --version]--------------------"
    echo
    echo    
    echo "----------[ npm -v]--------------------"
    npm -v
    echo "----------[ npm -v]--------------------"
    sleep $SLEEPER
    echo
    echo
    echo "-----[Started Removing Node Modules]-[sudo rm -rf ./node_modules]-----"
    echo
    echo
    echo "-------CHECK MONGO status before [functionInstallChat]---------"
    functionStartMongoDB
    read -r JUST_PAUSE
    echo "Press a key to continue..."
    echo
    echo

    rm -rfv /var/www/html/blockaptv9/icyber_loggers/sme_chat_module/node_modules

    ###rm -rfv ./node_modules ------> THIS THE ROOT CAUSE OF MONGO WIPEOUT!!
    
    echo "------------[Completd Removing Node Modules]-------------------"
    echo
    echo
    echo "------------[Start npm i && npm run dev]-------------------"
    ### Check if a directory does not exist ###
    ###if [ ! -d "./node_modules" ]
    
   #  if [ ! -d "/var/www/html/blockaptv9/icyber_loggers/sme_chat_module/node_modules" ]
   #  then
   #      echo "Directory [/var/www/html/blockaptv9/icyber_loggers/sme_chat_module/node_modules] DOES NOT exist... will run: [npm i && npm run dev]"
   #      npm i
   #  fi

    echo "------------[End npm i && npm run dev]-------------------"
    echo
    echo
    echo "--------------------------------------------------"
    echo "React App Ready!"
    echo "--------------------------------------------------"
    echo
    echo
    echo "-------------[ cd /var/www/html/blockaptv9]------------------"
    cd /var/www/html/blockaptv9/icyber_loggers/sme_chat_module/
    npm i
    echo "-------------------------------"
    echo
    echo
    echo "-------------------------------"
    echo "folder is: [ cd /var/www/html/blockaptv9/icyber_loggers/sme_chat_module/ ]" 
    echo "-------------------------------"
    echo
    echo
    echo "-----------[pwd]-------------------"
    pwd
    echo "-----------[pwd]-------------------"

    echo "-------CHECK MONGO status after [functionInstallChat]---------"
    functionStartMongoDB
    read -r JUST_PAUSE
    echo "Press a key to continue"  
}






#####################################################
# MTE Modules functionInstallMte Installation
#####################################################
functionInstallMte() {

echo "--------MTE Installation Started-----------"
#set -x

echo "----[export LD_LIBRARY_PATH=/var/www/html/blockaptv9/mte-server/MTE/lib] [echo $LD_LIBRARY_PATH]-----"
export LD_LIBRARY_PATH=/var/www/html/blockaptv9/mte-server/MTE/lib
echo $LD_LIBRARY_PATH
echo
echo
sleep $SLEEPER
echo "-------------------------------"


echo "----[export PYTHONPATH=/var/www/html/blockaptv9/mte-server/MTE/py]-----[echo $PYTHONPATH]-------"
export PYTHONPATH=/var/www/html/blockaptv9/mte-server/MTE/py
echo $PYTHONPATH
echo
echo
sleep $SLEEPER
echo "-------------------------------"


echo "------[sudo apt install software-properties-common][sudo apt install python3][sudo apt install python3-pip]------"
apt-get install software-properties-common -y
apt-get install python3 -y
apt-get install python3-pip -y
apt-get install python-is-python3 -y
echo
echo
sleep $SLEEPER
echo "-------------------------------"

echo "------[cd /var/www/html/blockaptv9/MTE-API/ && pip3 install -r requirements.txt]----------------"
cd /var/www/html/blockaptv9/MTE-API/ && pip3 install -r requirements.txt
echo
echo
sleep $SLEEPER
echo "--------MTE Installation End-----------" 
}




#####################################################
# Php critical Modules Installation
#####################################################
functionInstallPhp() {
echo
echo
sleep $SLEEPER
echo "--------------11----------------"
add-apt-repository ppa:ondrej/php -y
echo "------------12------------------"
apt-get -y update
echo "------------13------------------"
echo
echo
echo
sleep $SLEEPER
echo "----------------[apt-get install -y php${PHP_VERSION}]----[sudo apt install php${PHP_VERSION} libapache2-mod-php${PHP_VERSION} php${PHP_VERSION}-mysql]-----------------"
#aptitude --download-only install -y php${PHP_VERSION}
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/* 

#sudo apt install php7.3 libapache2-mod-php7.3 php7.3-mysql
#PHP_VERSION=7.3

sudo apt install php${PHP_VERSION} libapache2-mod-php${PHP_VERSION} php${PHP_VERSION}-mysql -y

apt-get install -y php${PHP_VERSION}
echo
echo
echo
echo "------------------------"
php -v;    /usr/bin/php -v;
echo "------------------------"
echo
echo
echo "Check PHP version must be [${PHP_VERSION}], if not trouble ahead..."
read PAUSE
#ls -l /cache/apt/archives/* 
echo "------------[apt-get install -y php${PHP_VERSION}]-16------------------"
echo
echo
echo
sleep $SLEEPER
echo "------------------[apt-get install -y php${PHP_VERSION}-common]-------------------"
#aptitude --download-only install -y php${PHP_VERSION}-common
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y php${PHP_VERSION}-common
sleep $SLEEPER
echo "------------------[apt-get install -y php${PHP_VERSION}-bcmath]-------------------"
#aptitude --download-only install -y php${PHP_VERSION}-bcmath
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y php${PHP_VERSION}-bcmath
echo
echo
echo
echo "------------------------"
php -v;    /usr/bin/php -v;
echo "------------------------"
echo
echo
echo "Check PHP version must be [${PHP_VERSION}] if not trouble ahead..."
read PAUSE
#ls -l /cache/apt/archives/*
echo "------------17-------[apt-get install -y php${PHP_VERSION}-common]-----------"
echo
echo
echo
sleep $SLEEPER
echo "----------------[apt-get install -y php${PHP_VERSION}-opcache ]---------------------"
#aptitude --download-only install -y php${PHP_VERSION}-opcache
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/* 
apt-get install -y php${PHP_VERSION}-opcache 
echo
echo
echo
echo "------------------------"
php -v;    /usr/bin/php -v;
echo "------------------------"
echo
echo
echo "Check PHP version must be [${PHP_VERSION}] if not trouble ahead..."
read PAUSE
#ls -l /cache/apt/archives/*
echo "-------------18---------[apt-get install -y php${PHP_VERSION}-opcache ]--------"
echo
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y php${PHP_VERSION}-cli
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/* 
apt-get install -y php${PHP_VERSION}-cli 
#ls -l /cache/apt/archives/*
echo "------------19------------------"
echo
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y php${PHP_VERSION}-gd
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/* 
apt-get install -y php${PHP_VERSION}-gd 
#ls -l /cache/apt/archives/*
echo "-------------20-----------------"
echo
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y php${PHP_VERSION}-curl 
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y php${PHP_VERSION}-curl 
#ls -l /cache/apt/archives/*
echo "-------------21-----------------"
echo
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y php${PHP_VERSION}-mysql
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y php${PHP_VERSION}-mysql
#ls -l /cache/apt/archives/*
echo "------------22------------------"
echo
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y php${PHP_VERSION}-xml
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y php${PHP_VERSION}-xml 
#ls -l /cache/apt/archives/*
echo "------------23------------------"
echo
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y php${PHP_VERSION}-simplexml
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y php${PHP_VERSION}-simplexml
#ls -l /cache/apt/archives/*
echo "-----------24-------------------"
echo
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y php${PHP_VERSION}-zip
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install -y php${PHP_VERSION}-zip
#ls -l /cache/apt/archives/*
echo "------------25------------------"
echo
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y php${PHP_VERSION}-imagick 
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install php${PHP_VERSION}-imagick -y
#ls -l /cache/apt/archives/*
echo "------------26------------------"
echo
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y php${PHP_VERSION}-mbstring
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install php${PHP_VERSION}-mbstring -y
#ls -l /cache/apt/archives/*
echo "--------------27----------------"
echo
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y php${PHP_VERSION}-soap
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install php${PHP_VERSION}-soap -y
#ls -l /cache/apt/archives/*
echo "-------------28-----------------"
echo
echo
echo
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y php${PHP_VERSION}-soap
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install php${PHP_VERSION}-ldap -y
#ls -l /cache/apt/archives/*
echo "-------------28-1-----------------"
echo
echo
echo


  echo "------[running... apt install php${PHP_VERSION} php${PHP_VERSION}-common php${PHP_VERSION}-opcache php${PHP_VERSION}-cli php${PHP_VERSION}-gd php${PHP_VERSION}-curl php${PHP_VERSION}-mysql php${PHP_VERSION}-xml php${PHP_VERSION}-simplexml -y php${PHP_VERSION}-zip -y php${PHP_VERSION}-ldap -y]---"
  #aptitude --download-only install -y php${PHP_VERSION} 
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y php${PHP_VERSION} 
  echo "Please wait..."
 sleep $SLEEPER

#aptitude --download-only install php${PHP_VERSION}-mbstring -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install php${PHP_VERSION}-imagick -y
#ls -l /cache/apt/archives/*
echo "---------------110---------------"
sleep $SLEEPER
echo "-------------------------------------"
#aptitude --download-only install -y php${PHP_VERSION}-mongodb
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install php${PHP_VERSION}-mongodb
#ls -l /cache/apt/archives/*
echo "-------------31-----------------"
echo
echo
echo
sleep $SLEEPER
echo "------------------111----------------------"
#aptitude --download-only install -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install php${PHP_VERSION}-mbstring -y
#ls -l /cache/apt/archives/*
echo "---------------111---------------"
echo
echo
echo
sleep $SLEEPER
echo "------------------112---------------------"
#aptitude --download-only install php${PHP_VERSION}-soap -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install php${PHP_VERSION}-soap -y
#ls -l /cache/apt/archives/*
echo "------------112------------------"
echo
echo
echo
sleep $SLEEPER
echo "----------------113-----------------------"
#aptitude --download-only install php${PHP_VERSION}-mongodb -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
apt-get install php${PHP_VERSION}-mongodb -y
#ls -l /cache/apt/archives/*
echo "-------------113-----------------"
echo
echo
echo
sleep $SLEEPER
echo "----------------114---------------------"
#aptitude --download-only install imagick -y
#cp -vr /var/cache/apt/archives/ /cache/apt/archives/
#ls -l /cache/apt/archives/*
/usr/bin/php -m | grep imagick
#ls -l /cache/apt/archives/*
echo "-------------114-----------------"



  echo 
  echo echo "-----------[apt-get install -y php${PHP_VERSION}-common]---------------------"
  #aptitude --download-only install -y php${PHP_VERSION}-common 
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y php${PHP_VERSION}-common 
  echo "Please wait..."
 sleep $SLEEPER
  echo 
  echo "-------[apt-get install -y php${PHP_VERSION}-opcache]-------------------------"
  #aptitude --download-only install -y php${PHP_VERSION}-opcache 
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y php${PHP_VERSION}-opcache 
 sleep $SLEEPER
  echo 
  echo "Please wait..."
  echo "----------[apt-get install -y php${PHP_VERSION}-cli ]----------------------"
  #aptitude --download-only install -y php${PHP_VERSION}-cli 
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y php${PHP_VERSION}-cli 
 sleep $SLEEPER
  echo 
  echo "Please wait..."
  echo "---------[apt-get install -y php${PHP_VERSION}-gd ]-----------------------"
  #aptitude --download-only  install -y php${PHP_VERSION}-gd 
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/* 
  apt-get install -y php${PHP_VERSION}-gd 
 sleep $SLEEPER
  echo 
  echo "Please wait..."
  echo "----------[apt-get install -y php${PHP_VERSION}-curl ]----------------------"
  #aptitude --download-only  install -y php${PHP_VERSION}-curl
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y php${PHP_VERSION}-curl 
 sleep $SLEEPER
  echo 
  echo "Please wait..."
  echo "-------[apt-get install -y php${PHP_VERSION}-mysql]-------------------------"
  #aptitude --download-only install -y php${PHP_VERSION}-mysql
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y php${PHP_VERSION}-mysql
 sleep $SLEEPER
  echo 
  echo "Please wait..."
  echo "--------[apt-get install -y php${PHP_VERSION}-xml ------------------------"
  #aptitude --download-only install -y php${PHP_VERSION}-xml 
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y php${PHP_VERSION}-xml 
 sleep $SLEEPER
  echo 
  echo "Please wait..."
  echo "------[apt-get install -y php${PHP_VERSION}-simplexml]--------------------------"
  #aptitude --download-only  install -y php${PHP_VERSION}-simplexml
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y php${PHP_VERSION}-simplexml
 sleep $SLEEPER
  echo 
  echo "Please wait..."
  echo "-----------[ apt-get install -y php${PHP_VERSION}-zip]---------------------"
  #aptitude --download-only install -y php${PHP_VERSION}-zip
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install -y php${PHP_VERSION}-zip
 sleep $SLEEPER
  echo 
  echo "Please wait..."
  echo "---------[apt-get install php${PHP_VERSION}-imagick -y]-----------------------"
  #aptitude --download-only  install php${PHP_VERSION}-imagick -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install php${PHP_VERSION}-imagick -y
 sleep $SLEEPER
  echo 
  echo "Please wait..."
  echo "--------[apt-get install php${PHP_VERSION}-mbstring------------------------"
  #aptitude --download-only install php${PHP_VERSION}-mbstring -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install php${PHP_VERSION}-mbstring -y
 sleep $SLEEPER
  echo 
  echo "Please wait..."
  echo "-------[apt-get install php${PHP_VERSION}-soap-------------------------"
  #aptitude --download-only install php${PHP_VERSION}-soap -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install php${PHP_VERSION}-soap -y
 sleep $SLEEPER
  echo 
    echo "----------[apt-get install php${PHP_VERSION}-mongodb]----------------------"
  #aptitude --download-only install php${PHP_VERSION}-mongodb -y
  #cp -vr /var/cache/apt/archives/ /cache/apt/archives/
  #ls -l /cache/apt/archives/*
  apt-get install php${PHP_VERSION}-mongodb -y
  sleep $SLEEPER
}







#####################################################
# Print global env variables
#####################################################
functionInstaPrinVars() {
echo
echo
echo "-----------------[functionInstaPrinVars]------------------------"
echo
echo
echo "DIR_HTDOCS=$DIR_HTDOCS"
echo "DIR_ICYBER=$DIR_ICYBER"
 
echo "NODE_VERSION=$NODE_VERSION"
echo "NODEJS_VERSION=$NODEJS_VERSION"
echo "NPM_VERSION=$NPM_VERSION"
echo "PM2_VERSION=$PM2_VERSION"
echo "NVM_VERSION=$NVM_VERSION"
echo "N_VERSION=$N_VERSION"

echo "MONGOD_VERSION=$MONGOD_VERSION"
echo "MONGOD_VERSION_REPO=$MONGOD_VERSION_REPO"
echo "MONGOD_VERSION_DB=$MONGOD_VERSION_DB"
echo "MONGO_VERSION=$MONGO_VERSION"
echo "MYSYQL_VERSION=$MYSYQL_VERSION"
echo "PHP_VERSION=$PHP_VERSION"

echo "PYTHON_PIP3=$PYTHON_PIP3"
echo "PYTHON_PIP_WERKZEUG=$PYTHON_PIP_WERKZEUG"
 
echo "UBUNTU_MONGO_CLI_KEYWORD=$UBUNTU_MONGO_CLI_KEYWORD"

echo "UBUNTU_MONGO_CODENAME_CLI=$UBUNTU_MONGO_CODENAME_CLI"
echo "UBUNTU_MONGO_LSB=$UBUNTU_MONGO_LSB"
echo "UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR=$UBUNTU_MONGO_LSB_CODENAME_BIONIC_NBR"
echo "UBUNTU_MONGO_LSB_CODENAME_FOCAL_NBR=$UBUNTU_MONGO_LSB_CODENAME_FOCAL_NBR"

echo "INSTALL_HOME_DIR=$INSTALL_HOME_DIR"

echo "SERVICE_apache=$SERVICE_apache"
echo "SERVICE_apached=$SERVICE_apached"
echo "SERVICE_splunk=$SERVICE_splunk"
echo "SERVICE_splunkd=$SERVICE_splunkd"
echo "SERVICE_mysql=$SERVICE_splunkd"
echo "SERVICE_mysqld=$SERVICE_mysqld"
echo "SERVICE_mongo=$SERVICE_mongo"
echo "SERVICE_mongod=$SERVICE_mongod"
echo "SERVICE_redisserver=$SERVICE_redisserver"
echo "SERVICE_http=$SERVICE_http"
echo "SERVICE_httpd=$SERVICE_httpd"
echo "SERVICE_httpd_bin=$SERVICE_httpd_bin"
 
echo "IS_UBUNTU=$IS_UBUNTU"
echo "UBUNTU_RELEASE=$UBUNTU_RELEASE"
echo "UBUNTU_FULL_VERSION=$UBUNTU_FULL_VERSION"
echo "UBUNTU_CODENAME=$UBUNTU_CODENAME"
echo "UBUNTU_ID=$UBUNTU_ID"

echo "GIT_URL=$GIT_URL"
 
echo "BITNAMI_FILE_RUN=$BITNAMI_FILE_RUN"
echo "DEBP_SPLUNK=$DEBP_SPLUNK"
echo "BITNAMI_PREFIX=$BITNAMI_PREFIX"
echo "BITNAMI_INSTAL_LANG=$BITNAMI_INSTAL_LANG"
echo "BITNAMI_BASE_USERNAME=$BITNAMI_BASE_USERNAME"
echo "BITNAMI_BASE_MAIL=$BITNAMI_BASE_MAIL"
echo "BITNAMI_BASE_USER=$BITNAMI_BASE_USER"
echo "BITNAMI_BASE_PWD=$BITNAMI_BASE_PWD"
echo "BITNAMI_DEBUG_LEVEL=$BITNAMI_DEBUG_LEVEL"
echo "BITNAMI_DEBUG_TRACE=$BITNAMI_DEBUG_TRACE"
echo "BITNAMI_ENABLE_PLUGINS=$BITNAMI_ENABLE_PLUGINS"
echo "BITNAMI_MYSQL_PWD=$BITNAMI_MYSQL_PWD"
echo "BITNAMI_WP_BLOGNAME=$BITNAMI_WP_BLOGNAME"
echo "BITNAMI_MYPHP_ADM=$BITNAMI_MYPHP_ADM"
echo "BITNAMI_LAUNCH_CLOUD=$BITNAMI_LAUNCH_CLOUD"
echo "BITNAMI_APACHE_SERVR_HTTP=$BITNAMI_APACHE_SERVR_HTTP"
echo "BITNAMI_APACHE_SERVR_HTTPS=$BITNAMI_APACHE_SERVR_HTTPS"
 
echo "PYTHON_NAME_FILE=$PYTHON_NAME_FILE"
echo "PREVIOUS_INSTALL_FILE=$PREVIOUS_INSTALL_FILE"
echo "DB_PASSWORD_FILE=$DB_PASSWORD_FILE"
echo "FUNCTION_ID_TRAC_FILE=$FUNCTION_ID_TRAC_FILE"
echo
echo
echo "-----------------[functionInstaPrinVars]------------------------"
echo
echo
echo "Press a key to continue... [functionInstaPrinVars]"
read PAUSE
sleep $SLEEPER
}





####################################################################################################
#
# Functions initialisation and calls 
# All functions calls must be added to this section
# Some functions required parameters
#
####################################################################################################


####################################################################################################
# Function #functionKillServices - 1
####################################################################################################
#functionKillServices


####################################################################################################
# Function functionCleanAllPreviousInstall - 1.1
####################################################################################################
functionCleanAllPreviousInstall
 echo "-------------------"
GLOBAL_DEBUG=1
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionCleanAllPreviousInstall"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionCleanAllPreviousInstall]---------------"
   sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionScriptInit - 2
####################################################################################################
functionScriptInit
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionScriptInit"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionScriptInit]---------------"
   sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionInstaPrinVars - 2a
####################################################################################################
 functionInstaPrinVars
 echo "-------------------"
GLOBAL_DEBUG=1
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionInstaPrinVars]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstaPrinVars]---------------"
   sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionCheckPlatformCompa -3
####################################################################################################
functionCheckPlatformCompa 
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionCheckPlatformCompa"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionCheckPlatformCompa]---------------"
   sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionInstallAllToolSingleFile - 3a
####################################################################################################
functionInstallAllToolSingleFile
 echo "-------------------"
GLOBAL_DEBUG=1
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionInstallAllToolSingleFile"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallAllToolSingleFile]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionInstallCriticalTools -23
####################################################################################################
functionInstallCriticalTools
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionInstallCriticalTools"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallCriticalTools]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionInstallPhp -23a
####################################################################################################
functionInstallPhp
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionInstallPhp"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallPhp]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionInstalltools -8
####################################################################################################
functionInstalltools
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionInstalltools"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstalltools]---------------"
   sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionIntsallGit -9
####################################################################################################
functionIntsallGit
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionIntsallGit"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionIntsallGit]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionInstallCurl - 10
####################################################################################################
functionInstallCurl
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionInstallCurl"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallCurl]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionInstallImagick - Must be after Git folder pull -22
####################################################################################################
functionInstallImagick
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionInstallImagick"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallImagick]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionLoadReplacerString -4
####################################################################################################
#functionLoadReplacerString
# echo "-------------------"
#if [ $GLOBAL_DEBUG -ge 1 ]; then
#    echo "Press Enter to continue...just completed ---> functionLoadReplacerString"
#    read -r JUST_PAUSE
# else
#    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionLoadReplacerString]---------------"
#   sleep $SLEEPER
# fi
# echo "-------------------"



####################################################################################################
# Function functionSetPath -5
####################################################################################################
#functionSetPath
# echo "-------------------"
#if [ $GLOBAL_DEBUG -ge 1 ]; then
#    echo "Press Enter to continue...just completed ---> functionSetPath"
#    read -r JUST_PAUSE
# else
#    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionSetPath]---------------"
#   sleep $SLEEPER
# fi
# echo "-------------------"



####################################################################################################
# Function functionCheckPath -6
####################################################################################################
#functionCheckPath
# echo "-------------------"
#if [ $GLOBAL_DEBUG -ge 1 ]; then
#    echo "Press Enter to continue...just completed ---> functionCheckPath"
#    read -r JUST_PAUSE
# else
#    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionCheckPath]---------------"
#   sleep $SLEEPER
# fi
# echo "-------------------"



####################################################################################################
# Function functionCheckIfLogout -7
####################################################################################################
#functionCheckIfLogout
# echo "-------------------"
#if [ $GLOBAL_DEBUG -ge 1 ]; then
#    echo "Press Enter to continue...just completed ---> functionCheckIfLogout"
#    read -r JUST_PAUSE
# else
#    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionCheckIfLogout]---------------"
#   sleep $SLEEPER
# fi
# echo "-------------------"



####################################################################################################
# Function functionInstallBitnami -13
####################################################################################################
###functionInstallBitnami
### echo "-------------------"
###if [ $GLOBAL_DEBUG -ge 1 ]; then
###    echo "Press Enter to continue...just completed ---> functionInstallBitnami"
###   read -r JUST_PAUSE
### else
###    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallBitnami]---------------"
###    sleep $SLEEPER
### fi
### echo "-------------------"



####################################################################################################
# Function functionClearHttpDocs -15
####################################################################################################
#functionClearHttpDocs
# echo "-------------------"
#if [ $GLOBAL_DEBUG -ge 1 ]; then
#    echo "Press Enter to continue...just completed ---> functionClearHttpDocs"
#    read -r JUST_PAUSE
# else
#    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionClearHttpDocs]---------------"
#    sleep $SLEEPER
# fi
# echo "-------------------"



####################################################################################################
# Function functionSetApacheRootDir -17
####################################################################################################
#functionSetApacheRootDir
# echo "-------------------"
#if [ $GLOBAL_DEBUG -ge 1 ]; then
#    echo "Press Enter to continue...just completed ---> functionSetApacheRootDir"
#    read -r JUST_PAUSE
# else
#    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionSetApacheRootDir]---------------"
#    sleep $SLEEPER
# fi
# echo "-------------------"



####################################################################################################
# Function functionGetDBPassword -18
####################################################################################################
# functionGetDBPassword  
#  echo "-------------------"
# if [ $GLOBAL_DEBUG -ge 1 ]; then
#     echo "Press Enter to continue...just completed ---> functionGetDBPassword"
#     read -r JUST_PAUSE
#  else
#     echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionGetDBPassword]---------------"
#     sleep $SLEEPER
#  fi
#  echo "-------------------"



####################################################################################################
# Function functionInstallMongoDB - Must be after Git folder pull -20
####################################################################################################
#####functionInstallMongoDB 
##### echo "-------------------"
#####if [ $GLOBAL_DEBUG -ge 1 ]; then
#####    echo "Press Enter to continue...just completed ---> functionInstallMongoDB [1]"
#####    read -r JUST_PAUSE
##### else
#####    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallMongoDB]---------------"
#####    sleep $SLEEPER
##### fi
##### echo "-------------------"



####################################################################################################
# Function functionCreateiCSDir -31
####################################################################################################
functionCreateiCSDir 
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionCreateiCSDir]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionCreateiCSDir]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"




####################################################################################################
# Function functionGetGitFolders -16
####################################################################################################
functionGetGitFolders
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionGetGitFolders"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionGetGitFolders]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



 ####################################################################################################
# Function functionSetEnvVariables -19
####################################################################################################
functionSetEnvVariables
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionSetEnvVariables]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionSetEnvVariables]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionComposerSetup -25
####################################################################################################
functionComposerSetup
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionComposerSetup]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionComposerSetup]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"




####################################################################################################
# Function functionStaticInstallMongoDB - Must be after Git folder pull -20
####################################################################################################
functionStaticInstallMongoDB 
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionStaticInstallMongoDB] [1]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionStaticInstallMongoDB]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



 ####################################################################################################
# Function functionInstallCfunctionInstallMongooseAndOthersriticalTools -31.1
####################################################################################################
functionInstallMongooseAndOthers
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionInstallMongooseAndOthers]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallMongooseAndOthers]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionStartMongoDB -30
####################################################################################################
functionStartMongoDB
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionStartMongoDB]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionStartMongoDB]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"





####################################################################################################
# Function functionInstallNginx -34
####################################################################################################
functionInstallNginx
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionInstallNginx]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallNginx]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionInstallMySQLLaravel -40
####################################################################################################
functionInstallMySQLLaravel
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionInstallMySQLLaravel]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallMySQLLaravel]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



 ####################################################################################################
# Function functionLoadPhpModules -14
####################################################################################################
functionLoadPhpModules
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionLoadPhpModules]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionLoadPhpModules]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionInstallPm2NpmNode - Must be after Git folder pull -21
####################################################################################################
functionInstallPm2NpmNode
echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionInstallPm2NpmNode"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallPm2NpmNode]---------------"
   sleep $SLEEPER
 fi
 echo "-------------------"




####################################################################################################
# Function functionInstallNodeJS -24
####################################################################################################
functionInstallNodeJS
echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...functionInstallNodeJS"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallNodeJS]---------------"
   sleep $SLEEPER
 fi
 echo "-------------------"




####################################################################################################
# Function functionComposerUpdate -26
####################################################################################################
functionComposerUpdate
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> functionComposerUpdate"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionComposerUpdate]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"




####################################################################################################
# Function functionGetSeed -27
####################################################################################################
functionGetSeed
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionGetSeed]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionGetSeed]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionKeyGenerate -28
####################################################################################################
functionKeyGenerate
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionKeyGenerate]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionKeyGenerate]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionInitMigration -29
####################################################################################################
functionInitMigration
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionInitMigration]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInitMigration]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionCheckApacheIsUp -36.1
####################################################################################################
functionInstallChat
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionInstallChat]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallChat]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionInstallMte - 37
####################################################################################################
functionInstallMte
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionInstallMte]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallMte]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"




####################################################################################################
# Function functionAddCrons -32
####################################################################################################
functionAddCrons
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionAddCrons]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionAddCrons]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionServerHardening -36
####################################################################################################
functionServerHardening
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionServerHardening]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionServerHardening]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionCheckApacheIsUp -36.1
####################################################################################################
functionCheckApacheIsUp
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionCheckApacheIsUp]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionCheckApacheIsUp]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"




####################################################################################################
# Function functionInstallNtopng -11
####################################################################################################
functionInstallNtopng 
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionInstallNtopng]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallNtopng]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"




####################################################################################################
# Function functionInstallSplunk -33
####################################################################################################
functionInstallSplunk
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionInstallSplunk]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionInstallSplunk]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"



####################################################################################################
# Function functionRestartAllServices -35
####################################################################################################
functionRestartAllServices
 echo "-------------------"
if [ $GLOBAL_DEBUG -ge 1 ]; then
    echo "Press Enter to continue...just completed ---> [functionRestartAllServices]"
    read -r JUST_PAUSE
 else
    echo "------------[$GLOBAL_DEBUG -eq 0] [Normal] [sleep $SLEEPER] [functionRestartAllServices]---------------"
    sleep $SLEEPER
 fi
 echo "-------------------"


echo "------------[Final Compile Started]---------------"
echo "---------rm -rfv node_modules/----------"
cd /var/www/html/blockaptv9
git reset --hard origin/master
rm -rfv node_modules/
cd /var/www/html/blockaptv9/icyber_loggers
rm -rfv node_modules/
cd /var/www/html/blockaptv9/icyber_loggers/sme_chat_module
rm -rfv node_modules/
cd /var/www/html/blockaptv9/icyber_graphs
rm -rfv node_modules/
echo "--------rm -rfv node_modules/-----------"

echo "--------sudo npm i-----------"
cd /var/www/html/blockaptv9
sudo npm i
sleep $SLEEPER
cd /var/www/html/blockaptv9/icyber_loggers
sudo npm i
sleep $SLEEPER
cd /var/www/html/blockaptv9/icyber_loggers/sme_chat_module
sudo npm i
sleep $SLEEPER
cd /var/www/html/blockaptv9/icyber_graphs
sudo npm i
sleep $SLEEPER
cd /var/www/html/blockaptv9
sudo npm run dev
echo "--------sudo npm i-----------"

echo "------------[install passport for icyber_graphs]---------------"
cd /var/www/html/blockaptv9
php artisan passport:install

echo "-------------------on_reboot_mongodb cron setting----------------------------"
 cp /var/www/html/blockaptv9/on_reboot_mongodb.sh  /blockapt/scripts/on_reboot_mongodb.sh
 cd /blockapt/scripts
 chmod 755 on_reboot_mongodb.sh
echo "-----------------------------------------------"

crontab -l >/tmp/c1
echo '@reboot      /blockapt/scripts/on_reboot_mongodb.sh &' >>/tmp/c1
crontab /tmp/c1
sudo service cron reload &

sleep $SLEEPER
cd /var/www/html/blockaptv9
sudo npm run dev
sleep $SLEEPER

echo "--------------Final Call PIP Things---------------------------------"
echo "----------------[pip ipwhois & pandas & scikit-learn & matplotlib & python-Levenshtein & mpld3 & apscheduler]-------------------------------"
sleep $SLEEPER
sudo pip install ipwhois

sleep $SLEEPER
# Installing the pandas package
sudo pip install pandas 

sleep $SLEEPER
# Installing the kMean package
sudo pip install scikit-learn

sleep $SLEEPER
# Installing the mat plot lib
sudo pip install matplotlib

sleep $SLEEPER
sudo pip install python-Levenshtein

sleep $SLEEPER
sudo pip install mpld3

sleep $SLEEPER
# Schedule 
sudo pip install apscheduler

sleep $SLEEPER
# Werkzeug 
sudo pip install 'Werkzeug=='$PYTHON_PIP_WERKZEUG
echo "---------------------PIP Completed--------------------------"

echo "------------[Final Compile Ended]---------------"


####################################################################################################
# Function functionCleanUpOnExit -36
####################################################################################################
#functionCleanUpOnExit


####################################################################################################
# Function functionRemovePostInstallLogs -37
####################################################################################################
#functionRemovePostInstallLogs


####################################################################################################
# Function functionActiveSSH -38
####################################################################################################
#functionActiveSSH
echo
echo
echo "*********************************************************"
echo "Active functions execution completed. Press enter to exit..."
