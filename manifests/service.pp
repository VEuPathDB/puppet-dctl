# @summary create a docker-compose 'service' which includes templates for compose files & environment
#
# this ensure that the service template is populated, and that the defined
# service is running.  Provide a list of images that should be updated before
# docker-compose is brought up

#
# @example
#  dctl::service {'testservice-prod':
#    project       => "testservice",
#    overrides     => {'domain' => 'bob.com' },
#    environment   => ['"SOLR_JAVA_MEM=-Xms128m -Xmx128m"'],
#    update_images => {image => 'example/image', image_tag => 'tag'}
#  }


define dctl::service (
  String $project,
  Hash $overrides = {},
  Array $update_images = [],
) {

  include '::docker'
  include '::docker::compose'

  # TODO fix how project_dir is overloaded
  $project_dir = "${$::dctl::docker_compose_dir}/${::dctl::project_dir}/${project}"

  # render template for the service
  file { "${project_dir}/docker-compose-${name}.yml":
    ensure  => file,
    content => epp(Dctl::Project[$project][docker_compose_service_template], $overrides),
  }

  # update any given images
  $update_images.each |Hash $image| {
    docker::image { $image['image']:
      image_tag => $image['image_tag'],
      before => Docker_compose["${project}_${name}"],
    }

  }

  # bring compose project up
  docker_compose { "${project}_${name}":
    ensure        => present,
    compose_files => ["${project_dir}/docker-compose.yml", "${project_dir}/docker-compose-${name}.yml"],
  }


}
