# @summary create a docker-compose 'service' which includes templates for compose files & environment
#
# this ensure that the service template is populated, and that the defined
# service is running.  Provide a list of images that should be updated before
# docker-compose is brought up

# This uses the naming convention PROJECT_SERVICE when this is used.  The
# project reference is taken directly from the name.
#
# image management is done through the passed in images argument, which *must* specify:
# * template name - the name used by the template for the image: line in the docker-compose-SERVICE.yml file
# * image_name    - the name of the image
# * update        - whether to update the image to the latest version
#
# The below example uses the testservice project

# @example
#  dctl::service {'testservice_prod':
#    images => {
#      'template_name' => 'demo_image',
#      'image_name' => 'demo_name',
#      'image_tag'  => 'demo_tag',
#      'update'     => false }
#    overrides     => {'domain' => 'bob.com' },
#    environment   => ['"SOLR_JAVA_MEM=-Xms128m -Xmx128m"'],
#    update_images => {image => 'example/image', image_tag => 'tag'}
#  }


define dctl::service (
  Hash $overrides = {},
  Array $images = [],
) {

  include '::docker'
  include '::docker::compose'

  $name_array = split($name, '_') # pull apart name, using PROJECT_SERVICE convention
  $project = $name_array[0]
  $service = $name_array[1]

  $full_project_path = "${$::dctl::docker_compose_dir}/${::dctl::project_dir}/${project}"

  # add images to template hash
  # this looks quite a mess, but just takes the $images array, and sets the 
  # 'template_name' to 'image_name/image_tag' based on the list of $images given for the service
  $template_images = $images.reduce({}) |$memo, $value| { $memo.merge( {$value['template_name'] => "${value['image_name']}:${value['image_tag']}" } ) }

  # merge in image hash
  $template_hash = merge($overrides, $template_images)

  # render template for the service
  file { "${full_project_path}/docker-compose-${service}.yml":
    ensure  => file,
    content => epp(Dctl::Project[$project][docker_compose_service_template], $template_hash),
  }

  # update any given images
  $images.each |Hash $image| {
    if ($image['update']) {
      docker::image { $image['image_name']:
        image_tag => $image['image_tag'],
        before    => Docker_compose[$name],
      }
    }
  }

  # TODO this unfortunately restarts the whole project on refresh - would be
  # nice if it did a nice 'docker-compose up'

  # bring compose project up
  docker_compose { $name:
    ensure        => present,
    compose_files => [
      "${full_project_path}/docker-compose.yml",
      "${full_project_path}/docker-compose-${service}.yml"
    ],
    subscribe     => [
      File["${full_project_path}/docker-compose.yml"],
      File["${full_project_path}/docker-compose-${service}.yml"]
    ],
  }


}
