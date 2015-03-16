#!/usr/bin/env python

#
# $Id: revtrans.py,v 1.10 2005/06/09 09:58:54 raz Exp $
#
#    Copyright 2002,2003,2004,2005 Rasmus Wernersson, Technical University of Denmark
#
#    This file is part of RevTrans.
#
#    RevTrans is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    RevTrans is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with RevTrans; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#


"""

NAME
	revtrans - performs a reverse translation of a peptide alignment

SYNOPSIS
	revtrans dnafile pepfile [-v] [-h] [-gapin chars] [-gapout char] 
	 [-Idna format] [-Ipep format] [-mtx tablename/file] [-match method] 
	 [-O format] [outfile] 

DESCRIPTION
       Reads a set of aligned peptide sequences from pepfile and uses
       the corresponding DNA sequences from dnafile to construct a
       reverse translated version of the alignment.
       
       By default the input file formats are auto detected and the 
       corresponding DNA and peptide sequences is found by translation.

       In the typical case this means that the user only need to 
       supply the DNA and peptide sequences, and may safely ignore
       the more advanced options. E.g :
       
	       revtrans kinases.dna.fsa kinases.prot.aln 
       
       The final alignment is written to STDOUT or outfile if specified,
       and is by default in FASTA format.

OPTIONS
	-h
		Help. Print this help information.
	
	-gapin chars
		Specify gap characters in the input sequences.
		Default is '.-~'
	
	-gapout	char
		Specify which character should be used for gaps in the
		output.
		Default is '-'
		
	-Idna format
		Specify format of the input DNA file.
		Valid formats are: auto (default), fasta, msf and aln

	-Ipep format
		Specify format of the input peptide file.
		Valid formats are: auto (default), fasta, msf and aln

	-O format
		Specify format of the output file.
		Valid formats are: fasta (default), msf and aln
		
	-mtx tablename/file
		Use alternative translation matrix instead of the build-in
		Standard Genetic Code for translation.
		
		If "tablename" is 1-6,9-16 or 21-23 one of the alternative 
		translation tables defined by the NCBI taxonomy group will be 
		used.
		
		Briefly, the following tables are defined:
		-----------------------------------------
		 1: The Standard Code 
		 2: The Vertebrate Mitochondrial Code 
		 3: The Yeast Mitochondrial Code 
		 4: The Mold, Protozoan, and Coelenterate Mitochondrial Code 
		    and the Mycoplasma/Spiroplasma Code 
		 5: The Invertebrate Mitochondrial Code 
		 6: The Ciliate, Dasycladacean and Hexamita Nuclear Code 
		 9: The Echinoderm and Flatworm Mitochondrial Code 
		10: The Euplotid Nuclear Code 
		11: The Bacterial and Plant Plastid Code 
		12: The Alternative Yeast Nuclear Code 
		13: The Ascidian Mitochondrial Code 
		14: The Alternative Flatworm Mitochondrial Code 
		15: Blepharisma Nuclear Code 
		16: Chlorophycean Mitochondrial Code 
		21: Trematode Mitochondrial Code 
		22: Scenedesmus obliquus mitochondrial Code 
		23: Thraustochytrium Mitochondrial Code 
		
		See http://www.ncbi.nlm.nih.gov/Taxonomy [Genetic Codes]
		for a detailed description. Please notice that the table
		of start codons is also used (see the -allinternal option
		below for details).
		
		If a filename is supplied the translation table is read from
		file instead. 
		
		The file should contain one line per codon in the format:
		
		codon<whitespace>aa-single letter code
		
		All 64 codons must be included. Stop codons is specified 
		by "*". T and U is interchangeable. Blank lines and lines
		starting with "#" are ignored.
		
		See the "gcMitVertebrate.mtx" file in the RevTrans source
		distribution for a well documented example.
		
	-allinternal
		By default the very first codon in each sequences is assumed
		to be the initial codon on the transcript. This means certain
		non-methionine codons actually codes for metionine at this 
		position. For example "TTG" in the standard genetic code (see
		above).
		
		Selecting this option treats all codons as internal codons.	
		
	-readthroughstop
		Allow the translation to continue after a stop codon is reached.
		The stop codon will be marked as "*".
		
		Be careful that stop codons have been addressed in the same manner
		in the input peptide alignment.		
			
	-match method
		Specify how to match the corresponding DNA and peptide 
		sequences. Valid methods are: trans (default), name and pos.
		
		Please note that both DNA and peptide sequence should have 
		unique names, regardless of the matching method. 
		
		trans:
			Match sequences by translation. The DNA sequences are
			translated using the standard genetic code (default)
			or an alternative translation matrix if the -mtx
			option is used.
			
		name:
			Match sequences by name. Please note that for FASTA 
			files everything after the ">" is considered the
			sequence name. 
			
		pos:
			Match by position. The sequence are matched by position
			in the files (first DNA sequence with first peptide
			sequence etc.).			
	-v
		Verbose. Print extra information about files, sequences
		and the progress in general to STDERR.
		
		The verbose level can be set to three degrees of
		detail.
		
		-v:   verbose level 1
			Info about files, number of sequences read etc.
			Use this as the first try if something needs
			investigation.
			
		-vv:  verbose level 2
			As level 1 + 
			Print detailed info about all the sequence names.
			
		-vvv: verbose level 3
			As level 2 +
			Do a sanity check on the degapped length of the
			sequences. Warn if the sizes do not match.
			
AUTHOR
	Rasmus Wernersson, raz@cbs.dtu.dk
	September 2002, February 2003, July 2004, April 2005

FILES
	revtrans.py, mod_translate.py, mod_seqfiles.py, 
	ncbi_genetic_codes.py
	
WEB PAGE
	http://www.cbs.dtu.dk/services/RevTrans/
	
REFERENCE
	Rasmus Wernersson and Anders Gorm Pedersen. 
	RevTrans - Constructing alignments of coding DNA from aligned amino 
	acid sequences.
	Nucl. Acids Res., 2003, 31(13), 3537-3539.

"""

import sys,string,mod_translate,mod_seqfiles


#Full IUPAC alphabet for peptide and DNA
alphaDNA = "ACGTRYMKWSBDHVN" 
alphaDNA += alphaDNA.lower()

alphaPEP = "ARNDCQEGHILKMFPSTWYVBZX*"
alphaPEP += alphaPEP.lower()
	 

def degap(s,gapin):
	result = []
	for c in s:
		if not c in gapin: result.append(c)
	return string.join(result,"")
	
def trim(s,alphabet):
	result = []
	for c in s:
		if c in alphabet: result.append(c)
	return string.join(result,"")
	
def trimseqs(seqs,alphabet):
	for key in seqs.keys():
		s,n = seqs[key]
		#s = s.upper()
		seqs[key] = (trim(s,alphabet) , n)
	
def matchtrans(dnaseqs,pepseqs,gapin,verbose,mtx,allinternal,readthroughstop):
	dnaref = {}
	dnaref_extra = {}
	result = {}
	
	# NOTICE:     We need the handle the situation where more than one DNA
	#             sequence translates to the same peptide sequence.
	#
	# ASSUMPTION: Identical peptide sequences will align exactly the same
	#             way. 
	#
	#
	# EXAMPLE:
	#
	#             dnaSeq17 -> pepSeq17
	#             dnaSeq32 -> pepSeq32   
	#
	#             *) dnaSeq17 and dnaSeq32 differs by a few nucleotides
	# 
	#             *) pepSeq17 and pepSeq32 are exactly the same
	#
	#             Given the assmuption mentioned above, it does NOT
	#             matter if dnaSeq17 gets paired with pepSeq32
	 
	for key in dnaseqs.keys():
		dna,note = dnaseqs[key]
		dna = degap(dna,gapin)
		newpep = mod_translate.translate(dna,mtx,not allinternal,readthroughstop)
		
		# Strip terminal stop-codon
		if newpep.endswith("*"):
			newpep = newpep[:-1]
		
		if verbose > 2:
			warn("DNA sequence "+key+" translated to:\n"+newpep);
		
		if dnaref.has_key(newpep):
			dnaref_extra[key] = newpep
		else:
			dnaref[newpep] = key
			
	for key in pepseqs.keys():
	 	pep,note = pepseqs[key]
		pep = degap(pep,gapin).upper()

		# Strip terminal stop-codon
		if pep.endswith("*"):
			pep = pep[:-1]
		
		if verbose > 2:
			warn("Pep sequence "+key+" degapped: \n"+pep);
		
		if dnaref.has_key(pep):
			result[key] = dnaref.pop(pep)
		else:
			for dnakey in dnaref_extra.keys():
				if pep == dnaref_extra[dnakey]:
					result[key] = dnakey
					dnaref_extra.pop(dnakey)
					break
					
	return result

def matchname(dnaseqs,pepseqs):
	result = {}
	for key in pepseqs.keys():
		if key in dnaseqs.keys():
			result[key] = key
	return result
	
def matchpos(dnaseqs,pepseqs):
	result = {}
	dnakeys = dnaseqs.keys()
	i = 0
	for key in pepseqs.keys():
		if i < len(dnakeys):
			result[key] = dnakeys[i]
			i += 1
	return result
		
def revtrans(dnaseqs,pepseqs,crossref,gapin,gapout,verbose):
	if verbose:
		warn("gapin: '"+gapin+"'")
		warn("gapout: '"+gapout+"'")
	
	newdnaseqs = {}
	error = 0
	for key in pepseqs.keys():
		try:
			# Find the corresponding sequences
			dna, pep, newdna = "","",""  # Just in the case of an exception
			if not key in crossref.keys():
				warn("No cross-reference, skipping peptide sequence "+key)
				continue
#			print key,crossref[key]
			dna,noted = dnaseqs[crossref[key]]
#			dnaName = d_dnames[dna]
			dnaName = crossref[key]
			
			#print dna
			dna = degap(dna,gapin)
			pep,notep = pepseqs[key]
			newdna = ""
			dnap = 0
	
			# Extra sanity check if verbose is 3+
			# Important: Is not intelligent enough to realize that
			# the DNA seq may be 3 bp longer (stop codon) than
			# expected.
			if verbose > 2:
				degapped = degap(pep,gapin)
				if (len(degapped)*3) != len(dna):
					warn("Warning:\n"+key+": size mismatch")
					warn("Len DNA:"+str(len(dna)))
					warn("Len pep:"+str(len(pep)))
					warn("Len pep degapped:"+str(len(degapped))+" *3:"+str(len(degapped)*3))
				
			# Do the reverse translation for this seq			
			l_dna = []
			for i in range(0,len(pep)):
				c = pep[i]
				if c in gapin:
					l_dna.append(gapout * 3)
				else:
					# Extract codon - keep case from the amino acid
					codon = dna[dnap:dnap+3]
					if c.isupper():
						codon = codon.upper()
					else:
						codon = codon.lower()
						
					l_dna.append(codon)
					dnap = dnap +3
			
			# Everything's cool - add the new seq to the result
			newdna = string.join(l_dna,"")
#			newdnaseqs[key] = (newdna,noted)
			newdnaseqs[dnaName] = (newdna,noted)
		except:
			if verbose:
				warn("Error rev-translating seq:"+key)
				warn("\nLen dna:"+str(len(dna))+" pep:"+str(len(pep))+" newdna:"+str(len(newdna))+"\n")
			error = error +1
	return (newdnaseqs,error)
	
def argerr(arg):
	warn("Error:\nThe parameter "+arg+" must be followed by a value.\n")
	sys.exit(1)
	
def warn(msg):
	sys.stderr.write(msg+"\n")		
#
# Notice (2005): All command-line option really should be processed by using the "optparse" module.
# However, since we need to retain backward compability with previous versions of RevTrans
# (which were written uning Python 2.0), it is problematic. For now really big changes 
# will have to wait, and new options will be processed using the current system.
#
def main():
	# Set defaults
	verbose  = 0
	gapin    = "-.~"
	gapout   = "-"
	outfile  = ""
	Idna     = "auto"
	Ipep     = "auto"
	outform  = "fasta"
	matchmet = "trans"
	mtx_file = ""
	mtx      = None
	allinternal = False
	readthroughstop = False
	
	# Quick sanity check
	if len(sys.argv)<3:
		print __doc__
		sys.exit(1)
		
	# Process arguments
	dnafile = ""
	pepfile = ""
	
	argv = sys.argv[1:]
	while (len(argv)>0):
		arg = argv[0]
		
		if arg == "-h" :
			print __doc__
			sys.exit(0)
		
		if arg == "-v"     : verbose = 1
		if arg == "-vv"    : verbose = 2
		if arg == "-vvv"   : verbose = 3
		
		if arg == "-match" :
			if len(argv) == 0: argerr("-match")
			matchmet = argv[1]
			argv = argv[2:]
			continue

		if arg == "-gapin" :
			if len(argv) == 0: argerr("-gapin")
			gapin = argv[1]
			argv = argv[2:]
			continue
			
		if arg == "-gapout" :
			if len(argv) == 0: argerr("-gapout")
			gapout = argv[1][0]			# Use only the first char
			argv = argv[2:]
			continue
	
		if arg == "-Idna" :
			if len(argv) == 0: argerr("-Idna")
			Idna = (argv[1]).lower()
			argv = argv[2:]
			continue
			
		if arg == "-Ipep" :
			if len(argv) == 0: argerr("-Ipep")
			Ipep = (argv[1]).lower()
			argv = argv[2:]
			continue	
				
		if arg == "-O" :
			if len(argv) == 0: argerr("-O")
			outform = (argv[1]).lower()
			argv = argv[2:]
			continue
			
		if arg == "-mtx" :
			if len(argv) == 0: argerr("-mtx")
			mtx_file = argv[1]
			argv = argv[2:]
			continue
			
		if arg == "-allinternal":
			allinternal = True
			
		if arg == "-readthroughstop":
			readthroughstop = True			

		if arg[0] != "-":
			if   dnafile == "" : dnafile = arg
			elif pepfile == "" : pepfile = arg
			else               : outfile = arg						
		
		argv = argv[1:]
	
	# Output extra info if requested
	if verbose:
		warn("verbose level: "+str(verbose))
		warn("dnafile:    "+dnafile+" [format:"+Idna+"]")
		warn("pepfile:    "+pepfile+" [format:"+Ipep+"]")
		if outfile : 
			warn("outfile: "+outfile)
		else       : 
			warn("outfile: None - writing to STDOUT")
		warn("out format:  "+outform)
		warn("Mtxfile:     "+mtx_file)
	
	# Read input files
	try:	
		if Idna == "auto": 
			Idna = mod_seqfiles.autotype(dnafile)
			if verbose: warn("DNA file format appears to be......: "+Idna)
			
		dnaseqs = mod_seqfiles.readfile(dnafile,Idna)
		if verbose: warn("#DNA entries read: "+str(len(dnaseqs)))

		if Ipep == "auto": 
			Ipep = mod_seqfiles.autotype(pepfile)
			if verbose: warn("Peptide file format appears to be..: "+Ipep)

		pepseqs = mod_seqfiles.readfile(pepfile,Ipep)
		if verbose: warn("#pep entries read: "+str(len(pepseqs)))
		
		#if 1:
		if len(dnaseqs) == 0 or len(pepseqs) == 0:
			warn("Error: Bad input.")
			warn("Dna sequences read: "+str(len(dnaseqs)))
			warn("peptide sequence read: "+str(len(pepseqs)))
			sys.exit(1)
			
		if mtx_file:
			try:
				mtx = mod_translate.parseMatrixFile(mtx_file)	
			except:
				warn("Invalid translation matrix: "+mtx_file)
				sys.exit(1)

	except Exception,msg:
		warn("Error reading input files: "+str(msg))
		warn("DNA File type: "+Idna)
		warn("Pep File type: "+Ipep)
		sys.exit(1)
		
	# Remove illegal characters
	trimseqs(dnaseqs,alphaDNA)
	trimseqs(pepseqs,alphaPEP + gapin)

	# Bit of extra info? 
	if verbose > 1:
		warn("DNA names ["+str(len(dnaseqs.keys()))+"] :")
		for key in dnaseqs.keys(): warn(key)
		warn("..")
		
		warn("pep names ["+str(len(pepseqs.keys()))+"] :")
		for key in pepseqs.keys(): warn(key)
		warn("..")

	if verbose:
		warn("Matching DNA and peptide sequences by: "+matchmet)
	
	# Establish cross-references
	if   matchmet == "name":  crossref = matchname(dnaseqs,pepseqs)
	elif matchmet == "pos":   crossref = matchpos(dnaseqs,pepseqs)
	elif matchmet == "trans": crossref = matchtrans(dnaseqs,pepseqs,gapin,verbose,mtx,allinternal,readthroughstop)
	else:
		warn('Match method "'+matchmet+'" not known.')
		sys.exit(1) 
	
	if len(crossref.keys()) <> len(dnaseqs.keys()) <> len(dnaseqs.keys()):
		warn ("Warning: Not all DNA and peptide sequences could be matched.")
		warn (str(len(crossref.keys())+" crossreference(s) could be established."))
	
	if verbose > 1:
		warn("Cross references: (Pep/DNA) sequence names")
		for key in crossref.keys():
			warn(key+" / "+crossref[key]) 

	# Do the reverse translation
	newdnaseqs, error = revtrans(dnaseqs,pepseqs,crossref,gapin,gapout,verbose)
	
	if verbose: warn("#rev-trans DNA entries: "+str(len(newdnaseqs.keys())))
	
	if (error > 0):
		warn ("# errors:"+str(error)+" aborting ...")
		sys.exit(1)
		
	# Output the result
	try:
		if outfile != "": out_stream = open(outfile,"w")
		else:             out_stream = sys.stdout
		
		mod_seqfiles.writestream(out_stream,newdnaseqs,outform,"N")
		
	except Exception, msg:
		warn("Failed to write output."+str(msg))
		if outfile: warn("outfile: "+outfile)
		sys.exit(1)
		
if __name__ == "__main__":
	main()
