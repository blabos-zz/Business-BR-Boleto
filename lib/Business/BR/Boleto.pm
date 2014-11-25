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
    is       => 'rwp',
    required => 1,
);

has 'cedente' => (
    is       => 'rwp',
    required => 1,
);

has 'sacado' => (
    is       => 'rwp',
    required => 1,
);

has 'pagamento' => (
    is       => 'rwp',
    required => 1,
);

has 'avalista' => (
    is       => 'rwp',
    required => 0,
);

has 'febraban' => (
    is      => 'rwp',
    lazy    => 1,
    builder => 1,
);

sub BUILD {
    my ($self) = @_;

    $self->_set_banco(
        load_and_new(
            module => $self->banco,
            prefix => 'Business::BR::Boleto::Banco',
            args   => [],
        )
    );

    $self->_set_cedente( Business::BR::Boleto::Cedente->new( $self->cedente ) );
    $self->_set_sacado( Business::BR::Boleto::Sacado->new( $self->sacado ) );
    $self->_set_pagamento(
        Business::BR::Boleto::Pagamento->new( $self->pagamento ) );

    if ( $self->avalista ) {
        $self->_set_avalista(
            Business::BR::Boleto::Avalista->new( $self->avalista ) );
    }
    else {
        $self->_set_avalista(
            Business::BR::Boleto::Avalista->new(
                map { $_ => '' } qw{ nome documento endereco }
            )
        );
    }

    ## Forçando build de atributos lazy
    $self->febraban;

    return;
}

sub _build_febraban {
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

=method BUILD

Método privado que inicializa objetos internos. Não deve ser invocado
diretamente.

=cut

