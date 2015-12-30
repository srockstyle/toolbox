#!/bin/bash
# Starts the hhvm daemon
#
# chkconfig: 345 30 80
# description: Moving fast with high performance Hack and PHP
# processname: hhvm
HHVM_USER="www"
HHVM_BIN=`which hhvm`
HHVM_CONF="/etc/hhvm/server.hdf"
HHVM_EXEC="$HHVM_BIN --config $HHVM_CONF 2> /dev/null"
LOCKFILE="/var/lock/subsys/hhvm"
. /etc/init.d/functions


setup() {
  [ -d /var/run/hhvm ] || mkdir -p /var/run/hhvm
  su - $USER -c '[ -w /var/run/hhvm ]' || chown -R $USER /var/run/hhvm
}

## Start
start() {
  setup
	echo -n "Starting hhvm: "
  daemon --user $HHVM_USER $HHVM_EXEC
	touch /var/run/hhvm
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && touch $LOCKFILE
  return $RETVAL]
}

## Stop
stop() {
  echo -n "Shutting down hhvm: "
	killproc -p ${PIDFILE}
	RETVAL=$?
	echo
	[ $RETVAL -eq 0 ] && rm -f $LOCKFILE
	return $RETVAL
}

case "$1" in
start)
  start
  ;;
stop)
  stop
  ;;
status)
  status -p /var/run/hhvm/hhvm.pid hhvm
  ;;
restart)
  stop
  start
  ;;
version)
  hhvm --version
  ;;
reload|condrestart|probe)
  echo "$1 - Not supported."
  ;;
*)
  echo "Usage: hhvm {start|stop|status|restart|version]"
  exit 1
  ;;
esac
exit $RETVAL
