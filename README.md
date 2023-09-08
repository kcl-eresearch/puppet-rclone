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
  ensure  => '1.63.1',
  backups => {
    'local_dirs_example' => {
      rclone => 'sync',
      src    => '/some/source/location/',
      dst    => '/some/destination/location/',
      user   => 'someLocalUser',
      group  => 'someLocalGroup',
      run_on => 'Fri',
      email  => 'someone.who.should.know@example.com',
      active => true,
      conf   => '',
    },
    'amzn_S3_example'    => {
      rclone => 'sync',
      src    => '/some/source/location/',
      dst    => 'amzn_S3_example:bucket/destination/',
      user   => 'someLocalUser',
      group  => 'someLocalGroup',
      run_on => '*-*-15 01:00:00',
      email  => 'someone.who.should.know@foo.com',
      active => true,
      conf   => {
        rclone_conf  => 'S3_AWS',
        access_key   => 'keep_it_safe_in_eyaml_or_vault',
        secret_key   => 'keep_it_safe_in_eyaml_or_vault',
        aws_region   => 'eu-central-1',
        aws_location => 'eu-central-1',
      },
    },
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
