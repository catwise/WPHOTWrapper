#! /bin/tcsh -f

#  shell script that runs WPHotpmc
#  T. Jarrett ; June 25, 2017


###  these will not change during processing (one-time change only)

set wphot = /Volumes/CatWISE1/CatWISEDev/WPHOT/WPHotpmc #wphot binary, this is the updated wphote as of nov21, 2017

set namelist = /Volumes/CatWISE1/CatWISEDev/WPHOT/nl.WPHot_unwise 


#### MDET (this will change every time)

set mdetfile = /Volumes/CatWISE1/fmarocco/PipelineTest/CatWISE/043/0438p030/Full/detlist.tbl

###### Frame parameters  (file names here will likely change)
#CHANGE
set flist =  /Volumes/CatWISE1/fmarocco/PipelineTest/CatWISE/043/0438p030//frames_list.tbl

set imageid = 0438p030

set ftype = m #KEEP need to hard code, make sure MDET wrapper and WPHOT wrapper does -m-

set fint = img #KEEP

set func = std #KEEP

set fcov = n

####  PSF parameters  (likely will change, depending on scan angles, etc)

#  /Volumes/CatWISE1/jwf/COSMOS_PSFs/ (option-0 wpro PSFs and awaic PSFs for the COSMOS tile)
#  /Volumes/CatWISE1/jwf/COSMOS_PSFs/asce/ (option-1 ascending wpro PSFs for the COSMOS tile)
#  /Volumes/CatWISE1/jwf/COSMOS_PSFs/desc/ (option-1 descending wpro PSFs for the COSMOS tile)

#set psfdir = /Volumes/CatWISE1/jwf/COSMOS_PSFs
#CHANGE
set psfdir = /Volumes/CatWISE1/fmarocco/PipelineTest/CatWISE/043/0438p030/Full/

set psfname = unWISE

####  Coadd parameters  (coadd name will change with every set) *** CAUTION -- you need to add the root name at the end of the path

#CHANGE
set cname = /Volumes/CatWISE1/fmarocco/PipelineTest/UnWISE/043/0438p030//unwise-0438p030

set ctype = u


#### output directories & file names 

#CHANGE
set outdir = /Volumes/CatWISE1/fmarocco/PipelineTest/CatWISE/043/0438p030/Full/
mkdir -p $outdir

#CHANGE
set outname = /Volumes/CatWISE1/fmarocco/PipelineTest/CatWISE/043/0438p030/Full//mdex_STD-msk.tbl
set metaname = /Volumes/CatWISE1/fmarocco/PipelineTest/CatWISE/043/0438p030/Full//meta_STD-msk.tbl
set verbose = /Volumes/CatWISE1/fmarocco/PipelineTest/CatWISE/043/0438p030/Full//ProgramTerminalOutput/wphot_output.txt

set outQAdir =  $outdir/QA 
mkdir -p $outQAdir


## copy some of the inputs to the outdir for the record
rsync -auv $flist $outdir #not needed
rsync -auv $namelist $outdir #not needed

########################################  run the command line
echo ' '

echo $wphot -namlis  $namelist \
-mdettab $mdetfile \
-mdex mdet \
-imageid $imageid  \
-ifile $flist \
-level $ftype -int $fint -unc $func -cov $fcov  \
-calpsfdir $psfdir \
-calbname $psfname \
-calgridszX 1  -calgridszY 1  \
-coadd  $cname \
-clevel $ctype \
-qadir $outQAdir \
-ofile $outname \
-meta $metaname 

echo 'begin: '
date
echo 'running ... standby ...'

echo ' ' #binary call for wphot
($wphot -namlis  $namelist \
-mdettab $mdetfile \
-mdex mdet \
-imageid $imageid  \
-ifile $flist \
-level $ftype -int $fint -unc $func -cov $fcov  \
-calpsfdir $psfdir \
-calbname $psfname \
-calgridszX 1  -calgridszY 1 \
-coadd  $cname \
-clevel $ctype \
-qadir $outQAdir \
-ofile $outname \
-meta $metaname -v >& $verbose) 

echo ' '
echo 'finished ; see '$verbose
date

