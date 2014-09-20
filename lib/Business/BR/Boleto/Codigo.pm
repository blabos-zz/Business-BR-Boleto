package Business::BR::Boleto::Codigo;

use Moo;

has 'numero' => (
    is       => 'ro',
    required => 1,
);

has 'dv' => (
    is       => 'ro',
    required => 0,
);

1;

