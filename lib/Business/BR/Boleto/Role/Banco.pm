package Business::BR::Boleto::Role::Banco;

use Moo::Role;
use File::ShareDir qw{ module_file };

requires qw{ nome codigo campo_livre };

has 'logo' => (
    is      => 'ro',
    builder => sub { module_file( ref( $_[0] ), 'logo.png' ); },
);

has 'codigo_cedente' => ( is => 'rw' );
has 'nosso_numero'   => ( is => 'rw' );

1;

