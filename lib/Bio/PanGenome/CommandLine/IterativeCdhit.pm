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
has 'number_of_input_files'           => ( is => 'rw', isa => 'Int', default => 1 );
has 'output_filtered_clustered_fasta' => ( is => 'rw', isa => 'Str', default => '_clustered_filtered.fa' );

has 'lower_bound_percentage'          => ( is => 'rw', isa => 'Num', default => 0.98 );
has 'upper_bound_percentage'          => ( is => 'rw', isa => 'Num', default => 0.99 );
has 'step_size_percentage'            => ( is => 'rw', isa => 'Num', default => 0.005 );


sub BUILD {
    my ($self) = @_;

    my ( $output_cd_hit_filename,$lower_bound_percentage,$upper_bound_percentage,$step_size_percentage, $output_combined_filename, $number_of_input_files, $output_filtered_clustered_fasta,
        $help );

    GetOptionsFromArray(
        $self->args,
        'c|output_cd_hit_filename=s'          => \$output_cd_hit_filename,
        'm|output_combined_filename=s'        => \$output_combined_filename,
        'n|number_of_input_files=i'           => \$number_of_input_files,
        'f|output_filtered_clustered_fasta=s' => \$output_filtered_clustered_fasta,
        'l|lower_bound_percentage=s'          => \$lower_bound_percentage,
        'u|upper_bound_percentage=s'          => \$upper_bound_percentage,
        's|step_size_percentage=s'            => \$step_size_percentage,
        'h|help'                              => \$help,
    );

    $self->help($help) if(defined($help));
    $self->lower_bound_percentage($lower_bound_percentage/100) if ( defined($lower_bound_percentage) );
    $self->upper_bound_percentage($upper_bound_percentage/100) if ( defined($upper_bound_percentage) );
    $self->step_size_percentage($step_size_percentage/100)     if ( defined($step_size_percentage) );
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
        lower_bound_percentage          => $self->lower_bound_percentage,
        upper_bound_percentage          => $self->upper_bound_percentage,
        step_size_percentage            => $self->step_size_percentage
        
    );
    $obj->run;
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: iterative_cdhit [options]
    Iteratively cluster a set of proteins with CD-hit, lower the threshold each time and extracting core genes (1 per isolate) to another file, and remove them from the input proteins file.
    
    # Basic usage where you have a single isolate
    iterative_cdhit -m proteome_fasta.faa
    
    # Where you have 10 isolates
    iterative_cdhit -m proteome_fasta.faa -n 10
    
    # Specify the output file name  cdhit results
    iterative_cdhit -m proteome_fasta.faa -n 10 -c _clustered 

    # Specify the output file name for the output protein sequences
    iterative_cdhit -m proteome_fasta.faa -n 10 -f output_filtered_clustered_fasta
    
    # Change the lower bound percentage that you iterate to (defaults to 98%)
    iterative_cdhit -m proteome_fasta.faa -l 95
    
    # Change the upper bound percentage that you iterate from (defaults to 99%)
    iterative_cdhit -m proteome_fasta.faa -l 100
    
    # Change the intermediate step size (defaults to 0.5%)
    iterative_cdhit -m proteome_fasta.faa -l 0.1

    # This help message
    iterative_cdhit -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
