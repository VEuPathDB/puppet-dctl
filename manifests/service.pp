# @summary create a docker-compose 'service' which includes templates for compose files & environment
#
# A description of what this defined type does

# this ensure that the service template is populated, and that the defined
# service is running 

#
# @example
#   dctl::service { 'namevar': }


define dctl::service (
  String $project,
  Hash $override_hash = {},
  Array $environment = [],
) {

  include '::docker'
  include '::docker::compose'

  # TODO fix how project_dir is overloaded
  $project_dir = "${$::dctl::docker_compose_dir}/${::dctl::project_dir}/${project}"


  # add environment array to override_hash for rendering
  $template_hash = merge($override_hash, {environment => $environment})

  # render template for the service
  file { "${project_dir}/docker-compose-${name}.yml":
    ensure  => file,
    content => epp(Dctl::Project[$project][docker_compose_service_template], $template_hash),
  }

  # bring compose project up
  docker_compose { "${project}_${name}":
    ensure        => present,
    compose_files => ["${project_dir}/docker-compose.yml", "${project_dir}/docker-compose-${name}.yml"],
  }


}
