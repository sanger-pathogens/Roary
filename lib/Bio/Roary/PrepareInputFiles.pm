package Bio::Roary::PrepareInputFiles;

# ABSTRACT: Take in a mixture of FASTA and GFF input files and output FASTA proteomes only

=head1 SYNOPSIS

Take in a mixture of FASTA and GFF input files and output FASTA proteomes only
   use Bio::Roary::PrepareInputFiles;
   
   my $obj = Bio::Roary::PrepareInputFiles->new(
     input_files   => ['abc.gff','ddd.faa'],
   );
   $obj->fasta_files;

=cut

use Moose;
use Bio::Roary::Exceptions;
use Bio::Roary::ExtractProteomeFromGFFs;
use Bio::Roary::FilterUnknownsFromFasta;
use Cwd qw(getcwd); 
use File::Temp;

has 'input_files'      => ( is => 'ro', isa => 'ArrayRef',        required => 1 );
has 'job_runner'       => ( is => 'ro', isa => 'Str',             default  => 'Local' );
has 'cpus'             => ( is => 'ro', isa => 'Int',      default => 1 );
has '_input_gff_files' => ( is => 'ro', isa => 'Maybe[ArrayRef]', lazy     => 1, builder => '_build__input_gff_files' );
has '_input_fasta_files' => ( is => 'ro', isa => 'Maybe[ArrayRef]', lazy => 1, builder => '_build__input_fasta_files' );
has '_input_fasta_files_filtered' =>
  ( is => 'ro', isa => 'Maybe[ArrayRef]', lazy => 1, builder => '_build__input_fasta_files_filtered' );
has '_input_fasta_files_filtered_obj' =>
    ( is => 'ro', isa => 'Bio::Roary::FilterUnknownsFromFasta', lazy => 1, builder => '_build__input_fasta_files_filtered_obj' );

has '_derived_fasta_files' =>
  ( is => 'ro', isa => 'Maybe[ArrayRef]', lazy => 1, builder => '_build__derived_fasta_files' );
has '_extract_proteome_obj' => (
    is      => 'ro',
    isa     => 'Bio::Roary::ExtractProteomeFromGFFs',
    lazy    => 1,
    builder => '_build__extract_proteome_obj'
);
has 'apply_unknowns_filter' => ( is => 'rw', isa => 'Bool', default => 1 );
has 'translation_table'     => ( is => 'rw', isa => 'Int',  default => 11 );
has 'verbose'               => ( is => 'rw', isa => 'Bool', default => 0 );
has '_fasta_filter_obj'     =>  ( is => 'ro', isa => 'Bio::Roary::FilterUnknowsFromFasta', lazy => 1, builder => '_fasta_filter_obj' );
has 'working_directory'    => ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );

sub _build__input_gff_files {
    my ($self) = @_;
    my @gff_files = grep( /\.gff$/, @{ $self->input_files } );
    return \@gff_files;
}

sub _build__input_fasta_files {
    my ($self) = @_;
    my @fasta_files = grep( !/\.gff$/, @{ $self->input_files } );
    return \@fasta_files;
}

sub _build__input_fasta_files_filtered_obj {
    my ($self) = @_;
    return Bio::Roary::FilterUnknownsFromFasta->new( fasta_files => $self->_input_fasta_files );
}

sub _build__input_fasta_files_filtered
{
  my ($self) = @_;
  return undef if ( !defined( $self->_input_fasta_files ) );
  return $self->_input_fasta_files_filtered_obj->filtered_fasta_files();
}

sub _build__extract_proteome_obj {
    my ($self) = @_;
    return Bio::Roary::ExtractProteomeFromGFFs->new(
        gff_files             => $self->_input_gff_files,
        job_runner            => $self->job_runner,
        apply_unknowns_filter => $self->apply_unknowns_filter,
        translation_table     => $self->translation_table,
        cpus                  => $self->cpus,
		verbose               => $self->verbose,
        working_directory    => $self->working_directory,
    );
}

sub _build__derived_fasta_files {
    my ($self) = @_;
    return undef if ( !defined( $self->_input_gff_files ) );
    return $self->_extract_proteome_obj->fasta_files();
}

sub fasta_files {
    my ($self) = @_;
    my @output_fasta_files = ( @{ $self->_input_fasta_files_filtered }, @{ $self->_derived_fasta_files } );
    return \@output_fasta_files;
}

sub lookup_fasta_files_from_unknown_input_files {
    my ( $self, $input_files ) = @_;
    $self->fasta_files;

    my @output_fasta_files;
    for my $input_file ( @{$input_files} ) {
        if ( defined( $self->_extract_proteome_obj->fasta_files_to_gff_files->{$input_file} ) ) {
            push( @output_fasta_files, $self->_extract_proteome_obj->fasta_files_to_gff_files->{$input_file} );
        }
        else {
            push( @output_fasta_files, $self->_input_fasta_files_filtered_obj->input_fasta_to_output_fasta->{$input_file} );
        }
    }
    return \@output_fasta_files;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
