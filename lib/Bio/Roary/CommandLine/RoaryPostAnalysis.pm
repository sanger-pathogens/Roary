undef $VERSION;
package Bio::Roary::CommandLine::RoaryPostAnalysis;

# ABSTRACT: Perform the post analysis on the pan genome

=head1 SYNOPSIS

Perform the post analysis on the pan genome

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::Roary::PostAnalysis;
use File::Find::Rule;
use Bio::Roary::External::GeneAlignmentFromNucleotides;
use File::Path qw(remove_tree);
use Bio::Roary::External::Fasttree;
extends 'Bio::Roary::CommandLine::Common';

has 'args'                        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'                 => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'                        => ( is => 'rw', isa => 'Bool',     default  => 0 );
has '_error_message'              => ( is => 'rw', isa => 'Str' );

has 'fasta_files'                 => ( is => 'rw', isa => 'Str',  default  => '_fasta_files' );
has 'input_files'                 => ( is => 'rw', isa => 'Str',  default  => '_gff_files');
has 'output_filename'             => ( is => 'rw', isa => 'Str',  default  => 'clustered_proteins' );
has 'output_pan_geneome_filename' => ( is => 'rw', isa => 'Str',  default  => 'pan_genome.fa' );
has 'output_statistics_filename'  => ( is => 'rw', isa => 'Str',  default  => 'gene_presence_absence.csv' );
has 'output_multifasta_files'     => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'clusters_filename'           => ( is => 'rw', isa => 'Str',  default  => '_clustered.clstr' );
has 'job_runner'                  => ( is => 'rw', isa => 'Str',  default  => 'Local' );
has 'cpus'                        => ( is => 'rw', isa => 'Int',  default => 1 );
has 'dont_delete_files'           => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'dont_create_rplots'          => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'dont_split_groups'           => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'verbose_stats'               => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'translation_table'           => ( is => 'rw', isa => 'Int',  default => 11 );
has 'group_limit'                 => ( is => 'rw', isa => 'Num',  default => 50000 );
has 'core_definition'             => ( is => 'rw', isa => 'Num',  default => 0.99 );
has 'verbose'                     => ( is => 'rw', isa => 'Bool', default => 0 );
has 'mafft'                       => ( is => 'rw', isa => 'Bool', default => 0 );

sub BUILD {
    my ($self) = @_;

    my ( 
      $output_filename, $dont_create_rplots, $dont_delete_files, $dont_split_groups, $output_pan_geneome_filename, 
      $job_runner, $output_statistics_filename, $output_multifasta_files, $clusters_filename, $core_definition,
      $fasta_files, $input_files, $verbose_stats, $translation_table, $help, $cpus,$group_limit,$verbose,$mafft
    );


    GetOptionsFromArray(
        $self->args,
        'o|output=s'                => \$output_filename,
        'j|job_runner=s'            => \$job_runner,
        'm|output_multifasta_files' => \$output_multifasta_files,
        'p=s'                       => \$output_pan_geneome_filename,
        's=s'                       => \$output_statistics_filename,
        'c=s'                       => \$clusters_filename,
        'f=s'                       => \$fasta_files,
        'i=s'                       => \$input_files,
        'a|dont_delete_files'       => \$dont_delete_files,
        'b|dont_create_rplots'      => \$dont_create_rplots,
        'd|dont_split_groups'       => \$dont_split_groups,
        'e|verbose_stats'           => \$verbose_stats,
        'z|processors=i'            => \$cpus,
        't|translation_table=i'     => \$translation_table,
        'g|group_limit=i'           => \$group_limit,
        'cd|core_definition=f'      => \$core_definition,
		'v|verbose'                 => \$verbose,
		'n|mafft'                   => \$mafft,
        'h|help'                    => \$help,
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
	$self->mafft($mafft)                                             if ( defined($mafft) );
    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }
}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

    my $input_files = $self->_read_file_into_array($self->input_files);
    my $obj = Bio::Roary::PostAnalysis->new(
      fasta_files                     =>  $self->_read_file_into_array($self->fasta_files) ,
      input_files                     =>  $input_files ,
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
	  verbose                         =>  $self->verbose,
	  cpus                            =>  $self->cpus,
	  logger                          =>  $self->logger,
	  core_definition                 =>  $self->core_definition,
      );                                                             
    $obj->run();
	
    if($self->dont_delete_files == 0)
    {
		unlink('_inflated_unsplit_mcl_groups');
        remove_tree('split_groups');
    }

    if($self->output_multifasta_files == 1)
    {
	  print "Aligning each cluster\n" if($self->verbose);
      
      my $job_runner_to_use = $self->job_runner;
      if($self->_is_lsf_job_runner_available && $self->job_runner eq "LSF")
      {
          $job_runner_to_use = $self->job_runner;
      }
      else
      {
          $job_runner_to_use = 'Parallel';
      }
      
      my $output_gene_files = $self->_find_input_files;
      my $seg = Bio::Roary::External::GeneAlignmentFromNucleotides->new(
        fasta_files         => $output_gene_files,
        job_runner          => $job_runner_to_use,
        translation_table   => $self->translation_table,
        core_definition     => $self->core_definition,
        cpus                => $self->cpus,
		verbose             => $self->verbose,
		mafft               => $self->mafft,
        dont_delete_files   => $self->dont_delete_files,
        num_input_files     => $#{$input_files},
      );
      $seg->run();
    }
}

sub _is_lsf_job_runner_available
{
    my ($self) = @_;
    my $rc = eval "require Bio::Roary::JobRunner::LSF; 1;";
    if(defined($rc) && $rc == 1)
    {
        return 1;
    }
    else
    {
        return 0;
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

Options: -a        dont delete intermediate files
         -b        dont create R plots
         -c STR    clusters filename [_clustered.clstr]
         -cd FLOAT percentage of isolates a gene must be in to be core [0.99]
         -d        dont split groups
         -e        add inference values to gene presence and absence spreadsheet
         -f STR    file of protein filenames [_fasta_files]
         -g INT    maximum number of clusters [50000]
         -i STR    file of GFF filenames [_gff_files]
         -m        core gene alignement with PRANK
         -n        fast core gene alignement with MAFFT instead of PRANK
         -o STR    clusters output filename [clustered_proteins]
         -p STR    output pan genome filename [pan_genome.fa]
         -s STR    output gene presence and absence filename [gene_presence_absence.csv]
         -t INT    translation table [11]
         -z INT    number of threads [1]
         -v        verbose output to STDOUT
         -h        this help message
         
For further info see: http://sanger-pathogens.github.io/Roary/
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
