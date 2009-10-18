use MooseX::Declare;
class SQL::Translator::Object::Table extends SQL::Translator::Object is dirty {
    use MooseX::Types::Moose qw(Any Bool HashRef Str);
    use MooseX::MultiMethods;
    use SQL::Translator::Types qw(Column Constraint Index Schema Sequence);
    clean;

    use overload
        '""'     => sub { shift->name },
        'bool'   => sub { $_[0]->name || $_[0] },
        fallback => 1,
    ;

    has 'name' => (
        is => 'rw',
        isa => Str,
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
            remove_column => 'delete',
            clear_columns => 'clear',
        },
        default => sub { my %hash = (); tie %hash, 'Tie::IxHash'; return \%hash },
    );
    
    has 'indexes' => (
        traits => ['Hash'],
        is => 'rw',
        isa => HashRef[Index],
        handles => {
            exists_index => 'exists',
            index_ids    => 'keys',
            get_indices  => 'values',
            get_index    => 'get',
            add_index    => 'set',
            remove_index => 'delete',
        },
        default => sub { my %hash = (); tie %hash, 'Tie::IxHash'; return \%hash },
    );
    
    has 'constraints' => (
        traits => ['Hash'],
        is => 'rw',
        isa => HashRef[Constraint],
        handles => {
            exists_constraint => 'exists',
            constraint_ids    => 'keys',
            get_constraints   => 'values',
            get_constraint    => 'get',
            add_constraint    => 'set',
            remove_constraint => 'delete',
        },
        default => sub { my %hash = (); tie %hash, 'Tie::IxHash'; return \%hash },
    );
    
    has 'sequences' => (
        traits => ['Hash'],
        is => 'rw',
        isa => HashRef[Sequence],
        handles => {
            exists_sequence => 'exists',
            sequence_ids    => 'keys',
            get_sequences   => 'values',
            get_sequence    => 'get',
            add_sequence    => 'set',
            remove_sequence => 'delete',
        },
        default => sub { my %hash = (); tie %hash, 'Tie::IxHash'; return \%hash },
    );

    has 'schema' => (
        is => 'rw',
        isa => Schema,
        weak_ref => 1,
    );

    has 'temporary' => (
        is => 'rw',
        isa => Bool,
        default => 0
    );

    around add_column(Column $column does coerce) {
        die "Can't use column name " . $column->name if $self->exists_column($column->name) || $column->name eq '';
        $column->table($self);
        return $self->$orig($column->name, $column);
    }

    around add_constraint(Constraint $constraint does coerce) {
        my $name = $constraint->name;
        if ($name eq '') {
            my $idx = 0;
            while ($self->exists_constraint('ANON' . $idx)) { $idx++ }
            $name = 'ANON' . $idx;
        }
        $constraint->table($self);
        if ($constraint->has_type && $constraint->type eq 'PRIMARY KEY') {
            $self->get_column($_)->is_primary_key(1) for $constraint->column_ids;
        }
        $self->$orig($name, $constraint)
    }

    around add_index(Index $index does coerce) {
        my $name = $index->name;
        if ($name eq '') {
            my $idx = 0;
            while ($self->exists_index('ANON' . $idx)) { $idx++ }
            $name = 'ANON' . $idx;
        }
        $index->table($self);
        $self->$orig($name, $index)
    }

    around add_sequence(Sequence $sequence does coerce) { $self->$orig($sequence->name, $sequence) }

    multi method primary_key(Any $) { grep /^PRIMARY KEY$/, $_->type for $self->get_constraints }
    multi method primary_key(Str $column) { $self->get_column($column)->is_primary_key(1) }

    method is_valid { return $self->get_columns ? 1 : undef }
    method order { }

    before name($name?) { die "Can't use table name $name, table already exists" if $name && $self->schema->exists_table($name) && $name ne $self->name }

    around remove_column(Column|Str $column, Int :$cascade = 0) {
        my $name = is_Column($column) ? $column->name : $column;
        die "Can't drop non-existant column " . $name unless $self->exists_column($name);
        $self->$orig($name);
    }

    around remove_index(Index|Str $index) {
        my $name = is_Index($index) ? $index->name : $index;
        die "Can't drop non-existant index " . $name unless $self->exists_index($name);
        $self->$orig($name);
    }

    around remove_constraint(Constraint|Str $constraint) {
        my $name = is_Constraint($constraint) ? $constraint->name : $constraint;
        die "Can't drop non-existant constraint " . $name unless $self->exists_constraint($name);
        $self->$orig($name);
    }
}
