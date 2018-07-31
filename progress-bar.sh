#!/bin/bash

usage()
{
    cat << EOF
Usage: $(basename $0) b|p|h|s
ARGS:
    -b       Show a "bouncing"-like bar.
    -h       Print this help and exit.
    -p       Show a progress bar.
    -s <sep> Specify the character to fill the spaces with.
EOF
}

bouncing_bar()
{
    ##### Input parameters #####
    local width=$1
    local sep=$2
    ############################
    if [[ -z $start_pos ]]; then
        # First time it's called. Initalize values
        start_pos=0
        end_pos=$(( $start_pos + $width ))
        dir=0
    else
        # Already initialized
        # Then move the bar depending on "dir"
        if [ $dir -eq 0 ]; then
            # Move forwards only if the bar is within range
            start_pos=$(( $start_pos + 1 ))
            end_pos=$(( $start_pos + $width ))
            if [ $end_pos -gt 100 ]; then
                end_pos=99
                start_pos=$(( $end_pos - $width ))
                # Switch direction
                dir=1
            fi
        else
            # Move backwards only if the bar is within range
            start_pos=$(( $start_pos - 1 ))
            end_pos=$(( $start_pos + $width ))
            if [ $start_pos -lt 0 ]; then
                start_pos=1
                end_pos=$(( $start_pos + $width ))
                # Switch direction
                dir=0
            fi
        fi
    fi
    echo -ne "\rProcessing ["
    # Main loop, paints the whole bar
    for i in `seq 0 99`; do
        if [ $i -lt $start_pos ]; then 
            echo -ne "\e[0m "
        else
            if [ $i -lt $end_pos ]; then
                echo -ne "\e[7m$sep"
            else
                echo -ne "\e[0m "
            fi
        fi 
    done
    # Print end
    echo -ne "\e[0m]"
}

progress_bar()
{
    local to=$1
    local max=$2
    local sep=$3
    local k=0
    if [ $to -eq 100 ]; then
        spaces=""
    elif [ $to -gt 9 ]; then
        spaces=" "
    else
        spaces="  "
    fi
    echo -ne "\rCompleted [$to%]$spaces["
    for k in `seq 1 $to`; do
        echo -ne "\e[7m$sep"
    done
    for k in `seq 1 $(( 100 - $i ))`; do
        echo -ne "\e[0m\e[8m$sep"
    done
    # Print end
    echo -ne "\e[0m]"
}

# default: progress
progress=1

while getopts "bhps:" opt; do
    case $opt in
        b)
            progress=0
            ;;
        h)
            usage && exit 0
            ;;
        p)
            progress=1
            ;;
        s)
            sep="$OPTARG"
            ;;
    esac
done

# Custom separator
if [[ -z $sep ]]; then
    sep='o'
else
    sep=${sep:0:1}
fi

# Feed the progress externally
# In a real scenario, N tasks would run
# and after each task the function would be
# called:
#
# progress_bar $task_number $number_of_tasks $sep
if [ $progress -eq 1 ]; then
    stty -echo
    i=0
    while [ $i -lt 101 ]; do
        # echo "i is now $i"
        progress_bar $i 100 $sep
        # Random sleep time between 0 and 1 seconds
        sleep 0.$(( $RANDOM % 100 )) 
        i=$(( $i + $(( $RANDOM % 10 )) ))
    done
    progress_bar 100 100 $sep
    echo " Done."
    stty echo 2>&1
else
    width=30
    stty -echo
    for step in `seq 0 1 1000`; do
        bouncing_bar $width $sep
        sleep 0.1
    done
    echo " Done."
    stty echo 2>&1
fi

