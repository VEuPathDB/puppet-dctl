# @summary create a docker-compose 'service' which includes templates for compose files & environment
#
# A description of what this defined type does

# the intent here:
# this will create the structure for a docker-compose service/project that includes templates for:
#    docker-compose.yaml           - base docker-compose
#    docker-compose-dctl.yaml      - overrides for User defined ("shell" template for use by dctl )
#    docker-compose-[service].yaml - overrides for [service]    (epp template for use by puppet )
#
# this will also ensure that the defined service is running 

#
# @example
#   dctl::service { 'namevar': }


define dctl::service (
  Hash $compose_hash,
) {

  # TODO this should be done as a project, with some kind of dependency
  file { "/var/lib/docker-compose/projects/solr/":
    ensure => directory,
  }

  file { "/var/lib/docker-compose/projects/solr/docker-compose-${name}.yml":
    ensure  => file,
    # content => to_yaml($compose_hash), # this apparently is too simple to work :/
    content => inline_template( '<%= @compose_hash.to_yaml %>' ),
  }

}
