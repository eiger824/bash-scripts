#!/bin/bash

login=1

while getopts "lu" opt; do
    case $opt in
        l)
            login=1
            ;;
        u)
            login=0
            ;;
    esac
done
echo -n "Enter username (defaults to '$(whoami)' if left blank): "
read user
test -z "$user" && user=$(whoami)

echo -n "Enter password for '$user': "
read -s pass
echo
pass_sha256=$(echo $pass | sha256sum | cut -d" " -f1)
echo "Logging in..."
./progress-bar.sh

# Compare the stored password to see if it matches
match=$(grep "^$user" secret_file.txt)
test -z "$match" && echo "No such user. Aborting." && exit 1
user_field=$(echo $match | cut -d: -f1)
pass_field=$(echo $match | cut -d: -f2)

if [ "$pass_field" != "$pass_sha256" ]; then
    echo "Wrong password. Aborting"
    exit 2
else
    echo "Correct!"
    if [ $login -eq 1 ]; then
        exit 0
    else
        # Update the password
        echo -n "Enter the NEW password for '$user': "
        read -s pass
        pass_sha256_new=$(echo $pass | sha256sum | cut -d" " -f1)
        if [ "$pass_sha256_new" != "$pass_sha256" ]; then
            echo -ne "\nRetype the NEW password for '$user': "
            read -s pass
            pass_sha256_retype=$(echo $pass | sha256sum | cut -d" " -f1)
            if [ "$pass_sha256_new" != "$pass_sha256_retype" ]; then
                echo -e "\nError: passwords don't match. Aborting."
                exit 1
            else
                sed -e "s/\(.*:\).*/\1$pass_sha256_retype/g" -i secret_file.txt
                echo -e "\nPassword updated!"
            fi
        else
            echo -e "\nError: the NEW and OLD passwords are the same."
        fi
    fi
fi

