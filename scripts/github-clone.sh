#!/bin/bash

get_remote_names()
{
    local repolist
    for i in `seq 1 2`; do
        repolist="$repolist $(wget -q 'https://github.com/eiger824?page='$i'&tab=repositories' -O - 2>&1 | sed -e '/^\s*$/d' -e 's/^\s\+//g' | \grep -E 'href=.*eiger824' | cut -d\" -f2 | \grep eiger824/ | cut -d/ -f3 )"
    done
    echo "$repolist"
}

usage()
{
    echo "Usage: $(basename $0) -u <username> -r <repository> -p <protocol>"
}

url="github.com"
username="eiger824"
protocol="ssh"
repository=""

while getopts "hu:p:r:" opt; do
    case $opt in
        h)
            usage && exit 0
            ;;
        u)
            username=${OPTARG,,}
            ;;
        p)
            protocol=${OPTARG,,}
            ;;
        r)
            repository=${OPTARG,,}
            repolist=$(get_remote_names)
            if [[ $repolist =~ $repository ]]; then
                echo "Valid repository. Cloning now!"
            else
                echo "Invalid repo. Exiting now." >&2
                exit 1
            fi
            ;;
    esac
done

if [[ -z "$repository" ]]; then
    echo "Which repository?" >&2
    usage && exit 1
fi

case $protocol in
    ssh)
        git clone $protocol://git@$url/$username/$repository".git"
        ;;
    https)
        git clone $protocol://$url/$username/$repo".git"
        ;;
    *)
        echo "Unknown protocol '$protocol'" >&2
        usage && exit 1
esac

