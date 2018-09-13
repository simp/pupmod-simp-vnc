# Create a new VNC Server Session
#
# Desktop gets set to 'name'.
#
# @param port
#   Port on which you wish to enable the VNC session
#
# @param geometry
#   Resolution of your VNC session
#
# @param depth
#   Specifies the pixel depth, in bits, of the desktop
#
# @param screensaver_timeout
#   Time after which to disable the screensaver, in minutes.
#
# @example
#    vnc::server::create { 'vnc_default':
#      port => '5900'
#    }
#
# @author https://github.com/simp/pupmod-simp-vnc/graphs/contributors
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
