#!/bin/bash

update_config() {
    printf "Check "$1" ..."

    OLD_CONFIG=$(sed -n "/$2/p" config.ini)
    if [[ $OLD_CONFIG != "" ]]
    then
        printf "\n"
        printf "Enter $1 to change (or press ENTER to pass): "

        read NEW_CONFIG

        if [[ $NEW_CONFIG != "" ]]
        then
            sed -i "s/$2/$NEW_CONFIG/" config.ini
        fi
    else
        printf " done\n"
    fi
}

update_nodeos_path() {
    find . -type f ! -iname ".*" ! -iname "setup.sh" ! -iname "README.md" -exec sed -i "s~$1~$2~g" {} \;
    # To update cleos & keosd path
    find . -type f ! -iname ".*" ! -iname "setup.sh" ! -iname "README.md" -exec sed -i "s~${1%"/nodeos"}~${2%"/nodeos"}~g" {} \;
}

# update server address
update_config p2p-server-address !!!NODE_IP_ADDRESS!!!!

# update producer-name
update_config producer-name !!_YOUR_PRODUCER_NAME_!!!

# update public-key
update_config public-key YOUR_PUB_KEY_HERE

# update private-key
update_config private-key YOUR_PRIV_KEY_HERE

# update data-dir
printf "Check the path for data-dir ..."

DATA_DIR=$(sed -n "/DATADIR=/p" start.sh)
DATA_DIR=${DATA_DIR#"DATADIR=\""}
DATA_DIR=${DATA_DIR%"\""}

CURRENT_DIR=$(pwd)
CURRENT_DIR=${CURRENT_DIR%"/EOS-Jungle-Testnet"}

if [[ $CURRENT_DIR != $DATA_DIR ]]
then
    printf "\n"
    printf "OLD: \""$DATA_DIR"\"\n"
    printf "NEW: \""$CURRENT_DIR"\"\n"
    printf "Enter 'y' to update data-dir (or press Enter to pass): "

    read CHANGE

    if [[ CHANGE == 'y' || CHANGE != 'Y' ]]
    then
        find . -type f ! -iname ".*" ! -iname "setup.sh" ! -iname "README.md" -exec sed -i "s~$DATA_DIR~$CURRENT_DIR~g" {} \;
    fi
else
    printf " done.\n"
fi

# update nodeos path
printf "Check the path for nodeos ..."

NODEOSBIN_OLD=$(sed -n "/NODEOSBINDIR=/p" start.sh)
NODEOSBIN_OLD=${NODEOSBIN_OLD#"NODEOSBINDIR=\""}
NODEOSBIN_OLD=${NODEOSBIN_OLD%"\""}

NODEOSBIN_DIR=$(which nodeos)
NODEOSBIN_DIR=${NODEOSBIN_DIR%"/nodeos"}

if [[ $NODEOSBIN_DIR = "" ]]
then
    printf "\n"
    printf "Current path for nodeos: "$NODEOSBIN_OLD"\n"
    printf "Enter new path to change (or press ENTER to pass): "

    read NODEOSBIN_DIR

    if [[ $NODEOSBIN_DIR != "" ]]
    then
        if [[ -x $NODEOSBIN_DIR"/nodeos" ]]
        then
            update_nodeos_path $NODEOSBIN_OLD $NODEOSBIN_DIR
        else
            printf "nodeos not found from given path.\n\n"
        fi
    else
        printf "The path for nodeos not changed.\n\n"
    fi
else
    update_nodeos_path $NODEOSBIN_OLD $NODEOSBIN_DIR
    find . -type f ! -iname ".*" ! -iname "setup.sh" ! -iname "README.md" -exec sed -i "s~/cleos/cleos~/cleos~" {} \;
    find . -type f ! -iname ".*" ! -iname "setup.sh" ! -iname "README.md" -exec sed -i "s~/keosd/keosd~/keosd~" {} \;
    printf " done.\n"
fi

# make all scripts executable
printf "Check the permission of scripts ..."
if [[ ! -x "./start.sh" ]]
then
    printf "\n"
    printf "Enter password to make scripts executable.\n"
    find . -name "*.sh" -exec sudo chmod +x {} \;
else
    printf " done.\n"
fi

# complete
printf "Setup completed.\n"
