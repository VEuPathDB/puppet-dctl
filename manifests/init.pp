
class dctl (
  $dctl_cli_enable    = $::dctl::params::dctl_cli_enable,
  $docker_compose_dir = $::dctl::params::docker_compose_dir,
  $project_dir        = $::dctl::params::project_dir,
) inherits ::dctl::params {
  contain 'dctl::common'
}

