
class dctl (
  $foo = $dctl::params::foo
) inherits dctl::params {
  contain 'dctl::common'
}

