package Bio::PanGenome::Output::NumberConservedGroups;

# ABSTRACT: Take in an array of files and output a matrix with number of conserved groups found when you add each file

=head1 SYNOPSIS

Take in an array of files and output a matrix with number of unique groups found when you add each file
   use Bio::PanGenome::Output::NumberConservedGroups;
   
   my $obj = Bio::PanGenome::Output::NumberConservedGroups->new(
     group_statistics_obj => $group_statistics
   );

   $obj->create_output_files();
=cut

use Moose;
with 'Bio::PanGenome::Output::NumberOfGroupsRole';

has 'output_raw_filename'       => ( is => 'ro', isa => 'Str', default => 'number_of_conserved_genes.tab' );

sub _single_iteration_gene_expansion {
    my ($self) = @_;
    my %existing_groups;
    my @genes_added_per_file;
    my $shuffled_input_files = $self->_shuffle_input_files();
    
    my $files_counter = 1;
    for my $input_file ( @{$shuffled_input_files} ) {
        my $conserved_groups_counter      = 0;
        my $new_groups  = $self->group_statistics_obj->_files_to_groups->{$input_file};

        for my $group ( @{$new_groups} ) {
            $existing_groups{$group}++;
        }
        for my $group (keys %existing_groups)
        {
          if($existing_groups{$group} == $files_counter)
          {
            $conserved_groups_counter++;
          }
        }
        push( @genes_added_per_file, $conserved_groups_counter );
        $files_counter++;
    }
    return \@genes_added_per_file;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
