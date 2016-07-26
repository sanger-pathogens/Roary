package Bio::Roary::Output::GroupsMultifastaNucleotide;

# ABSTRACT:  Take in a GFF files and a groups file and output one multifasta file per group with nucleotide sequences.

=head1 SYNOPSIS

Take in a GFF files and a groups file and output one multifasta file per group with nucleotide sequences.
   use Bio::Roary::Output::GroupsMultifastas;
   
   my $obj = Bio::Roary::Output::GroupsMultifastasNucleotide->new(
       group_names      => ['aaa','bbb'],
     );
   $obj->populate_files();

=cut

use Moose;
use Bio::SeqIO;
use File::Path qw(make_path);
use File::Basename;
use File::Copy;
use File::Temp qw/ tempfile /;
use Bio::Roary::Exceptions;
use Bio::Roary::AnalyseGroups;
use Bio::Tools::GFF;
with 'Bio::Roary::BedFromGFFRole';

has 'gff_file'         => ( is => 'ro', isa => 'Str',                           required => 1 );
has 'group_names'      => ( is => 'ro', isa => 'ArrayRef',                      required => 0 );
has 'output_directory' => ( is => 'ro', isa => 'Str',                           required => 1 );
has 'pan_reference_groups_seen' => ( is => 'rw', isa => 'HashRef',              required => 1 );
has 'number_of_gff_files'    => ( is => 'ro', isa => 'Int', required => 1 );
has 'pan_reference_filename' => ( is => 'ro', isa  => 'Str',default  => 'pan_genome_reference.fa' );
has 'dont_delete_files'      => ( is => 'ro', isa => 'Bool',default  => 0 );
has 'core_definition'        => ( is => 'ro', isa => 'Num', default  => 1.0 );

has 'annotate_groups'  => ( is => 'ro', isa => 'Bio::Roary::AnnotateGroups', required => 1 );
has 'output_multifasta_files'     => ( is => 'ro', isa => 'Bool',     default  => 0 );

has 'fasta_file'   => ( is => 'ro', isa => 'Str',        lazy => 1, builder => '_build_fasta_file' );
has '_input_seqio' => ( is => 'ro', isa => 'Bio::SeqIO', lazy => 1, builder => '_build__input_seqio' );

has 'output_filename' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_output_filename' );

sub _build_output_filename
{
  my ($self) = @_;
  my ( $filename, $directories, $suffix ) = fileparse($self->gff_file);
  return join('/',($self->output_directory, $filename.'.tmp_nuc_sequences.fa' ));
}

sub _build__input_seqio {
    my ($self) = @_;
    return Bio::SeqIO->new( -file => $self->fasta_file, -format => 'Fasta' );
}

sub _bed_output_filename {
    my ($self) = @_;
    return join( '.', ( $self->output_filename, 'intermediate.bed' ) );
}

sub populate_files {
    my ($self) = @_;
    while ( my $input_seq = $self->_input_seqio->next_seq() ) 
    {
        if ( $self->annotate_groups->_ids_to_groups->{$input_seq->display_id} ) 
        {
          my $current_group =  $self->annotate_groups->_ids_to_groups->{$input_seq->display_id};
		  my $gene_name = $self->annotate_groups->_groups_to_consensus_gene_names->{$current_group};

          if(! defined($self->pan_reference_groups_seen->{$current_group}))
		  {
		  	my $pan_output_seq = $self->_pan_genome_reference_io_obj($current_group);
			$pan_output_seq->write_seq(Bio::Seq->new( -display_id => $input_seq->display_id, -desc => ($gene_name ? $gene_name : $current_group), -seq => $input_seq->seq ) );
			$self->pan_reference_groups_seen->{$current_group} = 1;
		  }

          my $number_of_genes = @{$self->annotate_groups->_groups_to_id_names->{$current_group}};
          # Theres no need to align noncore files
          next if($self->dont_delete_files == 0 && $number_of_genes < ($self->core_definition * $self->number_of_gff_files ));
          
          my $output_seq = $self->_group_seq_io_obj($current_group,$number_of_genes);
          $output_seq->write_seq($input_seq);
        }
    }

    unlink($self->fasta_file);
    1;
}

sub _group_file_name
{ 
  my ($self,$group_name,$num_group_genes) = @_;
  my $annotated_group_name = $self->annotate_groups->_groups_to_consensus_gene_names->{$group_name};
  $annotated_group_name =~ s!\W!_!gi;
  my $filename = $annotated_group_name.'.fa';
  my $group_file_name = join('/',($self->output_directory, $filename ));
  return $group_file_name;
}


sub _pan_genome_reference_io_obj
{
  my ($self) = @_;
  return Bio::SeqIO->new( -file => ">>".$self->pan_reference_filename, -format => 'Fasta' );
}


sub _group_seq_io_obj
{
  my ($self,$group_name,$num_group_genes) = @_;
  my $filename = $self->_group_file_name($group_name,$num_group_genes);
  return Bio::SeqIO->new( -file => ">>".$filename, -format => 'Fasta' );
}


sub _extracted_nucleotide_fasta_file_from_bed_filename {
    my ($self) = @_;
    return join( '.', ( $self->output_filename, 'intermediate.extracted.fa' ) );
}

sub _create_nucleotide_fasta_file_from_gff {
    my ($self) = @_;
    
    open(my $input_fh, $self->gff_file);
    open(my $output_fh, '>', $self->_nucleotide_fasta_file_from_gff_filename);
    my $at_sequence = 0;
    while(<$input_fh>)
    {
	    my $line = $_;
	    if($line =~/^>/)
	    {
	    	$at_sequence = 1;
	    }
	    
	    if($at_sequence == 1)
	    {
		    print {$output_fh} $line;
	    }
    }
    close($input_fh);
    close($output_fh);
}

sub _nucleotide_fasta_file_from_gff_filename {
    my ($self) = @_;
    return join( '.', ( $self->output_filename, 'intermediate.fa' ) );
}

sub _extract_nucleotide_regions {
    my ($self) = @_;

    $self->_create_nucleotide_fasta_file_from_gff;
    $self->_create_bed_file_from_gff;

    my $cmd =
        'bedtools getfasta -s -fi '
      . $self->_nucleotide_fasta_file_from_gff_filename
      . ' -bed '
      . $self->_bed_output_filename . ' -fo '
      . $self->_extracted_nucleotide_fasta_file_from_bed_filename
      . ' -name > /dev/null 2>&1';
    system($cmd);
    unlink( $self->_nucleotide_fasta_file_from_gff_filename );
    unlink( $self->_bed_output_filename );
    unlink( $self->_nucleotide_fasta_file_from_gff_filename . '.fai' );
    return $self->_extracted_nucleotide_fasta_file_from_bed_filename;
}

sub _cleanup_fasta {
    my ($self,$infile) = @_;
    
    my($fh, $outfile) = tempfile();
    return unless ( -e $infile );

    open( my $in,  '<', $infile );
    open( my $out, '>', $outfile );
    while ( my $line = <$in> ) {
        chomp $line;
        $line =~ s/"//g if ( $line =~ /^>/ );
	
	if($line =~ /^(>[^:]+)/)
	{
		$line = $1;
	}
        print $out "$line\n";
    }
    close $in;
    close $out;
    
    move( $outfile, $infile);
    return $infile;
}


sub _build_fasta_file {
    my ($self) = @_;
    my $fasta_filename  = $self->_extract_nucleotide_regions;
    return $self->_cleanup_fasta($fasta_filename);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

