use MooseX::Declare;
role SQL::Translator::Producer::YAML {
    use YAML qw(Dump);
    use SQL::Translator::Types qw(Column Constraint Index Procedure Table Trigger View);
    
    method produce {
        my $schema = $self->schema;
        my $translator = $self->translator;

        return Dump({
            schema => {
                tables =>     { map { ($_->name => $self->_create_table($_)) } $schema->get_tables, },
                views =>      { map { ($_->name => $self->_create_view($_)) } $schema->get_views, },
                triggers =>   { map { ($_->name => $self->_create_trigger($_)) } $schema->get_triggers, },
                procedures => { map { ($_->name => $self->_create_procedure($_)) } $schema->get_procedures, },
            },
            translator => {
                add_drop_table => $translator->add_drop_table,
                filename       => $translator->filename,
                no_comments    => $translator->no_comments,
                parser_args    => $translator->parser_args || {},
                producer_args  => $translator->producer_args || {},
                parser_type    => $translator->parser_type,
                producer_type  => $translator->producer_type,
                show_warnings  => $translator->show_warnings,
                trace          => $translator->trace,
                version        => $translator->version,
            },
            keys %{$schema->extra} ? ('extra' => { $schema->extra } ) : (),
        });
    }
    
    method _create_table(Table $table) {
        return {
            'name'        => $table->name,
            'options'     => $table->options || [],
            $table->comments ? ('comments'    => $table->comments ) : (),
            'constraints' => [ map { $self->_create_constraint($_) } $table->get_constraints ],
            'indices'     => [ map { $self->_create_index($_) } $table->get_indices ],
            'fields'      => { map { ($_->name => $self->_create_field($_)) } $table->get_fields, },
            'order'       => $table->order,
            keys %{$table->extra} ? ('extra' => { $table->extra } ) : (),
        };
    }
    
    method _create_constraint(Constraint $constraint) {
        return {
            'deferrable'       => $constraint->deferrable,
            'expression'       => $constraint->expression || '',
            'fields'           => [ $constraint->fields ],
            'name'             => $constraint->name,
            'options'          => $constraint->options || [],
            'on_delete'        => $constraint->on_delete || '',
            'on_update'        => $constraint->on_update || '',
            'reference_fields' => [ map { ref $_ ? $_->name : $_ } $constraint->reference_fields ],
            'reference_table'  => $constraint->reference_table || '',
            'type'             => $constraint->type,
            'match_type'       => $constraint->match_type,
            keys %{$constraint->extra} ? ('extra' => { $constraint->extra } ) : (),
        };
    }
    
    method _create_field(Column $field) {
        return {
            'name'              => $field->name,
            'data_type'         => $field->data_type,
            'size'              => [ $field->size ],
            'default_value'     => $field->default_value,
            'is_nullable'       => $field->is_nullable,
            'is_primary_key'    => $field->is_primary_key,
            'is_unique'         => $field->is_unique,
            'order'             => $field->order,
            $field->is_auto_increment ? ('is_auto_increment' => 1) : (),
            $field->comments ? ('comments' => $field->comments) : (),
            keys %{$field->extra} ? ('extra' => { $field->extra } ) : (),
        };
    }
    
    method _create_procedure(Procedure $procedure) {
        return {
            'name'       => $procedure->name,
            'sql'        => $procedure->sql,
            'parameters' => $procedure->parameters,
            'owner'      => $procedure->owner,
            'comments'   => $procedure->comments,
            keys %{$procedure->extra} ? ('extra' => $procedure->extra ) : (),
        };
    }
    
    method _create_trigger(Trigger $trigger) {
        return {
            'name'                => $trigger->name,
            'perform_action_when' => $trigger->perform_action_when,
            'database_events'     => [ $trigger->database_events ],
            'fields'              => $trigger->fields ? [ $trigger->fields ] : undef,
            'on_table'            => $trigger->on_table,
            'action'              => $trigger->action,
            'order'               => $trigger->order,
            keys %{$trigger->extra} ? ('extra' => { $trigger->extra } ) : (),
        };
    }
    
    method _create_view(View $view) {
        return {
            'name'   => $view->name,
            'sql'    => $view->sql,
            'fields' => $view->fields ? [ $view->fields ] : '',
            'order'  => $view->order,
            keys %{$view->extra} ? ('extra' => { $view->extra } ) : (),
        };
    }
    
    method _create_index(Index $index) {
        return {
            'name'      => $index->name,
            'type'      => $index->type,
            'fields'    => [ $index->fields ],
            'options'   => $index->options,
            keys %{$index->extra} ? ('extra' => $index->extra ) : (),
        };
    }
}
