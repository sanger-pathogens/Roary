package Bio::PanGenome::ExtractProteomeFromGFF;

# ABSTRACT: Take in GFF files and create protein sequences in FASTA format

=head1 SYNOPSIS

Take in GFF files and create protein sequences in FASTA format
   use Bio::PanGenome::ExtractProteomeFromGFF;
   
   my $plot_groups_obj = Bio::PanGenome::ExtractProteomeFromGFF->new(
       gff_files        => $fasta_files,
     );
   $plot_groups_obj->fasta_files();

=cut

use Moose;
use Cwd;
use Bio::Perl;
use Bio::SeqIO;
use Bio::PanGenome::Exceptions;
use Bio::Tools::GFF;
use File::Basename;

has 'gff_files' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'fasta_files' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_fasta_files' );

has '_awk_filter' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__awk_filter' );
has '_tags_to_filter' => ( is => 'ro', isa => 'Str', default => 'CDS' );
has '_tags_to_ignore' => ( is => 'ro', isa => 'Str', default => 'rRNA|tRNA|ncRNA|tmRNA' );
has '_working_directory' =>
  ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_working_directory_name' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__working_directory_name' );

sub _build__working_directory_name {
    my ($self) = @_;
    return $self->_working_directory->dirname();
}

sub _gff_parser {
    my ( $self, $filename ) = @_;
    # $self->_awk_filter .
    open( my $fh, '-|',  "cat  " . $filename ) or die "Couldnt open GFF file";
    my $gff_parser = Bio::Tools::GFF->new( -fh => $fh, gff_version => 3 );
    return $gff_parser;
}

sub _output_filename {
    my ( $self, $input_filename ) = @_;
    my ( $filename, $directories, $suffix ) = fileparse( $input_filename, qr/\.[^.]*/ );
    return join( '/', ( $self->_working_directory_name, $filename . '.faa' ) );
}

sub _setup_gff_sequences
{
  my ( $self, $gff_parser ) = @_;
  my %seq_names_to_sequences;
  my @sequences = $gff_parser->get_seqs;

  for my $sequence (@sequences) {
      $seq_names_to_sequences{ $sequence->id } = $sequence;
  } 
  return \%seq_names_to_sequences;
}

sub _create_protein_file_from_gff {
    my ( $self, $filename ) = @_;
    my $gff_parser = $self->_gff_parser($filename);

    my %seq_names_to_sequences;

    my $output_filename = $self->_output_filename($filename);
    my $output_fh = Bio::SeqIO->new( -file => '>' . $output_filename, -format => 'Fasta' );

    my @features;
    while ( my $raw_feature = $gff_parser->next_feature() ) {
        last unless defined($raw_feature);    # No more features
        next if !( $raw_feature->primary_tag eq 'CDS' );
        push(@features,$raw_feature);
    }
    
    for my $raw_feature (@features)
    {
      if(!  %seq_names_to_sequences)
      {
        %seq_names_to_sequences = %{$self->_setup_gff_sequences($gff_parser)};
      }
      my $feature_sequence = $seq_names_to_sequences{ $raw_feature->seq_id }->subseq( $raw_feature->start, $raw_feature->end );
      if ( $raw_feature->strand == -1 ) {
          $feature_sequence = revcom($feature_sequence)->seq;
      }
      
      my $feature = Bio::Seq->new( -display_id => $raw_feature->seq_id, -seq => $feature_sequence );
      $output_fh->write_seq( $feature->translate( -codontable_id => 11 ) );
    }
    $gff_parser->close();
    
    return $output_filename;
}

sub _build__awk_filter {
    my ($self) = @_;
    return
        'awk \'BEGIN {FS="\t"};{ if ($3 ~/'
      . $self->_tags_to_filter
      . '/) print $0;else if ($3 ~/'
      . $self->_tags_to_ignore
      . '/) ; else print $0;}\' ';
}

sub _build_fasta_files {
    my ($self) = @_;

    my @fasta_files;
    for my $filename ( @{ $self->gff_files } ) {
        push( @fasta_files, $self->_create_protein_file_from_gff($filename) );
    }
    return \@fasta_files;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

