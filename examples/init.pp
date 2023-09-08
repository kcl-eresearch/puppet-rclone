# @example
#
#   class { 'rclone':
#     # like to use a specific version
#     ensure  => '1.63.1'
#     project => {
#       # the basic rclone command like 'sync' or 'copy'
#       command => 'sync',
#       # opts is to add rclone options like -L, does not have to be defined
#       opts    => '',
#       # if you do not need a conf file (like in this example) this can be left undefined,
#       # only local files (undef) and 'S3_AWS' are currently supported
#       # conf  => undef,
#       # a source must be specified
#       src     => '/srv/project/imptdir1/',
#       # as must a destination
#       dst     => '/backups/project/imptdir1/',
#       # who is the user that should own this job (read/write perms reqd on src and dst)
#       user    => 'user',
#       # and the users group
#       group   => 'group',
#       # when should the systemd run this, can also use the systemd timer style *-*-15 01:00:00 (0100 on the 15th of each month)
#       run_on  => 'Fri',
#       # who should be sent an email NB there is an rclone::service::admin_email too
#       email   => 'user@foo.com',
#       # enable or disable this backup
#       active  => true,
#       # array of tasks to run before rclone backup runs (post_rclone will add tasks after the backup)
#       pre_rclone => ["%s -c 'echo date=$(/bin/date +%%Y-%%m-%%d) > /tmp/systemd_local_dirs_example_rclone.env'"],
#     },
#     otherproject => {
#       command => 'sync',
#       src     => '/srv/otherproject/imptdir/',
#       dst     => 'otherproject:some-bucket/path/imptdir/',
#       user    => 'otheruser',
#       group   => 'othergroup',
#       run_on  => '*-*-15 01:00:00',
#       email   => 'otheruser@bar.com',
#       # details required to generate a config for S3_AWS connection for this backup
#       # stored in a hash called 'conf'
#       conf    => {
#         rclone_conf  => 'S3_AWS'
#         access_key   => 'RECOMMEND USE EYAML or VAULT',
#         secret_key   => 'RECOMMEND USE EYAML or VAULT',
#         aws_region   => 'some-region',
#         aws_location => 'some-location',
#       },
#       # enable or disable this backup
#       active  => true,
#     },
#   }

class { 'rclone':
  ensure  => '1.63.1',
  backups => {
    'local_dirs_example' => {
      command    => 'sync',
      src        => '/some/source/location/',
      dst        => '/some/destination/location/',
      user       => 'someLocalUser',
      group      => 'someLocalGroup',
      run_on     => 'Fri',
      email      => 'someone.who.should.know@example.com',
      active     => true,
      pre_rclone => ["%s -c 'echo date=$(/bin/date +%%Y-%%m-%%d) > /tmp/systemd_local_dirs_example_rclone.env'"],
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
