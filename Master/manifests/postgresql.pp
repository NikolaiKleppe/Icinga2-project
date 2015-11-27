class { 'postgresql::server':
  postgres_password => hiera('icinga2::db_password'),
}

  postgresql::server::db { 'icinga2_data':
    user     => 'icinga2',
    password => postgresql_password('icinga2', '$(postgres_password)'),
  }
