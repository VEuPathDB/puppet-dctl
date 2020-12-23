# @summary create a docker-compose project 
#
# this will create the structure for a docker-compose service/project.
# It is mainly used to create the directory structure used by service,
# however, it also provides defaults that can be used by service resources.

#
# @example
#  dctl::project{'testservice':
#    project_url  => "https://raw.githubusercontent.com/ORG/REPO",
#    compose_hash => "462926ba1c7fad675ff2e072ef791e070b40a910",
#    compose_path => "docker-compose.yml",
#    project_vars => { "KEY" => "VALUE},
#  }



define dctl::project (
  String $project_url = "",
  String $compose_hash = "",
  String $compose_path = "",
  Hash $project_vars = {},
  #  Hash $service_vars = {},
) {

  # top level project dir
  $project_dir = "${$::dctl::docker_compose_dir}/${::dctl::project_dir}/${name}"

  # create project dir and compose_files storage dir

  file { [$project_dir, "${project_dir}/compose_files"]:
    ensure => directory,
  }

}
