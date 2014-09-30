package Business::BR::Boleto::Utils;

use Moo;
extends 'Exporter';

our @EXPORT_OK = qw{
  mod10 mod11
  fator_vencimento
};

use List::Util qw{ sum };

use DateTime;
use Const::Fast;

const our $SEGUNDOS_POR_DIA => 86400;
const our $DATA_BASE_FATOR  => DateTime->new(
    year      => 1997,
    month     => 10,
    day       => 7,
    hour      => 0,
    minute    => 0,
    second    => 0,
    time_zone => 'America/Sao_Paulo',
);

sub mod10 {
    my $number = shift || '';

    $number =~ s/\D+//g;

    my @digits = reverse split //, $number;

    my $sum = 0;
    for my $i ( 0 .. $#digits ) {
        $sum += sum( split //, $i % 2 ? $digits[$i] : 2 * $digits[$i] );
    }

    my $mod = $sum % 10;

    return $mod ? 10 - $mod : 0;
}

sub mod11 {
    my $number = shift || '';

    $number =~ s/\D+//g;

    my @digits = reverse split //, $number;

    my $sum = 0;
    foreach my $i ( 0 .. $#digits ) {
        $sum += $digits[$i] * ( 2 + $i % 8 );
    }

    my $mod = $sum % 11;
    my $res = $mod > 1 ? 11 - $mod : 1;

    return wantarray ? ( $res, $mod ) : $res;
}

sub fator_vencimento {
    my $data_fator = shift;

    $data_fator->truncate( to => 'day' );

    my $delta = $data_fator->subtract_datetime_absolute($DATA_BASE_FATOR);

    return int( 0.5 + $delta->seconds / $SEGUNDOS_POR_DIA );
}

1;

# ABSTRACT: Funções auxiliares para geração de boletos

=head1 SYNOPSIS

    use Business::BR::Boleto::Utils qw{ mod10 mod11 fator_vencimento };

    my $mod10 = mod10( '1234567890' );
    say $mod10;
    # 3

    my $mod11 = mod11( '1234567890' );
    say $mod11;
    # 1

    my ( $res, $mod ) = mod11( '1234567890' );
    say $res;
    say $mod;
    # 1, 0

=method mod10( $str_num )

Calcula o B<Módulo 10> de uma determinada sequência numérica de acordo
o seguinte algoritmo:

1) Enumere a partir de zero, os dígitos da sequência da direita para a
esquerda;

2) Multiplique os dígitos em posições pares (0, 2, 4, ...) por 2 e os
dígitos em posições ímpares (1, 3, 5, ...) por 1;

3) Some os dígitos de cada produto e em seguida calcule o resto da divisão
inteira dessa soma por 10;

4) O B<Módulo 10> será o resultado da subtração C<10 - resto>.

Exemplo:

    Sequência numérica: 261533

      5   4   3   2   1   0
    +---+---+---+---+---+---+
    | 2 | 6 | 1 | 5 | 3 | 3 |
    +---+---+---+---+---+---+
      |   |   |   |   |   |
    X 1   2   1   2   1   2
      |   |   |   |   |   |
    = 2  12   1  10   3   6
    -------------------------
    soma      = 2 + 1 + 2 + 1 + 1 + 0 + 3 + 6   = 16
    resto     = 16 % 10                         = 6
    módulo 10 = 10 - 6                          = 4

=method mod11( $str_num )

Calcula o B<Módulo 11> de uma determinada sequência numérica de acordo
com o seguinte algoritmo:

1) Enumere a partir de zero, os dígtos da sequência da direita para a
esquerda;

2) Multiplique os dígitos da direita para a esquerda pela sequência
(2, 3, 4, 5, 6, 7, 8, 9) ciclicamente.

3) Some os resultados dos produtos e em seguida calcule o resto da divisão
inteira dessa soma por 11.

4) O B<Módulo 11> será B<0> se o resto for menor que B<2> ou B<11 - resto>
caso contrário.

Exemplo:

    Sequência numérica: 12345261533

     10   9   8   7   6   5   4   3   2   1   0
    +---+---+---+---+---+---+---+---+---+---+---+
    | 1 | 2 | 3 | 4 | 5 | 2 | 6 | 1 | 5 | 3 | 3 |
    +---+---+---+---+---+---+---+---+---+---+---+
      |   |   |   |   |   |   |   |   |   |   |
    X 4   3   2   9   8   7   6   5   4   3   2
      |   |   |   |   |   |   |   |   |   |   |
    = 4   6   6  36  40  14  36   5  20   9   6
    ---------------------------------------------
    soma      = 4 + 6 + 6 + 36 + 40 + 14 + 36 + 5 + 20 + 9 + 6  = 182
    resto     = 182 % 11                                        = 6
    módulo 11 = 11 - 8                                          = 5

=method fator_vencimento( DateTime $data )

Calcula o fator de vencimento bancário que nada mais é do que a quantidade
de dias corridos desde o dia 07 de outubro de 1997 até a data desejada.

Recebe como argumento um objeto B<DateTime> contendo a data desejada e
retorna a quantidade de dias desde a data base descrita acima.

=cut

