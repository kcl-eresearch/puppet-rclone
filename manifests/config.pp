# @summary Potential to allow development of creating rclone configs on the fly
#
# @param group
#   the users group
#
# @param conf
#   Hash with details for config, requires rclone_conf as a key; only 'S3_AWS' and 'Azure_Blob' are currently supported
#   for S3_AWS will also need:
#      access_key
#      secret_key
#      aws_region 
#      aws_location
#   for AzureBlob:
#      account
#      secret_key
define rclone::config (
  String               $group,
  Hash[String, Variant[String, Sensitive[String]]] $conf,
) {
  case $conf['rclone_conf'] {
    'S3_AWS': {
      $config = {
        'config_name'  => $name,
        'access_key'   => $conf['access_key'],
        'secret_key'   => $conf['secret_key'],
        'aws_region'   => $conf['aws_region'],
        'aws_location' => $conf['aws_location'],
      }
    }

    'azureblob': {
      $config = {
        'config_name' => $name,
        'account'     => $conf['account'],
        'secret_key'  => $conf['secret_key'],
      }
    }

    default: {
      fail('Unsupported config type')
    }
  }

  file {
    "/etc/rclone/${name}_rclone.conf":
      ensure    => 'file',
      owner     => 'root',
      group     => $group,
      mode      => '0440',
      content   => epp("${module_name}/providers/${conf['rclone_conf']}.epp", $config),
      show_diff => false;
  }
}
