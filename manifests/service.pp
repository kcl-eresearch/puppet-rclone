# @summary Configures the rclone backups and the systemd timers and services that run them
#
#  - tidy up all backup files if an active one is made inactive then create the ones that are needed
#  - create a systemd service to run a named backup
#  - create a timer to run the service at the time specified
#  - organise a log for each backup and rotate them weekly
#  - add a config file for a named backup to an S3_AWS bucket
#  - example for how to notify a slack service is included but commented out
#
# TODO: add do_before and do_after 
#   want to be able to run user defined commands or scripts before and after 
#   the systemd service does the rclone run
#   (add conditional ExecStartPre and ExecStartPost lines to rclone-backup.service.epp)
#
#
# @param command
#   the basic rclone command like 'sync' or 'copy'
#
# @param src
#   a source must be specified
#
# @param dst
#   as must a destination
#
# @param user
#   who is the user that should own this job
#   (read/write perms reqd on src and dst)
#
# @param group
#   the users group
#
# @param run_on
#   when should the systemd run this, can use the systemd
#   timer style e.g. *-*-15 01:00:00 (0100 on the 15th of each month)
#
# @param email
#   who should be sent an email, comma separated list
#   an admin email can also be set globally with
#   rclone::service::admin_email
#
# @param active
#   enable or disable this backup
#
# @param opts
#   rclone_opts is to add rclone options like -L
#
# @param conf
#   the type of backend, only 'S3_AWS' is currently supported
#   for S3 will need a hash including:
#      rclone_conf: S3_AWS
#      access_key: super_secret
#      secret_key: super_secret
#      aws_region: 
#      aws_location:
#
# @param pre_rclone
#   any ExecStartPre that may be desired to run before rclone runs
#
# @param post_rclone
#   any ExecStartPost that may be desired to run after rclone runs
#
define rclone::service (
  String                         $command,
  String                         $src,
  String                         $dst,
  String                         $user,
  String                         $group,
  String                         $run_on,
  String                         $email,
  Boolean                        $active   = true,
  Optional[String]               $opts     = undef,
  Optional[Hash[String, Variant[String, Sensitive[String]]]] $conf     = undef,
  Optional[Array[String]] $pre_rclone      = undef,
  Optional[Array[String]] $post_rclone     = undef,
) {
  if !$active {
    tidy {
      'delete-rclone-backup-systemd-files':
        path    => '/lib/systemd/system',
        recurse => true,
        matches => ["${name}-backup.timer", "${name}-backup.service"],
        rmdirs  => false;

      'delete-rclone-conf-files':
        path    => '/etc/rclone',
        recurse => true,
        matches => ["${name}_rclone.conf"],
        rmdirs  => false;
    }
  }

  if $active {
    if $conf != undef {
      if $opts == undef {
        $rclone_opts = "--config=/etc/rclone/${name}_rclone.conf"
      }
      else {
        $rclone_opts = "${opts} --config=/etc/rclone/${name}_rclone.conf"
      }
      rclone::config { $name:
        group => $group,
        conf  => $conf,
      }
    }
    else {
      if $opts == undef {
        $rclone_opts = ''
      }
      else {
        $rclone_opts = $opts
      }
    }
    file {
      "/lib/systemd/system/${name}-backup.timer":
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => epp("${module_name}/rclone-backup.timer.epp", {
            'svc_name'   => $name,
            'run_on_cal' => $run_on,
        });

      "/lib/systemd/system/${name}-backup.service":
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template("${module_name}/rclone-backup.service.erb");

      "/var/log/rclone-backups/${name}-backup.log":
        ensure => 'present',
        owner  => $user,
        group  => $group,
        mode   => '0664';
    }

    logrotate::rule {
      "${name}-backup-log-rotate":
        path         => "/var/log/rclone-backups/${name}-backup.log",
        rotate       => 6,
        rotate_every => 'week',
        ifempty      => false,
        create       => true,
        create_owner => $user,
        create_group => $group,
        create_mode  => '0664',
    }
  }

  if $active {
    systemd::timer {
      "${name}-backup.timer":
        timer_source   => "/lib/systemd/system/${name}-backup.timer",
        service_source => "/lib/systemd/system/${name}-backup.service",
        active         => true,
        enable         => true;
    }
  }
}
