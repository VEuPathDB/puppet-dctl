class dctl::common {
  include '::docker'
  include '::docker::compose'

  # create directory structure
  file { [ $dctl::docker_compose_dir, "${$dctl::docker_compose_dir}/${dctl::project_dir}" ] :
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  if ( $dctl::dctl_cli_enable ) {
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

}

