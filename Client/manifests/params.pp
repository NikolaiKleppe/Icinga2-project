#Params.pp

class ssl::params {
  $pki_dir     = '/etc/icinga2/pki'
  $init_dir    = '/etc/icinga2'

  $fqdn        = ''  #Client FQDN
  $master      = ''  #Master FQDN
  $master_port = 5665
  $ticket      = ''  #Generate ticket on [master] with icinga2 pki ticket --cn (FQDN)
}
