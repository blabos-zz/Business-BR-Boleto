package Business::BR::Boleto::Renderer::Teste;

use Moo;
with 'Business::BR::Boleto::Role::Renderer';

sub render {
    my ( $self, $boleto ) = @_;

    $boleto->{pagamento}{data_documento} =
      $boleto->pagamento->data_documento->ymd;
    $boleto->{pagamento}{data_vencimento} =
      $boleto->pagamento->data_vencimento->ymd;

    return _fake_unbless($boleto);
}

sub _fake_unbless {
    my $boleto = shift;

    my %boleto = %{$boleto};
    foreach my $key ( sort keys %boleto ) {
        $boleto{$key} = { %{ $boleto{$key} } };
    }

    return \%boleto;
}

1;

