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
  Hash $override_hash,
) {

  # TODO this should be done as a project, with some kind of dependency
  #  file { "/var/lib/docker-compose/projects/solr/":
  #    ensure => directory,
  #  }


  # TODO merge override hash with project template
  # merged hashes won't work, because lists won't merge.  Will have to do with a template

  # $merged_hash = merge(Dctl::Project[$project][service_hash], $override_hash)

  # TODO use main var
  file { "/var/lib/docker-compose/projects/${project}/docker-compose-${name}.yml":
    ensure    => file,
    # content => to_yaml($compose_hash), # this apparently is too simple to work :/
    # content => inline_template( '<%= @merged_hash.to_yaml %>' ),
    content   => epp(Dctl::Project[$project][docker_compose_service_template], $override_hash),
  }

}
