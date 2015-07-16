package Bio::Roary::CommandLine::Common;
# ABSTRACT: Common command line settings

=head1 SYNOPSIS

Common command line settings

   extends 'Bio::Roary::CommandLine::Common';

=cut

use Moose;
use FindBin;
use Log::Log4perl qw(:easy);

has 'logger'                  => ( is => 'ro', lazy => 1, builder => '_build_logger');

sub _build_logger
{
    my ($self) = @_;
    Log::Log4perl->easy_init(level => $ERROR);
    my $logger = get_logger();
    return $logger;
}


sub run {
	my ($self) = @_;
}

sub usage_text {
    my ($self) = @_;
	return "Usage text";
}

# add our included binaries to the END of the PATH
before 'run' => sub {
	my ($self) = @_;
	my $OPSYS = $^O;
	my $BINDIR = "$FindBin::RealBin/../binaries/$OPSYS";

    for my $dir ($BINDIR, $FindBin::RealBin) {
      if (-d $dir) {
        $ENV{PATH} .= ":$dir";
       }
  }
};

no Moose;
1;