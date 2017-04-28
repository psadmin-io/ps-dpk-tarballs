class pt_role::io_tools_deployment inherits pt_role::pt_base {
  notify { "Applying pt_role::io_tools_deployment": }

  $ensure   = hiera('ensure')

  contain ::pt_profile::pt_tools_deployment
  contain ::pt_profile::pt_psft_environment

  if $ensure == present {
    Class['::pt_profile::pt_system'] ->
    Class['::pt_profile::pt_tools_deployment'] ->
    Class['::pt_profile::pt_psft_environment']
  }
  elsif $ensure == absent {
    Class['::pt_profile::pt_psft_environment'] ->
    Class['::pt_profile::pt_tools_deployment'] ->
    Class['::pt_profile::pt_system']
  }
}
