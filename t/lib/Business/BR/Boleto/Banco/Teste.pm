package Business::BR::Boleto::Banco::Teste;

use Moo;
with 'Business::BR::Boleto::Role::Banco';

use Business::BR::Boleto::Utils qw{ mod10 mod11 };

sub nome   { 'Teste' }
sub codigo { '999' }

sub campo_livre {
    my ( $self, $cedente, $pagamento ) = @_;

    my $nosso_numero = sprintf '%08d', $pagamento->nosso_numero;
    my $carteira     = sprintf '%03d', $cedente->carteira;
    my $agencia      = sprintf '%04d', $cedente->agencia->{numero};
    my $conta        = sprintf '%05d', $cedente->conta->{numero};
    my $conta_dv     = $cedente->conta->{dv};

    my $dac_nn = mod10( $agencia . $conta . $carteira . $nosso_numero );
    my $dac_ac = mod11( $agencia . $conta );

    $self->codigo_cedente( $agencia . '/' . $conta . '-' . $conta_dv );
    $self->nosso_numero( $carteira . '/' . $nosso_numero . '-' . $dac_nn );

    return
        $carteira
      . $nosso_numero
      . $dac_nn
      . $agencia
      . $conta
      . $dac_ac . '999';
}

1;

#ABSTRACT: Operações específicas em um banco de teste.

=pod

=head1 SYNOPSIS

Implementa as operações que são específicas do banco, na geração
do código de barras e linha digitável.

    use Business::BR::Boleto;

    my $b = Business::BR::Boleto->new(
        banco => 'Teste',
        ...
    );

=method nome

Retorna o nome do banco, B<Teste>.

=method codigo

Retorna o código númerico que representa o banco, B<000>

=method pre_render

Realiza alguma manipulação nos dados antes do render gerar o boleto para
impressão.

=method campo_livre

Gera o campo livre do código de barras de acordo com as regras do banco.

=cut

