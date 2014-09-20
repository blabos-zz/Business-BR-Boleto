package Business::BR::Boleto::Pagamento;

use Moo;
use DateTime;

has 'data_documento' => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $hoje = DateTime->today;

        return $hoje;
    },
);

has 'data_vencimento' => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my ($self) = @_;

        my $copia = $self->data_documento->clone;

        return $copia->truncate( to => 'day' )->add( days => 5 );
    },
);

has 'numero_documento' => (
    is      => 'ro',
    default => sub { '' },
);

has 'nosso_numero' => (
    is       => 'ro',
    required => 1,
);

has 'quantidade' => (
    is      => 'ro',
    default => sub { '' },
);

has 'valor' => (
    is      => 'ro',
    default => sub { '' },
);

has 'valor_documento' => (
    is       => 'ro',
    required => 1,
);

has 'especie' => (
    is      => 'ro',
    default => sub { 'DM' },
);

has 'moeda' => (
    is      => 'ro',
    default => sub { 'R$' },
);

has 'aceite' => (
    is      => 'ro',
    default => sub { 'N' },
);

has 'local_pagamento' => (
    is      => 'ro',
    default => 'Pagável em qualquer banco até o vencimento',
);

has 'instrucoes' => (
    is      => 'ro',
    default => sub { '' },
);

1;
