# @example
#
#   class { 'rclone':
#     project => {
#       # the basic rclone command like 'sync' or 'copy'
#       rclone      => 'sync',
#       # rclone_opts is to add rclone options like -L, does not have to be defined
#       rclone_opts => '',
#       # if you do not need a conf file (like in this example) this can be left undefined, only '' and 'S3_AWS' are currently supported
#       conf        => '',
#       # a source must be specified
#       src         => '/srv/project/imptdir1/',
#       # as must a destination
#       dst         => '/backups/project/imptdir1/',
#       # who is the user that should own this job (read/write perms reqd on src and dst)
#       user        => 'user',
#       # and the users group
#       group       => 'group',
#       # when should the systemd run this, can also use the systemd timer style *-*-15 01:00:00 (0100 on the 15th of each month)
#       run_on      => 'Fri',
#       # who should be sent an email NB there is an rclone::service::admin_email too
#       email       => 'user@foo.com',
#       # enable or disable this backup
#       active      => true,
#     },
#     otherproject => {
#       rclone       => 'sync',
#       # only '' and 'S3_AWS' are currently supported
#       conf         => 'S3_AWS',
#       src          => '/srv/otherproject/imptdir/',
#       dst          => 'otherproject:some-bucket/path/imptdir/',
#       user         => 'otheruser',
#       group        => 'othergroup',
#       run_on       => '*-*-15 01:00:00',
#       email        => 'otheruser@bar.com',
#       # details required for S3_AWS connection for this backup
#       access_key   => 'RECOMMEND USE EYAML or VAULT',
#       secret_key   => 'RECOMMEND USE EYAML or VAULT',
#       aws_region   => 'some-region',
#       aws_location => 'some-location',
#       # enable or disable this backup
#       active       => true,
#     },
#   }

class { 'rclone':
  ensure  => '1.63.1',
  backups => {
    'local_dirs_example' => {
      command => 'sync',
      src     => '/some/source/location/',
      dst     => '/some/destination/location/',
      user    => 'someLocalUser',
      group   => 'someLocalGroup',
      run_on  => 'Fri',
      email   => 'someone.who.should.know@example.com',
      active  => true,
    },
    'amzn_S3_example'    => {
      command => 'sync',
      src     => '/some/source/location/',
      dst     => 'amzn_S3_example:bucket/destination/',
      user    => 'someLocalUser',
      group   => 'someLocalGroup',
      run_on  => '*-*-15 01:00:00',
      email   => 'someone.who.should.know@foo.com',
      active  => true,
      conf    => {
        rclone_conf  => 'S3_AWS',
        access_key   => 'keep_it_safe_in_eyaml_or_vault',
        secret_key   => 'keep_it_safe_in_eyaml_or_vault',
        aws_region   => 'eu-central-1',
        aws_location => 'eu-central-1',
      },
    },
  },
}
