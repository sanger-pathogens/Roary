package Bio::Roary::Output::QueryGroups;

# ABSTRACT:  Output the groups of the union of a set of input isolates

=head1 SYNOPSIS

Output the groups of the union of a set of input isolates
   use Bio::Roary::Output::QueryGroups;
   
   my $obj = Bio::Roary::Output::QueryGroups->new(
       analyse_groups  => $analyse_groups
     );
   $obj->groups_union();
   $obj->groups_intersection();
   $obj->groups_complement();

=cut

use Moose;
use Bio::SeqIO;
use Bio::Roary::Exceptions;
use Bio::Roary::AnalyseGroups;
use POSIX;

has 'analyse_groups'        => ( is => 'ro', isa => 'Bio::Roary::AnalyseGroups', required => 1 );
has 'input_filenames'       => ( is => 'ro', isa => 'ArrayRef',                      required => 1 );
has 'output_union_filename' => ( is => 'ro', isa => 'Str',                           default  => 'union_of_groups.gg' );
has 'output_intersection_filename' => ( is => 'ro', isa => 'Str',      default => 'intersection_of_groups.gg' );
has 'output_complement_filename'   => ( is => 'ro', isa => 'Str',      default => 'complement_of_groups.gg' );
has 'core_definition'       => ( is => 'ro', isa => 'Num', default => 1.0 );

has '_groups_freq'                 => ( is => 'ro', isa => 'HashRef', lazy    => 1, builder => '_build__groups_freq' );
has '_groups_intersection' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build__groups_intersection' );
has '_groups_complement'  => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build__groups_complement' );
has '_groups'             => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build__groups' );
has '_number_of_isolates' => ( is => 'ro', isa => 'Int',      lazy => 1, builder => '_builder__number_of_isolates' );
has '_min_no_isolates_for_core' => ( is => 'rw', isa => 'Int',      lazy_build => 1 );

sub _build__min_no_isolates_for_core {
    my ( $self ) = @_;
    my $threshold = ceil( $self->_number_of_isolates * $self->core_definition );

    return $threshold;
}

sub _builder__number_of_isolates {
    my ($self) = @_;
    return @{ $self->input_filenames };
}

sub _build__groups_freq {
    my ($self) = @_;
    my %groups_freq;

    for my $filename ( @{ $self->input_filenames } ) {
        my $genes = $self->analyse_groups->_files_to_genes->{$filename};
        
		my %file_groups_seen;
        for my $gene ( @{$genes} ) {
          next if(!defined($gene));
          next if(!defined($self->analyse_groups->_genes_to_groups->{$gene}));
		  next if(defined($file_groups_seen{$self->analyse_groups->_genes_to_groups->{$gene}}));
		  
          push(@{$groups_freq{ $self->analyse_groups->_genes_to_groups->{$gene} }}, $gene);
          $file_groups_seen{$self->analyse_groups->_genes_to_groups->{$gene}} = 1;
        }
    }

    return \%groups_freq;
}

sub _build__groups {
    my ($self) = @_;
    my %groups_freq = %{ $self->_groups_freq };
    my @groups = sort { @{$groups_freq{$b}} <=> @{$groups_freq{$a}} } keys %groups_freq;
    return \@groups;
}

sub _build__groups_intersection {
    my ($self) = @_;
    my @groups_intersection;

    for my $group ( @{$self->_groups} ) {
        if ( scalar @{$self->_groups_freq->{$group}} >= $self->_min_no_isolates_for_core ) {
            push( @groups_intersection, $group );
        }
    }
    return \@groups_intersection;
}

sub _build__groups_complement {
    my ($self) = @_;
    my %groups_intersection = map { $_ => 1 } @{ $self->_groups_intersection };
    my @complement = grep { not $groups_intersection{$_} } @{ $self->_groups };
    return \@complement;
}

sub _print_out_groups {
    my ( $self, $filename, $groups ) = @_;
    open( my $fh, '>', $filename )
      or Bio::Roary::Exceptions::CouldntWriteToFile->throw( error => 'Couldnt write to file: ' . $filename );

   my %groups_freq = %{ $self->_groups_freq };
   my @sorted_groups = sort { @{$groups_freq{$b}} <=> @{$groups_freq{$a}} } @{$groups};

    for my $group ( @sorted_groups ) {
        print {$fh} $group.': '.join("\t",@{$self->_groups_freq->{$group}}) . "\n";
    }
    close($fh);
    return $self;
}

sub groups_complement {
    my ($self) = @_;
    $self->_print_out_groups( $self->output_complement_filename, $self->_groups_complement );
}

sub groups_intersection {
    my ($self) = @_;
    $self->_print_out_groups( $self->output_intersection_filename, $self->_groups_intersection );
}

sub groups_union {
    my ($self) = @_;
    $self->_print_out_groups( $self->output_union_filename, $self->_groups );
}

sub groups_with_external_inputs
{
  my ($self, $output_filename,$groups) = @_;
  $self->_print_out_groups( $output_filename, $groups );
  
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

