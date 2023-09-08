# rclone

configures different backups (sources and destinations) using
local file systems or S3_AWS, looking to add other backends as required.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with rclone](#setup)
    * [What rclone affects](#what-rclone-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with rclone](#beginning-with-rclone)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Manage multiple backups using rclone, currently only supporting local file
system and S3_AWS backends, more may be added.
Also at the moment only for Debian/Ubuntu

## Setup

### What rclone affects

It ensures unzip is present
It adds services triggered by systemd timers
It ensures mailutils is available to send notifications
It installs an alert-slack@.service tha tis notified on failure, start and completion of backups

### Setup Requirements

logrotate is used
systemd is used

### Beginning with rclone

```
class { 'rclone':
  # like to use a specific version
  ensure  => '1.63.1'
  project => {
    # the basic rclone command like 'sync' or 'copy'
    command => 'sync',
    # opts is to add rclone options like -L, does not have to be defined
    opts    => '',
    # if you do not need a conf file (like in this example) this can be left undefined,
    # only local files (undef) and 'S3_AWS' are currently supported
    # conf  => undef,
    # a source must be specified
    src     => '/srv/project/imptdir1/',
    # as must a destination
    dst     => '/backups/project/imptdir1/',
    # who is the user that should own this job (read/write perms reqd on src and dst)
    user    => 'user',
    # and the users group
    group   => 'group',
    # when should the systemd run this, can also use the systemd timer style *-*-15 01:00:00 (0100 on the 15th of each month)
    run_on  => 'Fri',
    # who should be sent an email NB there is an rclone::service::admin_email too
    email   => 'user@foo.com',
    # enable or disable this backup
    active  => true,
    # array of tasks to run before rclone backup runs (post_rclone will add tasks after the backup)
    pre_rclone => ["%s -c 'echo date=$(/bin/date +%%Y-%%m-%%d) > /tmp/systemd_local_dirs_example_rclone.env'"],
  },
  otherproject => {
    command => 'sync',
    src     => '/srv/otherproject/imptdir/',
    dst     => 'otherproject:some-bucket/path/imptdir/',
    user    => 'otheruser',
    group   => 'othergroup',
    run_on  => '*-*-15 01:00:00',
    email   => 'otheruser@bar.com',
    # details required to generate a config for S3_AWS connection for this backup
    # stored in a hash called 'conf'
    conf    => {
      rclone_conf  => 'S3_AWS'
      access_key   => 'RECOMMEND USE EYAML or VAULT',
      secret_key   => 'RECOMMEND USE EYAML or VAULT',
      aws_region   => 'some-region',
      aws_location => 'some-location',
    },
    # enable or disable this backup
    active  => true,
  },
}
```

## Limitations

There probably are some, early days atm

## Development

Early days atm!!

## Release Notes/Contributors/Etc.

Includes work from https://github.com/Smarteon/puppet-rclone/tree/master

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
