#!/usr/bin/perl -w

# start-redis
# 2003/2004 - Jay Bonci <jaybonci@debian.org>
# This script handles the parsing of the /etc/redis-server.conf file
# and was originally created for the Debian distribution.
# Anyone may use this little script under the same terms as
# redis-server itself.

use POSIX qw(setsid);
use strict;

if($> != 0 and $< != 0)
{
    print STDERR "Only root wants to run start-redis.\n";
    exit;
}

my $cmdPrefix; my $params; my $etchandle; my $etcfile = "/etc/redis/redis.conf"; my $userfile="";

# This script assumes that redis-server is located at /usr/bin/redis-server, and
# that the pidfile is writable at /var/run/redis/redis-server.pid

my $redisserver = "/usr/bin/redis-server";
my $pidfile = "/var/run/redis/redis-server.pid";

if (scalar(@ARGV) == 3) {
    $etcfile = shift(@ARGV);
    $pidfile = shift(@ARGV);
    $userfile = shift(@ARGV);
}

# If we don't get a valid logfile parameter in the /etc/redis-server.conf file,
# we'll just throw away all of our in-daemon output. We need to re-tie it so
# that non-bash shells will not hang on logout. Thanks to Michael Renner for
# the tip
my $fd_reopened = "/dev/null";

sub handle_logfile
{
    my ($logfile) = @_;
    $fd_reopened = $logfile;
}

sub reopen_logfile
{
    my ($logfile) = @_;

    open *STDERR, ">>$logfile";
    open *STDOUT, ">>$logfile";
    open *STDIN, ">>/dev/null";
    $fd_reopened = $logfile;
}

# This is set up in place here to support other non -[a-z] directives

my $conf_directives = {
    "logfile" => \&handle_logfile,
};

open USERHANDLE, "$userfile";
$cmdPrefix = <USERHANDLE>;
close USERHANDLE;

$cmdPrefix = "sudo -u $cmdPrefix";

push @$params, "-u root" unless(grep "-u", @$params);
$params = join " ", @$params;

if(-e $pidfile)
{
    open PIDHANDLE, "$pidfile";
    my $localpid = <PIDHANDLE>;
    close PIDHANDLE;

    chomp $localpid;
    if(-d "/proc/$localpid")
    {
        print STDERR "redis-server is already running.\n";
        exit;
    }else{
        `rm -f $localpid`;
    }

}

my $pid = fork();

if($pid == 0)
{
    # setsid makes us the session leader
    setsid();
    reopen_logfile($fd_reopened);
    # must fork again now that tty is closed
    $pid = fork();
    if ($pid) {
      if(open PIDHANDLE,">$pidfile")
      {
          print PIDHANDLE $pid;
          close PIDHANDLE;
      }else{

          print STDERR "Can't write pidfile to $pidfile.\n";
      }
      exit(0);
    }
    exec "$cmdPrefix $redisserver $etcfile";
    exit(0);

}

