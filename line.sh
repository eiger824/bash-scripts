#!/bin/bash

is_nr()
{
    if [[ $1 =~ [0-9]+ ]]; then
        return 0
    else
        return 1
    fi
}

usage()
{
    echo "Usage: $(basename $0) <fname> <line-nr>" >&2
    exit 1
}

fname=$1
linenr=$2

! is_nr $linenr && usage
test ! -f "$fname" && usage

sed $linenr'q;d' $fname

