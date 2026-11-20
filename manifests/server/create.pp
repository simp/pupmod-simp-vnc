# Create a new VNC Server Session
#
# Each session is a systemd socket, `${name}.socket`, listening on
# `127.0.0.1:${port}`. Every connection starts a new `Xvnc -inetd` instance
# from the templated `${name}@.service` unit, running as `nobody`, which
# queries the local display manager over XDMCP.
#
# Desktop gets set to 'name', which must also be a valid systemd unit name
# prefix.
#
# @param port
#   Port on which you wish to enable the VNC session. The socket only listens
#   on the loopback address.
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
  Simplib::Port $port,
  Vnc::Geometry $geometry            = '800x600',
  Integer       $depth               = 16,
  Integer       $screensaver_timeout = 15
) {
  $_server_args = [
    '-inetd',
    '-localhost',
    '-audit 4',
    "-s ${screensaver_timeout}",
    '-query localhost',
    '-NeverShared',
    '-once',
    '-SecurityTypes None',
    "-desktop ${name}",
    "-geometry ${geometry}",
    "-depth ${depth}",
  ].join(' ')

  systemd::unit_file { "${name}@.service":
    content => epp('vnc/server/xvnc.service.epp', {
        'desktop'     => $name,
        'server_args' => $_server_args,
    }),
  }

  systemd::unit_file { "${name}.socket":
    enable  => true,
    active  => true,
    content => epp('vnc/server/xvnc.socket.epp', {
        'desktop' => $name,
        'port'    => $port,
    }),
    require => Systemd::Unit_file["${name}@.service"],
  }
}
