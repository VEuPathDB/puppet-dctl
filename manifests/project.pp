# @summary create a docker-compose 'service' which includes templates for compose files & environment
#
# A description of what this defined type does

# the intent here:
# this will create the structure for a docker-compose service/project that includes templates for:
#    docker-compose.yaml           - base docker-compose
#    docker-compose-dctl.yaml      - overrides for User defined ("shell" template for use by dctl )
#    docker-compose-[service].yaml - overrides for [service]    (epp template for use by puppet )
#

#
# @example
#   dctl::project { 'namevar': }


define dctl::project (
  
) {

  # TODO, use var for first part
  file { "/var/lib/docker-compose/projects/${name}/":
    ensure => directory,
  }

  # the rest of the files

}
