#
# == Class: vnc::client
#
# Makes sure the latests vnc package is installed.
#
# == Parameters
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class vnc::client {
  package { 'tigervnc': ensure => 'latest' }
}
