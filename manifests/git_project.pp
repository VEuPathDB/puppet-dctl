# @summary create a docker-compose project 
#
# this will create the structure for a docker-compose service/project.
# It is mainly used to create the directory structure used by git_service,
# however, it also provides defaults that can be used by git_service resources.

#
# @example
#  dctl::git_project{'testservice':
#    project_url  => "https://raw.githubusercontent.com/ORG/REPO",
#    compose_hash => "462926ba1c7fad675ff2e072ef791e070b40a910",
#    compose_path => "docker-compose.yml",
#    project_vars => { "KEY" => "VALUE},
#  }



define dctl::git_project (
  String $project_url = "",
  String $compose_hash = "",
  String $compose_path = "",
  Hash $project_vars = {},
  #  Hash $service_vars = {},
) {

  # top level project dir
  $project_dir = "${$::dctl::docker_compose_dir}/${::dctl::project_dir}/${name}"

  # create project dir and compose_files storage dir

  # until old-style projects are retired, we need to conditionally check for
  # existence of this resource, since it is defined both places

  if ! defined(File[$project_dir]) {
    file { $project_dir:
      ensure => directory,
    }
  }

  file { "${project_dir}/compose_files":
    ensure => directory,
  }

}
