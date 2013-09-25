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
has 'job_runner'              => ( is => 'ro', isa => 'Str',      default  => 'Local' );

has '_job_runner_class'       => ( is => 'ro', isa => 'Str',      lazy => 1, builder => '_build__job_runner_class' );
has '_memory_required_in_mb'  => ( is => 'ro', isa => 'Int',  default => '1000' );
has '_queue'                  => ( is => 'ro', isa => 'Str',  default => 'small' );

sub _build__job_runner_class {
    my ($self) = @_;
    my $job_runner_class = "Bio::PanGenome::JobRunner::" . $self->job_runner;
    eval "require $job_runner_class";
    return $job_runner_class;
}

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
    my @commands_to_run;
    for my $filename ( @{ $self->gff_files } ) 
    {
        my($gff_filename_without_directory, $directories, $suffix) = fileparse($filename);
        my $output_suffix = "proteome.faa";
        
        my $output_filename = $filename.'.'.$output_suffix;
        $fasta_files{ $filename  } = $gff_filename_without_directory.'.'.$output_suffix;
        push(@commands_to_run, "extract_proteome_from_gff -o $output_suffix $filename");
    }
    # Farm out the computation and block until its ready
    my $job_runner_obj = $self->_job_runner_class->new( commands_to_run => \@commands_to_run, memory_in_mb => $self->_memory_required_in_mb, queue => $self->_queue);
    $job_runner_obj->run();
    
    return \%fasta_files;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

