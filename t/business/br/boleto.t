#!perl

use Test::Most;
use DateTime;

use lib 't/lib';

use Business::BR::Boleto;
use Business::BR::Boleto::Renderer::Teste;

my ( $boleto, $renderer, %args, $got, %expected );

%args     = %{ args() };
%expected = %{ dados_renderizados() };
delete $args{avalista};
$expected{avalista} = { map { $_ => '' } qw{ nome documento endereco } };

$boleto   = Business::BR::Boleto->new(%args);
$renderer = Business::BR::Boleto::Renderer::Teste->new;
$got      = $renderer->render($boleto);
is_deeply( $got, \%expected, 'Renderizando sem avalista', );

%args     = %{ args() };
%expected = %{ dados_renderizados() };

$boleto   = Business::BR::Boleto->new(%args);
$renderer = Business::BR::Boleto::Renderer::Teste->new;
$got      = $renderer->render($boleto);
is_deeply( $got, \%expected, 'Renderizando com avalista', );

done_testing;
##############################################################################

sub args {
    my $data_documento = DateTime->new(
        year      => 2014,
        month     => 1,
        day       => 1,
        locale    => 'pt_BR',
        time_zone => 'America/Sao_Paulo',
    );

    my $data_vencimento = $data_documento->clone->add( months => 3 );

    ## Documentos gerados com:
    ## Business::BR::CNPJ::raondom_cnpj
    ## Business::BR::CPF::random_cpf
    return {
        banco    => 'Teste',
        avalista => {
            nome      => 'Beltrano Augusto',
            documento => '553.869.767-37',
            endereco  => 'Rua de Lá, 42 - Centro, São Paulo/SP',
        },
        cedente => {
            nome      => 'Lojas Silva LTDA',
            endereco  => 'Av. José da Silva, 2 - Centro, São Paulo/SP',
            documento => '84.476.158/0001-22',
            agencia   => {
                numero => '1234',
            },
            conta => {
                numero => '12345',
                dv     => '6',
            },
            carteira => '123',
        },
        sacado => {
            nome      => 'Fulano de Souza',
            endereco  => 'Rua Daqui, s/n - Centro, São Paulo/SP',
            documento => '995.818.798-11',
        },
        pagamento => {
            data_documento   => $data_documento,
            data_vencimento  => $data_vencimento,
            valor_documento  => 1234.56,
            nosso_numero     => '777',
            numero_documento => '123',
            instrucoes       => 'Pague o aluguel!',
        },
    };
}

sub dados_renderizados {
    return {
        'pagamento' => {
            'especie'         => 'DM',
            'local_pagamento' => 'Pagável em qualquer banco até o vencimento',
            'instrucoes'      => 'Pague o aluguel!',
            'moeda'           => 'R$',
            'valor_documento' => '1234.56',
            'numero_documento' => '123',
            'quantidade'       => '',
            'data_documento'   => '2014-01-01',
            'data_vencimento'  => '2014-04-01',
            'valor'            => '',
            'aceite'           => 'N',
            'nosso_numero'     => '777',
        },
        'sacado' => {
            'documento' => '995.818.798-11',
            'endereco'  => 'Rua Daqui, s/n - Centro, São Paulo/SP',
            'nome'      => 'Fulano de Souza',
        },
        'banco' => {
            'logo' => 't/lib/auto/Business/BR/Boleto/Banco/Teste/logo.png',
            'nosso_numero'   => '123/00000777-6',
            'codigo_cedente' => '1234/12345-6',
        },
        'cedente' => {
            'documento' => '84.476.158/0001-22',
            'carteira'  => '123',
            'agencia'   => {
                'numero' => 1234,
            },
            'endereco' => 'Av. José da Silva, 2 - Centro, São Paulo/SP',
            'conta'    => {
                'dv'     => '6',
                'numero' => 12345,
            },
            'nome' => 'Lojas Silva LTDA',
        },
        'avalista' => {
            'nome'      => 'Beltrano Augusto',
            'documento' => '553.869.767-37',
            'endereco'  => 'Rua de Lá, 42 - Centro, São Paulo/SP',
        },
        'febraban' => {
            'linha_digitavel' =>
              '99991.23004 00077.761237 41234.519993 3 60200000123456',
            'codigo_banco'     => '999',
            'codigo_moeda'     => '9',
            'dv'               => 3,
            'valor_nominal'    => '0000123456',
            'fator_vencimento' => '6020',
            'campo_livre'      => '1230000077761234123451999',
        },
    };
}

