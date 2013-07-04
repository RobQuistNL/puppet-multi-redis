#! /bin/bash
##
## FILE MANAGED BY PUPPET
##

### BEGIN INIT INFO
# Provides:            redis
# Required-Start:      $remote_fs $syslog
# Required-Stop:       $remote_fs $syslog
# Should-Start:        $local_fs
# Should-Stop:         $local_fs
# Default-Start:       2 3 4 5
# Default-Stop:        0 1 6
# Short-Description:   Start redis-server daemon
# Description:         Start up redis-server, a mediocre-performance memory caching daemon
### END INIT INFO

# Usage:
# cp /etc/redis/redis.conf /etc/redis-server_server1.conf
# cp /etc/redis/redis.conf /etc/redis-server_server2.conf
# start all instances:
# /etc/init.d/redis-server start
# start one instance:
# /etc/init.d/redis-server start server1
# stop all instances:
# /etc/init.d/redis-server stop
# stop one instance:
# /etc/init.d/redis-server stop server1
# There is no "status" command.

#
# Modified to allow for multiple instances and (re)start them individually 
#

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/bin/redis-server
DAEMONNAME=redis-server
DAEMONBOOTSTRAP=/usr/share/redis-server/scripts/start-redis-server
DESC=redis-server

test -x $DAEMON || exit 0
test -x $DAEMONBOOTSTRAP || exit 0

set -e

. /lib/lsb/init-functions

# Edit /etc/default/redis-server to change this.
ENABLE_REDIS=no
test -r /etc/default/redis-server && . /etc/default/redis-server

shopt -s extglob
if [[ "${0##*/}" =~ "-" ]]; then
  FILES=(/etc/${0##*/}.conf)
else
  FILES=(/etc/${0##*/}?(-*).conf)
fi

FILES=(/etc/${0##*/}?(-*).conf)
# check for alternative config schema
CONFIGS=()
for FILE in ${FILES[@]}
do
  if [ ! -e "$FILE" ] ; then
    continue
  fi

  # remove prefix
  NAME=${FILE#/etc/}
  # remove suffix
  NAME=${NAME%.conf}

  # check optional second param
  if [ $# -ne 2 ];
    then
      # add to config array
      CONFIGS+=($NAME)
    elif [ "redis-server_$2" == "$NAME" ];
    then
      # use only one redis
      CONFIGS=($NAME)
      break;
  fi;
done;

if [ ${#CONFIGS[@]} == 0 ];
then
  echo "Config not exist for: $2" >&2
  exit 1
fi;

CONFIG_NUM=${#CONFIGS[@]}
for ((i=0; i < $CONFIG_NUM; i++)); do
  NAME=${CONFIGS[${i}]}
  PIDFILE="/var/run/redis-server/${NAME}.pid"

case "$1" in
  start)
       echo -n "Starting $DESC: "
       if [ $ENABLE_REDIS = yes ]; then
            echo start-stop-daemon --start --exec "$DAEMONBOOTSTRAP" /etc/${NAME}.conf $PIDFILE
            start-stop-daemon --start --exec "$DAEMONBOOTSTRAP" /etc/${NAME}.conf $PIDFILE
       else
            echo "$NAME disabled in /etc/default/memcached."
       fi
       ;;
  stop)
       echo -n "Stopping $DESC: "
       start-stop-daemon --stop --quiet --oknodo --retry 5 --pidfile $PIDFILE
       echo "$NAME."
       rm -f $PIDFILE
       ;;

  restart|force-reload)
       #
       #       If the "reload" option is implemented, move the "force-reload"
       #       option to the "reload" entry above. If not, "force-reload" is
       #       just the same as "restart".
       #
       echo -n "Restarting $DESC: "
       start-stop-daemon --stop --quiet --oknodo --retry 5 --pidfile $PIDFILE
       rm -f $PIDFILE
       if [ $ENABLE_REDIS = yes ]; then
       		start-stop-daemon --start --exec "$DAEMONBOOTSTRAP" /etc/${NAME}.conf $PIDFILE
       		echo "$NAME."
       else
            echo "$NAME disabled in /etc/default/redis-server."
       fi
       ;;
  status)
       status_of_proc -p $PIDFILE $DAEMON $NAME  && exit 0 || exit $?
       ;;
  *)
	N=/etc/init.d/$NAME
	echo "Usage: $N {start|stop|restart|force-reload|status}" >&2
	exit 1
	;;
esac
done;

exit 0

