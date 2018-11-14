#!/bin/bash

usage()
{
    cat << EOF
This script installs a series of scripts under ~/scripts.

USAGE: $(basename $0)

-h       Print this help and exit.
-d <dir> Install scripts to "dir".
         Defaults to $HOME/scripts
EOF
}

dir=$HOME/scripts

while getopts "d:h" opt; do
    case $opt in
        d)
            dir=$OPTARG
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

# Test if "dir" exist
if [[ ! -d $dir ]]; then
    echo "Creating $dir"
    mkdir $dir
fi

# Install scripts
for file in $(find scripts -type f); do
    if [[ ! -h $dir/$(basename $file) ]]; then
        echo "Creating a symlink for: \"$file\""
        ln -s $(readlink -f $file) $dir/$(basename $file)
    fi
done

# Backup .bashrc and .bash_aliases, if existing
if [[ -f $HOME/.bashrc ]] && [[ ! -h $HOME/.bashrc ]]; then
    echo "Creating backup of $HOME/.bashrc"
    mv $HOME/.bashrc $HOME/.bashrc.bkup
fi
if [[ -f $HOME/.bash_aliases ]] && [[ ! -h $HOME/.bash_aliases ]]; then
    echo "Creating backup of $HOME/.bash_aliases"
    mv $HOME/.bash_aliases $HOME/.bash_aliases.bkup
fi

# Create symlinks
if [[ ! -h $HOME/.bashrc ]]; then
    echo "Creating symlink for $HOME/.bashrc"
    ln -s $(readlink -f bash/.bashrc) $HOME/.bashrc
fi
if [[ ! -h $HOME/.bash_aliases ]]; then
    echo "Creating symlink for $HOME/.bash_aliases"
    ln -s $(readlink -f bash/.bash_aliases) $HOME/.bash_aliases 
fi

echo "Done!"
