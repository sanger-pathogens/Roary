# Roary the pan genome pipeline
For instructions on how to use the software, the input format and output formats, please see [the Roary website](http://sanger-pathogens.github.io/Roary).

[![Build Status](https://travis-ci.org/sanger-pathogens/Roary.svg?branch=master)](https://travis-ci.org/sanger-pathogens/Roary)

Roary is a high speed stand alone pan genome pipeline, which takes annotated assemblies in GFF3 format (produced by Prokka) and calculates the pan genome.  Using a standard desktop PC, it can analyse datasets with thousands of samples, something which is computationally infeasible with existing methods, without compromising the quality of the results.  128 samples can be analysed in under 1 hour using 1 GB of RAM and a single processor. To perform this analysis using existing methods would take weeks and hundreds of GB of RAM.

## Citation
    "Roary: Rapid large-scale prokaryote pan genome analysis",
    Andrew J. Page, Carla A. Cummins, Martin Hunt, Vanessa K. Wong, Sandra Reuter, Matthew T. G. Holden, Maria Fookes, Daniel Falush, Jacqueline A. Keane, Julian Parkhill,
    Bioinformatics, (2015). doi: http://dx.doi.org/10.1093/bioinformatics/btv421
[Roary: Rapid large-scale prokaryote pan genome analysis](http://dx.doi.org/10.1093/bioinformatics/btv421)

# Installation
Theres are a number of dependancies required for Roary, with instructions specific to the type of system you have:
* Ubuntu/Debian
* CentOS/RedHat
* Homebrew/Linuxbrew - OSX/Linux
* Guix - Linux
* Virtual Machine - OSX/Linux/Windows
* Docker - OSX/Linux/Windows/Cloud
* Installing from source - OSX/Linux

If the installation fails please contact your system administrator. If you encounter a bug please let us know by emailing roary@sanger.ac.uk .

## Ubuntu/Debian
### Debian Testing
```
sudo apt-get install roary
```

### Ubuntu 14.04/16.04
All the dependancies can be installed using apt and cpanm. Root permissions are required. Ubuntu 16.04 contains a package for Roary but it is frozen at v3.6.0.

```
sudo apt-get install bedtools cd-hit ncbi-blast+ mcl parallel cpanminus prank mafft fasttree
sudo cpanm -f Bio::Roary
```

### Ubuntu 12.04
Some of the software versions in apt are quite old so follow the instructions for [LinuxBrew](http://brew.sh/linuxbrew/) below.

## CentOS/RedHat
To install the dependancies, the easiest way is to install [LinuxBrew](http://brew.sh/linuxbrew/) using the steps for Fedora, then follow the steps below for installing Roary on LinuxBrew.

## Homebrew/Linuxbrew - OSX/Linux
Assuming you have [homebrew](http://brew.sh/) (OSX) or [linuxbrew](http://brew.sh/linuxbrew/) (Linux) setup and installed on your system:

```
brew tap homebrew/science
brew install bedtools cd-hit blast mcl parallel prank mafft fasttree cpanm
sudo cpanm -f Bio::Roary
```

## GNU Guix
Roary is not included in version in [Guix](https://www.gnu.org/software/guix) 0.11.0 so `guix pull` is currently required before installation.
```
guix pull
guix package --install roary
```

## Virtual Machine - OSX/Linux/Windows
Roary wont run natively on Windows but we have created virtual machine which has all of the software setup, including Prokka, along with the test datasets from the paper. It is based on [Bio-Linux 8](http://environmentalomics.org/bio-linux/).  You need to first install [VirtualBox](https://www.virtualbox.org/), then load the virtual machine, using the 'File -> Import Appliance' menu option. The root password is 'manager'.

ftp://ftp.sanger.ac.uk/pub/pathogens/pathogens-vm/pathogens-vm.latest.ova

More importantly though, if your trying to do bioinformatics on Windows, your not going to get very far and you should seriously consider upgrading to Linux.

## Docker - OSX/Linux/Windows/Cloud
We have a docker container which gets automatically built from the latest version of Roary in Debian Med. To install it:

```
docker pull sangerpathogens/roary
```

To use it you would use a command such as this (substituting in your directories), where your GFF files are assumed to be stored in /home/ubuntu/data:
```
docker run --rm -it -v /home/ubuntu/data:/data sangerpathogens/roary roary -f /data /data/*.gff
```

## Installing from source (advanced Linux users only)
As a last resort you can install everything from source. This is for users with advanced Linux skills and we do not provide any support with this method since you have the skills to figure things out.
Download the latest software from (https://github.com/sanger-pathogens/Roary/tarball/master).

Choose somewhere to put it, for example in your home directory (no root access required):

```
cd $HOME
tar zxvf sanger-pathogens-Roary-xxxxxx.tar.gz
ls Roary-*
```

Add the following lines to your $HOME/.bashrc file, or to /etc/profile.d/roary.sh to make it available to all users:

```
export PATH=$PATH:$HOME/Roary-x.x.x/bin
export PERL5LIB=$PERL5LIB:$HOME/Roary-x.x.x/lib
```
Install the perl dependancies:

```
sudo cpanm  Array::Utils Bio::Perl Exception::Class File::Basename File::Copy File::Find::Rule File::Grep File::Path File::Slurper File::Spec File::Temp File::Which FindBin Getopt::Long Graph Graph::Writer::Dot List::Util Log::Log4perl Moose Moose::Role Text::CSV PerlIO::utf8_strict 
```
Install the external dependances either from source or from your packaging system:
```
bedtools cd-hit blast mcl GNUparallel prank mafft fasttree
```

## Ancient systems and versions of perl
The code will not work with perl 5.8 or below (pre-modern perl). We no longer test against 5.10 (released 2007). If your running a very old verison of Linux, your also in trouble.

# Versions of software we test against
* Perl 5.14, 5.16, 5.20, 5.24
* cdhit 4.6.1
* ncbi blast+ 2.4.0
* mcl 14-137
* bedtools 2.26.0
* prank 130410
* GNU parallel 20130922, 20160722, 20150122
* FastTree 2.1.9
