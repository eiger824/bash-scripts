#!/bin/bash

usage()
{
    echo "Usage: $(basename $0) <fname> <line-nr>" >&2
    exit 1
}

fname=$1
linenr=$2

test -z "$fname" && usage

sed $linenr'q;d' $fname

