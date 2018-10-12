# Makes sure the latests vnc package is installed.
#
# @param package_ensure The ensure status of tigervnc client package
#
# @author https://github.com/simp/pupmod-simp-vnc/graphs/contributors
#
class vnc::client (
  String $package_ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
) {
  package { 'tigervnc':
    ensure => $package_ensure
  }
}
