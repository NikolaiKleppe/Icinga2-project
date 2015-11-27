#Installing Icinga2 for the server

class { 'icinga2::server':
  server_db_type => 'pgsql',
  db_host        => 'localhost',
  db_port        => '5432',
  db_name        => 'icinga2_data',
  db_user        => 'icinga2',
  db_password    => hiera('icinga2::db_password'),
  
# List all features to be enabled/disabled here.
#    server_enabled_features => ['checker', 'notification', 'ido-pgsql'],
}

#This class will add an IDO connection object for our icinga2 master-server
icinga2::object::idopgsqlconnection { 'postgres_connection':
   target_dir       => '/etc/icinga2/features-enabled',
   target_file_name => 'ido-pgsql.conf',
   host             => '127.0.0.1',
   port             => 5432,
   user             => 'icinga2',
   password         => hiera('icinga2::password'),
   database         => 'icinga2_data',
   categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
}

#Objects:

icinga2::object::filelogger { 'debug-file':
  severity         => 'critical',    #debug, notice, information, warning, critical
  path             => '/var/log/icinga2/debug.log',
  target_dir       => '/etc/icinga2/objects/fileloggers/',
  target_file_name => 'filelogger.conf',
}

#Test, basic checks on the client node. 
icinga2::object::host { 'monitor.borg.trek':
  ipv4_address     => '192.168.180.104',
  check_command    => 'hostalive',
  target_dir       => '/etc/icinga2/objects/hosts',
  target_file_name => 'monitor.borg.trek.conf',
}

icinga2::object::service { 'pingTest':
  host_name        => 'monitor.borg.trek',
  check_command    => 'ping4',
  target_dir       => '/etc/icinga2/objects/services',
  target_file_name => 'pingTest.conf',
}

icinga2::object::service { 'httpTest':
  host_name        => 'monitor.borg.trek',
  check_command    => 'http',
  target_dir       => '/etc/icinga2/objects/services',
  target_file_name => 'httpTest.conf',
}

icinga2::object::service { 'loadCheck':
  host_name        => 'monitor.borg.trek',
  check_command    => 'load',
  target_dir       => '/etc/icinga2/objects/services',
  target_file_name => 'loadCheck.conf',
}





