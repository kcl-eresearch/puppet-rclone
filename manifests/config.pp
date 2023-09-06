# @summary Potential to allow development of creating rclone configs on the fly
#
# @param group
#   the users group
#
# @param conf
#   Hash with details for config, requires rclone_conf as a key and only 'S3_AWS' is currently supported
#   for S3 will also need:
#      access_key
#      secret_key
#      aws_region 
#      aws_location
#
define rclone::config (
  String               $group,
  Hash[String, String] $conf,
) {
  if $conf[rclone_conf] == 'S3_AWS' {
    file {
      "/etc/rclone/${name}_rclone.conf":
        ensure  => 'file',
        owner   => 'root',
        group   => $group,
        mode    => '0440',
        content => epp("${module_name}/rclone-S3-AWS-backup.conf.epp", {
            'config_name'  => $name,
            'access_key'   => $conf[access_key],
            'secret_key'   => $conf[secret_key],
            'aws_region'   => $conf[aws_region],
            'aws_location' => $conf[aws_location],
        });
    }
  }
}
