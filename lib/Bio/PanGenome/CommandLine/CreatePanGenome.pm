package Bio::PanGenome::CommandLine::CreatePanGenome;

# ABSTRACT: Create a pan genome from a set of proteins in a FASTA file

=head1 SYNOPSIS

Create a pan genome from a set of proteins in a FASTA file

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::PanGenome::CombinedProteome;
use Bio::PanGenome::External::Cdhit;
use Bio::PanGenome::External::Makeblastdb;
use Bio::PanGenome::External::Blastp;
use Bio::PanGenome::GGFile;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'fasta_files'     => ( is => 'rw', isa => 'ArrayRef' );
has 'output_filename' => ( is => 'rw', isa => 'Str' );

has '_error_message' => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ($self) = @_;

    my ( $fasta_files, $output_filename, $help );

    GetOptionsFromArray(
        $self->args,
        'o|output=s' => \$output_filename,
        'h|help'     => \$help,
    );

    $self->output_filename($output_filename) if ( defined($output_filename) );

    if ( @{ $self->args } == 0 ) {
        $self->_error_message("Error: You need to provide at least 1 FASTA file");
    }

    for my $filename ( @{ $self->args } ) {
        if ( !-e $filename ) {
            $self->_error_message("Error: Cant access file $filename");
            last;
        }
    }
    $self->fasta_files( $self->args );

}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

    my $combined_proteome_obj = Bio::PanGenome::CombinedProteome->new(
          proteome_files  => $self->fasta_files,
          output_filename => 'combined_proteome.faa'
      );
   $combined_proteome_obj->create_combined_proteome_file;
   print "Created combined file:\n";
   my $percentage_sequences_ignored = (($combined_proteome_obj->number_of_sequences_ignored/$combined_proteome_obj->number_of_sequences_seen)*100);
   print $percentage_sequences_ignored."  percent of sequences ignored\n";
   
   print "Clustering the data:\n";
   my $cdhit_obj = Bio::PanGenome::External::Cdhit->new( input_file   => 'combined_proteome.faa', output_base  => 'clustered.faa');
   $cdhit_obj->run();
   
   print "Creating a blast database:\n";
   my $blast_database= Bio::PanGenome::External::Makeblastdb->new(fasta_file => 'clustered.faa');
   $blast_database->run();
   
   print "Blasting all against all:\n";
   my $blastp_obj =  Bio::PanGenome::External::Blastp->new(
     fasta_file     => 'clustered.faa',
     blast_database => $blast_database->output_database,
     output_file    => 'results.out'
   );
   $blastp_obj->run();

   print "Create GG file:\n";
   my $ggfile = Bio::PanGenome::GGFile->new(
     fasta_file   => 'clustered.faa'
   );
   $ggfile->create_gg_file;
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: create_pan_geneome [options]
    Create a pan genome from a set of proteins in a FASTA file

    # Create a pan genome from some FASTA files
    create_pan_geneome *.faa
    
    # Provide an output filename
    create_pan_geneome -o outputfile.faa *.faa

    # This help message
    create_pan_geneome -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
