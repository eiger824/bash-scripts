#!/bin/bash

color()
{
    local color="$1"
    shift
    local txt="$@"
    case ${color,,} in
        green)
            echo -ne "\e[92m"
            ;;
        red)
            echo -ne "\e[91m"
            ;;
        blue)
            echo -ne "\e[94m"
            ;;
        white)
            echo -ne "\e[97m"
            ;;
        light-gray)
            echo -ne "\e[37m"
            ;;
        dark-gray)
            echo -ne "\e[90m"
            ;;
        yellow)
            echo -ne "\e[93m"
            ;;
        cyan)
            echo -ne "\e[96m"
            ;;
        magenta)
            echo -ne "\e[95m"
            ;;
    esac
    echo -n "$txt"
   echo -e "\e[39m"
}

underline()
{
    local txt="$@"
    echo -e "\e[4m$txt\e[0m"
}

bold()
{
    local txt="$@"
    echo -e "\e[1m$txt\e[0m"
}

blink()
{
    local txt="$@"
    echo -e "\e[5m$txt\e[0m"
}

inverted()
{
    local txt="$@"
    echo -e "\e[7m$txt\e[0m"
}


echo "This $(inverted "is") an $(bold "example") of an $(underline "underlined") word!"
echo "$(color cyan "This") $(color magenta "is") a $(color light-gray "multicolor") $(color yellow "line!")"
