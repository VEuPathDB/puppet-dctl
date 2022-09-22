# this is a helper class that will allow all your services to be defined in a
# central place like hiera, but allow you to filter which ones are actually
# created on a per manifest basis.

# For example, you could define a series of dev, qa, and prod services in a
# single hiera structure, then create dev ones with an class definition like:
#
#   class {'::dctl::services':
#     filter => '.*dev',
#   }
#
# That structure would look like:
#
# dctl::services::services:
#   sample_dev:
#     service_vars:
#       NUM_WORKERS: "3"
#
#   sample_prod:
#     service_vars:
#       NUM_WORKERS: "10"

# This approach is modeled loosely after the apache::vhosts class

class dctl::services (
  Hash $services = {},
  String $filter = '.*',
)  {

  # create each service listed in services
  # if there is a filter, only create services that match

  $services.each | $service_name, $service | {
    if $service_name =~ $filter {
      create_resources('dctl::service', {$service_name =>  $services[$service_name]})
    }

  }

}
