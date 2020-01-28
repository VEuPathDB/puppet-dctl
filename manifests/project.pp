# @summary create a docker-compose project which includes templates for compose files & environment
#

# this will create the structure for a docker-compose service/project that includes templates for:
#    docker-compose.yaml           - base docker-compose
#    docker-compose-dctl.yaml      - overrides for User defined ("shell" template for use by dctl )
#    docker-compose-[service].yaml - overrides for [service]    (epp template for use by puppet )
#

#
# @example
#  dctl::project{'testservice':
#    docker_compose_base => "puppet:///modules/profiles/testservice/docker-compose.yml",
#    docker_compose_dctl => "puppet:///modules/profiles/testservice/docker-compose.yml",
#    docker_compose_service_template => "profiles/testservice/docker-compose-service.epp",
#  }



define dctl::project (
  String $docker_compose_base,
  String $docker_compose_dctl,
  String $docker_compose_service_template,
) {

  # all templates will be deposited here
  $project_dir = "${$::dctl::docker_compose_dir}/${::dctl::project_dir}/${name}"

  file { $project_dir:
    ensure => directory,
  }

  # base docker-compose.yml
  file { "${project_dir}/docker-compose.yml":
    source => $docker_compose_base,
  }

  # dctl docker-compose template
  file { "${project_dir}/docker-compose-dctl.yml":
    source => $docker_compose_dctl,
  }


}
