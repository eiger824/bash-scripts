#!/bin/bash

# Error names: define here suitable error names
# (e.g. ERR_NOT_FOUND, ERR_FORMAT_ERR) and associate
# them with a value
ERR_FIRST=1
ERR_SECOND=2
ERR_THIRD=3
ERR_FOUR=4
ERR_UNKNW=100

# Then, write a function that takes the error code as
# an input argument and set a descriptive error text
# for every error
err_hdlr()
{
    case $1 in
        0)
            echo -n "Success" >&2
            ;;
        1)
            echo -n "The first error" >&2
            ;;
        2)
            echo -n "The second error" >&2
            ;;
        3)
            echo -n "No such file or directory" >&2
            ;;
        4)
            echo -n "Four and last known error" >&2
            ;;
        *)
            echo -n "Unknown error" >&2
            ;;
    esac
    echo " ($1)"
}

check_ret()
{
    local code=$1
    if [[ -z "$code" ]]; then
        return
    fi
    if [ $code -ne 0 ]; then
        err_hdlr $code
    fi
}

some_fun()
{
    return $ERR_FOUR
}

some_other_fun()
{
    return $ERR_UNKNW
}

# Finally, when using the above function, always:
# 1. execute the function
# 2. parse the return code
# 3. [optional] check if the parsed code is != 0, then call the err handler
some_fun
# Do stuff
err_hdlr $?

# Example with successful operation
true && err_hdlr $?

# Alternatively, have a helper function that checks that internally
some_other_fun
check_ret $?

some_other_fun
check_ret $?
