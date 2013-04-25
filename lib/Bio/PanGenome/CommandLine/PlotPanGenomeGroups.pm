package Bio::PanGenome::CommandLine::PlotPanGenomeGroups;

# ABSTRACT: Take in the groups file and output some summary plots

=head1 SYNOPSIS

Take in the groups file and output some summary plots

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::PanGenome::AnalyseGroups;

has 'args'              => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'       => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'              => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'fasta_files'       => ( is => 'rw', isa => 'ArrayRef' );
has 'groups_filename'   => ( is => 'rw', isa => 'Str' );
has 'output_filename'   => ( is => 'rw', isa => 'Str', default => 'clustered_proteins' );

has '_error_message'    => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ($self) = @_;

    my ( $fasta_files, $output_filename, $groups_filename, $help );

    GetOptionsFromArray(
        $self->args,
        'o|output=s'           => \$output_filename,
        'g|groups_filename=s'  => \$groups_filename,
        'h|help'               => \$help,
    );
    
    if ( @{ $self->args } == 0 ) {
        $self->_error_message("Error: You need to provide a FASTA file");
    }

    $self->output_filename($output_filename)   if ( defined($output_filename) );
     if ( defined($groups_filename)  && (-e $groups_filename))
     {
      $self->groups_filename($groups_filename)  ; 
     }
     else
     {
       $self->_error_message("Error: Cant access the groups file $groups_filename");
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
    
    my $plot_groups_obj = Bio::PanGenome::AnalyseGroups->new(
        fasta_files      => $self->fasta_files,
        groups_filename  => $self->groups_filename,
        output_filename  => $self->output_filename
      );
    $plot_groups_obj->create_plots();
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: plot_pan_genome_groups [options]
    Take in the groups file and output some summary plots
    
    # Create summary plots
    plot_pan_genome_groups -g groupfile example.faa
    
    # Provide an output filename
    plot_pan_genome_groups  -g groupfile -o results *.faa

    # This help message
    plot_pan_genome_groups -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
