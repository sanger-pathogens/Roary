package Bio::PanGenome::CommandLine::PanGenomePostAnalysis;

# ABSTRACT: Perform the post analysis on the pan genome

=head1 SYNOPSIS

Perform the post analysis on the pan genome

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::PanGenome::PostAnalysis;
use File::Find::Rule;
use Bio::PanGenome::External::ProteinMuscleAlignmentFromNucleotides;
use File::Path qw(remove_tree);
extends 'Bio::PanGenome::CommandLine::Common';

has 'args'                        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'                 => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'                        => ( is => 'rw', isa => 'Bool',     default  => 0 );
has '_error_message'              => ( is => 'rw', isa => 'Str' );

has 'fasta_files'                 => ( is => 'rw', isa => 'Str' );
has 'input_files'                 => ( is => 'rw', isa => 'Str');
has 'output_filename'             => ( is => 'rw', isa => 'Str',  default  => 'clustered_proteins' );
has 'output_pan_geneome_filename' => ( is => 'rw', isa => 'Str',  default  => 'pan_genome.fa' );
has 'output_statistics_filename'  => ( is => 'rw', isa => 'Str',  default  => 'gene_presence_absence.csv' );
has 'output_multifasta_files'     => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'clusters_filename'           => ( is => 'rw', isa => 'Str' );
has 'job_runner'                  => ( is => 'rw', isa => 'Str',  default  => 'LSF' );
has 'cpus'                        => ( is => 'rw', isa => 'Int',  default => 1 );
has 'dont_delete_files'           => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'dont_create_rplots'          => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'dont_split_groups'           => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'verbose_stats'               => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'translation_table'           => ( is => 'rw', isa => 'Int',  default => 11 );
has 'group_limit'                 => ( is => 'rw', isa => 'Num',  default => 50000 );
has 'core_definition'             => ( is => 'rw', isa => 'Num',  default => 1.0 );

sub BUILD {
    my ($self) = @_;

    my ( 
      $output_filename, $dont_create_rplots, $dont_delete_files, $dont_split_groups, $output_pan_geneome_filename, 
      $job_runner, $output_statistics_filename, $output_multifasta_files, $clusters_filename, $core_definition,
      $fasta_files, $input_files, $verbose_stats, $translation_table, $help, $cpus,$group_limit
    );


    GetOptionsFromArray(
        $self->args,
        'o|output=s'              => \$output_filename,
        'j|job_runner=s'          => \$job_runner,
        'output_multifasta_files' => \$output_multifasta_files,
        'p=s'                     => \$output_pan_geneome_filename,
        's=s'                     => \$output_statistics_filename,
        'c=s'                     => \$clusters_filename,
        'f=s'                     => \$fasta_files,
        'i=s'                     => \$input_files,
        'dont_delete_files'       => \$dont_delete_files,
        'dont_create_rplots'      => \$dont_create_rplots,
        'dont_split_groups'       => \$dont_split_groups,
        'verbose_stats'           => \$verbose_stats,
        'processors=i'            => \$cpus,
        't|translation_table=i'   => \$translation_table,
        'group_limit=i'           => \$group_limit,
        'cd|core_definition=f'    => \$core_definition,
        'h|help'                  => \$help,
    );
    
    $self->help($help) if(defined($help));
    $self->job_runner($job_runner)                                   if ( defined($job_runner) );
    $self->fasta_files($fasta_files)                                 if ( defined($fasta_files) );
    $self->input_files($input_files)                                 if ( defined($input_files) );
    $self->output_filename($output_filename)                         if ( defined($output_filename) );
    $self->output_pan_geneome_filename($output_pan_geneome_filename) if ( defined($output_pan_geneome_filename) );
    $self->output_statistics_filename($output_statistics_filename)   if ( defined($output_statistics_filename) );
    $self->output_multifasta_files($output_multifasta_files)         if ( defined($output_multifasta_files) );
    $self->clusters_filename($clusters_filename)                     if ( defined($clusters_filename) );
    $self->dont_delete_files($dont_delete_files)                     if ( defined($dont_delete_files) );
    $self->dont_create_rplots($dont_create_rplots)                   if ( defined($dont_create_rplots) );
    $self->dont_split_groups($dont_split_groups)                     if ( defined($dont_split_groups) );
    $self->verbose_stats($verbose_stats)                             if ( defined($verbose_stats));
    $self->translation_table($translation_table)                     if ( defined($translation_table) );
    $self->cpus($cpus)                                               if ( defined($cpus) );
    $self->group_limit($group_limit)                                 if ( defined($group_limit) );
    $self->core_definition( $core_definition/100 )                   if ( defined($core_definition) );
}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

    my $obj = Bio::PanGenome::PostAnalysis->new(
      fasta_files                     =>  $self->_read_file_into_array($self->fasta_files) ,
      input_files                     =>  $self->_read_file_into_array($self->input_files) ,
      output_filename                 =>  $self->output_filename            ,
      output_pan_geneome_filename     =>  $self->output_pan_geneome_filename,
      output_statistics_filename      =>  $self->output_statistics_filename ,
      output_multifasta_files         =>  $self->output_multifasta_files    ,
      clusters_filename               =>  $self->clusters_filename          ,
      dont_delete_files               =>  $self->dont_delete_files,
      dont_create_rplots              =>  $self->dont_create_rplots,
      dont_split_groups               =>  $self->dont_split_groups,
      verbose_stats                   =>  $self->verbose_stats,
      group_limit                     =>  $self->group_limit,
      );                                                             
    $obj->run();


    if($self->output_multifasta_files == 1)
    {
      my $output_gene_files = $self->_find_input_files;
      my $seg = Bio::PanGenome::External::ProteinMuscleAlignmentFromNucleotides->new(
        fasta_files         => $output_gene_files,
        job_runner          => $self->job_runner,
        translation_table   => $self->translation_table,
        core_definition     => $self->core_definition,
        cpus                => $self->cpus
      );
      $seg->run();
	
      # Cleanup intermediate multifasta files
      if($self->dont_delete_files == 0)
      {
        remove_tree('pan_genome_sequences');
      }
    }
     

}

sub _find_input_files
{
   my ($self) = @_;
   my @files = File::Find::Rule->file()
                               ->name( '*.fa' )
                               ->in('pan_genome_sequences' );
   return \@files;
}

sub _read_file_into_array
{
  my ($self, $filename) = @_;
  open(my $in_fh, $filename);
  
  my @filenames;
  while(<$in_fh>){
    chomp;
    my $line = $_;
    push(@filenames, $line);
  }
  return \@filenames;
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: pan_genome_post_analysis [options]
    Perform the post analysis on the pan genome. This script is usally only called by another script.
    
    #Normal usage
    pan_genome_post_analysis 
      -o <output_groups_filename>     
      -p <output_pan_genome_filename>
      -s <output_stats_filename>     
      -c <output_clusters_filename>   
      -f <file_of_proteins>              
      -i <file_of_gffs> 
      --processors <number of processors>
      --verbose_stats
      --core_definition <percentage of genomes required to qualify gene as core>        

    # This help message
    pan_genome_post_analysis -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
