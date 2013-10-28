package Bio::PanGenome::Output::NumberNewGroups;

# ABSTRACT: take in an array of files and output a matrix with number of new genes found when you add each file

=head1 SYNOPSIS

take in an array of files and output a matrix with number of new genes found when you add each file
   use Bio::PanGenome::Output::NumberNewGroups;
   
   my $obj = Bio::PanGenome::Output::NumberNewGroups->new(
     group_statistics_obj => $group_statistics
   );

   $obj->create_output_files();
=cut

use Moose;
use List::Util qw( min max );
use Statistics::Basic qw(:all);
use Bio::PanGenome::Plot::NumberNewGroups;
with 'Bio::PanGenome::Output::NumberOfGroupsRole';

has '_mean_objects' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build__mean_objects' );

sub create_plot {
    my ($self) = @_;
    my $plot_obj = Bio::PanGenome::Plot::NumberNewGroups->new(
        output_filename => $self->output_filename,
        input_keys      => $self->_key_values,
        input_highs     => $self->_high_values,
        input_lows      => $self->_low_values,
        input_opens     => $self->_low_std_dev_values,
        input_values    => $self->_high_std_dev_values,
    );
    $plot_obj->create_plot();
}

sub _high_values {
    my ($self) = @_;
    my @high_values;

    for my $iteration_values ( @{ $self->gene_pool_expansion } ) {
        push( @high_values, max( @{$iteration_values} ) );
    }

    return \@high_values;
}

sub _low_values {
    my ($self) = @_;
    my @low_values;

    for my $iteration_values ( @{ $self->gene_pool_expansion } ) {
        push( @low_values, min( @{$iteration_values} ) );
    }

    return \@low_values;
}

sub _build__mean_objects {
    my ($self) = @_;

    my @values;
    for my $iteration_values ( @{ $self->gene_pool_expansion } ) {
        my $mean_obj = mean( @{$iteration_values} );
        push( @values, $mean_obj );
    }

    return \@values;
}

sub _high_std_dev_values {
    my ($self) = @_;

    my @values;
    for my $mean_obj ( @{ $self->_mean_objects } ) {
        my $stddev_obj = stddev( $mean_obj->query_vector );
        push( @values, $mean_obj->query + $stddev_obj->query );
    }

    return \@values;
}

sub _low_std_dev_values {
    my ($self) = @_;

    my @values;
    for my $mean_obj ( @{ $self->_mean_objects } ) {
        my $stddev_obj = stddev( $mean_obj->query_vector );
        push( @values, $mean_obj->query - $stddev_obj->query );
    }

    return \@values;
}

sub _key_values {
    my ($self) = @_;
    my @key_values;

    for ( my $i = 0 ; $i < @{ $self->gene_pool_expansion } ; $i++ ) {
        push( @key_values, ( $i + 1 ) );
    }

    return \@key_values;
}

sub _single_iteration_gene_expansion {
    my ($self) = @_;
    my %existing_groups;
    my @genes_added_per_file;
    my $shuffled_input_files = $self->_shuffle_input_files();
    for my $input_file ( @{$shuffled_input_files} ) {
        my $new_group_counter      = 0;
        my $existing_group_counter = 0;
        my $new_groups             = $self->group_statistics_obj->_files_to_groups->{$input_file};

        for my $group ( @{$new_groups} ) {
            if ( defined( $existing_groups{$group} ) ) {
                $existing_group_counter++;
            }
            else {
                $new_group_counter++;
            }
            $existing_groups{$group}++;
        }
        push( @genes_added_per_file, $new_group_counter );
    }
    return \@genes_added_per_file;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
