package Bio::Roary::ExtractProteomeFromGFF;

# ABSTRACT: Take in a GFF file and create protein sequences in FASTA format

=head1 SYNOPSIS

Take in GFF files and create protein sequences in FASTA format
   use Bio::Roary::ExtractProteomeFromGFF;
   
   my $obj = Bio::Roary::ExtractProteomeFromGFF->new(
       gff_file        => $fasta_file,
     );
   $obj->fasta_file();

=cut

use Moose;
use Bio::SeqIO;
use Cwd;
use Bio::Roary::Exceptions;
use File::Basename;
use File::Temp;
use File::Copy;
with 'Bio::Roary::JobRunner::Role';

has 'gff_file' => ( is => 'ro', isa => 'Str', required => 1 );
has 'apply_unknowns_filter' => ( is => 'rw', isa => 'Bool', default => 1 );
has 'maximum_percentage_of_unknowns' => ( is => 'ro', isa => 'Num',      default  => 5 );
has 'min_gene_size_in_nucleotides' => ( is => 'ro', isa => 'Int',      default  => 120 );

has 'fasta_file' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_fasta_file' );
has 'output_filename' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_output_filename' );

has '_working_directory' =>
  ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_working_directory_name' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__working_directory_name' );
has 'translation_table'           => ( is => 'rw', isa => 'Int',  default => 11 );
has '_tags_to_filter' => ( is => 'ro', isa => 'Str',             default => '(CDS|ncRNA|tRNA|tmRNA|rRNA)' );

sub _build_fasta_file
{
  my ($self) = @_;
  $self->_extract_nucleotide_regions;
  $self->_convert_nucleotide_to_protein;
  $self->_cleanup_fasta;
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
  unlink($self->_unfiltered_output_filename);
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

sub _unfiltered_output_filename {
    my $self = shift;
    return join( '.', ( $self->output_filename, 'unfiltered.fa' ) );
}

sub _create_bed_file_from_gff {
    my ($self) = @_;
    my $cmd =
        'sed -n \'/##gff-version 3/,/##FASTA/p\' '
      . $self->gff_file
      .' | awk \'BEGIN {FS="\t"};{ if ($3 ~/'. $self->_tags_to_filter. '/) print $0;}\' '
      . ' | grep -v \'^#\' | awk \'{if ($5 - $4 >= '.$self->min_gene_size_in_nucleotides.') print $1"\t"($4-1)"\t"($5)"\t"$9"\t1\t"$7}\' | sed \'s/ID=//\' | sed \'s/;[^\t]*\t/\t/g\' > '
      . $self->_bed_output_filename;
    $self->logger->debug($cmd);
    system($cmd);
}

sub _create_nucleotide_fasta_file_from_gff {
    my ($self) = @_;
    my $cmd =
        'sed -n \'/##FASTA/,//p\' '
      . $self->gff_file
      . ' | grep -v \'##FASTA\' > '
      . $self->_nucleotide_fasta_file_from_gff_filename;
    $self->logger->debug($cmd);
    system($cmd);
}

sub _extract_nucleotide_regions {
    my ($self) = @_;

    $self->_create_nucleotide_fasta_file_from_gff;
    $self->_create_bed_file_from_gff;

    my $cmd =
        'bedtools getfasta -s -fi '
      . $self->_nucleotide_fasta_file_from_gff_filename
      . ' -bed '
      . $self->_bed_output_filename
      . ' -fo '
      . $self->_extracted_nucleotide_fasta_file_from_bed_filename
      . ' -name > /dev/null 2>&1';
      
    $self->logger->debug($cmd);
    system($cmd);
    unlink($self->_nucleotide_fasta_file_from_gff_filename);
    unlink($self->_bed_output_filename);
    unlink($self->_nucleotide_fasta_file_from_gff_filename.'.fai');
}

sub _cleanup_fasta {
    my $self = shift;
    my $infile  = $self->_unfiltered_output_filename;
    my $outfile = $self->output_filename;
    return unless(-e $infile);
  
    open(my $in, '<', $infile);
    open(my $out, '>', $outfile);
    while( my $line = <$in> ){
        chomp $line;
        $line =~ s/"//g if ( $line =~ /^>/ );
        print $out "$line\n";
    }
    close $in;
    close $out;
}

sub _fastatranslate_filename {
    my ($self) = @_;
    return join( '.', ( $self->output_filename, 'intermediate.translate.fa' ) );
}

sub _fastatranslate
{
  my ($self, $inputfile, $outputfile) = @_;
  
  my $input_fasta_file_obj    = Bio::SeqIO->new(-file => $inputfile, -format => 'Fasta' );
  my $output_protein_file_obj = Bio::SeqIO->new(-file =>">".$outputfile,    -format => 'Fasta', -alphabet => 'protein' );

  my %protein_sequence_objs;
  while (my $seq = $input_fasta_file_obj->next_seq){
    $seq->desc(undef);
    my $protseq = $seq->translate(-codontable_id => $self->translation_table);
    $output_protein_file_obj->write_seq($protseq);
  }
  return 1;
}

sub _convert_nucleotide_to_protein
{
  my ($self) = @_;
  $self->_fastatranslate($self->_extracted_nucleotide_fasta_file_from_bed_filename,$self->_unfiltered_output_filename);
  unlink($self->_extracted_nucleotide_fasta_file_from_bed_filename);
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
  
  my $sequence_found = 0;

  while(my $seq = $fasta_obj->next_seq())
  {
    if($self->_does_sequence_contain_too_many_unknowns($seq))
    {
      next; 
    }
    $seq->desc(undef);
    $out_fasta_obj->write_seq($seq);
    $sequence_found = 1;
  }
  
  if($sequence_found == 0)
  {
      $self->logger->error("Could not extract any protein sequences from ".$self->gff_file.". Does the file contain the assembly as well as the annotation?");
  }
  
  # Replace the original file.
  move($temp_output_file, $filename);
  return 1;
}



no Moose;
__PACKAGE__->meta->make_immutable;

1;

