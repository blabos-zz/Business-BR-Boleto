package Business::BR::Boleto::FebrabanSpec;

use Moo;

use Business::BR::Boleto::Utils qw{ mod11 };

has 'codigo_banco' => (
    is       => 'ro',
    required => 1,
);

has 'codigo_moeda' => (
    is      => 'ro',
    default => sub { '9' },
);

has 'dv_codigo_barras' => (
    is      => 'rw',
    lazy    => 1,
    builder => sub {
        my ($self) = @_;

        return mod11( $self->codigo_banco
              . $self->codigo_moeda
              . $self->fator_vencimento
              . $self->valor_nominal
              . $self->campo_livre );
    },
);

has 'fator_vencimento' => (
    is       => 'ro',
    required => 1,
);

has 'valor_nominal' => (
    is       => 'ro',
    required => 1,
);

has 'campo_livre' => (
    is       => 'ro',
    required => 1,
);

sub codigo_barras {
    my ($self) = @_;

    return
        $self->codigo_banco
      . $self->codigo_moeda
      . $self->dv_codigo_barras
      . $self->fator_vencimento
      . $self->valor_nominal
      . $self->campo_livre;
}

1;

