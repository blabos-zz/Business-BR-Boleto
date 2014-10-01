package Business::BR::Boleto;

use Moo;
use Carp;

use MAD::Loader qw{ load_and_new };

use Business::BR::Boleto::Cedente;
use Business::BR::Boleto::Sacado;
use Business::BR::Boleto::Avalista;
use Business::BR::Boleto::Pagamento;
use Business::BR::Boleto::FebrabanSpec;

use Business::BR::Boleto::Utils qw{ mod10 fator_vencimento };

has 'banco' => (
    is  => 'ro',
    isa => sub {
        Carp::croak 'Banco inválido'
          unless $_[0]->does('Business::BR::Boleto::Role::Banco');
    },
);

has 'cedente' => (
    is       => 'ro',
    required => 1,
    isa      => sub {
        Carp::croak 'Cendente inválido'
          unless $_[0]->isa('Business::BR::Boleto::Cedente');
    },
);

has 'sacado' => (
    is       => 'ro',
    required => 1,
    isa      => sub {
        Carp::croak 'Sacado inválido'
          unless $_[0]->isa('Business::BR::Boleto::Sacado');
    },
);

has 'avalista' => (
    is      => 'ro',
    default => sub {
        Business::BR::Boleto::Avalista->new(
            nome      => '',
            endereco  => '',
            documento => '',
        );
    },
);

has 'pagamento' => (
    is       => 'ro',
    required => 1,
    isa      => sub {
        Carp::croak 'Dados de pagamento inválidos'
          unless $_[0]->isa('Business::BR::Boleto::Pagamento');
    },
);

has 'febraban' => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        my ($self) = @_;

        my $banco = $self->banco->codigo;
        my $fator = fator_vencimento( $self->pagamento->data_vencimento );
        my $valor = int( 100 * $self->pagamento->valor_documento );

        my $campo_livre = $self->banco->campo_livre(
            ## Calculado pelo módulo específico de cada banco
            $self->cedente,
            $self->pagamento,
        );

        return Business::BR::Boleto::FebrabanSpec->new(
            codigo_banco     => $banco,
            fator_vencimento => $fator,
            valor_nominal    => $valor,
            campo_livre      => $campo_livre,
        );
    }
);

sub BUILDARGS {
    my ( $class, %args ) = @_;

    $args{banco} = load_and_new(
        module => $args{banco},
        prefix => 'Business::BR::Boleto::Banco',
        args   => [],
    );

    $args{cedente}   = Business::BR::Boleto::Cedente->new( $args{cedente} );
    $args{sacado}    = Business::BR::Boleto::Sacado->new( $args{sacado} );
    $args{pagamento} = Business::BR::Boleto::Pagamento->new( $args{pagamento} );

    $args{avalista} = Business::BR::Boleto::Avalista->new( $args{avalista} )
      if $args{avalista};

    return \%args;
}

1;

# ABSTRACT: Sistema para emissão de boletos bancários

=pod

=head1 SYNOPSIS

Sistema para a emissão de boletos bancários

    use Business::BR::Boleto;

    my $boleto = Business::BR::Boleto->new(
        banco     => 'CEF'          ## Caixa Econômica Federal
        avalista  => {
            ...                     ## Dados do sacador avalista se houver
        },
        cedente   => {
            ...                     ## Dados do emissor do boleto
        },
        sacado    => {
            ...                     ## Dados do pagador do boleto
        },
        pagamento => {
            ...                     ## Dados do pagamento, valor, etc
        },
    );

    my $renderer = Business::BR::Boleto::Renderer::PDF->new(
        boleto   => $boleto,
        base_dir => '/tmp/boletos',
    );

    $renderer->render;

=method banco

Retorna o objeto representando a instituição bancária escolhida. Esse objeto
é instanciado automaticamente, desde que disponível no sistema. Veja
L<Business::BR::Boleto::Role::Banco> ou L<Business::BR::Boleto::Banco::Itau>.

=method avalista

Retorna o objeto representando o sacador avalista. Veja
L<Business::BR::Boleto::Avalista>.

=method cedente

Retorna o objeto representando o cedente. Veja
L<Business::BR::Boleto::Cedente>.

=method sacado

Retorna o objeto representando o sacado. Veja
L<Business::BR::Boleto::Sacado>.

=method pagamento

Retorna o objeto que contém os dados de pagamento fornecidos. Veja
L<Business::BR::Boleto::Pagamento>.

=method febraban

Retorna o objeto que contem a representação do código de barras segundo
a especificação da L<FEBRABAN|http://www.febraban.org.br>. Veja
L<Business::BR::Boleto::FebrabanSpec>.

=method BUILDARGS

Método privado que maniula os argumentos e instancia objetos internos a
partir deles. Não deve ser invocada diretamente.

=cut

