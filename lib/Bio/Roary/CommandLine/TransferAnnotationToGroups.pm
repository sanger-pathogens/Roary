undef $VERSION;
package Bio::Roary::CommandLine::TransferAnnotationToGroups;

# ABSTRACT: Take in a groups file and a set of GFF files and transfer the consensus annotation

=head1 SYNOPSIS

Take in a groups file and a set of GFF files and transfer the consensus annotation

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::Roary::AnnotateGroups;
extends 'Bio::Roary::CommandLine::Common';


has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'gff_files'       => ( is => 'rw', isa => 'ArrayRef' );
has 'groups_filename' => ( is => 'rw', isa => 'Str' );
has 'output_filename' => ( is => 'rw', isa => 'Str', default => 'reannotated_groups' );
has 'verbose'         => ( is => 'rw', isa => 'Bool', default => 0 );
has '_error_message'  => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ($self) = @_;

    my ( $gff_files, $output_filename, $groups_filename, @group_names, $action,$verbose,  $help );

    GetOptionsFromArray(
        $self->args,
        'o|output=s'          => \$output_filename,
        'g|groups_filename=s' => \$groups_filename,
		'v|verbose'           => \$verbose,
        'h|help'              => \$help,
    );
	
    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }
	
    $self->help($help) if(defined($help));
    ( !$self->help ) or die $self->usage_text;
    
    if ( @{ $self->args } == 0 ) {
        $self->_error_message("Error: You need to provide a FASTA file");
    }

    $self->output_filename($output_filename) if ( defined($output_filename) );
    if ( defined($groups_filename) && ( -e $groups_filename ) ) {
        $self->groups_filename($groups_filename);
    }
    else {
        $self->_error_message("Error: Cant access the groups file");
    }

    for my $filename ( @{ $self->args } ) {
        if ( !-e $filename ) {
            $self->_error_message("Error: Cant access file $filename");
            last;
        }
    }
    $self->gff_files( $self->args );

}

sub run {
    my ($self) = @_;

    
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

  
    my $obj = Bio::Roary::AnnotateGroups->new(
      gff_files   => $self->gff_files,
      output_filename   => $self->output_filename,
      groups_filename => $self->groups_filename,
    );
    $obj->reannotate;

}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage: transfer_annotation_to_groups [options] *.gff
Take in a groups file and the protein fasta files and output selected data

Options: -o STR output filename [reannotated_groups]
         -g STR clusters filename [clustered_proteins]
         -v     verbose output to STDOUT
         -h     this help message

For further info see: http://sanger-pathogens.github.io/Roary/
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
