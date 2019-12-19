if [ $1 -eq 0 ]; then
test -f /etc/rhsm/rhsm.conf.kat-backup && command cp /etc/rhsm/rhsm.conf.kat-backup /etc/rhsm/rhsm.conf
fi
