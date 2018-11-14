#!/bin/bash

usage()
{
    cat << EOF
Usage: $(basename $0) b|h|l|p|s
ARGS:
    -b       Show a "bouncing"-like bar.
    -h       Print this help and exit.
    -l <len> Sets the length of the bar (either progress or bouncing.)
             Defaults to 100 columns.
    -p       Show a progress bar.
    -s <sep> Specify the character to fill the spaces with.
    -t       Show a filling water tank.
    -w       When using in the bouncing bar, sets the width of the slider.
             This option has no effect when using a progress bar.
             Defaults to 30.
EOF
}

handle_sigint()
{
    # Make sure echo is activated back on the terminal
    stty echo
    echo
    exit 2
}

fill_water_tank()
{
    local width=20
    local height=20
    local i=0
    local j=0
    local level=$1
    local max=$2
    local line=$(( $level * $height / 100 ))
    for i in `seq $height -1 1`; do
        for j in `seq $width -1 1`; do
            if [ $j -eq 1 ] || [ $j -eq $width ]; then
                echo -n "|"
            else
                if [ $j -gt 1 ] && [ $j -lt $width ] && [ $i -eq 1 ]; then
                    echo -n "_"
                else
                    if [ $i -le $line ]; then
                        echo -n "~"
                    else
                        echo -n " "
                    fi
                fi
            fi
        done
        echo
    done
    tput cuu $height
}

bouncing_bar()
{
    ##### Input parameters #####
    local width=$1
    local sep=$2
    local length=$3
    ############################
    # First check: if width >= length ---> exit
    if [ $width -ge $length ]; then
        echo "Error: the width of the slider is greater than the length of the bar. Aborting."
        handle_sigint
    fi
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
            if [ $end_pos -gt $length ]; then
                end_pos=$(( $length - 1 ))
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
    for i in `seq 0 $(( $length - 1 ))`; do
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
    # We always want to represent a number from 0 to 100
    # in case the bar's length is *not* 100. Calculate this
    local to=$1
    local val=$(( $to * 100 / $len ))
    local max=$2
    local sep=$3
    local k=0
    if [ $val -eq 100 ]; then
        spaces=""
    elif [ $val -gt 9 ]; then
        spaces=" "
    else
        spaces="  "
    fi
    echo -ne "\rCompleted [$val%]$spaces["
    for k in `seq 1 $to`; do
        echo -ne "\e[7m$sep"
    done
    for k in `seq 1 $(( $len - $i ))`; do
        echo -ne "\e[0m\e[8m$sep"
    done
    # Print end
    echo -ne "\e[0m]"
}

# Important to keep character echo-ing if aborted
trap handle_sigint INT

# default values
progress=1
len=100
width=30
sep='o'
tank=0

while getopts "bhl:ps:tw:" opt; do
    case $opt in
        b)
            progress=0
            ;;
        h)
            usage && exit 0
            ;;
        l)
            len=$OPTARG
            ;;
        p)
            progress=1
            ;;
        s)
            sep="$OPTARG"
            ;;
        t)
            tank=1
            ;;
        w)
            width="$OPTARG"
            ;;
        *)
            echo "Illegal option" >&2
            usage
            exit 1
            ;;
    esac
done

# Feed the progress externally
# In a real scenario, N tasks would run
# and after each task the function would be
# called:
#
# progress_bar $task_number $number_of_tasks $sep
if [ $progress -eq 1 ]; then
    stty -echo
    i=0
    while [ $i -lt $(( $len + 1 )) ]; do
        # echo "i is now $i"
        progress_bar $i $len $sep
        # Random sleep time between 0 and 1 seconds
        sleep 0.$(( $RANDOM % 100 )) 
        i=$(( $i + $(( $RANDOM % 10 )) ))
    done
    progress_bar $len $len $sep
    echo " Done."
    stty echo 2>&1
else
    if [ $tank -eq 1 ]; then
        for i in `seq 1 100`; do
            fill_water_tank $i 100
            sleep 0.2
        done
    fi
    stty -echo
    for step in `seq 0 1 1000`; do
        bouncing_bar $width $sep $len
        sleep 0.1
    done
    echo " Done."
    stty echo 2>&1
fi

