#!/bin/bash

whole_line()
{
    for i in `seq 1 $(tput cols)`; do
        echo -n "*"
    done
    echo
}

content_line()
{
    echo -n "*"
    for i in `seq 1 $(( $(tput cols) - 2))`; do
        echo -n " "
    done
    echo "*"
}

echo "Enter something in the field below..."

whole_line
content_line
whole_line
tput cuu 2 && tput cuf 2
read str
tput cud 2

