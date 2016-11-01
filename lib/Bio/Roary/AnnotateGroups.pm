package Bio::Roary::AnnotateGroups;

# ABSTRACT: Take in a group file and associated GFF files for the isolates and update the group name to the gene name

=head1 SYNOPSIS

Take in a group file and associated GFF files for the isolates and update the group name to the gene name
   use Bio::Roary::AnnotateGroups;
   
   my $obj = Bio::Roary::AnnotateGroups->new(
     gff_files   => ['abc.gff','efg.gff'],
     output_filename   => 'example_output.fa',
     groups_filename => 'groupsfile',
   );
   $obj->reannotate;

=cut

use Moose;
use Bio::Roary::Exceptions;
use Bio::Roary::GeneNamesFromGFF;
use Array::Utils qw(array_minus);
use List::Util qw(max min sum);
use File::Grep qw(fgrep);

has 'gff_files'          => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'output_filename'    => ( is => 'ro', isa => 'Str',      default  => 'reannotated_groups_file' );
has 'groups_filename'    => ( is => 'ro', isa => 'Str',      required => 1 );
has '_ids_to_gene_names' => ( is => 'ro', isa => 'HashRef',  lazy     => 1, builder => '_build__ids_to_gene_names' );
has '_ids_to_product'    => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has '_ids_to_gene_size'  => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has 'group_nucleotide_lengths'  => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_group_nucleotide_lengths');

has '_groups_to_id_names'   => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_builder__groups_to_id_names' );
has '_output_fh'            => ( is => 'ro', lazy => 1, builder => '_build__output_fh' );
has '_groups_to_consensus_gene_names' =>
  ( is => 'rw', isa => 'HashRef', lazy => 1, builder => '_build__groups_to_consensus_gene_names' );
has '_filtered_gff_files'   => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build__filtered_gff_files' );
has '_number_of_files'      => ( is => 'ro', isa => 'Int',      lazy => 1, builder => '_build__number_of_files' );
has '_ids_to_groups'        => ( is => 'rw', isa => 'HashRef',  lazy => 1, builder => '_builder__ids_to_groups' );
has '_group_counter'        => ( is => 'rw', isa => 'Int', lazy => 1, builder => '_builder__group_counter' );
has '_group_default_prefix' => ( is => 'rw', isa => 'Str', default => 'group_' );
has '_ids_to_verbose_stats' => ( is => 'rw', isa => 'HashRef', lazy_build => 1 );

sub BUILD {
    my ($self) = @_;
    $self->_ids_to_gene_names;
}

sub _builder__group_counter {
    my ($self)        = @_;
    my $prefix        = $self->_group_default_prefix;
    my $highest_group = 0;
    for my $group ( @{ $self->_groups } ) {
        if ( $group =~ /$prefix([\d]+)$/ ) {
            my $group_id = $1;
            if ( $group_id > $highest_group ) {
                $highest_group = $group_id;
            }
        }
    }
    return $highest_group + 1;
}

sub _generate__ids_to_groups {
    my ($self) = @_;
    my %ids_to_groups;

    for my $group ( keys %{ $self->_groups_to_id_names } ) {
        for my $id_name ( @{ $self->_groups_to_id_names->{$group} } ) {
            $ids_to_groups{$id_name} = $group;
        }
    }
    return \%ids_to_groups;
}

sub _builder__ids_to_groups {
    my ($self) = @_;
    return $self->_generate__ids_to_groups;
}

sub _build__output_fh {
    my ($self) = @_;
    open( my $fh, '>', $self->output_filename )
      or Bio::Roary::Exceptions::CouldntWriteToFile->throw(
        error => "Couldnt write output file:" . $self->output_filename );
    return $fh;
}

sub _build__filtered_gff_files {
    my ($self) = @_;
    my @gff_files = grep( /\.gff$/, @{ $self->gff_files } );
    return \@gff_files;
}

sub _build__ids_to_gene_names {
    my ($self) = @_;
    my %ids_to_gene_names;
    my %ids_to_product;
	my %ids_to_gene_size;
    for my $filename ( @{ $self->_filtered_gff_files } ) {
        my $gene_names_from_gff = Bio::Roary::GeneNamesFromGFF->new( gff_file => $filename );
        my %id_to_gene_lookup = %{ $gene_names_from_gff->ids_to_gene_name };
        @ids_to_gene_names{ keys %id_to_gene_lookup } = values %id_to_gene_lookup;

        my %id_to_product_lookup = %{ $gene_names_from_gff->ids_to_product };
        @ids_to_product{ keys %id_to_product_lookup } = values %id_to_product_lookup;
		
		my %ids_to_gene_size_lookup = %{ $gene_names_from_gff->ids_to_gene_size };
        @ids_to_gene_size{ keys %ids_to_gene_size_lookup } = values %ids_to_gene_size_lookup;
    }
    $self->_ids_to_product( \%ids_to_product );
	$self->_ids_to_gene_size( \%ids_to_gene_size );

    return \%ids_to_gene_names;
}

sub _build__ids_to_verbose_stats {
        my $self = shift;

        my @matches_hash = fgrep { /ID=/i } @{ $self->_filtered_gff_files };
        my @matches;
        foreach my $m ( @matches_hash ){
            push( @matches, values %{$m->{matches}} );
        }
        # chomp @matches;
        
        my %verbose;
        foreach my $line ( @matches ){
            my ( $id, $inf, $prod );
            if( $line =~ m/ID=["']?([^;"']+)["']?;?/i ){
                $id = $1;
            }
            else {
                next;
            }

            $inf = $1 if ( $line =~ m/inference=([^;]+);/ );
            $prod = $1 if ( $line =~ m/product=([^;]+)[;\n]/ );

            my %info = ( 'inference' => $inf, 'product' => $prod );
            $verbose{$id} = \%info;
        }
        return \%verbose;
}


sub consensus_product_for_id_names {
    my ( $self, $id_names ) = @_;
    my %product_freq;
    for my $id_name ( @{$id_names} ) {
        next unless ( defined( $self->_ids_to_product->{$id_name} ) );
        $product_freq{ $self->_ids_to_product->{$id_name} }++;
    }

    my @sorted_product_keys = sort { $product_freq{$b} <=> $product_freq{$a} } keys(%product_freq);

    if ( @sorted_product_keys > 0 ) {
        return $sorted_product_keys[0];
    }
    else {
        return '';
    }
}

sub _builder__groups_to_id_names {
    my ($self) = @_;
    my %groups_to_id_names;

    open( my $fh, $self->groups_filename )
      or Bio::Roary::Exceptions::FileNotFound->throw( error => "Group file not found:" . $self->groups_filename );
    while (<$fh>) {
        chomp;
        my $line = $_;
        if ( $line =~ /^(.+): (.+)$/ ) {
            my $group_name = $1;
            my $genes      = $2;
            my @elements   = split( /[\s\t]+/, $genes );
            $groups_to_id_names{$group_name} = \@elements;
        }
    }
    
    return \%groups_to_id_names;
}

sub _groups {
    my ($self) = @_;
    my @groups = keys %{ $self->_groups_to_id_names };
    return \@groups;
}

sub _ids_grouped_by_gene_name_for_group {
    my ( $self, $group_name ) = @_;
    my %gene_name_freq;
    for my $id_name ( @{ $self->_groups_to_id_names->{$group_name} } ) {
        if ( defined( $self->_ids_to_gene_names->{$id_name} ) && $self->_ids_to_gene_names->{$id_name} ne "" ) {
            push( @{ $gene_name_freq{ $self->_ids_to_gene_names->{$id_name} } }, $id_name );
        }
    }
    return \%gene_name_freq;
}

sub _consensus_gene_name_for_group {
    my ( $self, $group_name ) = @_;
    my $gene_name_freq = $self->_ids_grouped_by_gene_name_for_group($group_name);

    my @sorted_gene_names = sort { @{ $gene_name_freq->{$b} } <=> @{ $gene_name_freq->{$a} } } keys %{$gene_name_freq};
    if ( @sorted_gene_names > 0 ) {
        return shift(@sorted_gene_names);
    }
    else {
        return $group_name;
    }
}

sub _build_group_nucleotide_lengths
{
	my ($self) = @_;
	my %group_nucleotide_lengths;
    for my $group_name (keys %{ $self->_groups_to_id_names } )
    {
		my @gene_lengths;
		for my $gene_id (@{$self->_groups_to_id_names->{$group_name}})
		{
			my $current_gene_size = $self->_ids_to_gene_size->{$gene_id};
			next unless(defined($current_gene_size) );
			next if($current_gene_size < 1);
			push(@gene_lengths, $current_gene_size);
		}
		
		next if(@gene_lengths == 0);
		my $average_gene_size = (int((sum @gene_lengths)/@gene_lengths)) || 0;
		my $min_gene_size = (min @gene_lengths) || 0;
		my $max_gene_size = (max @gene_lengths) || 0;
		$group_nucleotide_lengths{$group_name} = {'min' => $min_gene_size, 'max' =>$max_gene_size , 'average' => $average_gene_size};
    }
	return \%group_nucleotide_lengths;
}

sub _generate_groups_to_consensus_gene_names {
    my ($self) = @_;
    my %groups_to_gene_names;
    my %gene_name_freq;
    my $group_prefix = $self->_group_default_prefix;

    # These are already annotated
    for my $group_name ( sort { @{ $self->_groups_to_id_names->{$b} } <=> @{ $self->_groups_to_id_names->{$a} } }
        keys %{ $self->_groups_to_id_names } )
    {
        next if ( $group_name =~ /$group_prefix/ );
        $groups_to_gene_names{$group_name} = $group_name;
    }

    for my $group_name ( sort { @{ $self->_groups_to_id_names->{$b} } <=> @{ $self->_groups_to_id_names->{$a} } }
        keys %{ $self->_groups_to_id_names } )
    {
        next unless ( $group_name =~ /$group_prefix/ );
        my $consensus_gene_name = $self->_consensus_gene_name_for_group($group_name);

        if ( defined( $gene_name_freq{$consensus_gene_name} ) ) {
            $groups_to_gene_names{$group_name} = $group_name;
        }
        else {
            $groups_to_gene_names{$group_name} = $consensus_gene_name;
            $gene_name_freq{$consensus_gene_name}++;
        }
    }
    return \%groups_to_gene_names;
}

sub _build__groups_to_consensus_gene_names {
    my ($self) = @_;
    return $self->_generate_groups_to_consensus_gene_names;
}

sub _build__number_of_files {
    my ($self) = @_;
    return @{ $self->gff_files };
}


sub _split_groups {
    my ($self) = @_;
     
    $self->_groups_to_consensus_gene_names( $self->_generate_groups_to_consensus_gene_names );
    $self->_ids_to_groups( $self->_generate__ids_to_groups );
}

sub _remove_ids_from_group {
    my ( $self, $ids_to_remove, $group ) = @_;

    my @remaining_ids = array_minus( @{ $self->_groups_to_id_names->{$group} }, @{ $ids_to_remove } );
    $self->_groups_to_id_names->{$group} = \@remaining_ids;
    if ( @{ $self->_groups_to_id_names->{$group} } == 0 ) {
        delete( $self->_groups_to_id_names->{$group} );
    }
}

sub reannotate {
    my ($self) = @_;

    $self->_split_groups;

    my %groups_to_id_names = %{ $self->_groups_to_id_names };
    for
      my $group_name ( sort { @{ $groups_to_id_names{$b} } <=> @{ $groups_to_id_names{$a} } } keys %groups_to_id_names )
    {
        my $consensus_gene_name = $self->_groups_to_consensus_gene_names->{$group_name};
        print { $self->_output_fh } $consensus_gene_name . ": "
          . join( "\t", @{ $self->_groups_to_id_names->{$group_name} } ) . "\n";
    }
    close( $self->_output_fh );
    return $self;
}

sub full_annotation {
    my ( $self, $group ) = @_;

    my @id_names = @{ $self->_groups_to_id_names->{$group} };

    my %product_freq;
    for my $id_name ( @id_names ) {
        next unless ( defined( $self->_ids_to_verbose_stats->{$id_name}->{'product'} ) );
        $product_freq{ $self->_ids_to_verbose_stats->{$id_name}->{'product'} }++;
    }

    my @sorted_product_keys = sort { $product_freq{$b} <=> $product_freq{$a} } keys(%product_freq);

    if ( @sorted_product_keys > 0 ) {
        return join('; ', @sorted_product_keys);
    }
    else {
        return '';
    }
    
}

sub inference {
    my ( $self, $group ) = @_;

    my @infs;
    foreach my $g ( @{ $self->_groups_to_id_names->{$group} } ){
        next unless ( defined  $self->_ids_to_verbose_stats->{$g}->{'inference'} );
        push( @infs, $self->_ids_to_verbose_stats->{$g}->{'inference'} );
    }

    # maybe make a consensus in the future?

    return $infs[0];
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
 