use Module::Build;
my $build = Module::Build->new (
  module_name => 'Business::Bof::Server',
  dist_name => 'Business::Bof::Server',
  dist_author => 'Kaare Rasmussen <kar at kakidata.dk>',
  dist_abstract => 'Application Server featuring User Control and Remote Object Execution',
  dist_version => '0.06',
  license => 'perl',
  requires => {
    'POE'                          => '0.29',
    'POE::Component::Server::SOAP' => '1.05',
    'DateTime'                     => '0.22',
    'DBD::SQLite'                  => '0',
    'DBIx::Recordset'              => '0',
    'Class::DBI'                   => 'x',
    'Log::Log4perl'                => '0.47',
    'XML::Dumper'                  => '0.71',
    'Digest::MD5'                  => '2.33',
    'Printer'                      => '0',
    'LWP::Protocol::https'         => '0'
  },
);
$build->create_build_script;
