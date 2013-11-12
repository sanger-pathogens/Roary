package Bio::PanGenome::CommandLine::IterativeCdhit;

# ABSTRACT: Iteratively run cdhit

=head1 SYNOPSIS

Iteratively run cdhit

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::PanGenome::IterativeCdhit;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );
has '_error_message' => ( is => 'rw', isa => 'Str' );

has 'output_cd_hit_filename'          => ( is => 'rw', isa => 'Str', default => '_clustered' );
has 'output_combined_filename'        => ( is => 'rw', isa => 'Str', default => '_combined_files' );
has 'number_of_input_files'           => ( is => 'rw', isa => 'Int' );
has 'output_filtered_clustered_fasta' => ( is => 'rw', isa => 'Str', default => '_clustered_filtered.fa' );

sub BUILD {
    my ($self) = @_;

    my ( $output_cd_hit_filename, $output_combined_filename, $number_of_input_files, $output_filtered_clustered_fasta,
        $help );

    GetOptionsFromArray(
        $self->args,
        'c|output_cd_hit_filename=s'          => \$output_cd_hit_filename,
        'm|output_combined_filename=s'        => \$output_combined_filename,
        'n|number_of_input_files=i'           => \$number_of_input_files,
        'f|output_filtered_clustered_fasta=s' => \$output_filtered_clustered_fasta,
        'h|help'                              => \$help,
    );

    $self->output_cd_hit_filename($output_cd_hit_filename)     if ( defined($output_cd_hit_filename) );
    $self->output_combined_filename($output_combined_filename) if ( defined($output_combined_filename) );
    $self->number_of_input_files($number_of_input_files)       if ( defined($number_of_input_files) );
    $self->output_filtered_clustered_fasta($output_filtered_clustered_fasta)
      if ( defined($output_filtered_clustered_fasta) );

}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

    my $obj = Bio::PanGenome::IterativeCdhit->new(
        output_cd_hit_filename          => $self->output_cd_hit_filename,
        output_combined_filename        => $self->output_combined_filename,
        number_of_input_files           => $self->number_of_input_files,
        output_filtered_clustered_fasta => $self->output_filtered_clustered_fasta,
    );
    $obj->run;
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: iterative_cdhit [options]
    Iteratively run cdhit
    
    iterative_cdhit -c _clustered -m _combined_files -n 10 -f _clustered_filtered.fa

    # This help message
    iterative_cdhit -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
