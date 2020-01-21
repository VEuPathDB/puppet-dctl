class dctl::common {
  include '::docker'
  include '::docker::compose'

  $docker_compose_project_root = '/var/lib/docker-compose'

  # this may need to move to a higher level, if we are going
  # to manage them centrally
  file { [ $docker_compose_project_root, "${docker_compose_project_root}/projects" ] :
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

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

