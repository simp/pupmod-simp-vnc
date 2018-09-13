# Makes sure the latests vnc package is installed.
#
# @author https://github.com/simp/pupmod-simp-vnc/graphs/contributors
#
class vnc::client {
  package { 'tigervnc': ensure => 'latest' }
}
