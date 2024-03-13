# @summary Download and install Rclone
#
# Install rclone binary and man page
#
# @example
#   include rclone
#
# @param ensure
#   installed version, can be 'latest', 'absent' or valid version string
#
# @param backups
#   define backups to be made using rclone
#
class rclone (
  Pattern[/absent/, /latest/, /\d+\.\d+\.\d+/] $ensure = 'latest',
  Optional[Hash]                              $backups = undef,
) {
  $install_dir = '/opt/rclone'
  $binary = '/usr/bin/rclone'
  $man_page_dir = '/usr/local/share/man/man1'
  $man_page = "${man_page_dir}/rclone.1"

  case $ensure {
    'absent': { contain rclone::uninstall }
    default: { contain rclone::install }
  }

  exec { 'rclone mandb':
    command     => '/usr/bin/mandb',
    refreshonly => true,
  }

  if $ensure != 'absent' and $backups != undef {
    $backups.each |$name, $config| {
      rclone::service { $name:
        * => $config,
      }
    }
  }
}
