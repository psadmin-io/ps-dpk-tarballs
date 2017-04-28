node default {
  include ::pt_role::pt_tools_deployment
}

# Temp fix for bug that still deploys the unicode.cfg when `unicode: false` is set
# $ps_home = hiera('ps_home_location')
# file { "${ps_home}/setup/unicode.cfg": 
# 	ensure => absent,
# }