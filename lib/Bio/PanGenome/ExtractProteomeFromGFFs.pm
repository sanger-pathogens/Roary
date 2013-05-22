package Bio::PanGenome::ExtractProteomeFromGFFs;

# ABSTRACT: Take in GFF files and create protein sequences in FASTA format

=head1 SYNOPSIS

Take in GFF files and create protein sequences in FASTA format
   use Bio::PanGenome::ExtractProteomeFromGFFs;
   
   my $plot_groups_obj = Bio::PanGenome::ExtractProteomeFromGFFs->new(
       gff_files        => $fasta_files,
     );
   $plot_groups_obj->fasta_files();

=cut

use Moose;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::ExtractProteomeFromGFF;
use File::Basename;

has 'gff_files' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'fasta_files' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_fasta_files' );
has 'fasta_files_to_gff_files' =>
  ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_fasta_files_to_gff_files' );


has '_extract_proteome_objects' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build__extract_proteome_objects' );

sub _build__extract_proteome_objects
{
  my ($self) = @_;

  my %extract_proteome_objects; 
  for my $filename ( @{ $self->gff_files } ) {
    my $extract_proteome = Bio::PanGenome::ExtractProteomeFromGFF->new(
        gff_file        => $filename,
      );
      $extract_proteome_objects{ $filename  } = $extract_proteome;
  }
  return \%extract_proteome_objects;
}

sub _build_fasta_files {
    my ($self) = @_;
    my @fasta_files = sort values( %{$self->fasta_files_to_gff_files} );
    return \@fasta_files;
}

sub _build_fasta_files_to_gff_files {
    my ($self) = @_;

    my %fasta_files;
    for my $filename ( keys %{ $self->_extract_proteome_objects } ) {
        $fasta_files{ $filename  } = $self->_extract_proteome_objects->{$filename}->fasta_file();
    }
    return \%fasta_files;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

