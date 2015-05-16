Summary: VNC Puppet Module
Name: pupmod-vnc
Version: 4.1.0
Release: 3
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: pupmod-auditd >= 4.1.0-3
Requires: pupmod-common >= 4.2.0
Requires: puppetlabs-stdlib >= 4.1.0-0
Requires: pupmod-xinetd >= 2.1.0-0
Requires: puppet >= 3.3.0
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Obsoletes: pupmod-vnc-test

Prefix: /etc/puppet/environments/simp/modules

%description
This Puppet module provides the capability to configure a secure VNC Server and
client.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/vnc

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/vnc
done

mkdir -p %{buildroot}/usr/share/simp/tests/modules/vnc

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/vnc

%files
%defattr(0640,root,puppet,0750)
%{prefix}/vnc

%post
#!/bin/sh

if [ -d %{prefix}/vnc/plugins ]; then
  /bin/mv %{prefix}/vnc/plugins %{prefix}/vnc/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Mon Apr 06 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-3
- Updated to ensure that a banner is not printed since this breaks many
  clients.

* Thu Feb 19 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-2
- Migrated to the new 'simp' environment.

* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-1
- Changed puppet-server requirement to puppet

* Fri Apr 04 2014 Nick Markowski <nmarkowski@keywcorp.com> - 4.1.0-0
- Updated module for puppet3/hiera
- Complies with lint and added rspec tests

* Wed Oct 02 2013 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-6
- Use 'versioncmp' for all version comparisons.

* Tue Dec 11 2012 Maintenance
4.0.0-5
- Created a Cucumber test to ensure that vnc and its dependencies install correctly
  from the vnc module.
- Created a Cucumber test to ensure that the ports 5901, 5902, and 5903 are in state
  LISTEN and owned by xinetd after vnc::server has been installed and configured.

* Wed Nov 14 2012 Maintenance
4.0.0-4
- Removed tigervnc-server-module from the included packages list since it is
  not included in RHEL/CentOS 6.3 by default and is not needed for Xvnc
  performance.

* Wed Apr 11 2012 Maintenance
4.0.0-3
- Moved mit-tests to /usr/share/simp...
- Updated pp files to better meet Puppet's recommended style guide.

* Fri Mar 02 2012 Maintenance
4.0.0-2
- Improved test stubs.

* Mon Dec 26 2011 Maintenance
4.0.0-1
- Updated the spec file to not require a separate file list.

* Wed Nov 02 2011 Maintenance
4.0.0-0
- Updated to handle RHEL6

* Mon Jun 06 2011 Maintenance - 2.0.0-1
- Added -audit 4 and a variable screensaver timeout to the VNC spawned X sessions.

* Tue Jan 11 2011 Maintenance - 2.0.0-0
- Refactored for SIMP-2.0.0-alpha release

* Tue Oct 26 2010 Maintenance - 1-1
- Converting all spec files to check for directories prior to copy.

* Mon May 24 2010 Maintenance
1.0-0
- Code refactoring.

* Thu Oct 1 2009 Maintenance
0.1-0
- Initial Release
- You *must* have vncserver >= 4.1.2-14.el5_3.1 for VNC to work properly!
