# mini example shell script to test 'sh-to-mod' sub-command

export FOOMINI=value
export FOOPATH=/path/to/mini:$FOOPATH
alias almini='echo mini'

if [ "${TESTSUITE_SOURCESH_ESCCHAR:+x}" = 'x' ]; then
   export FOOESC=:
   export FOOPATH=/path/\{\|:$FOOPATH:/path/\}\&
fi

if [ "${TESTSUITE_SOURCESH_PRIO:+x}" = 'x' ]; then
   export __MODULES_PRIORITY_FOOPATH='/path/to/mini&|-10'
fi

# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
