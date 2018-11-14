#!/bin/bash

repaint()
{
    local w=$width
    local h=$height
    local posy=$1
    local posx=$2
    local mark=$3
    for i in `seq 1 $h`; do
        for j in `seq 1 $w`; do
            if [ $i -eq $posx ] && [ $j -eq $posy ]; then
                echo -n "$mark"
            else
                echo -n "."
            fi
        done
        echo
    done
    # Set the cursor at the initial position
    tput cuu $h
    tput cub $w
}

width=40
height=20
x=1
y=1

repaint $x $y
while read -sn1 key; do
    case $key in
        q)
            tput cud $height
            exit 0
            ;;     
        h)
            # Left
            if [ $x -eq 0 ]; then
                x=$width
            else
                ((x--))
            fi
            ;;
        l)
            # Right
            if [ $x -eq $width ]; then
                x=0
            else
                ((x++))
            fi
            ;;
        j)
            # Down 
            if [ $y -eq $height ]; then
                y=0
            else
                ((y++))
            fi
            ;;
        k)
            # Up 
            if [ $y -eq 0 ]; then
                y=$height
            else
                ((y--))
#                 y=$(( $y - 1 ))
            fi
            ;;
        *)
            echo "Unknown key - '$key'"
            ;;
    esac
    repaint $x $y 'o'
done

