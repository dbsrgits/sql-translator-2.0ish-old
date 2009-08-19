use MooseX::Declare;
class SQL::Translator::Object::Trigger {
    use MooseX::Types::Moose qw(ArrayRef HashRef Str);
    use MooseX::AttributeHelpers;
    use SQL::Translator::Types qw(Column);
    extends 'SQL::Translator::Object';
    
    has 'name' => (
        is => 'ro',
        isa => Str,
        required => 1
    );

    has 'columns' => (
        metaclass => 'Collection::Hash',
        is => 'rw',
        isa => HashRef[Column],
        provides => {
            exists => 'exists_column',
            keys   => 'column_ids',
            values => 'get_columns',
            get    => 'get_column',
        },
        curries => {
            set => {
                add_column => sub {
                    my ($self, $body, $column) = @_;
                    $self->$body($column->name, $column);
                }
            }
        },
        default => sub { my %hash = (); tie %hash, 'Tie::IxHash'; return \%hash },
    );

    has 'on_table' => (
        is => 'rw', 
        isa => Str,
        required => 1
    );

    has 'action' => (
        is => 'rw',
        isa => Str
    );

    has 'perform_action_when' => (
        is => 'rw',
        isa => Str,
        required => 1
    );

    has 'database_events' => (
        is => 'rw',
        isa => ArrayRef,
        required => 1
    );

    method get_fields { return $self->get_columns }
    method fields { return $self->column_ids }
}
