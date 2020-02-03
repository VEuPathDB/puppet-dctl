# @summary create a docker-compose 'service' which includes templates for compose files & environment
#
# this ensure that the service template is populated, and that the defined
# service is running.  Provide a list of images that should be updated before
# docker-compose is brought up

# This uses the naming convention PROJECT_SERVICE when this is used.  The
# project reference is taken directly from the name.
#
# The below example uses the testservice project

# @example
#  dctl::service {'testservice_prod':
#    overrides     => {'domain' => 'bob.com' },
#    environment   => ['"SOLR_JAVA_MEM=-Xms128m -Xmx128m"'],
#    update_images => {image => 'example/image', image_tag => 'tag'}
#  }


define dctl::service (
  Hash $overrides = {},
  Array $update_images = [],
) {

  include '::docker'
  include '::docker::compose'

  $name_array = split($name, '_') # pull apart name, using PROJECT_SERVICE convention
  $project = $name_array[0]
  $service = $name_array[1]

  # TODO fix how project_dir is overloaded
  $project_dir = "${$::dctl::docker_compose_dir}/${::dctl::project_dir}/${project}"

  # render template for the service
  file { "${project_dir}/docker-compose-${service}.yml":
    ensure  => file,
    content => epp(Dctl::Project[$project][docker_compose_service_template], $overrides),
  }

  # update any given images
  $update_images.each |Hash $image| {
    docker::image { $image['image']:
      image_tag => $image['image_tag'],
      before => Docker_compose["${name}"],
    }

  }

  # TODO this unfortunately restarts the whole project on refresh - would be
  # nice if it did a nice 'docker-compose up'

  # bring compose project up
  docker_compose { "${name}":
    ensure        => present,
    compose_files => ["${project_dir}/docker-compose.yml", "${project_dir}/docker-compose-${service}.yml"],
    subscribe     => [File["${project_dir}/docker-compose.yml"], File["${project_dir}/docker-compose-${service}.yml"]],
  }


}
