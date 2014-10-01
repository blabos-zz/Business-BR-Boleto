package Business::BR::Boleto::Role::Renderer;

use Moo::Role;

requires qw{ render };

has 'boleto' => (
    is       => 'ro',
    required => 1,
);

1;

