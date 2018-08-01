#!/bin/bash

login=1
file="secret_file.txt"

sha256_pass()
{
    echo $1 | sha256sum | cut -d" " -f1
}

register_new_user()
{
    local username="$1"
    local hashed_password="$2"
    test ! -f $file && touch $file
    echo "$username:$hashed_password" >> $file
}

update_existing_user()
{
    local username="$1"
    local new_password="$2"
    sed -e "s/^\($username:\).*/\1$new_password/g" -i $file
}

add_new_user()
{
    test ! -f $file && touch $file
    echo -n "Enter new user name (defaults to '$(whoami)' if left blank): "
    read user
    test -z "$user" && user=$(whoami)
    if grep $user $file 2>&1 > /dev/null; then
        echo "Error: username '$user' already exists. Exiting now."
        exit 1
    fi
    while true; do
        echo -n "Enter a new password for user '$user': "
        read -s pass1
        echo -ne "\nRetype the password for user '$user': "
        read -s pass2
        if [ "$pass1" != "$pass2" ]; then
            echo -e "\nError: passwords don't match" >&2
        else
            register_new_user "$user" "$(sha256_pass $pass1)"
            echo -e "\nSuccessfully added new entry for user '$user'."
            break
        fi
    done
}

get_existing_user()
{
    local username="$1"
    grep "^$username" $file
}

edit_existing_user()
{
    test ! -f $file && touch $file
    echo -n "Enter user name (defaults to '$(whoami)' if left blank): "
    read user
    test -z "$user" && user=$(whoami)
    if ! grep $user $file 2>&1 > /dev/null; then
        echo "Error: username '$user' does not exist. Exiting now."
        exit 1
    fi
    while true; do
        echo -n "Enter password for user '$user': "
        read -s pass
        # Parse user's password
        match=$(get_existing_user $user)
        user_field=$(echo $match | cut -d: -f1)
        pass_field=$(echo $match | cut -d: -f2)
        if [ "$(sha256_pass $pass)" != "$pass_field" ]; then
            echo -e "\nError: wrong password" >&2
            exit 1
        else
        # Update the password
        echo -ne "\nEnter the NEW password for '$user': "
        read -s pass
        pass_sha256_new=$(sha256_pass $pass)
        if [ "$pass_sha256_new" != "$pass_sha256" ]; then
            echo -ne "\nRetype the NEW password for '$user': "
            read -s pass
            pass_sha256_retype=$(sha256_pass $pass)
            if [ "$pass_sha256_new" != "$pass_sha256_retype" ]; then
                echo -e "\nError: passwords don't match. Aborting."
                exit 1
            else
                update_existing_user "$user" "$pass_sha256_retype"
                echo -e "\nPassword updated!"
                break
            fi
        else
            echo -e "\nError: the new password is the same as the actual password."
            exit 1
        fi
        fi
    done

}

login_user()
{
    echo -n "Enter username (defaults to '$(whoami)' if left blank): "
    read user
    test -z "$user" && user=$(whoami)

    echo -n "Enter password for '$user': "
    read -s pass
    echo
    pass_sha256=$(sha256_pass $pass)
    echo "Logging in..."
    ./progress-bar.sh
    match=$(get_existing_user $user)
    user_field=$(echo $match | cut -d: -f1)
    pass_field=$(echo $match | cut -d: -f2)
    if [ "$(sha256_pass $pass)" != "$pass_field" ]; then
        echo -e "\nError: wrong password ($(sha256_pass $pass) vs. $pass_field)" >&2
        exit 1
    else
        echo "Login correct!"
    fi
}

test ! -f $file &&
{
    echo "No users were found. Creating database"
    add_new_user
    touch $file
}

while getopts "ahlu" opt; do
    case $opt in
        a)
            add_new_user
            exit 0
            ;;
        l)
            login_user
            exit 0
            ;;
        h)
            echo "Usage: $(basename $0) -a(add) | -l(login) | -u(update)"
            exit 0
            ;;
        u)
            edit_existing_user
            exit 0
            ;;
        *)
            echo "Illegal option"
            exit 1
            ;;
    esac
done


