#!/bin/bash

var1="This is some string"
var2="Some,comma,separated,values"

echo "var1:  '$var1'"
echo "var2:  '$var2'"

# Transform
var1=${var1// /-}
var2=${var2//,/\/}

echo "var1:  '$var1'"
echo "var2:  '$var2'"

# Regexp match
if [[ "$var1" =~ ^[A-Z][a-z]*\s\+ ]]; then
    echo "The sentence \"$var1\" starts correctly."
else
    echo "The sentence \"$var1\" does not start as it should."
fi

# Transform only the first occurrence of '-'
var1=${var1/-/ }
echo "var1:  '$var1'"

# Try it again now
if [[ "$var1" =~ ^[A-Z][a-z]*s+ ]]; then
    echo "The sentence \"$var1\" starts correctly."
else
    echo "The sentence \"$var1\" does not start as it should."
fi

# String redirection to STDIN of a program
string='This string will be printed to STDOUT. It came all the way in from STDIN.'
cat <<< $string
sed 's/STD\([A-Z]*\)/standard \L\1put/g' <<< $string

# Arrays
declare -a array
# Sequence of letters
pos=0
for letter in {a..z}; do
    # Note the post-increment op '++' that is understood in the expression evaluation
    array[((pos++))]=$letter
done
# Let's read the array!
pos=0
while [[ -n "${array[$pos]}" ]]; do
    echo -n "${array[((pos++))]}"
done
