#!/bin/bash

dbg()
{
    [ $DEBUG -eq 1 ] && echo "$@" >&2
}

die()
{
    DEBUG=1
    dbg "$@"
    exit 1
}

find_distro()
{
    if [[ -f /usr/bin/lsb_release ]]; then
        if egrep -i '(ubuntu|debian)' /etc/issue &> /dev/null; then
            dbg "Ubuntu/Debian detected."
            PM=apt
            PMARGS='install -y'
            return 0
        fi
    fi
    if grep -i 'arch' /etc/issue &> /dev/null; then
        dbg "Arch Linux detected."
        PM=pacman
        PMARGS='-S'
        return 1
    fi
    if egrep -i '(centos|redhat)' /etc/issue &> /dev/null; then
        dbg "CentOS/RedHat detected."
        PM=yum
        PMARGS='install -y'
        return 2
    fi
}

download_pkgs()
{
    local distro
    distro=$1
    case $distro in
        0)
            sudo apt install -y git zsh wget
            ;;
        1)
            sudo pacman -S git zsh wget
            ;;
        2)
            sudo yum install -y git zsh wget
            ;;
        *)
            die "Unsupported distro, bailing out!"
            ;;
    esac
}

change_shell()
{
    local user
    user=$1
    if [[ ! "$(\grep ^${user} /etc/passwd)" =~ /bin/zsh$ ]]; then
        dbg "Changing shell for user $user, enter your password"
        chsh -s /bin/zsh $user
    else
        dbg "Skipping shell change, /bin/zsh already set"
    fi
}

install_zsh()
{
    if [[ ! -d ~/.oh-my-zsh ]]; then
        wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
        # Copy the template config
        cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
        source ~/.zshrc
        # Change the default theme
        sed -i -e 's/^\(ZSH_THEME=\).*$/\1agnoster/g' ~/.zshrc
    else
        dbg "Skipping installation, already in ~/.oh-my-zsh"
    fi
}

finish_banner()
{
    cat << EOF

*******************************************
$@
*******************************************
EOF
}

main()
{
    find_distro
    download_pkgs $?
    change_shell $USER
    install_zsh
    finish_banner "Done! Now open a new shell and enjoy ZSH :-)"
}

DEBUG=1
main
