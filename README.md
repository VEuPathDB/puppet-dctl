# dctl - Docker-Compose Control

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with dctl](#setup)
    * [What dctl affects](#what-dctl-affects)
    * [Beginning with dctl](#beginning-with-dctl)
3. [Usage - Configuration options and additional functionality](#usage)
5. [Development - Guide for contributing to the module](#development)

## Description

This module manages deploying docker-compose projects via the docker puppet module.  It allows you to provide references to docker-compose files and variables in hiera, and have them end up in a structured format.

## Setup

### What dctl affects 

This module creates a set of docker-compose files under /var/lib/docker-compose/projects (default, this location is configurable) and provides a way to manage them and their variables.

### Beginning with dctl

No setup is needed, although knowledge of docker & docker-compose is assumed.  This module uses the terms *project* and *service* in distict ways:

#### Projects

a *project* is contained in a docker-compose.yml file.

#### Services

a *service* is a single running instance of a project.  You may have a project named "webapp" that provides a compose file detailing your web application image, environment, etc.  You are likely to also want several running instances of this project, one for qa, one for prod, etc.  A *service* provides values that fill in the service template, which is run as an overrides file through docker-compose.


## Usage

Define a project:

``` 
  dctl::project{'testservice':
    project_url => "https://raw.githubusercontent.com/MyOrg/testservice",
    compose_hash: "deadbee"
    compose_path: "docker-compose.yml"
  }
```

Define 2 service instances of this project.  NOTE: The naming of the resource *must* follow the PROJECT_SERVICE pattern.  The reference to the project is taken directly from the name:

```
TODO
```




## Development

Pull requests welcomed

