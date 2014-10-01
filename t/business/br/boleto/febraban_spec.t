#!perl

use Test::Most;

use Business::BR::Boleto::FebrabanSpec;
use Business::BR::Boleto::Utils qw{ fator_vencimento };

my $data = DateTime->new(
    year      => 2000,
    month     => 1,
    day       => 1,
    locale    => 'pt_BR',
    time_zone => 'America/Sao_Paulo',
);

my $fator = fator_vencimento($data);

my $cb = Business::BR::Boleto::FebrabanSpec->new(
    codigo_banco     => '999',
    fator_vencimento => $fator,
    valor_nominal    => 12345,
    campo_livre      => '1112222222234444555556777',
);

is(
    $cb->codigo_barras,
    '99999081600000123451112222222234444555556777',
    'Código de barras'
);

is(
    $cb->linha_digitavel,
    '99991.11223 22222.234449 45555.567770 9 08160000012345',
    'Linha Digitável',
);

done_testing;

