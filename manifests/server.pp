#
# == Class: vnc::server
#
# Installs vnc-server, sets up necessary gdm configuration, and sets up some
# default vnc sessions.
#
# == Parameters
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class vnc::server {
  include 'simplib'
  include 'xinetd'
  include 'gdm'

  # Some useful defaults
  vnc::server::create { 'vnc_standard':
    port     => '5901',
    geometry => '1024x768',
    depth    => '16'
  }

  vnc::server::create { 'vnc_lowres':
    port     => '5902',
    geometry => '800x600',
    depth    => '16'
  }

  vnc::server::create { 'vnc_highres':
    port     => '5903',
    geometry => '1280x1024',
    depth    => '16'
  }

  package { 'tigervnc-server': ensure => 'latest' }

  # Enable XDMCP queries so that VNC works properly.
  gdm::set { 'enable_xdmcp':
    section => 'xdmcp',
    key     => 'Enable',
    value   => true
  }
}
