package Bio::PanGenome::CommandLine::ProteinMuscleAlignmentFromNucleotides;

# ABSTRACT: Take in a multifasta file of nucleotides, convert to proteins and align with muscle

=head1 SYNOPSIS

Take in a multifasta file of nucleotides, convert to proteins and align with muscle, reverse translate back to nucleotides

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::PanGenome::AnnotateGroups;
use Bio::PanGenome::External::Muscle;
use Bio::PanGenome::External::Revtrans;
use Bio::PanGenome::Output::GroupsMultifastaProtein;
use Bio::PanGenome::SortFasta;


has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'nucleotide_fasta_files'  => ( is => 'rw', isa => 'ArrayRef' );
has '_error_message'          => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ($self) = @_;

    my ( $nucleotide_fasta_files, $help );

    GetOptionsFromArray(
        $self->args,
        'h|help'              => \$help,
    );

    $self->help($help) if(defined($help));
    if ( @{ $self->args } == 0 ) {
        $self->_error_message("Error: You need to provide at least 1 FASTA file");
    }

    for my $filename ( @{ $self->args } ) {
        if ( !-e $filename ) {
            $self->_error_message("Error: Cant access file $filename");
            last;
        }
    }
    $self->nucleotide_fasta_files( $self->args );
}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

    for my $fasta_file (@{$self->nucleotide_fasta_files})
    {
      
      my $sort_fasta_before = Bio::PanGenome::SortFasta->new(
         input_filename   => $fasta_file,
       );
      $sort_fasta_before->sort_fasta->replace_input_with_output_file;
      
      my $multifasta_protein_obj = Bio::PanGenome::Output::GroupsMultifastaProtein->new(
          nucleotide_fasta_file => $fasta_file,
        );
      $multifasta_protein_obj->convert_nucleotide_to_protein();
      
      my $seg = Bio::PanGenome::External::Muscle->new(
        fasta_files => [$multifasta_protein_obj->output_filename],
        job_runner  => 'Local'
      );
      $seg->run();
      
      my $sort_fasta_after_muscle = Bio::PanGenome::SortFasta->new(
         input_filename   => $multifasta_protein_obj->output_filename. '.aln',
       );
      $sort_fasta_after_muscle->sort_fasta->replace_input_with_output_file;

      my $revtrans= Bio::PanGenome::External::Revtrans->new(
        nucleotide_filename => $fasta_file,
        protein_filename  => $multifasta_protein_obj->output_filename. '.aln',
        output_filename   => $fasta_file.'.aln'
      );
      $revtrans->run();
      
      my $sort_fasta_after_revtrans = Bio::PanGenome::SortFasta->new(
         input_filename   => $fasta_file.'.aln',
       );
      $sort_fasta_after_revtrans->sort_fasta->replace_input_with_output_file;
      
      unlink($multifasta_protein_obj->output_filename);
      unlink($multifasta_protein_obj->output_filename. '.aln');
    }
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: protein_muscle_alignment_from_nucleotides [options]
    Take in a multifasta file of nucleotides, convert to proteins and align with muscle
    
    # Transfer the annotation from the GFF files to the group file
    protein_muscle_alignment_from_nucleotides protein_fasta_1.faa protein_fasta_2.faa
    
    # This help message
    protein_muscle_alignment_from_nucleotides -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
