#Website
(http://sanger-pathogens.github.io/Roary)

#Roary the pan genome pipeline

[![Build Status](https://travis-ci.org/sanger-pathogens/Roary.svg?branch=master)](https://travis-ci.org/sanger-pathogens/Roary)

Roary is a high speed stand alone pan genome pipeline, which takes annotated assemblies in GFF3 format (produced by Prokka) and calculates the pan genome.  Using a standard desktop PC, it can analyse datasets with thousands of samples, something which is computationally infeasible with existing methods, without compromising the quality of the results.  128 samples can be analysed in under 1 hour using 1 GB of RAM and a single processor. To perform this analysis using existing methods would take weeks and hundreds of GB of RAM.

##Citation
    "Roary: Rapid large-scale prokaryote pan genome analysis",
    Andrew J. Page, Carla A. Cummins, Martin Hunt, Vanessa K. Wong, Sandra Reuter, Matthew T. G. Holden, Maria Fookes, Daniel Falush, Jacqueline A. Keane, Julian Parkhill,
    Bioinformatics, (2015). doi: http://dx.doi.org/10.1093/bioinformatics/btv421

##Read the paper
[Roary: Rapid large-scale prokaryote pan genome analysis](http://dx.doi.org/10.1093/bioinformatics/btv421)

##Input
Roary takes annotated assemblies as input in GFF3 format, such as those produced by [Prokka](https://github.com/tseemann/prokka/).  You should try and give each genome a unique prefix (--prefix option in prokka) so that the IDs are globally unique. Roary will fix any clashes, but it will be less intuitive than if you do it yourself.  Files downloaded from GenBank should already have unique IDs.


# Installation
Theres are a number of dependancies required for Roary, with instructions specific to the type of system you have:
* Ubuntu/Debian
* CentOS/RedHat
* Homebrew/Linuxbrew - OSX/Linux
* Bundled binaries - OSX/Linux
* Virtual Machine - OSX/Linux/Windows

##Ubuntu/Debian
Assuming you have root on your system, all the dependancies can be installed using apt and cpanm (only tested on Ubuntu 14.04).

```
sudo apt-get install bedtools cd-hit ncbi-blast+ mcl parallel cpanminus prank mafft exonerate fasttree
sudo cpanm -f Bio::Roary
```   

##CentOS/RedHat
To install the dependancies, the easiest way is through [linuxbrew](http://brew.sh/linuxbrew/), following the instructions for Fedora. Alternatively try the ./install_dependencies.sh script. 

```
brew tap homebrew/science
brew install bedtools cd-hit blast mcl parallel prank mafft exonerate fasttree cpanm
sudo cpanm -f Bio::Roary
```


###Older versions of Ubuntu/Debian (12.04 and below)
Follow the instructions for LinuxBrew. 

Alternatively, run this script from BASH, then copy and paste the last few lines into your BASH profile, as per the instructions.  Not all the packages Roary requires are available on older versions of Ubuntu/Debian or the versions dont support features Roary requires.  So this script will build them from source in the current working directory and install missing dependancies using apt and cpanm. This script is run automatically by our [continous integration server](https://travis-ci.org/andrewjpage/Roary) which runs on Ubuntu 12.04.
```
./install_dependencies.sh
```

##Homebrew/Linuxbrew - OSX/Linux
Assuming you have [homebrew](http://brew.sh/) (OSX) or [linuxbrew](http://brew.sh/linuxbrew/) (Linux) setup and installed on your system:

```
brew tap homebrew/science
brew install bedtools cd-hit blast mcl parallel prank mafft exonerate fasttree cpanm
sudo cpanm -f Bio::Roary
```

##Bundled binaries - OSX/Linux
As a last resort we have included precompiled binaries of the dependancies. They might work, if they dont, you'll need to install the dependancies from source. If your running an ancient version of Linux or OSX (more than 3 years since release) its unlikely to work.

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
sudo cpanm  Array::Utils Bio::Perl Exception::Class File::Basename File::Copy File::Find::Rule File::Grep File::Path File::Slurp::Tiny File::Spec File::Temp File::Which FindBin Getopt::Long Graph Graph::Writer::Dot List::Util Log::Log4perl Moose Moose::Role Text::CSV
```

##Virtual Machine - OSX/Linux/Windows
Roary wont run natively on Windows but we have created virtual machine which has all of the software setup, including Prokka, along with the test datasets from the paper. It is based on [Bio-Linux 8](http://environmentalomics.org/bio-linux/).  You need to first install [VirtualBox](https://www.virtualbox.org/), then load the virtual machine, using the 'File -> Import Appliance' menu option. The root password is 'manager'.

ftp://ftp.sanger.ac.uk/pub/pathogens/pathogens-vm/pathogens-vm.latest.ova

More importantly though, if your trying to do bioinformatics on Windows, your not going to get very far and you should seriously consider upgrading to Linux.

##Other versions of Linux
If none of the above options work, you'll have to install the depedancies from source or from your distributions packaging system.  You should probably ask your system administrator for assistance if you havent done this kind of thing before.

### Ancient versions of perl
The code will not work with perl 5.8 or below (pre-modern perl). 

#Versions of software we test against
* Perl 5.10, 5.14, 5.16, 5.18, 5.20
* cdhit 4.6.1
* ncbi blast+ 2.2.30
* mcl 14-137
* bedtools 2.20.1
* prank 130410
* GNU parallel 20130922, 20141022, 20150122

#When things go wrong
###cdhit seg faults
Old versions of cdhit have a bug, so you need to use at least version 4.6.1.  The cdhit packages for Ubuntu 12.04 seem to be effected, so [installing from the source](http://cd-hit.org/) is the only option. 

###I installed the homebrew Kraken package and now theres an error when I run the tests or QC
Theres a bug and you'll need to [install it from source](https://ccb.jhu.edu/software/kraken/) on older versions of OSX (like Mountain Lion).  

###Why dont you bundle a Kraken database for the QC?
Its massive (2.7GB) and changes as RefSeq is updated.  The [authors](https://ccb.jhu.edu/software/kraken/) have prebuilt databases and details about how to make your own.
