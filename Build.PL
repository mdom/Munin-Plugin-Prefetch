use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name        => 'Munin::Plugin::PreFetch',
    dist_version       => '0.01',
    release_status     => 'stable',
    configure_requires => {
        'Module::Build'  => 0,
        'File::Temp'     => 0,
        'File::Basename' => 0,
        'File::Copy'     => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup     => ['Munin-Plugin-PreFetch-*'],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
