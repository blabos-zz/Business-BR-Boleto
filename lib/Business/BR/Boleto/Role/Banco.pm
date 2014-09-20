package Business::BR::Boleto::Role::Banco;

use Moo::Role;
use File::ShareDir qw{ module_file };

requires qw{ nome codigo campo_livre pre_render };

sub logo {
    my ($self) = @_;

    my $class = ref $self;
    return module_file( ref($self), 'logo.png' );
}

1;

