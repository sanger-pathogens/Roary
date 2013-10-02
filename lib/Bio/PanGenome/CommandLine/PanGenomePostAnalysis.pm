package Bio::PanGenome::CommandLine::PanGenomePostAnalysis;

# ABSTRACT: Perform the post analysis on the pan genome

=head1 SYNOPSIS

Perform the post analysis on the pan genome

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::PanGenome::PostAnalysis;


has 'args'                        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'                 => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'                        => ( is => 'rw', isa => 'Bool',     default  => 0 );
has '_error_message'              => ( is => 'rw', isa => 'Str' );

has 'fasta_files'                 => ( is => 'rw', isa => 'ArrayRef' );
has 'input_files'                 => ( is => 'rw', isa => 'ArrayRef');
has 'output_filename'             => ( is => 'rw', isa => 'Str',  default  => 'clustered_proteins' );
has 'output_pan_geneome_filename' => ( is => 'rw', isa => 'Str',  default  => 'pan_genome.fa' );
has 'output_statistics_filename'  => ( is => 'rw', isa => 'Str',  default  => 'group_statisics.csv' );
has 'output_multifasta_files'     => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'clusters_filename'           => ( is => 'rw', isa => 'Str' );
has 'job_runner'                  => ( is => 'rw', isa => 'Str',  default  => 'LSF' );

sub BUILD {
    my ($self) = @_;

    my ( $output_filename, $output_pan_geneome_filename, $job_runner, $output_statistics_filename, $output_multifasta_files, $clusters_filename, $fasta_files, $input_files, $help );

    GetOptionsFromArray(
        $self->args,
        'o|output=s'              => \$output_filename,
        'j|job_runner=s'          => \$job_runner,
        'output_multifasta_files' => \$output_multifasta_files,
        'p=s'                     => \$output_pan_geneome_filename,
        's=s'                     => \$output_statistics_filename,
        'c=s'                     => \$clusters_filename,
        'f=s@'                    => \$fasta_files,
        'i=s@'                    => \$input_files,
        'h|help'                  => \$help,
    );
    
    $self->job_runner($job_runner)                                  if ( defined($job_runner) );
    $self->fasta_files($fasta_files)                                 if (defined($fasta_files));
    $self->input_files($input_files)                                 if (defined($input_files));
    $self->output_filename($output_filename)                         if (defined($output_filename));
    $self->output_pan_geneome_filename($output_pan_geneome_filename) if (defined($output_pan_geneome_filename));
    $self->output_statistics_filename($output_statistics_filename)   if (defined($output_statistics_filename));
    $self->output_multifasta_files($output_multifasta_files)         if (defined($output_multifasta_files));
    $self->clusters_filename($clusters_filename)                     if (defined($clusters_filename));

}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

    my $obj = Bio::PanGenome::PostAnalysis->new(
      fasta_files                     =>  $self->fasta_files                ,
      input_files                     =>  $self->input_files                ,
      output_filename                 =>  $self->output_filename            ,
      output_pan_geneome_filename     =>  $self->output_pan_geneome_filename,
      output_statistics_filename      =>  $self->output_statistics_filename ,
      output_multifasta_files         =>  $self->output_multifasta_files    ,
      clusters_filename               =>  $self->clusters_filename          ,
      );                                                             
    $obj->run();
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: pan_genome_post_analysis [options]
    Perform the post analysis on the pan genome. This script is usally only called by another script.
    
    #Normal usage
    pan_genome_post_analysis 
      -o output_groups_filename      /
      -p output_pan_genome_filename  /
      -s output_stats_filename       /
      -c output_clusters_filename    /
      -f proteins1.faa               /
      -f proteins2.faa               /
      -f proteins3.faa               /
      -i annotation1.gff             /
      -i annotation2.gff             /

    # This help message
    pan_genome_post_analysis -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
