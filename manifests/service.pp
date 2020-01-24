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

  # TODO, use var for first part, defined in params
  $main_project_dir = '/var/lib/docker-compose/projects'
  $project_dir = "${main_project_dir}/${project}/"


  # TODO merge override hash with project template
  # merged hashes won't work, because lists won't merge.  Will have to do with a template
  # $merged_hash = merge(Dctl::Project[$project][service_hash], $override_hash)

  $template_hash = merge($override_hash, {environment => $environment})

  # TODO use main var
  file { "/var/lib/docker-compose/projects/${project}/docker-compose-${name}.yml":
    ensure    => file,
    # content => inline_template( '<%= @merged_hash.to_yaml %>' ),
    content   => epp(Dctl::Project[$project][docker_compose_service_template], $template_hash),
  }

  docker_compose { "${project}_${name}":
    ensure        => present,
    compose_files => ["${project_dir}/docker-compose.yml", "${project_dir}/docker-compose-${name}.yml"],
  }


}
