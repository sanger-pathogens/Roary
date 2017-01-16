undef $VERSION;
package Bio::Roary::CommandLine::IterativeCdhit;

# ABSTRACT: Iteratively run cdhit

=head1 SYNOPSIS

Iteratively run cdhit

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::Roary::IterativeCdhit;
extends 'Bio::Roary::CommandLine::Common';

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
has 'cpus'                            => ( is => 'rw', isa => 'Int', default => 1 );
has 'verbose'                         => ( is => 'rw', isa => 'Bool', default => 0 );


sub BUILD {
    my ($self) = @_;

    my ( $output_cd_hit_filename,$cpus,$lower_bound_percentage,$upper_bound_percentage,$step_size_percentage, $output_combined_filename, $number_of_input_files, $output_filtered_clustered_fasta,$verbose, 
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
        'p|cpus=i'                              => \$cpus,
		'v|verbose'                           => \$verbose,
        'h|help'                              => \$help,
    );

    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }
    $self->help($help) if(defined($help));
    $self->lower_bound_percentage($lower_bound_percentage/100) if ( defined($lower_bound_percentage) );
    $self->upper_bound_percentage($upper_bound_percentage/100) if ( defined($upper_bound_percentage) );
    $self->step_size_percentage($step_size_percentage/100)     if ( defined($step_size_percentage) );
    $self->output_cd_hit_filename($output_cd_hit_filename)     if ( defined($output_cd_hit_filename) );
    $self->output_combined_filename($output_combined_filename) if ( defined($output_combined_filename) );
    $self->number_of_input_files($number_of_input_files)       if ( defined($number_of_input_files) );
    $self->cpus($cpus)                                         if ( defined($cpus) );
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

    my $obj = Bio::Roary::IterativeCdhit->new(
        output_cd_hit_filename          => $self->output_cd_hit_filename,
        output_combined_filename        => $self->output_combined_filename,
        number_of_input_files           => $self->number_of_input_files,
        output_filtered_clustered_fasta => $self->output_filtered_clustered_fasta,
        lower_bound_percentage          => $self->lower_bound_percentage,
        upper_bound_percentage          => $self->upper_bound_percentage,
        step_size_percentage            => $self->step_size_percentage,
        cpus                            => $self->cpus,
		logger                          => $self->logger
        
    );
    $obj->run;
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage: iterative_cdhit [options]
Iteratively cluster a FASTA file of proteins with CD-hit, lower the threshold each time and extracting core genes (1 per isolate) to another file, and remove them from the input proteins file.

Required arguments:
         -m STR   input FASTA file of protein sequences [_combined_files]

Options: -p INT   number of threads [1]
         -n INT   number of isolates [1]
         -c STR   cd-hit output filename [_clustered]
         -f STR   output filename for filtered sequences [_clustered_filtered.fa]
         -l FLOAT lower bound percentage identity [98.0]
         -u FLOAT upper bound percentage identity [99.0]
         -s FLOAT step size for percentage identity [0.5]
         -v       verbose output to STDOUT
         -h       this help message

For further info see: http://sanger-pathogens.github.io/Roary/
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
