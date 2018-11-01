[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/vnc.svg)](https://forge.puppetlabs.com/simp/vnc)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/vnc.svg)](https://forge.puppetlabs.com/simp/vnc)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-vnc.svg)](https://travis-ci.org/simp/pupmod-simp-vnc)

#### Table of Contents

## This is a SIMP module
This module is a component of the
[System Integrity Management Platform](https://simp-project.com) a
compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net/).

## Module Description

This module installs the tigervnc client and server, and can create VNC Server
Sessions

## Setup

### What simp vnc affects

Packages managed by `simp/vnc`:
* tigervnc

Ports used by default for VNC Server:
* 5901 (1024x768)
* 5902 (800x600)
* 5903 (1280x1024)

### Beginning with VNC

#### Client Installation

To install the tigervnc client, just include `vnc::client`

#### Server Installation

To create a basic VNC server with default ports, include `vnc::server`

NOTE: You **MUST** set the following in Hiera to enable XDMCP. VNC will not
work without it.

```
---
gdm::settings:
  xdmcp:
    Enable: true
```

## Usage

### I want to create another VNC Connection

```puppet
# Screensaver timeout in minutes
vnc::server::create {'myconn':
  port => '65000',
  geometry => '1920x1080',
  depth => '32',
  screensaver_timeout => '30',
```

## Development

Please read our [Contribution Guide](http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html).
