#
# == Define: vnc::server::create
#
# Create a new VNC Server Session
#
# == Parameters
#
# Desktop gets set to 'name'.
#
# [*port*]
#   Port on which you wish to enable the VNC session
#
# [*geometry*]
#   Resolution of your VNC session
#
# [*depth*]
#   Specifies the pixel depth, in bits, of the desktop
#
# [*screensaver_timeout*]
#   Time after which to disable the screensaver, in minutes.
#
# == Example
#
# vnc::server::create { 'vnc_default':
#   port => '5900'
# }
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
define vnc::server::create (
  Integer $port,
  String  $geometry            = '800x600',
  Integer $depth               = 16,
  Integer $screensaver_timeout = 15
) {

  validate_port($port)
  validate_re($geometry, '^\d+x\d+$')

  include 'xinetd'

  xinetd::service { $name:
    banner         => '/dev/null',
    flags          => ['REUSE','IPv4'],
    protocol       => 'tcp',
    socket_type    => 'stream',
    x_wait         => 'no',
    x_type         => 'UNLISTED',
    log_on_success => ['HOST', 'PID', 'DURATION'],
    user           => 'nobody',
    server         => '/usr/bin/Xvnc',
    server_args    => "-inetd -localhost -audit 4 -s ${screensaver_timeout} -query localhost -NeverShared -once -SecurityTypes None -desktop ${name} -geometry ${geometry} -depth ${depth}",
    disable        => 'no',
    trusted_nets   => ['127.0.0.1'],
    port           => $port
  }

}
