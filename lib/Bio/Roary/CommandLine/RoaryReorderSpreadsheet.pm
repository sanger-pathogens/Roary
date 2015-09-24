undef $VERSION;
package Bio::Roary::CommandLine::RoaryReorderSpreadsheet;

# ABSTRACT: Take in a tree and a spreadsheet and output a reordered spreadsheet

=head1 SYNOPSIS

Take in a tree and a spreadsheet and output a reordered spreadsheet

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::Roary::ReorderSpreadsheet;
extends 'Bio::Roary::CommandLine::Common';

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'tree_file'            => ( is => 'rw', isa => 'Str' );
has 'spreadsheet_filename' => ( is => 'rw', isa => 'Str' );
has 'output_filename'      => ( is => 'rw', isa => 'Str', default => 'reordered_spreadsheet.csv' );
has 'tree_format'          => ( is => 'rw', isa => 'Str', default => 'newick' );
has 'search_strategy'      => ( is => 'rw', isa => 'Str', default =>  'depth' );
has 'sortby'               => ( is => 'rw', isa => 'Str', default => 'height');
has 'verbose'              => ( is => 'rw', isa => 'Bool', default => 0 );


sub BUILD {
    my ($self) = @_;

    my ( $output_filename, $tree_file,$search_strategy, $sortby, $tree_format, $spreadsheet_filename,$verbose,  $help );

    GetOptionsFromArray(
        $self->args,
        'o|output_filename=s'      => \$output_filename,
        't|tree_file=s'            => \$tree_file,
        'f|tree_format=s'          => \$tree_format,
        's|spreadsheet_filename=s' => \$spreadsheet_filename,
        'a|search_strategy=s'      => \$search_strategy,
        'b|sortby=s'               => \$sortby,
		'v|verbose'                => \$verbose,
        'h|help'                   => \$help,
    );

    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }
    $self->help($help) if(defined($help));
    $self->output_filename($output_filename)           if ( defined($output_filename) );
    $self->tree_file($tree_file)                       if ( defined($tree_file) );
    $self->tree_format($tree_format)                   if ( defined($tree_format) );
    $self->spreadsheet_filename($spreadsheet_filename) if ( defined($spreadsheet_filename) );
    $self->sortby($sortby)                             if ( defined($sortby) );
    $self->search_strategy($search_strategy)           if ( defined($search_strategy) );
}

sub run {
    my ($self) = @_;
    ( defined($self->spreadsheet_filename) && defined($self->tree_file) && ( -e $self->spreadsheet_filename ) && ( -e $self->tree_file ) && ( !$self->help ) ) or die $self->usage_text;

    ($self->sortby eq "height" || $self->sortby eq "creation" || $self->sortby eq "alpha" || $self->sortby eq "revalpha") or die $self->usage_text;
    ($self->search_strategy eq "breadth" || $self->search_strategy eq "depth") or die $self->usage_text;

    my $obj = Bio::Roary::ReorderSpreadsheet->new(
        tree_file       => $self->tree_file,
        spreadsheet     => $self->spreadsheet_filename,
        output_filename => $self->output_filename,
        sortby          => $self->sortby,
        search_strategy => $self->search_strategy
    );
    $obj->reorder_spreadsheet();

}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: pan_genome_reorder_spreadsheet [options]
    Take in a tree and a spreadsheet from the pan genome pipeline and output a spreadsheet with the columns ordered by the tree. 
    By default it expects the tree to be in newick format.
    
    # Reorder the spreadsheet columns to match the order of the samples in the tree
    pan_genome_reorder_spreadsheet -t my_tree.tre -s my_spreadsheet.csv
    
    # Specify an output filename
    pan_genome_reorder_spreadsheet -t my_tree.tre -s my_spreadsheet.csv -o output_spreadsheet.csv
    
    # Use a different search strategy  (default is 'depth' first search)
    pan_genome_reorder_spreadsheet -t my_tree.tre -s my_spreadsheet.csv -a breadth
    
    # Use a different child sorting method (height/creation/alpha/revalpha), default is 'height'
    pan_genome_reorder_spreadsheet -t my_tree.tre -s my_spreadsheet.csv -b alpha
    
    # This help message
    pan_genome_reorder_spreadsheet -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
