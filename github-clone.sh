#!/bin/bash

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
            ;;
    esac
done

echo "Args are: $@"

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

