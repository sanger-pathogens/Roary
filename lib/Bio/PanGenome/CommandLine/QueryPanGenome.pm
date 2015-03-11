package Bio::PanGenome::CommandLine::QueryPanGenome;

# ABSTRACT: Take in a groups file and the protein fasta files and output selected data

=head1 SYNOPSIS

Take in a groups file and the protein fasta files and output selected data

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::Output::GroupsMultifastas;
use Bio::PanGenome::Output::OneGenePerGroupFasta;
use Bio::PanGenome::Output::QueryGroups;
use Bio::PanGenome::PrepareInputFiles;
use Bio::PanGenome::Output::DifferenceBetweenSets;
use Bio::PanGenome::AnnotateGroups;
use Bio::PanGenome::GroupStatistics;
use Bio::PanGenome::OrderGenes;

has 'args'        => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'input_files'     => ( is => 'rw', isa => 'ArrayRef' );
has 'groups_filename' => ( is => 'rw', isa => 'Str', default => 'clustered_proteins');
has 'group_names'     => ( is => 'rw', isa => 'ArrayRef' );
has 'input_set_one'   => ( is => 'rw', isa => 'ArrayRef' );
has 'input_set_two'   => ( is => 'rw', isa => 'ArrayRef' );
has 'output_filename' => ( is => 'rw', isa => 'Str', default => 'pan_genome_results' );
has 'action'          => ( is => 'rw', isa => 'Str', default => 'one_gene_per_group' );
has 'core_definition' => ( is => 'rw', isa => 'Num', default => 1.0 );

has '_error_message' => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ($self) = @_;

    my ( $input_files, $output_filename, $groups_filename, @group_names, @input_set_one, @input_set_two, $action, $core_definition, $help );

    GetOptionsFromArray(
        $self->args,
        'o|output=s'          => \$output_filename,
        'g|groups_filename=s' => \$groups_filename,
        'n|group_names=s'     => \@group_names,
        'a|action=s'          => \$action,
        'i|input_set_one=s'   => \@input_set_one,
        't|input_set_two=s'   => \@input_set_two,
        'c|core_definition=f' => \$core_definition,
        'h|help'              => \$help,
    );

    $self->help($help) if(defined($help));
    
    $self->output_filename($output_filename) if ( defined($output_filename) );
    $self->action($action)                   if ( defined($action) );
    $self->core_definition($core_definition) if ( defined($core_definition) );
    if ( defined($groups_filename) && ( -e $groups_filename ) ) {
        $self->groups_filename($groups_filename);
    }
    
    if(! (-e $self->groups_filename)) {
        $self->_error_message("Error: Cant access the groups file: ".$self->groups_filename);
    }

    @group_names = split( /,/, join( ',', @group_names ) );
    $self->group_names( \@group_names ) if (@group_names);
    
    @input_set_one = split( /,/, join( ',', @input_set_one ) );
    $self->input_set_one( \@input_set_one ) if (@input_set_one);
    
    @input_set_two = split( /,/, join( ',', @input_set_two ) );
    $self->input_set_two( \@input_set_two ) if (@input_set_two);
    
    if(defined($self->input_set_one) && defined($self->input_set_two) )
    {
        my @all_input_files = (@{ $self->input_set_one },@{ $self->input_set_two });
        $self->args(\@all_input_files);
    }


    if ( !defined($self->input_set_two) &&  @{ $self->args } == 0) {
        $self->_error_message("Error: You need to provide a FASTA file");
    }
    
    for my $filename ( @{ $self->args } ) {
        if ( !-e $filename ) {
            $self->_error_message("Error: Cant access file $filename");
            last;
        }
    }
    $self->input_files( $self->args );

}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }
    
    my $prepare_input_files = Bio::PanGenome::PrepareInputFiles->new(
      input_files   => $self->input_files,
    );

    my $analyse_groups_obj = Bio::PanGenome::AnalyseGroups->new(
        fasta_files     => $prepare_input_files->fasta_files,
        groups_filename => $self->groups_filename,
    );

    if ( $self->action eq 'one_gene_per_group' ) {
        my $one_gene_per_fasta = Bio::PanGenome::Output::OneGenePerGroupFasta->new(
            analyse_groups  => $analyse_groups_obj,
            output_filename => $self->output_filename
        );
        $one_gene_per_fasta->create_file();
    }
    elsif ( $self->action eq 'union' ) {
        my $query_groups = Bio::PanGenome::Output::QueryGroups->new(
            analyse_groups        => $analyse_groups_obj,
            output_union_filename => $self->output_filename,
            input_filenames       => $prepare_input_files->fasta_files
        );
        $query_groups->groups_union();
    }
    elsif ( $self->action eq 'intersection' ) {
        my $query_groups = Bio::PanGenome::Output::QueryGroups->new(
            analyse_groups               => $analyse_groups_obj,
            output_intersection_filename => $self->output_filename, 
            input_filenames => $prepare_input_files->fasta_files,
            core_definition => $self->core_definition
        );
        $query_groups->groups_intersection();
    }
    elsif ( $self->action eq 'complement' ) {
        my $query_groups = Bio::PanGenome::Output::QueryGroups->new(
            analyse_groups             => $analyse_groups_obj,
            output_complement_filename => $self->output_filename, 
            input_filenames => $prepare_input_files->fasta_files,
            core_definition => $self->core_definition
        );
        $query_groups->groups_complement();
    }
    elsif ( $self->action eq 'gene_multifasta' && defined( $self->group_names ) ) {
        my $group_multi_fastas = Bio::PanGenome::Output::GroupsMultifastas->new(
            group_names          => $self->group_names,
            analyse_groups       => $analyse_groups_obj,
            output_filename_base => $self->output_filename
        );
        $group_multi_fastas->create_files();
    }
    elsif($self->action eq 'difference' && defined($self->input_set_one) && defined($self->input_set_two))
    {
      my $difference_between_sets = Bio::PanGenome::Output::DifferenceBetweenSets->new(
          analyse_groups       => $analyse_groups_obj,
          input_filenames_sets => [ 
            $prepare_input_files->lookup_fasta_files_from_unknown_input_files($self->input_set_one),  
            $prepare_input_files->lookup_fasta_files_from_unknown_input_files($self->input_set_two) 
          ],
        );
      $difference_between_sets->groups_set_one_unique();
      $difference_between_sets->groups_set_two_unique();
      $difference_between_sets->groups_in_common();
      
      for my $differences_group_filename(($difference_between_sets->groups_set_one_unique_filename,$difference_between_sets->groups_set_two_unique_filename,$difference_between_sets->groups_in_common_filename))
      {
        $self->create_spreadsheets($differences_group_filename, $prepare_input_files->fasta_files, $prepare_input_files->fasta_files);
      }

    }
    else {
        print "Nothing done\n";
    }
}


sub create_spreadsheets
{
      my ($self, $groups_file, $fasta_files, $gff_files) = @_;

      my $analyse_groups_obj = Bio::PanGenome::AnalyseGroups->new(
          fasta_files     => $fasta_files,
          groups_filename => $groups_file,
      );
      
      my $annotate_groups = Bio::PanGenome::AnnotateGroups->new(
          gff_files       => $gff_files,
          output_filename => $groups_file.'_reannotated',
          groups_filename => $groups_file,
      );
      $annotate_groups->reannotate;
    
      my $order_genes_obj = Bio::PanGenome::OrderGenes->new(
        analyse_groups_obj => $analyse_groups_obj,
        gff_files          => $gff_files,
      );
      
      my $group_statistics = Bio::PanGenome::GroupStatistics->new(
          output_filename     => $groups_file.'_statistics.csv',
          annotate_groups_obj => $annotate_groups,
          analyse_groups_obj  => $analyse_groups_obj,
          groups_to_contigs   => $order_genes_obj->groups_to_contigs
      );
      $group_statistics->create_spreadsheet;
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: query_pan_genome [options]
    Take in a groups file and GFF files and output selected data
    
    # Create a FASTA file with one gene per group (representative pan genome)
    query_pan_genome -a one_gene_per_group -g clustered_proteins example.gff
    
    # Provide an output filename
    query_pan_genome  -a one_gene_per_group -g clustered_proteins -o results.fa *.gff
    
    # Create multifasta files for each group/gene passed in
    query_pan_genome  -a gene_multifasta -g clustered_proteins -n gryA,mecA,abc *.gff
    
    # Union
    query_pan_genome  -a union -g clustered_proteins *.gff
    
    # Intersection
    query_pan_genome  -a intersection -g clustered_proteins *.gff

    # Complement (Union minus Intersection)
    query_pan_genome  -a complement -g clustered_proteins *.gff
    
    # Difference between sets 
    query_pan_genome  -a difference --input_set_one 1.gff,2.gff --input_set_two 3.gff,4.gff,5.gff  -g clustered_proteins

    # This help message
    query_pan_genome -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
