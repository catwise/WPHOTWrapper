#! /bin/tcsh -fe

#===============================================================================================================================================================

set wrapperDir = $PWD
set startTime = `date '+%m/%d/%Y %H:%M:%S'`
echo
echo Wrapper Started at:
echo $startTime
echo
echo This Wrapper will wrap around and run WPHOTPMC
#echo ================================================================================================================
#echo WARNING\: Elijah is doing testing\/editing to this program \(Oct10 2017\). This script will not work propperly.
#echo ================================================================================================================
if ($# != 3) then
        #Error handling
        #Too many or too little arguments       
        echo "ERROR: not enough arguments:"
        echo "Parameters for wrapper must be in the order:"
        echo 1\) Option 1, 2, or 3 \(1 == Input directory, 2 == Input list, 3 == Single Tile\)
        echo 2\) Input directory or list
        echo 3\) Output directory
        echo "i.e. 'icore_wrapper_executable option InputDir/List OutputDir'"
        echo
        echo Exiting...
        exit
#Mode1
else if ($1 == 1) then
        goto Mode1
#Mode2
else if ($1 == 2) then
        goto Mode2
#Mode3 Single Tile Mode
else if ($1 == 3) then
	set ParentDir = $2
	set RadecID = $3
 	echo Parent Dir ==  $ParentDir
        echo Tile Name == $RadecID
        echo
        echo "Is this the correct Parent Directory  and Tile Name? (y/n)"
        set userInput = $<
 	#Error handling
        #if user input dir wrong
        if($userInput != "Y" && $userInput != "y") then
                echo Please execute program again with Parent Directory as the 2nd parameter and the Tile Name as your 3rd parameter
                #TODO actually throw an error instead of just outputing to stdout... output to stderr
                echo
                echo Exiting...
                exit
        endif
        #if directories dont exist, throw error
        if(! -d $ParentDir) then
                echo ERROR: $ParentDir doest not exist.
                echo
                echo Exiting...
                exit
        endif
	goto Mode3
else
        #Error handling
        #option 1/2/3 not second parameter. program exits.
        echo ERROR mode 1, 2, or 3 not selected
        echo
        echo Exiting...
	exit
endif

Mode1:
	goto Done
Mode2:
	goto Done

Mode3:
	set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
	set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
	set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/ 
	set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/

	#Error Checking
	if(! -d $UnWISEDir) then
                echo ERROR: $UnWISEDir does not exist.
                echo
                echo Exiting...
                exit
        endif
	if(! -d $CatWISEDir) then
                echo ERROR: $CatWISE does not exist.
                echo
                echo Exiting...
                exit
        endif 
	
	#TODO generate frames_list.tbl
	##***READ CAUTION***, the cname == root name == unwise-0657p151... thus, same as the "base" in frames_list.tbl 

	#automatically generates frames_list.tbl
	set rootname = unwise-$RadecID
	#print tbl header in frames_list.tbl
	echo "|  path              |      base     | b1 | b2 | b3 | b4 |" > ${wrapperDir}/frames_list.tbl
	echo "|   c                |       c       |  i |  i |  i |  i |" >> ${wrapperDir}/frames_list.tbl
	echo "|                    |" >> ${wrapperDir}/frames_list.tbl
	echo "|                    |" >> ${wrapperDir}/frames_list.tbl
	#print each epoch in frames_list.tbl
	set fullDir = ${TileDir}Full/
        foreach subDir ($TileDir*/)
		echo "Subdir == ${subDir}"
		echo "fullDir == ${fullDir}"
		if($subDir != ${fullDir}) then
			echo $subDir $rootname 1 1 0 0 >> ${wrapperDir}/frames_list.tbl
		endif
	end

	#replaces escape character on all existing "/"
	set editedUnWISEDir=`echo $UnWISEDir | sed 's/\//\\\//g'`
	set editedCatWISEDir=`echo $CatWISEDir | sed 's/\//\\\//g'`
	sed -i --follow-symlinks "16s/.*.*/set mdetfile = ${editedCatWISEDir}detlist.tbl/g" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes frames_list output location TODO Do I really need to keep the frames list?
        #sed -i --follow-symlinks "22s/.*.*/set set flist =  frames_list.tbl" ${wrapperDir}/wphot_wrapper_option-0 #for this tile, list of the epochs. Wphot-Wrapper needs to generate this.
        #changes image id to the tile name (RadecID)
        sed -i --follow-symlinks "22s/.*.*/set imageid = ${RadecID}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes psfdir
        sed -i --follow-symlinks "40s/.*.*/set psfdir = ${editedCatWISEDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh	
	#changes cname
	sed -i --follow-symlinks "47s/.*.*/set cname = ${editedUnWISEDir}\/$rootname/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes outdir
        sed -i --follow-symlinks "55s/.*.*/set outdir = ${editedCatWISEDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes verbose
        sed -i --follow-symlinks "61s/.*.*/set verbose = ${editedCatWISEDir}\/ProgramTerminalOutput\/wphot_output.txt/" ${wrapperDir}/wphot_wrapper_option-0.tcsh

	#Run WPHOT Option 0
	${wrapperDir}/wphot_wrapper_option-0.tcsh
	goto Done

Done:
echo WPHOTWrapper Done!
echo Removing wphot_wrapper_option-0.tcsh--follow-symlinks
rm -f wphot_wrapper_option-0.tcsh--follow-symlinks
set endTime = `date '+%m/%d/%Y %H:%M:%S'`
echo
echo Wrapper Ended at:
echo $endTime
