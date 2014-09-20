package Business::BR::Boleto::Beneficiario;

use Moo;
use Business::BR::Boleto::Codigo;

has 'agencia' => (
    is       => 'ro',
    required => 1,
);

has 'conta' => (
    is       => 'ro',
    required => 1,
);

sub BUILDARGS {
    my ( $class, $args ) = @_;

    $args->{agencia} = Business::BR::Boleto::Codigo->new( $args->{agencia} );
    $args->{conta}   = Business::BR::Boleto::Codigo->new( $args->{conta} );

    return $args;
}

1;

