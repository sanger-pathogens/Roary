package Bio::Roary::ExtractProteomeFromGFFs;

# ABSTRACT: Take in GFF files and create protein sequences in FASTA format

=head1 SYNOPSIS

Take in GFF files and create protein sequences in FASTA format
   use Bio::Roary::ExtractProteomeFromGFFs;
   
   my $plot_groups_obj = Bio::Roary::ExtractProteomeFromGFFs->new(
       gff_files        => $fasta_files,
     );
   $plot_groups_obj->fasta_files();

=cut

use Moose;
use Bio::Roary::Exceptions;
use Bio::Roary::ExtractProteomeFromGFF;
use File::Basename;
use Cwd qw(getcwd); 
use File::Temp;
with 'Bio::Roary::JobRunner::Role';

has 'gff_files'                => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'fasta_files'              => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_fasta_files' );
has 'fasta_files_to_gff_files' => ( is => 'ro', isa => 'HashRef',  lazy => 1, builder => '_build_fasta_files_to_gff_files' );
has 'apply_unknowns_filter'    => ( is => 'rw', isa => 'Bool', default => 1 );
has '_queue'                   => ( is => 'rw', isa => 'Str',  default => 'small' );
has 'translation_table'        => ( is => 'rw', isa => 'Int',  default => 11 );
has 'verbose'                  => ( is => 'rw', isa => 'Bool', default => 0 );
has 'working_directory'        => ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );

sub _build__extract_proteome_objects
{
  my ($self) = @_;

  my %extract_proteome_objects; 
  for my $filename ( @{ $self->gff_files } ) {
    my $extract_proteome = Bio::Roary::ExtractProteomeFromGFF->new(
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
		print "Extracting proteins from $filename\n" if($self->verbose);
        my($gff_filename_without_directory, $directories, $suffix) = fileparse($filename);
        my $output_suffix = "proteome.faa";
        
        my $output_filename = $filename.'.'.$output_suffix;
        $fasta_files{ $filename  } = $self->working_directory.'/'.$gff_filename_without_directory.'.'.$output_suffix;
        push(@commands_to_run, "extract_proteome_from_gff --translation_table ".$self->translation_table." --apply_unknowns_filter ".$self->apply_unknowns_filter." -d ".$self->working_directory." -o $output_suffix $filename");
    }
    #Farm out the computation and block until its ready
    my $job_runner_obj = $self->_job_runner_class->new( commands_to_run => \@commands_to_run, memory_in_mb => $self->memory_in_mb, queue => $self->_queue, cpus  => $self->cpus);
    $job_runner_obj->run();
    
    return \%fasta_files;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

