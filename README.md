# dctl - Docker-Compose Control

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with dctl](#setup)
    * [What dctl affects](#what-dctl-affects)
    * [Beginning with dctl](#beginning-with-dctl)
3. [Usage - Configuration options and additional functionality](#usage)
5. [Development - Guide for contributing to the module](#development)

## Description

This module manages deploying docker-compose projects via the docker puppet module.  It allows you to provide files and templates to docker compose, and manage those services in a flexible way.

## Setup

### What dctl affects 

This modules creates a set of templates under /var/lib/docker-compose/projects (default, this location is configurable) and provides a way to define services using those templates

### Beginning with dctl

No setup is needed, although knowledge of docker & docker-compose is assumed.  This module uses the terms *project* and *service* in distict ways:

#### Projects

a *project* is a set of docker-compose.yml files.  These consist of 3:
* docker-compose.yml - the base configuration of the project
* docker-compose-dctl.yml - an optional template used for a separate user based script (under development)
* docker-compose-\[service\].yml - a template that provides overrides specific to a *service*

#### Services

a *service* is a single running instance of a project.  You may have a project named "webapp" that provides a compose file detailing your web application image, environment, etc.  You are likely to also want several running instances of this project, one for qa, one for prod, etc.  A *service* provides values that fill in the service template, which is run as an overrides file through docker-compose.

## Usage

Define a project:

``` dctl::project{'testservice':
    docker_compose_base => "puppet:///modules/profiles/testservice/docker-compose.yml",
    docker_compose_dctl => "puppet:///modules/profiles/testservice/docker-compose.yml",
    docker_compose_service_template => "profiles/testservice/docker-compose-service.epp",
  }
```

Define 2 service instances of this project:

```
  dctl::service {'testservice-prod':
    project => "testservice",
    override_hash => {'domain' => 'production.example.com' },
    environment => ['"JAVA_MEM=-Xms128m -Xmx128m"'],
  }

  dctl::service {'testservice-staging':
    project => "testservice",
    override_hash => {'domain' => 'staging.example.com' },
  }
```

Care should to be taken when defining the service templates, to make sure appropriate values are provided in the right way.  Environment variables should be handled this way:


Example docker-compose-service.epp

```
version: '3.5'

services:
  solr:
<% if $environment != [] { -%>
    environment:
<% $environment.each |$env| { -%>
      - <%= $env %>
<% } } -%>
    labels:
      - "traefik.http.routers.solr.rule=Host(`<%= $domain %>`)"
      - "traefik.http.routers.solr.tls=true"
      - "traefik.http.routers.solr.entrypoints=local"
```



## Development

Pull requests welcomed

