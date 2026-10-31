# example shell script reading its standard input to test 'sh-to-mod'
# shellcheck shell=sh

read -r line
FOO="read_$line"
export FOO
