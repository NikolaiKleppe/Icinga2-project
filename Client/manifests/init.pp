#init.pp

class ssl (
  $pki_dir     = $::ssl::params::pki_dir,
  $init_dir    = $::ssl::params::init_dir,
  $fqdn        = $::ssl::params::fqdn,
  $master      = $::ssl::params::master,
  $master_port = $::ssl::params::master_port,
  $ticket      = $::ssl::params::ticket,

) inherits ssl::params {

  validate_absolute_path($pki_dir)
  validate_absolute_path($init_dir)

  file { "${::ssl::params::init_dir}/icinga2.conf":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',  #Root R/W
  }
}
