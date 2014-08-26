package Bio::PanGenome::ExtractProteomeFromGFF;

# ABSTRACT: Take in a GFF file and create protein sequences in FASTA format

=head1 SYNOPSIS

Take in GFF files and create protein sequences in FASTA format
   use Bio::PanGenome::ExtractProteomeFromGFF;
   
   my $obj = Bio::PanGenome::ExtractProteomeFromGFF->new(
       gff_file        => $fasta_file,
     );
   $obj->fasta_file();

=cut

use Moose;
use Bio::SeqIO;
use Cwd;
use Bio::PanGenome::Exceptions;
use File::Basename;
use File::Temp;
use File::Copy;
with 'Bio::PanGenome::JobRunner::Role';

has 'gff_file' => ( is => 'ro', isa => 'Str', required => 1 );
has 'apply_unknowns_filter' => ( is => 'rw', isa => 'Bool', default => 1 );
has 'maximum_percentage_of_unknowns' => ( is => 'ro', isa => 'Num',      default  => 5 );
has 'min_gene_size_in_nucleotides' => ( is => 'ro', isa => 'Int',      default  => 120 );

has 'fasta_file' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_fasta_file' );
has 'output_filename' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_output_filename' );

has '_working_directory' =>
  ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_working_directory_name' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__working_directory_name' );


sub _build_fasta_file
{
  my ($self) = @_;
  $self->_extract_nucleotide_regions;
  $self->_convert_nucleotide_to_protein;
  $self->_cleanup_intermediate_files;
  $self->_filter_fasta_sequences($self->output_filename);
  return $self->output_filename;
}

sub _build__working_directory_name {
    my ($self) = @_;
    return $self->_working_directory->dirname();
}

sub _build_output_filename {
    my ( $self ) = @_;
    my ( $filename, $directories, $suffix ) = fileparse( $self->gff_file, qr/\.[^.]*/ );
    return join( '/', ( $self->_working_directory_name, $filename . '.faa' ) );
}

sub _bed_output_filename {
    my ($self) = @_;
    return join( '.', ( $self->output_filename, 'intermediate.bed' ) );
}

sub _cleanup_intermediate_files
{
  my ($self) = @_;
  unlink($self->_fastatranslate_filename);
}

sub _nucleotide_fasta_file_from_gff_filename {
    my ($self) = @_;
    return join( '.', ( $self->output_filename, 'intermediate.fa' ) );
}

sub _extracted_nucleotide_fasta_file_from_bed_filename {
    my ($self) = @_;
    return join( '.', ( $self->output_filename, 'intermediate.extracted.fa' ) );
}

sub _create_bed_file_from_gff {
    my ($self) = @_;
    my $cmd =
        'sed -n \'/##gff-version 3/,/##FASTA/p\' '
      . $self->gff_file
      . ' | grep -v \'^#\' | awk \'{if ($5 - $4 >= '.$self->min_gene_size_in_nucleotides.') print $1"\t"($4-1)"\t"($5)"\t"$9"\t1\t"$7}\' | sed \'s/ID=//\' | sed \'s/;[^\t]*\t/\t/g\' > '
      . $self->_bed_output_filename;
    system($cmd);
}

sub _create_nucleotide_fasta_file_from_gff {
    my ($self) = @_;
    my $cmd =
        'sed -n \'/##FASTA/,//p\' '
      . $self->gff_file
      . ' | grep -v \'##FASTA\' > '
      . $self->_nucleotide_fasta_file_from_gff_filename;
    system($cmd);
}

sub _extract_nucleotide_regions {
    my ($self) = @_;

    $self->_create_nucleotide_fasta_file_from_gff;
    $self->_create_bed_file_from_gff;

    print STDERR "\n\n\n\n\nExtracting regions with bedtools!\n\n\n\n\n";

    my $cmd =
        'bedtools getfasta -fi '
      . $self->_nucleotide_fasta_file_from_gff_filename
      . ' -bed '
      . $self->_bed_output_filename
      . ' -fo '
      . $self->_extracted_nucleotide_fasta_file_from_bed_filename
      . ' -name > /dev/null 2>&1';
      system($cmd);
      $self->_cleanup_fasta; # remove quotes from fasta headers
      unlink($self->_nucleotide_fasta_file_from_gff_filename);
      unlink($self->_bed_output_filename);
      unlink($self->_nucleotide_fasta_file_from_gff_filename.'.fai');
}

sub _cleanup_fasta {
  my $self = shift;
  my $fa = $self->_extracted_nucleotide_fasta_file_from_bed_filename;
  return unless(-e $fa);
  my $cmd = "sed -n 's/\"//g' $fa > $fa.intermediate.sed";
  system($cmd);
  move("$fa.intermediate.sed", $fa);
}

sub _fastatranslate_filename {
    my ($self) = @_;
    return join( '.', ( $self->output_filename, 'intermediate.translate.fa' ) );
}

sub _fastatranslate_cmd
{
  my ($self) = @_;
  return 'fastatranslate --geneticcode 11  -f '. $self->_extracted_nucleotide_fasta_file_from_bed_filename.' >> '.$self->_fastatranslate_filename;
}

sub _convert_nucleotide_to_protein
{
  my ($self) = @_;
  system($self->_fastatranslate_cmd(1));
  # Only keep sequences which have a start and stop codon.
  my $cmd = 'fasta_grep -f '.$self->_fastatranslate_filename.' > '.$self->output_filename;
  unlink($self->_extracted_nucleotide_fasta_file_from_bed_filename);
  system($cmd);
}



sub _does_sequence_contain_too_many_unknowns
{
  my ($self, $sequence_obj) = @_;
  my $maximum_number_of_Xs = int(($sequence_obj->length()*$self->maximum_percentage_of_unknowns)/100);
  my $number_of_Xs_found = () = $sequence_obj->seq() =~ /X/g;
  if($number_of_Xs_found  > $maximum_number_of_Xs)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}


sub _filter_fasta_sequences
{
  my ($self, $filename) = @_;
  my $temp_output_file = $filename.'.tmp.filtered.fa';
  my $out_fasta_obj = Bio::SeqIO->new( -file => ">".$temp_output_file, -format => 'Fasta');
  my $fasta_obj     = Bio::SeqIO->new( -file => $filename, -format => 'Fasta');

  while(my $seq = $fasta_obj->next_seq())
  {
    if($self->_does_sequence_contain_too_many_unknowns($seq))
    {
      next; 
    }
    # strip out extra details put in by fastatranslate
    $seq->description(undef);
    $out_fasta_obj->write_seq($seq);
  }
  # Replace the original file.
  move($temp_output_file, $filename);
  return 1;
}



no Moose;
__PACKAGE__->meta->make_immutable;

1;

