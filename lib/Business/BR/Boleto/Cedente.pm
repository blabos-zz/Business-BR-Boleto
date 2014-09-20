package Business::BR::Boleto::Cedente;

use Moo;
extends 'Business::BR::Boleto::Pessoa';

use Carp;

has 'agencia' => (
    is       => 'ro',
    required => 1,
    isa      => sub {
        Carp::croak 'Agência do cendente inválida'
          unless ref $_[0] eq 'HASH' && exists $_[0]->{numero};
    },
);

has 'conta' => (
    is       => 'ro',
    required => 1,
    isa      => sub {
        Carp::croak 'Conta do cendente inválida'
          unless ref $_[0] eq 'HASH' && exists $_[0]->{numero};
    },
);

has 'carteira' => (
    is       => 'ro',
    required => 1,
);

1;

