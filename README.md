#Website
(http://sanger-pathogens.github.io/Roary)

#Roary the pan genome pipeline

Roary is a high speed stand alone pan genome pipeline, which takes annotated assemblies in GFF3 format (produced by Prokka) and calculates the pan genome.  Using a standard desktop PC, it can analyse datasets with thousands of samples, something which is computationally infeasible with existing methods, without compromising the quality of the results.  128 samples can be analysed in under 1 hour using 1 GB of RAM and a single processor. To perform this analysis using existing methods would take weeks and hundreds of GB of RAM.

##Input
Roary takes annotated assemblies as input in GFF3 format, such as those produced by [Prokka](http://www.vicbioinformatics.com/software.prokka.shtml).


##Installation - Ubuntu/Debian
Assuming you have root on your system, all the dependancies can be installed using apt and cpanm.

```
sudo apt-get install bedtools cd-hit ncbi-blast+ mcl muscle parallel cpanminus
sudo cpanm Bio::Roary
```   

##Installation - OSX using homebrew
Assuming you have homebrew setup and installed on your OSX system, tap the science keg and install the dependancies, then install the perl modules:

```
brew tap homebrew/science
brew install bedtools cd-hit blast mcl muscle parallel
cpanm Bio::Roary
```

##Installation - With bundled binaries

###Download
Download the latest software from 
https://github.com/sanger-pathogens/Roary/tarball/master

###Extract
Choose somewhere to put it, for example in your home directory (no root access required):

```
cd $HOME
tar zxvf sanger-pathogens-Roary-xxxxxx.tar.gz
ls Roary-*
```

###Add to your Environment
Add the following lines to your $HOME/.bashrc file, or to /etc/profile.d/roary.sh to make it available to all users:

```
export PATH=$PATH:$HOME/Roary-x.x.x/bin
export PERL5LIB=$PERL5LIB:$HOME/Roary-x.x.x/lib
```

###Install perl dependancies

```
cpanm Array::Utils BioPerl Exception::Class File::Find::Rule File::Grep File::Slurp::Tiny Graph Moose Moose::Role Text::CSV Log::Log4perl File::Which
```

#When things go wrong
###cdhit seg faults
Old versions of cdhit have a bug, so you need to use at least version 4.6.1.  The cdhit packages for Ubuntu 12.04 seem to be effected, so [installing from the source](http://cd-hit.org/) is the only option. 

###I installed the homebrew Kraken package and now theres an error when I run the tests or QC
Theres a bug and you'll need to [install it from source](https://ccb.jhu.edu/software/kraken/) on older versions of OSX (like Mountain Lion).  

###Why dont you bundle a Kraken database for the QC?
Its massive (2.7GB) and changes as RefSeq is updated.  The [authors](https://ccb.jhu.edu/software/kraken/) have prebuilt databases and details about how to make your own.


