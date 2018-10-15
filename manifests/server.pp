# Installs vnc-server, includes GDM for configuration, and sets up some default
# vnc sessions.
#
# NOTE: You *MUST* set the following in Hiera to enable XDMCP. VNC will not
# work without it.
#
# @example
#   ---
#   gdm::settings:
#     xdmcp:
#       Enable: true
#
# @author https://github.com/simp/pupmod-simp-vnc/graphs/contributors
#
class vnc::server {
  include 'xinetd'
  include 'gdm'

  # Some useful defaults
  vnc::server::create { 'vnc_standard':
    port     => 5901,
    geometry => '1024x768',
    depth    => 16
  }

  vnc::server::create { 'vnc_lowres':
    port     => 5902,
    geometry => '800x600',
    depth    => 16
  }

  vnc::server::create { 'vnc_highres':
    port     => 5903,
    geometry => '1280x1024',
    depth    => 16
  }

  package { 'tigervnc-server': ensure => 'latest' }
}
