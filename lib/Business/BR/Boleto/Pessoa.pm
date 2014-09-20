package Business::BR::Boleto::Pessoa;

use Moo;
use Carp;

has 'nome' => (
    is       => 'ro',
    required => 1,
);

has 'endereco' => (
    is       => 'ro',
    required => 1,
);

has 'documento' => (
    is       => 'ro',
    required => 1,
);

1;

