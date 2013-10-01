
package Bio::PanGenome::Output::GroupsMultifastasNucleotide;

# ABSTRACT:  Take in a set of GFF files and a groups file and output one multifasta file per group with nucleotide sequences.

=head1 SYNOPSIS

Take in a set of GFF files and a groups file and output one multifasta file per group with nucleotide sequences.
   use Bio::PanGenome::Output::GroupsMultifastasNucleotide;
   
   my $obj = Bio::PanGenome::Output::GroupsMultifastasNucleotide->new(
       group_names      => ['aaa','bbb'],
       analyse_groups  => $analyse_groups
     );
   $obj->create_files();

=cut

use Moose;
use File::Path qw(make_path);
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::Output::GroupsMultifastaNucleotide;

has 'gff_files'        => ( is => 'ro', isa => 'ArrayRef',                      required => 1 );
has 'group_names'      => ( is => 'ro', isa => 'ArrayRef',                      required => 0 );
has 'analyse_groups'   => ( is => 'ro', isa => 'Bio::PanGenome::AnalyseGroups', required => 1 );
                       
has 'output_directory' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_output_directory');

sub _build_output_directory
{
  my ($self) = @_;
  my $output_directory = 'pan_genome_sequences';
  return $output_directory;
}

sub create_files {
    my ($self) = @_;
  
    make_path($self->output_directory);
    
    for my $gff_file ( @{ $self->gff_files } ) 
    {
      my $gff_multifasta = Bio::PanGenome::Output::GroupsMultifastaNucleotide->new(
          gff_file             => $gff_file,
          analyse_groups       => $self->analyse_groups,
          group_names          => $self->group_names,
          output_directory     => $self->output_directory
      );
      $gff_multifasta->populate_files;
    }
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

