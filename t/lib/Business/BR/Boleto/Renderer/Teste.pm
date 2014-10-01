package Business::BR::Boleto::Renderer::Teste;

use Moo;
with 'Business::BR::Boleto::Role::Renderer';

use Storable qw{ dclone };
use Data::Structure::Util qw{ unbless };

sub render {
    my ($self) = @_;

    my $ld     = $self->boleto->febraban->linha_digitavel;
    my $boleto = dclone( $self->boleto );

    $boleto->{pagamento}{data_documento} =
      $boleto->pagamento->data_documento->ymd;
    $boleto->{pagamento}{data_vencimento} =
      $boleto->pagamento->data_vencimento->ymd;

    return unbless($boleto);
}

1;

