
# service define uses the PROJECT_ENV convention to avoid disruption to
# existing hiera structures. It allows the specification of a PROJECT_ENV pair,
# and creates the appropriate services.


# This define creates a "service" which is just an environment that uses
# project defaults.  Environments should not be used by themselves, they only
# exist in the context of a service.



define dctl::service (
  String $project_url = '',
  String $compose_hash = '',
  String $compose_path = '',
  Hash $project_vars = {},
  Hash $service_vars = {},
) {

  # split this the same way as environment
  $name_array = split($name, '_')
  $project = $name_array[0]
  $deploy_env = $name_array[1]

  # ensure that the project exists
  ensure_resource('dctl::project', $project)


  # create the environment. We allow some vars to be overriden (url/hash/path),
  # but project_vars will always reference the project's project_vars.  The
  # project_vars as a parameter to this define were initially put in place to
  # faciliate hiera lookups & defaults, but it can likely be removed.

  # project_vars and service_vars are merged in the environment
  # (dctl::environment)

  dctl::environment { "${project}_${deploy_env}":
    project_url  => pick($project_url, Dctl::Project[$project]["project_url"]),
    compose_hash => pick($compose_hash, Dctl::Project[$project]["compose_hash"]),
    compose_path => pick($compose_path, Dctl::Project[$project]["compose_path"]),
    project_vars => Dctl::Project[$project]["project_vars"],
    service_vars => $service_vars,
  }

}

