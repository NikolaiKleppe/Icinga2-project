#Generate the PKI certification

class ssl::cert (
  $pki_dir     = $::ssl::pki_dir,
  $fqdn        = $::ssl::fqdn,
  $master      = $::ssl::master,
  $master_port = $::ssl::master_port,
  $ticket      = $::ssl::ticket,
) {

 include ssl
 include ssl::params

 $crt_file       = "${ssl::params::pki_dir}/${fqdn}.crt"
 $key_file       = "${ssl::params::pki_dir}/${fqdn}.key"
 $ca_signed      = "${ssl::params::pki_dir}/ca.crt"                #Hardcoded
 $trusted_master = "${ssl::params::pki_dir}/trusted-master.crt"    #Hardcoded  


# [Generate local self-signed cert and private key]
 exec { "local-cert":
   command => "/usr/sbin/icinga2 pki new-cert --cn ${fqdn} --key ${key_file} --cert ${crt_file}",
   path    => "/usr/bin:/usr/sbin:/bin",
   unless  => "test -f ${key_file}",          #Only run exec if file doesn't exist

 }
 
 file { $key_file:                            #Private key must be read only by root.
   ensure  => present,
   mode    => '0600',
   owner   => 'root',
   group   => 'root',
   require => Exec['local-cert'],             #Make sure the file is created before setting attributes
 }

# [Request master cert from master and store it]
 exec { 'master-cert':
   command => "/usr/sbin/icinga2 pki save-cert --key ${key_file} --cert ${crt_file} \
               --trustedcert ${trusted_master} --host ${master} --port ${master_port}",
   path    => "/usr/bin:/usr/sbin:/bin",
   unless  => "test -f ${trusted_master}",
   require => Exec['local-cert'],             #Run the command in order (Top to bottom in this file)
 }

# [Send self-signed cert to master host using ticket, receive CA signed cert and master ca.crt cert]
 exec { 'ca-signed-cert':
   command => "/usr/sbin/icinga2 pki request --host ${master} --port ${master_port} \
               --ticket ${ticket} --key ${key_file} --cert ${crt_file} \
               --trustedcert ${trusted_master} --ca ${ca_signed}",
   path    => "/usr/bin:/usr/sbin:/bin",
   unless  => "test -f ${ca_signed}",
   require => Exec['master-cert'],            #Run the command in order
 }
 
 # [Specify local endpoint and zone name, set master host as parent zone]
 exec { 'node-setup':
   command => "/usr/sbin/icinga2 node setup --ticket ${ticket} --endpoint ${master} \
               --zone ${fqdn} --master_host ${master} --trustedcert ${trusted_master}",
   path    => "/usr/bin:/usr/sbin:/bin",
   unless  => "grep -r \'object Endpoint \"manager.borg.trek\"\' /etc/icinga2/zones.conf",
                                              #^ Just checking a random line in the file, probably not a very good way. 
   require => Exec['ca-signed-cert'],         #Run the command in order
 }

# [Restart icinga2 on client]
}
