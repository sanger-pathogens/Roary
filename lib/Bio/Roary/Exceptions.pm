package Bio::Roary::Exceptions;
# ABSTRACT: Exceptions for input data 

=head1 SYNOPSIS

Exceptions for input data 

=cut

use strict; use warnings;
use Exception::Class (
    'Bio::Roary::Exceptions::FileNotFound'   => { description => 'Couldnt open the file' },
    'Bio::Roary::Exceptions::CouldntWriteToFile'   => { description => 'Couldnt open the file for writing' },
);  

1;
