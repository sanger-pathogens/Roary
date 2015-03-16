package Bio::PanGenome::CommandLine::TransferAnnotationToGroups;

# ABSTRACT: Take in a groups file and a set of GFF files and transfer the consensus annotation

=head1 SYNOPSIS

Take in a groups file and a set of GFF files and transfer the consensus annotation

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::PanGenome::AnnotateGroups;
extends 'Bio::PanGenome::CommandLine::Common';


has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'gff_files'     => ( is => 'rw', isa => 'ArrayRef' );
has 'groups_filename' => ( is => 'rw', isa => 'Str' );
has 'output_filename' => ( is => 'rw', isa => 'Str', default => 'reannotated_groups' );

has '_error_message' => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ($self) = @_;

    my ( $gff_files, $output_filename, $groups_filename, @group_names, $action, $help );

    GetOptionsFromArray(
        $self->args,
        'o|output=s'          => \$output_filename,
        'g|groups_filename=s' => \$groups_filename,
        'h|help'              => \$help,
    );

    $self->help($help) if(defined($help));
    if ( @{ $self->args } == 0 ) {
        $self->_error_message("Error: You need to provide a FASTA file");
    }

    $self->output_filename($output_filename) if ( defined($output_filename) );
    if ( defined($groups_filename) && ( -e $groups_filename ) ) {
        $self->groups_filename($groups_filename);
    }
    else {
        $self->_error_message("Error: Cant access the groups file $groups_filename");
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

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

  
    my $obj = Bio::PanGenome::AnnotateGroups->new(
      gff_files   => $self->gff_files,
      output_filename   => $self->output_filename,
      groups_filename => $self->groups_filename,
    );
    $obj->reannotate;

}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: transfer_annotation_to_groups [options]
    Take in a groups file and the protein fasta files and output selected data
    
    # Transfer the annotation from the GFF files to the group file
    transfer_annotation_to_groups -g groupfile *.gff
    
    # Specify an output filename
    transfer_annotation_to_groups -o output_filename -g groupfile *.gff
    
    # This help message
    transfer_annotation_to_groups -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
