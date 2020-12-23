# should pull down compose file from git by hash, and create env file from vars

# directory layout per service:

# full_project_path
#  \_ compose_files
#    \_ HASH
#  \_ ${deploy_environment} # (dev/qa/prod)
#    \_ docker-compose.yml -> ../compose_files/HASH
#    \_ env

# puppet then just runs:
# "docker-compose -f ${full_project_path}/env/docker-compose.yml up", 
# DOCKER_PROJECT_NAME is injected into the env so admins can run
# "docker-compose up" in $(full_project_path}/env/ for the same thing

# compose only refreshes if docker-compose.yml link changes

# hiera structure:

#dctl::projects:
#  osigen:
#    project_url: "https://raw.githubusercontent.com/ORG/REPO"
#    compose_hash: "46d826b81cefad675ff2e972ef771e078b007910"
#    compose_path: "docker/docker-compose.yml"
#    project_vars:
#      KEY: "default_value"
#      FOO: "default_bar"
#      BAZ: "default_ham"
#
#dctl::osigen::qa:
#  osigen_qa:
#    #compose_hash: "deadbeef" # possible override
#    service_vars:
#      KEY: "value"
#      FOO: "bar"


define dctl::service (
  String $project_url = undef,
  String $compose_hash = "",
  String $compose_path = "",
  Hash $project_vars = {},
  Hash $service_vars = {},
) {

  include '::docker'
  include '::docker::compose'

  # pull apart name, using PROJECT_ENV convention.  This is done this way to
  # ensure unique names for the services. When using hiera and
  # create_resources, it is often easier to conform to the PROJECT_ENV standard
  # in hiera than to try and construct it after the fact in this define

  $name_array = split($name, '_')
  $project = $name_array[0]
  $deploy_env = $name_array[1]


  # the root of the project
  $full_project_path = "${$::dctl::docker_compose_dir}/${::dctl::project_dir}/${project}"

  # merge in project default vars
  # we also set COMPOSE_PROJECT_NAME to $name so that "docker-compose up /
  # down" can work from the deploy_env dir

  $vars = deep_merge($project_vars, ($service_vars + {'COMPOSE_PROJECT_NAME' => $name}))

  # create deploy_env dir
  file { "${full_project_path}/${deploy_env}":
    ensure => directory,
  }

  # create cached hash file.
  # we do it this way to not make requests to github every run.  When the file
  # at that hash is downloaded, it will not change, so this will work fine as
  # long as the hash file on the server itself is left unmolested.

  $dc_url = "${project_url}/${compose_hash}/${compose_path}"
  $hash_file = "${full_project_path}/compose_files/${compose_hash}"

  exec{"dc_hash_${name}":
    command => "curl -o ${hash_file} ${dc_url}",
    creates => $hash_file
  }

  # Then we ensure the docker-compose.yml in the deploy_env dir links to the correct hash

  file{ "${full_project_path}/${deploy_env}/docker-compose.yml":
    ensure  => link,
    target  => "../compose_files/${compose_hash}",
    notify  => Docker_compose[$name],
  }

  # create env file

  $env_template = @(END)
<% $vars.each |$key, $value| { -%>
<%= $key -%>=<%= $value %>
<% } -%>
END

  file { "${full_project_path}/${deploy_env}/.env":
    content => inline_epp($env_template, {vars => $vars}),
    notify  => Docker_compose[$name],
  }

  # setup docker-compose resource / service
  docker_compose { $name:
    ensure        => present,
    compose_files => [
      "${full_project_path}/${deploy_env}/docker-compose.yml",
    ],
    options => ["--env-file", "${full_project_path}/${deploy_env}/.env"],
  }


}


