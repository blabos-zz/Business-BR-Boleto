package Business::BR::Boleto::FebrabanSpec;

use Moo;

use Business::BR::Boleto::Utils qw{ mod10 mod11 };

has 'codigo_moeda' => (
    is      => 'ro',
    default => sub { '9' },
);

has 'codigo_banco' => (
    is       => 'ro',
    required => 1,
);

has 'fator_vencimento' => (
    is       => 'rwp',
    required => 1,
);

has 'valor_nominal' => (
    is       => 'rwp',
    required => 1,
);

has 'campo_livre' => (
    is       => 'ro',
    required => 1,
);

has 'dv' => (
    is      => 'ro',
    lazy    => 1,
    builder => 1,
);

has 'codigo_barras' => (
    is      => 'ro',
    lazy    => 1,
    builder => 1,
);

has 'linha_digitavel' => (
    is      => 'ro',
    lazy    => 1,
    builder => 1,
);

sub BUILD {
    my ($self) = @_;

    $self->_set_valor_nominal( sprintf '%010d', $self->valor_nominal );
    $self->_set_fator_vencimento( sprintf '%04d', $self->fator_vencimento );

    ## Forçando o build de atributos lazy
    $self->linha_digitavel;

    return;
}

sub _build_dv {
    my ($self) = @_;

    return mod11( $self->codigo_banco
          . $self->codigo_moeda
          . $self->fator_vencimento
          . $self->valor_nominal
          . $self->campo_livre );
}

sub _build_codigo_barras {
    my ($self) = @_;

    return
        ''
      . $self->codigo_banco
      . $self->codigo_moeda
      . $self->dv
      . $self->fator_vencimento
      . $self->valor_nominal
      . $self->campo_livre;
}

sub _build_linha_digitavel {
    my ($self) = @_;

    my $banco       = $self->codigo_banco;
    my $moeda       = $self->codigo_moeda;
    my $campo_livre = $self->campo_livre;
    my $dv          = $self->dv;
    my $fator       = $self->fator_vencimento;
    my $valor       = $self->valor_nominal;

    my ( $campo1, $campo2, $campo3, $dac, $campo5 );

    $campo1 = $banco . $moeda . substr $campo_livre, 0, 5;
    $campo1 .= mod10($campo1);
    $campo1 =~ s/(.{5})(.{5})/$1.$2/;

    $campo2 = substr $campo_livre, 5, 10;
    $campo2 .= mod10($campo2);
    $campo2 =~ s/(.{5})(.{6})/$1.$2/;

    $campo3 = substr $campo_livre, 15, 10;
    $campo3 .= mod10($campo3);
    $campo3 =~ s/(.{5})(.{6})/$1.$2/;

    $campo5 = $fator . $valor;

    return join ' ', $campo1, $campo2, $campo3, $dv, $campo5;
}

1;

#ABSTRACT: Cálculo do código de barras e linha digitável

=pod

=head1 SYNOPSIS

Monta a sequência numérica do código de barras e da linha digitável a partir
do B<codigo do banco>, B<fator de vencimento>, B<valor nominal> e
B<campo livre> do boleto.

A sequência numérica do código de barras será utilizada pelo render para
desenhar o código de barras.

=method new( %args )

Construtor. Recebe como argumento um hash contendo as seguintes chaves:

=over 4

=item codigo_banco: O código numérico do banco

=item fator_vencimento: O fator de vencimento calculado a partir da data de
vencimento do boleto.

=item valor_nominal: O valor do documento em centavos.

=item campo_livre: O campo livre calculado pelo módulo específico do banco.

=back

=method codigo_barras

Retorna a sequência numérica do código de barras.

=method linha_digitavel

Retorna a representação da sequência numérica do código de barras sob a
forma de uma linha digitável formatada conforme será renderizado depois
no próprio boleto.

=method BUILD

Método privado que inicializa objetos internos. Não deve ser invocado
diretamente.

=cut

