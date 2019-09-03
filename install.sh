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


# Backup existing files
for rc in $HOME/.{bashrc,zshrc} $HOME/.{bash,zsh}_aliases $HOME/.tmux.conf; do
    if [[ -f ${rc} ]] && [[ ! -h ${rc} ]]; then
        echo "Creating backup of ${rc}"
        mv ${rc} ${rc}.bkup
    fi
done

# Create symlinks
for dir in bash zsh tmux; do
    for rc in $(find ${dir} -type f); do
        link_name="${HOME}/$(basename ${rc})"
        if [[ ! -h ${link_name} ]]; then
            echo "Creating symlink for ${rc}"
            ln -s $(readlink -f ${rc}) ${link_name}
        fi
    done
done

echo "Done!"
