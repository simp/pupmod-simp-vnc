[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html) [![Build Status](https://travis-ci.org/simp/pupmod-simp-vnc.svg)](https://travis-ci.org/simp/pupmod-simp-vnc) [![SIMP compatibility](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - A Puppet module for managing vnc](#module-description)
3. [Setup - The basics of getting started with pupmod-simp-vnc](#setup)
    * [What pupmod-simp-vnc affects](#what-simp-vnc-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with pupmod-simp-vnc](#beginning-with-simp-vnc)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## This is a SIMP module
This module is a component of the
[System Integrity Management Platform](https://github.com/NationalSecurityAgency/SIMP),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net/).

Please read our [Contribution Guide](https://simp-project.atlassian.net/wiki/display/SD/Contributing+to+SIMP)
and visit our [developer wiki](https://simp-project.atlassian.net/wiki/display/SD/SIMP+Development+Home).

## Module Description

This module installs the tigervnc client and server, and can create a VNC Server Session

## Setup

### What simp vnc affects

Packages managed by `simp/vnc`:
* tigervnc

Ports used by default for VNC Server:
* 5901 (1024x768)
* 5902 (800x600)
* 5903 (1280x1024)

### Setup Requirements

`simp/vnc` requires the `simp/simblib`,`simp/xinetd` and `simp/xwindows` modules.

### Beginning with SIMP SSSD

To install tigervnc, just include `vnc::client`

To create a basic VNC server with default ports, include `vnc::server`

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

## Reference

### Public Classes
* vnc
* vnc::client
* vnc::server
* vnc::server::create

## Limitations

This module is only designed to work in RHEL or CentOS 6 and 7. Any other
operating systems have not been tested and results cannot be guaranteed.

# Development

Please see the
[SIMP Contribution Guidelines](https://simp-project.atlassian.net/wiki/display/SD/Contributing+to+SIMP).

General developer documentation can be found on
[Confluence](https://simp-project.atlassian.net/wiki/display/SD/SIMP+Development+Home).
Visit the project homepage on [GitHub](https://simp-project.com),
chat with us on our [HipChat](https://simp-project.hipchat.com/),
and look at our issues on  [JIRA](https://simp-project.atlassian.net/).
