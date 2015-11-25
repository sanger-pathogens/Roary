package Bio::Roary::External::CheckTools;

# ABSTRACT: Check external executables are available and are the correct version

=head1 SYNOPSIS
Functionality borrowed from PROKKA by Torsten Seemann.
Check external executables are available and are the correct version

   use Bio::Roary::External::CheckTools;
   
   my $obj = Bio::Roary::External::CheckTools->new();
   $obj->check_all_tools;

=cut

use Moose;
use File::Spec;
use Log::Log4perl qw(:easy);
has 'logger' => ( is => 'ro', lazy => 1, builder => '_build_logger' );

sub _build_logger {
    my ($self) = @_;
    Log::Log4perl->easy_init($DEBUG);
    my $logger = get_logger();
    return $logger;
}

my $BIDEC = '(\d+\.\d+)';    # pattern of NN.NN for versions that can be compared

my %tools = (
    'parallel' => {
        GETVER => "parallel --version | grep '^GNU parallel 2'",
        REGEXP => qr/GNU parallel (\d+)/,
        MINVER => "20130422",
        NEEDED => 1,
    },
    'blastp' => {
        GETVER => "blastp -version",
        REGEXP => qr/blastp:\s+(\d+\.\d+\.\d+)/,
        NEEDED => 1,
    },
    'makeblastdb' => {
        GETVER => "makeblastdb -version",
        REGEXP => qr/makeblastdb:\s+(\d+\.\d+\.\d+)/,
        NEEDED => 1,
    },
    'mcl' => {
        GETVER => "mcl --version | head -n 1",
        REGEXP => qr/(\d+\-\d+)/,
        NEEDED => 1,
    },
    'bedtools' => {
        GETVER => "bedtools --version",
        REGEXP => qr/bedtools v($BIDEC)/,
        MINVER => "2.1",
        NEEDED => 1,
    },
    'mafft' => {
        GETVER => "mafft --version < /dev/null 2>&1",
        REGEXP => qr/v($BIDEC) /,
        NEEDED => 1,
    },
    'kraken' => {
        GETVER => "kraken --version | head -n 1",
        REGEXP => qr/Kraken version kraken-(\d+\.\d+\.\d+.*)/,
        NEEDED => 0,
    },
    'kraken-report' => {
        GETVER => "kraken-report --version | head -n 1",
        REGEXP => qr/Kraken version kraken-(\d+\.\d+\.\d+.*)/,
        NEEDED => 0,
    },
	'Rscript'  => {
        GETVER => "Rscript --version 2>&1 | head -n 1",
        REGEXP => qr/R scripting front-end version ($BIDEC)/,
		MINVER => "3",
        NEEDED => 0,
    },

    # prank version also performs an update check so cant use it
    'prank' => { NEEDED => 1 },

    # now just the standard unix tools we need
    'grep' => { NEEDED => 1 },
    'sed'  => { NEEDED => 1 },
    'awk'  => { NEEDED => 1 },
	
);

my %cdhit_tools = (
    'cdhit' => {
        GETVER => "cdhit -h | grep 'CD-HIT version'",
        REGEXP => qr/version ($BIDEC) /,
        MINVER => "4.6",
    },
    'cd-hit' => {
        GETVER => "cd-hit -h | grep 'CD-HIT version'",
        REGEXP => qr/version ($BIDEC) /,
        MINVER => "4.6",
    }
);

my %fasttree_tools = (
    'fasttree' => {
        GETVER => "fasttree 2>&1 | head -n 1",
        REGEXP => qr/Usage for FastTree version ($BIDEC)/,
    },
    'FastTree' => {
        GETVER => "FastTree 2>&1 | head -n 1",
        REGEXP => qr/Usage for FastTree version ($BIDEC)/,
    }
);

sub which_tool_exec {
    my ( $self, $alt_tools ) = @_;
    for my $toolname ( sort keys %{$alt_tools} ) {
        my $fp = $self->find_exe($toolname);
        return $toolname if $fp;
    }
    $self->logger->error( "Required tool missing. Can't find one of " . join( '/', keys %{$alt_tools} ) . " in your \$PATH." );
    return undef;
}

sub check_tool {
    my ( $self, $toolname ) = @_;
    my $t  = $tools{$toolname};
    my $fp = $self->find_exe($toolname);
    $self->logger->error("ERROR: Can't find required '$toolname' in your \$PATH")     if !$fp and $t->{NEEDED};
    $self->logger->error("Optional tool '$toolname' not found in your \$PATH") if !$fp and !$t->{NEEDED};

    if ($fp) {
        $t->{HAVE} = $fp;
        $self->logger->warn("Looking for '$toolname' - found $fp");
        if ( $t->{GETVER} ) {
            my ($s) = qx($t->{GETVER});
            if ( defined $s ) {
                $s =~ $t->{REGEXP};
                $t->{VERSION} = $1 if defined $1;
                $self->logger->warn("Determined $toolname version is $t->{VERSION}");
                if ( defined $t->{MINVER} and $t->{VERSION} < $t->{MINVER} ) {
                    $self->logger->error("Roary needs $toolname $t->{MINVER} or higher. Please upgrade and try again.");
                }
                if ( defined $t->{MAXVER} and $t->{VERSION} > $t->{MAXVER} ) {
                    $self->logger->error(
                        "Roary needs a version of $toolname between $t->{MINVER} and $t->{MAXVER}. Please downgrade and try again.");
                }
            }
            else {
                $self->logger->error( "Could not determine version of $toolname - please install version ", $t->{MINVER}, " or higher" )
                  ;    # FIXME: or less <= MAXVER if given
            }
        }
    }
}

sub check_all_tools {
    my ($self) = @_;
    $ENV{"GREP_OPTIONS"} = '';    # --colour => version grep fails (Issue #117)
    for my $toolname ( sort keys %tools ) {
        $self->check_tool($toolname);
    }
	
    my $cdhit = $self->which_tool_exec( \%cdhit_tools );
    if ($cdhit) {
        $tools{$cdhit} = $cdhit_tools{$cdhit};
        $self->check_tool($cdhit);
    }

    my $fasttree = $self->which_tool_exec( \%fasttree_tools );
    if ($fasttree) {
        $tools{$fasttree} = $fasttree_tools{$fasttree};
        $self->check_tool($fasttree);
    }

    return $self;
}

sub find_exe {
    my ( $self, $bin ) = @_;
    for my $dir ( File::Spec->path ) {
        my $exe = File::Spec->catfile( $dir, $bin );
        return $exe if -x $exe;
    }
    return;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
