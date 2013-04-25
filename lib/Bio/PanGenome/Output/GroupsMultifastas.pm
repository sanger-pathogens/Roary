package Bio::PanGenome::Output::GroupsMultifastas;

# ABSTRACT:  Take in a list of groups and create multifastas files for each group

=head1 SYNOPSIS

Take in a list of groups and create multifastas files for each group
   use Bio::PanGenome::Output::GroupsMultifastas;
   
   my $obj = Bio::PanGenome::Output::GroupsMultifastas->new(
       group_names      => ['aaa','bbb'],
       analyse_groups  => $analyse_groups
     );
   $obj->create_files();

=cut

use Moose;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::Output::GroupMultifasta;

has 'group_names'          => ( is => 'ro', isa => 'ArrayRef',                      required => 1 );
has 'analyse_groups'       => ( is => 'ro', isa => 'Bio::PanGenome::AnalyseGroups', required => 1 );
has 'output_filename_base' => ( is => 'ro', isa => 'Str',                           default  => 'output_groups' );

sub create_files {
    my ($self) = @_;
    for my $group_name ( @{ $self->group_names } ) {
      # Check the group name exists
      next unless($self->analyse_groups->_groups_to_genes->{$group_name});    
        my $group_multifasta = Bio::PanGenome::Output::GroupMultifasta->new(
            group_name           => $group_name,
            analyse_groups       => $self->analyse_groups,
            output_filename_base => $self->output_filename_base
        );
        $group_multifasta->create_file;
    }
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

