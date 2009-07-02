package SQL::Translator::Object::Trigger;
use Moose;
use MooseX::Types::Moose qw(Str);
use SQL::Translator::Types qw();
extends 'SQL::Translator::Object';

has 'name' => (is => 'ro', isa => Str, required => 1);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
