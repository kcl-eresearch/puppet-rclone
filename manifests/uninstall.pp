# @summary Removes rclone and systemd files installed by this module
#
# @api private
#
class rclone::uninstall {
  file { "remove ${rclone::man_page}":
    ensure => absent,
    path   => $rclone::man_page,
    notify => Exec['rclone mandb'],
  }

  file { "remove ${rclone::binary}":
    ensure => absent,
    path   => $rclone::binary,
  }

  file { "remove ${rclone::install_dir}":
    ensure  => absent,
    path    => $rclone::install_dir,
    purge   => true,
    recurse => true,
    force   => true,
  }

  tidy {
    'delete-rclone-backup-systemd-files':
      path    => '/lib/systemd/system',
      recurse => true,
      matches => ['*-backup.timer', '*-backup.service'],
      rmdirs  => false;

    'delete-rclone-conf-files':
      path    => '/etc/rclone',
      recurse => true,
      matches => ['*_rclone.conf'],
      rmdirs  => false;
  }
}
