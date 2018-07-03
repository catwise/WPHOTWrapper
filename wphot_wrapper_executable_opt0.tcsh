#! /bin/tcsh -f

#===============================================================================================================================================================

set wrapperDir = $PWD
set startTime = `date '+%m/%d/%Y %H:%M:%S'`
echo
echo Wrapper Started at:
echo $startTime
echo 
echo Version 2.07 B80621
echo
echo This Wrapper will wrap around and run WPHOTPMC

#check hyphenated argument
@ i = 0
set arg_nl = ""
set rsyncSet = "false"
while ($i < $# + 1)
     #user input nameslist -nl argument
     if("$argv[$i]" == "-nl") then
        @ temp = $i + 1
        if($temp < $# + 1) then
                if($argv[$temp] != "") then
                        set arg_nl = $argv[$temp]
                        echo Custom nameslist == $arg_nl
                else
                        echo please enter nameslist after '-nl'
                endif
        else
                echo please enter nameslist after '-nl'
        endif
      else if("$argv[$i]" == "-rsync") then
        echo Argument "-rsync" detected. Will rsync Tyto, Otus, and Athene.
        set rsyncSet = "true"
      endif
      @ i +=  1
end


if ($# < 2) then #($# != 2 && $# != 3) then
        #Error handling
        #Too many or too little arguments       
        echo ""
        echo "ERROR: not enough arguments:"
        echo Mode 1 call:
        echo ./wphot_wrapper_executable_opt0.tcsh 1 ParentDir/
        echo Mode 2 call:
        echo ./wphot_wrapper_executable_opt0.tcsh 2 inputList.txt ParentDir/
        echo Mode 3 call:
        echo ./wphot_wrapper_executable_opt0.tcsh 3 ParentDir/ TileName
        echo
        echo Exiting...
        exit
#Mode1
else if ($# == 2 && $1 == 1) then
        set ParentDir = $2
       # set OutputsDir = $3
        echo Parent directory ==  $ParentDir
       # echo Outputs directory == $OutputsDir
        echo "Is this the correct Parent directory? (y/n)"
        set userInput = $<

        #Error handling
        #if user input dir wrong
        if($userInput != "Y" && $userInput != "y") then
                echo Please execute program again with full Input Directory path as the 2nd parameter and the Ouput Directory path as your 3rd parameter
                #TODO actually throw an error instead of just outputing to stdout... output to stderr
                echo
                echo Exiting...
                exit
        endif
        #if directories dont exist, throw error
        if(! -d $ParentDir) then
                echo ERROR: Input Directory $ParentDir doest not exist.
                echo
                echo Exiting...
                exit
        endif
	goto Mode1
#Mode2
else if ($1 == 2) then
        set InputsList = $3
        set ParentDir = $2
        echo Inputs list ==  $InputsList
        echo Parent directory == $ParentDir
        echo
        echo "Is this the correct input list and Parent directory? (y/n)"
        set userInput = $<
    
    #Error handling
        #if user input dir wrong
        if($userInput != "Y" && $userInput != "y") then
                echo Please execute program again with full Input List file as the 2nd parameter and the Parent Directory path as your 3rd parameter
                #TODO actually throw an error instead of just outputing to stdout... output to stderr
                echo
                echo Exiting...
                exit
        endif
        #if directories dont exist, throw error
        if(! -f $InputsList) then
                echo ERROR: Input List file $InputsDir doest not exist.
                echo
                echo Exiting...
                exit
        endif
        if (! -d $ParentDir) then
                echo ERROR: Parent Directory $ParentDir does not exist.
                echo
                echo Exiting...
                exit
        endif
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
		echo
                echo ERROR: $ParentDir doest not exist.
                echo
		echo Mode 1 call:
      		echo ./wphot_wrapper_executable_opt0.tcsh 1 ParentDir/
       		echo Mode 2 call:
        	echo ./wphot_wrapper_executable_opt0.tcsh 2 inputList.txt ParentDir/
        	echo Mode 3 call:
        	echo ./wphot_wrapper_executable_opt0.tcsh 3 ParentDir/ TileName
                echo
		echo Exiting...
                exit
        endif
	goto Mode3
else
        #Error handling
        #option 1/2/3 not second parameter. program exits.
	echo
        echo ERROR mode 1, 2, or 3 not selected
	echo Mode 1 call:
        echo ./wphot_wrapper_executable_opt0.tcsh 1 ParentDir/
        echo Mode 2 call:
        echo ./wphot_wrapper_executable_opt0.tcsh 2 inputList.txt ParentDir/
        echo Mode 3 call:
        echo ./wphot_wrapper_executable_opt0.tcsh 3 ParentDir/ TileName
        echo
        echo Exiting...
	exit
endif

Mode1:
#===============================================================================================================================================================        
# loops through all of the tiles and executes wphot

set FulldepthDir = $ParentDir/UnWISE/

echo iterating over $FulldepthDir
echo Wrapper now starting...
echo
echo
echo 1\) wphot wrapper programs now starting...

#TESTING
#while
foreach RaRaRaDir ($FulldepthDir*/) #for each directory in FulldepthDir, get each RadecIDdir, run wrapper on RadecID tile

        foreach RadecIDDir ($RaRaRaDir*/)

                echo =============================== starting wphot wrapper loop iteration =================================
	#Stops calling programs if number of scripts running is greater than number of threads on CPU
               
		set tempSize = `echo $RadecIDDir  | awk '{print length($0)}'`
                @ tempIndex = ($tempSize - 8)
                set RadecID = `echo $RadecIDDir | awk -v startIndex=$tempIndex '{print substr($0,startIndex,8)}'`
		set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
		set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
		set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/ 
		set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
		echo $FulldepthDir
		echo $RadecIDDir
		echo RadecID == $RadecID
		echo RaRaRa == $RaRaRa
		#Error Checking
		if(! -d $UnWISEDir) then
			echo ERROR: Input dir $UnWISEDir does not exist.
                	echo
                	echo Exiting...
                	exit
        	endif
		if(! -d $CatWISEDir) then
                	echo ERROR: Output dir $CatWISE does not exist.
                	echo
                	echo Exiting...
                	exit
        	endif 
	
		if($rsyncSet == "true") then
			(echo y | ./wphot_wrapper_executable_opt0.tcsh 3 $ParentDir $RadecID -rsync -nl $arg_nl) &  #&& (echo Wrapper Call for ${RadecID} success!)
		else
			(echo y | ./wphot_wrapper_executable_opt0.tcsh 3 $ParentDir $RadecID -nl $arg_nl) &  #&& (echo Wrapper Call for ${RadecID} success!)
		endif
		
        	if(`ps -ef | grep wphot_wrapper_executable_opt0 | wc -l` > 14) then
               		echo ${RadecID} More than 12 wphot_wrapper_executable_opt0 processes, waiting...
                	while(`ps -ef | grep wphot_wrapper_executable_opt0 | wc -l` > 14)
                        	sleep 1
                        	#echo IM WATING
               	         	#do nothing
                	end
                	echo ${RadecID} Done waiting!
        	endif


                echo wphot for ${RadecID} done!

                echo ================================ ending wphot wrapper loop iteration =================================
        end
    end

#===============================================================================================================================================================

    #wait for background processes to finish
    wait
    echo wphot wrapper finished!
    echo
    goto Done

Mode2:
    
    foreach line (`cat $InputsList`)    
            echo ===================================== start wphot wrapper loop iteration ======================================
     
        set RadecID = `echo $line`
        set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`

        echo "RaRaRa == "$RaRaRa
        echo "RadecID == "$RadecID
        
        set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
        set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/ 
        set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
        
        #Error Checking
        if(! -d $UnWISEDir) then
            echo ERROR: Input dir $UnWISEDir does not exist.
                    echo
                    echo Exiting...
                    exit
            endif
        if(! -d $CatWISEDir) then
                    echo ERROR: Output dir $CatWISE does not exist.
                    echo
                    echo Exiting...
                    exit
            endif 
    
	if($rsyncSet == "true") then
                (echo y | ./wphot_wrapper_executable_opt0.tcsh 3 $ParentDir $RadecID -rsync -nl $arg_nl)  &  #&& (echo Wrapper Call for ${RadecID} success!)
        else
                (echo y | ./wphot_wrapper_executable_opt0.tcsh 3 $ParentDir $RadecID -nl $arg_nl) &  #&& (echo Wrapper Call for ${RadecID} success!)
        endif

        if(`ps -ef | grep wphot_wrapper_executable_opt0 | wc -l` > 14) then
                echo ${RadecID} More than 12 wphot_wrapper_executable_opt0 processes, waiting...
                while(`ps -ef | grep wphot_wrapper_executable_opt0 | wc -l` > 14)
                        sleep 1
                        #echo IM WATING
                        #do nothing
                end
                echo ${RadecID} Done waiting!
        endif

                echo wphot for ${RadecID} done!
            
            echo ====================================== end wphot wrapper loop iteration =======================================
    end

    #===============================================================================================================================================================

    #wait for background processes to finish
    wait
    echo wphot wrapper finished!
    echo


	goto Done

Mode3:
	set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
	set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
	set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/ 
	set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
	echo "\033[1;31m Creating temp dir for $RadecID \033[0m"
        mkdir -p ${CatWISEDir}/ProgramTerminalOutput/DELETEME
        echo "DONE CREATING DELETEME/"	

	chmod 775 $CatWISEDir

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
	
	##***READ CAUTION***, the cname == root name == unwise-0657p151... thus, same as the "base" in frames_list.tbl 
	#automatically generates frames_list.tbl
	set rootname = unwise-$RadecID
	#print tbl header in frames_list.tbl
	echo "|  path              |      base     | b1 | b2 | b3 | b4 |" > ${TileDir}/frames_list.tbl
	echo "|   c                |       c       |  i |  i |  i |  i |" >> ${TileDir}/frames_list.tbl
	echo "|                    |" >> ${TileDir}/frames_list.tbl
	echo "|                    |" >> ${TileDir}/frames_list.tbl
	#print each epoch in frames_list.tbl
	set fullDir = ${TileDir}Full/
        foreach subDir ($TileDir*/)
		echo "Subdir == ${subDir}"
		echo "fullDir == ${fullDir}"
		if($subDir != ${fullDir}) then
			echo $subDir $rootname 1 1 0 0 >> ${TileDir}/frames_list.tbl
		endif
	end

	#replaces escape character on all existing "/"
	set editedUnWISEDir=`echo $UnWISEDir | sed 's/\//\\\//g'`
	set editedCatWISEDir=`echo $CatWISEDir | sed 's/\//\\\//g'`
	set editedTileDir=`echo $TileDir | sed 's/\//\\\//g'`
	cp $wrapperDir/wphot_wrapper_option-0.tcsh ${CatWISEDir}/ProgramTerminalOutput/DELETEME/
        set wrapperDir = ${CatWISEDir}/ProgramTerminalOutput/DELETEME	

	if($arg_nl != "") then #custom nameslist 
		set editedarg_nl=`echo $arg_nl | sed 's/\//\\\//g'`
                sed -i --follow-symlinks "11s/.*.*/set namelist = $editedarg_nl/g" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        else #use default nameslist
		sed -i --follow-symlinks "11s/.*.*/set namelist = \/Users\/CatWISE\/WPHOT\/nl_opt0.WPHot_unwise/g" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        endif
	sed -i --follow-symlinks "16s/.*.*/set mdetfile = ${editedCatWISEDir}detlist.tbl/g" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes frames_list output location TODO Do I really need to keep the frames list?
	sed -i --follow-symlinks "20s/.*.*/set flist =  ${editedTileDir}\/frames_list.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes image id to the tile name (RadecID)
        sed -i --follow-symlinks "22s/.*.*/set imageid = ${RadecID}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes psfdir
        sed -i --follow-symlinks "40s/.*.*/set psfdir = ${editedCatWISEDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh	
	#changes cname
	sed -i --follow-symlinks "47s/.*.*/set cname = ${editedUnWISEDir}\/$rootname/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes outdir
        sed -i --follow-symlinks "55s/.*.*/set outdir = ${editedCatWISEDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes mdex output file name
        sed -i --follow-symlinks "59s/.*.*/set outname = ${editedCatWISEDir}\/mdex_STD-msk.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes meta output file name
        sed -i --follow-symlinks "60s/.*.*/set metaname = ${editedCatWISEDir}\/meta_STD-msk.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes verbose
        sed -i --follow-symlinks "61s/.*.*/set verbose = ${editedCatWISEDir}\/ProgramTerminalOutput\/wphot_output.txt/" ${wrapperDir}/wphot_wrapper_option-0.tcsh

	#Run WPHOT Option 0
	${wrapperDir}/wphot_wrapper_option-0.tcsh
	
	set saved_status = $?
        #check exit status
        echo wphot saved_status == $saved_status
        if($saved_status != 0) then #if program failed, status != 0
                echo Failure detected on tile $RadecID
                set failedProgram = "wphot"
                goto Failed
        endif


	echo Removing ${CatWISEDir}/ProgramTerminalOutput/DELETEME
        rm -rf ${CatWISEDir}/ProgramTerminalOutput/DELETEME

	(/Users/CatWISE/stf ${CatWISEDir}/mdex_STD-msk.tbl 1-11 16-21 28 29 32 33 36-39 44-49 56-60 63 64 67-77 88-93 100-105 112-117 124-129 136-141 148-153 160-165 172-177 184-205 228 231 234-246 259-275 278-281 286-291 298-301 > ${CatWISEDir}/stf-mdex_STD-msk.tbl) 
	
	set saved_status = $?
        #check exit status
        echo stf saved_status == $saved_status
        if($saved_status != 0) then #if program failed, status != 0
                echo Failure detected on tile $RadecID
                set failedProgram = "stf"
                goto Failed
        endif

	set date_t = `date +"%Y%m%d%H%M%S"`
	/Users/CatWISE/add-opt1-cols ${CatWISEDir}/stf-mdex_STD-msk.tbl ${CatWISEDir}/${RadecID}_opt0_${date_t}.tbl 
	set saved_status = $?
        #check exit status
        echo add-opt1-cols saved_status == $saved_status
        if($saved_status != 0) then #if program failed, status != 0
                echo Failure detected on tile $RadecID
                set failedProgram = "add-opt1-cols"
                goto Failed
        endif

	chmod 775 $CatWISEDir

       #gzip output
	gzip -f ${CatWISEDir}/${RadecID}_opt0_${date_t}.tbl
       #rm output
	rm -f ${CatWISEDir}/mdex_STD-msk.tbl
	rm -f ${CatWISEDir}/stf-mdex_STD-msk.tbl

	
	#rsync step
	if($rsyncSet == "true") then
       	#rsync
        echo running rsync on tile $RadecID
        set currIP = `dig +short myip.opendns.com @resolver1.opendns.com`
        echo current IP = $currIP
        if($currIP == "137.78.30.21") then #Tyto
                set otus_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/otus1/g'`
                set athene_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/athene1/g'`
                set otus_CatWISEDir = `echo $otus_CatWISEDir | sed 's/tyto/otus/g'`
                set athene_CatWISEDir = `echo $athene_CatWISEDir | sed 's/tyto/athene/g'`
                set otus_CatWISEDir = `echo $otus_CatWISEDir | sed 's/CatWISE3/otus3/g'`
                set athene_CatWISEDir = `echo $athene_CatWISEDir | sed 's/CatWISE3/athene3/g'`
                echo On Tyto!

               #Transfer Tyto CatWISE/ dir to Otus
                echo rsync Tyto\'s $CatWISEDir to Otus $otus_CatWISEDir
                ssh ${user}@137.78.80.75 "mkdir -p $otus_CatWISEDir"
                rsync -avu $CatWISEDir ${user}@137.78.80.75:$otus_CatWISEDir

               #Transfer Tyto CatWISE/ dir to Athene
                echo rsync Tyto\'s $CatWISEDir to Athene $athene_CatWISEDir
                ssh ${user}@137.78.80.72 "mkdir -p $athene_CatWISEDir"
                rsync -avu  $CatWISEDir ${user}@137.78.80.72:$athene_CatWISEDir
        else if($currIP == "137.78.80.75") then  #Otus
                set tyto_CatWISEDir = `echo $CatWISEDir | sed 's/otus3/CatWISE3/g'`
                set tyto_CatWISEDir = `echo $tyto_CatWISEDir | sed 's/otus/tyto/g'`
                set athene_CatWISEDir = `echo $CatWISEDir | sed 's/otus/athene/g'`
                echo On Otus!

               #Transfer Otus CatWISE/ dir to Tyto
                echo rsync Otus\'s $CatWISEDir to Tyto $tyto_CatWISEDir
                ssh ${user}@137.78.30.21 "mkdir -p $tyto_CatWISEDir"
                rsync -avu $CatWISEDir ${user}@137.78.30.21:$tyto_CatWISEDir

               #Transfer Otus CatWISE/ to Athene
                echo rsync Otus\'s $CatWISEDir/to Athene $athene_CatWISEDir
                ssh ${user}@137.78.80.72 "mkdir -p $athene_CatWISEDir"
                rsync -avu  $CatWISEDir ${user}@137.78.80.72:$athene_CatWISEDir
        else if($currIP == "137.78.80.72") then #Athene
                set tyto_CatWISEDir = `echo $CatWISEDir | sed 's/athene3/CatWISE3/g'`
                set tyto_CatWISEDir = `echo $tyto_CatWISEDir | sed 's/athene/tyto/g'`
                set otus_CatWISEDir = `echo $CatWISEDir | sed 's/athene/otus/g'`
                echo On Athene!
               
	       #Transfer to Tyto
                echo rsync Athene\'s $CatWISEDir/ to Tyto $tyto_CatWISEDir
		ssh ${user}@137.78.30.21 "mkdir -p $tyto_CatWISEDir"
                rsync -avu $CatWISEDir ${user}@137.78.30.21:$tyto_CatWISEDir

               #Transfer to Otus
                echo rsync Athene\'s $CatWISEDir/ to Otus $otus_CatWISEDir
                ssh ${user}@137.78.80.75 "mkdir -p $otus_CatWISEDir"
                rsync -avu $CatWISEDir ${user}@137.78.80.75:$otus_CatWISEDir
        endif
        endif
	


	goto Done

Done:
echo WPHOTWrapper Mode: ${1} Done!
echo Removing wphot_wrapper_option-0.tcsh--follow-symlinks
rm -f wphot_wrapper_option-0.tcsh--follow-symlinks
set endTime = `date '+%m/%d/%Y %H:%M:%S'`
echo
echo Wrapper Mode: ${1} Ended at:
echo $endTime
exit

#program jumps here if a program returns an exit status 32(Warning) or 64(Error)
Failed:
echo exit status of ${failedProgram} for tile \[${RadecID}\]\: ${saved_status}
        set currIP = `dig +short myip.opendns.com @resolver1.opendns.com`
        echo current IP = $currIP
        if($currIP == "137.78.30.21") then #Tyto
                if($saved_status <= 32) then #status <= 32, WARNING 
                        echo WARNING ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status}
                        echo WARNING ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status} >> /Volumes/tyto2/ErrorLogsTyto/errorlog_${startTime}.txt
                        echo WARNING output to error log: /Volumes/tyto2/ErrorLogsTyto/errorlog_${startTime}.txt

                        if($rsyncSet == "true") then #rsync to other machines
                               #Transfer Tyto ErrorLogsTyto/ dir to Otus
                                echo rsync Tyto\'s /Volumes/tyto2/ErrorLogsTyto/ to Otus /Volumes/otus2/ErrorLogsTyto/
                                ssh ${user}@137.78.80.75 "mkdir -p /Volumes/otus2/ErrorLogsTyto/"
                                rsync -avu /Volumes/tyto2/ErrorLogsTyto/ ${user}@137.78.80.75:/Volumes/otus2/ErrorLogsTyto/

                               #Transfer Tyto ErrorLogsTyto/ dir to Athene
                                echo rsync Tyto\'s /Volumes/tyto2/ErrorLogsTyto/ to Athene /Volumes/athene2/ErrorLogsTyto/
                                ssh ${user}@137.78.80.72 "mkdir -p /Volumes/athene2/ErrorLogsTyto/"
                                rsync -avu  /Volumes/tyto2/ErrorLogsTyto/ ${user}@137.78.80.72:/Volumes/athene2/ErrorLogsTyto/
                        endif
                        echo Exiting wrapper...
                        exit
                else if($saved_status > 32) then #status > 32, ERROR
                        echo ERROR ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status}
                        echo ERROR ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status} >> /Volumes/tyto2/ErrorLogsTyto/errorlog_${startTime}.txt
                        echo ERROR output to error log: /Volumes/tyto2/ErrorLogsTyto/errorlog_${startTime}.txt

                        if($rsyncSet == "true") then #rsync to other machines
                               #Transfer Tyto ErrorLogsTyto/ dir to Otus
                                echo rsync Tyto\'s /Volumes/tyto2/ErrorLogsTyto/ to Otus /Volumes/otus2/ErrorLogsTyto/
                                ssh ${user}@137.78.80.75 "mkdir -p /Volumes/otus2/ErrorLogsTyto/"
                                rsync -avu /Volumes/tyto2/ErrorLogsTyto/ ${user}@137.78.80.75:/Volumes/otus2/ErrorLogsTyto/

                               #Transfer Tyto ErrorLogsTyto/ dir to Athene
                                echo rsync Tyto\'s /Volumes/tyto2/ErrorLogsTyto/ to Athene /Volumes/athene2/ErrorLogsTyto/
                                ssh ${user}@137.78.80.72 "mkdir -p /Volumes/athene2/ErrorLogsTyto/"
                                rsync -avu  /Volumes/tyto2/ErrorLogsTyto/ ${user}@137.78.80.72:/Volumes/athene2/ErrorLogsTyto/
                        endif
                        echo Exiting wrapper...
                        exit
                endif
        else if($currIP == "137.78.80.75") then  #Otus
                if($saved_status <= 32) then #status <= 32, WARNING
                        echo WARNING ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status}
                        echo WARNING ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status} >> /Volumes/otus1/ErrorLogsOtus/errorlog_${startTime}.txt
                        echo WARNING output to error log: /Volumes/otus1/ErrorLogsOtus/errorlog_${startTime}.txt

                        if($rsyncSet == "true") then #rsync to other machines
                               #Transfer Otus ErrorLogsOtus/ dir to Tyto
                                echo rsync Otus\'s /Volumes/otus1/ErrorLogsOtus/ to Tyto /Volumes/tyto1/ErrorLogsOtus/
                                ssh ${user}@137.78.30.21 "mkdir -p /Volumes/tyto1/ErrorLogsOtus/"
                                rsync -avu /Volumes/otus1/ErrorLogsOtus/ ${user}@137.78.30.21:/Volumes/tyto1/ErrorLogsOtus/

                               #Transfer Otus ErrorLogsOtus/ dir to Athene
                                echo rsync Otus\'s /Volumes/otus1/ErrorLogsOtus/ to Athene /Volumes/athene1/ErrorLogsOtus/
                                ssh ${user}@137.78.80.72 "mkdir -p /Volumes/athene1/ErrorLogsOtus/"
                                rsync -avu /Volumes/otus1/ErrorLogsOtus/ ${user}@137.78.80.72:/Volumes/athene1/ErrorLogsOtus/
                        endif
                        echo Exiting wrapper...
                        exit
                else if($saved_status > 32) then #status > 32, ERROR
                        echo ERROR ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status}
                        echo ERROR ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status} >> /Volumes/otus1/ErrorLogsOtus/errorlog_${startTime}.txt
                        echo ERROR output to error log: /Volumes/otus1/ErrorLogsOtus/errorlog_${startTime}.txt

                        if($rsyncSet == "true") then #rsync to other machines
                               #Transfer Otus ErrorLogsOtus/ dir to Tyto
                                echo rsync Otus\'s /Volumes/otus1/ErrorLogsOtus/ to Tyto /Volumes/tyto1/ErrorLogsOtus/
                                ssh ${user}@137.78.30.21 "mkdir -p /Volumes/tyto1/ErrorLogsOtus/"
                                rsync -avu /Volumes/otus1/ErrorLogsOtus/ ${user}@137.78.30.21:/Volumes/tyto1/ErrorLogsOtus/

                               #Transfer Otus ErrorLogsOtus/ dir to Athene
                                echo rsync Otus\'s /Volumes/otus1/ErrorLogsOtus/ to Athene /Volumes/athene1/ErrorLogsOtus/
                                ssh ${user}@137.78.80.72 "mkdir -p /Volumes/athene1/ErrorLogsOtus/"
                                rsync -avu /Volumes/otus1/ErrorLogsOtus/ ${user}@137.78.80.72:/Volumes/athene1/ErrorLogsOtus/
                        endif
                        echo Exiting wrapper...
                        exit
                endif

        else if($currIP == "137.78.80.72") then  #Athene
                if($saved_status <= 32) then #status <= 32, WARNING
                        echo WARNING ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status}
                        echo WARNING ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status} >> /Volumes/athene3/ErrorLogsAthene/errorlog_${startTime}.txt
                        echo WARNING output to error log: /Volumes/athene3/ErrorLogsAthene/errorlog_${startTime}.txt

                        if($rsyncSet == "true") then #rsync to other machines
                               #Transfer Athene ErrorLogsAthene/ dir to Tyto
                                echo rsync Athene\'s /Volumes/athene3/ErrorLogsAthene/ to Tyto /Volumes/CatWISE3/ErrorLogsAthene/
                                ssh ${user}@137.78.30.21 "mkdir -p /Volumes/CatWISE3/ErrorLogsAthene/"
                                rsync -avu /Volumes/athene3/ErrorLogsAthene/ ${user}@137.78.30.21:/Volumes/CatWISE3/ErrorLogsAthene/

                               #Transfer Athene ErrorLogsTyto/ dir to Otus
                                echo rsync Athene\'s /Volumes/athene3/ErrorLogsAthene/ to Otus /Volumes/otus3/ErrorLogsAthene/
                                ssh ${user}@137.78.80.72 "mkdir -p /Volumes/otus3/ErrorLogsAthene/"
                                rsync -avu /Volumes/athene3/ErrorLogsAthene/ ${user}@137.78.80.72:/Volumes/otus3/ErrorLogsAthene/
                        endif
                        echo Exiting wrapper...
                        exit
                else if($saved_status > 32) then #status > 32, ERROR
                        echo ERROR ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status}
                        echo ERROR ${failedProgram} on tile \[$RadecID\] exited with status ${saved_status} >> /Volumes/athene3/ErrorLogsAthene/errorlog_${startTime}.txt
                        echo ERROR output to error log: /Volumes/athene3/ErrorLogsAthene/errorlog_${startTime}.txt
 if($rsyncSet == "true") then #rsync to other machines
                               #Transfer Athene ErrorLogsAthene/ dir to Tyto
                                echo rsync Athene\'s /Volumes/athene3/ErrorLogsAthene/ to Tyto /Volumes/CatWISE3/ErrorLogsAthene/
                                ssh ${user}@137.78.30.21 "mkdir -p /Volumes/CatWISE3/ErrorLogsAthene/"
                                rsync -avu /Volumes/athene3/ErrorLogsAthene/ ${user}@137.78.30.21:/Volumes/CatWISE3/ErrorLogsAthene/

                               #Transfer Athene ErrorLogsTyto/ dir to Otus
                                echo rsync Athene\'s /Volumes/athene3/ErrorLogsAthene/ to Otus /Volumes/otus3/ErrorLogsAthene/
                                ssh ${user}@137.78.80.72 "mkdir -p /Volumes/otus3/ErrorLogsAthene/"
                                rsync -avu /Volumes/athene3/ErrorLogsAthene/ ${user}@137.78.80.72:/Volumes/otus3/ErrorLogsAthene/
                        endif
                        echo Exiting wrapper...
                        exit
                endif

        endif



