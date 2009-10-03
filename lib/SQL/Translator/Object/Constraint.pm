use MooseX::Declare;
class SQL::Translator::Object::Constraint extends SQL::Translator::Object {
    use MooseX::Types::Moose qw(ArrayRef Bool HashRef Maybe Str Undef);
    use MooseX::MultiMethods;
    use SQL::Translator::Types qw(Column Table);

    has 'table' => (
        is => 'rw',
        isa => Table,
        weak_ref => 1,
    );
    
    has 'name' => (
        is => 'rw',
        isa => Maybe[Str],
        required => 1
    );
    
    has 'columns' => (
        traits => ['Hash'],
        is => 'rw',
        isa => HashRef[Column],
        handles => {
            exists_column => 'exists',
            column_ids    => 'keys',
            get_columns   => 'values',
            get_column    => 'get',
            add_column    => 'set',
        },
        default => sub { my %hash = (); tie %hash, 'Tie::IxHash'; return \%hash },
    );
    
    has 'type' => (
        is => 'rw',
        isa => Str,
        required => 1
    );

    has 'deferrable' => (
        is => 'rw',
        isa => Bool,
        default => 1
    );

    has 'expression' => (
        is => 'rw',
        isa => Str,
    );

    has 'reference_table' => (
        isa => Maybe[Str],
        is => 'rw',
    );

    has 'reference_columns' => (
        isa => ArrayRef,
        traits => ['Array'],
        handles => {
            reference_columns => 'elements',
        },
        default => sub { [] },
    );

    has 'match_type' => (
        isa => Str,
        is => 'rw'
    );

    around add_column(Column $column) { $self->$orig($column->name, $column) }

    method reference_fields { $self->reference_columns }
}
