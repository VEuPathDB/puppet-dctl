# create framework directory structure, package requirements

# @param dctl_cli_enable
#   flag to toggle if the dependencies for the dctl cli application are needed.
#
# @param docker_compose_dir
#   Main directory where project files are stored
#
# @param project_dir
#   Name of the subdirectory where projects are stored
#
# @param projects
#   list of projects to create
#

class dctl (
  $dctl_cli_enable    = $::dctl::params::dctl_cli_enable,
  $docker_compose_dir = $::dctl::params::docker_compose_dir,
  $project_dir        = $::dctl::params::project_dir,
  $projects           = $::dctl::params::projects,
) inherits ::dctl::params {

  include '::docker'
  include '::docker::compose'

  # create directory structure
  file { [ $::dctl::docker_compose_dir, "${$::dctl::docker_compose_dir}/${::dctl::project_dir}" ] :
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  if ( $::dctl::dctl_cli_enable ) {
    # dctl cli requires python36-docker module
    package { 'python36-docker':
      ensure   => installed
    }

    $sudo_rule = @(END)
User_Alias DOCKER_DEV_GROUP = %eupa
DOCKER_DEV_GROUP ALL=(root) NOPASSWD:/usr/local/bin/dctl
END

    sudo::conf { 'dev_docker_dctl':
      content  => $sudo_rule,
      priority => 16,
    }

  }

  # create projects (typically pulled from hiera)
  if ($projects) {
    create_resources(dctl::project, $projects)
  }


}

