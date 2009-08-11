use MooseX::Declare;
class SQL::Translator::Object::ForeignKey {
    use MooseX::Types::Moose qw(ArrayRef Maybe Undef Str);
    extends 'SQL::Translator::Object::Constraint';
    
    has '+type' => (
        default => 'FOREIGN KEY',
    );
    
    has 'reference_columns' => (
         isa => ArrayRef | Undef,
         is => 'rw',
         auto_deref => 1
    );

    has 'on_delete' => (
        isa => Maybe[Str],
        is => 'rw',
    );

    has 'on_update' => (
        isa => Maybe[Str],
        is => 'rw',
    );

    has 'reference_table' => (
        isa => Str,
        is => 'rw',
    );

    method reference_fields { return $self->reference_columns }
}
