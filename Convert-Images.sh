#!/bin/bash
# Author: Muhammad Kamran Azeem
# License: GPL v2
# Created: 2013-04-30
# Summary: Loads images from one location, converts them and stores in a different location. Pretty simple haan!
#          This may run through cron.

####### - START - User Configuration
# IMAGESOURCEDIRECTORY is the location where the raw images are uploaded through FTP.
IMAGESOURCEDIRECTORY=/tmp/UploadedImages

# POSTPROCESSDIRECTORY is the location where the original image will be moved to instead of deleting it.
POSTPROCESSDIRECTORY=/tmp/PostProcessImages

# TARGETDIRECTORY is a location where the processed images will be stored, to be used by the web application. This location will hold sub directories Big, Small, Medium and Zoom. Till now I see a PIC directory inside each of the mentioned directories but I do not see a reason to do that.
TARGETDIRECTORY=/tmp/httpdocs/default_images

# FTPUSERNAME and FTPGROUPNAMES must be specified, so that after the script finishes running, it can update the ownerships of the converted files. If not, the generated files will be owned by the user root. The files may be unreadable, or they may not be deleted from web and FTP interfaces.
FTPUSERNAME=generalimages
FTPGROUPNAME=webmasters

# CONVERT is the name of the program which is used to convert/ resize images. 
# ImageMagick package provides the command line utility convert, which does that.
CONVERT="/usr/bin/convert"

# Sizes to convert the source image into target images.
SIZEBIG=600
SIZEMEDIUM=190
SIZESMALL=50
SIZEZOOM=1600


####### - END - User Configuration

# There is nothing for the user to modify below.


####### - START - Sanity Checks
echo ""

if [ -d ${IMAGESOURCEDIRECTORY} ] && [ -d ${POSTPROCESSDIRECTORY} ] && [ ${TARGETDIRECTORY} ] ; then
  echo "IMAGE SOURCE DIRECTORY=${IMAGESOURCEDIRECTORY}"
  echo "POST PROCESS DIRECTORY=${POSTPROCESSDIRECTORY}"
  echo "TARGET DIRECTORY=${TARGETDIRECTORY}"
  echo "Directories exit; moving forward."
else
  echo "Please configure the directories correctly in the script. Stopping."
  exit 9
fi
echo ""

if [ ! -d ${TARGETDIRECTORY}/Big ] || [ ! -d ${TARGETDIRECTORY}/Medium ] || [ ! -d ${TARGETDIRECTORY}/Small ] || [ ! -d ${TARGETDIRECTORY}/Zoom ] ; then
  echo "At least any one of Big, Medium, Small and Zoom directories does not exist inside ${TARGETDIRECTORY}."
  echo "I will create these for you. Take it as a favor!"
  # mkdir -p ${TARGETDIRECTORY}/{Big,Medium,Small,Zoom}
  # chown ${FTPUSERNAME}:${FTPGROUPNAME} $TARAGETDIRECTORY} -R
else
  echo "Big, Medium, Small and Zoom directories exist inside ${TARGETDIRECTORY} ; moving forward."
fi
echo ""

if  [ "${FTPUSERNAME}" == "" ] ||  [ "${FTPGROUPNAME}" == "" ] ; then
  echo "FTPUSERNAME and FTPGROUPNAME cannot be empty. They must be a valid system user id and group id. You can use name or id. Stopping."
else
  echo "FTPUSERNAME=${FTPUSERNAME}"
  echo "FTPGROUPNAME=${FTPGROUPNAME}"
  # Note: Need to introduce the checks to see if the user and groups actually exist.
  echo "FTP User and Group exist; moving forward."
fi  
echo ""

if [ -x ${CONVERT} ] ; then
  echo "Coversion program found at ${CONVERT} ; moving forward."
else
  echo "This is silly. A conversion program is needed. Please provide the correct path in the CONVERT variable. Stopping."
  echo "9"
fi
echo ""
####### - END - Sanity Checks


####### - START - Program Logic
# Generate list of files for processing
LISTOFIMAGES=$(ls ${IMAGESOURCEDIRECTORY})

for i in ${LISTOFIMAGES}; do 
  echo "Processing Image file: ${i}"
  convert -verbose -resize ${SIZEZOOM}x   ${IMAGESOURCEDIRECTORY}/${i} ${TARGETDIRECTORY}/Zoom/${i}
  convert -verbose -resize ${SIZEBIG}x    ${IMAGESOURCEDIRECTORY}/${i} ${TARGETDIRECTORY}/Big/${i}
  convert -verbose -resize ${SIZEMEDIUM}x ${IMAGESOURCEDIRECTORY}/${i} ${TARGETDIRECTORY}/Medium/${i}
  convert -verbose -resize ${SIZESMALL}x  ${IMAGESOURCEDIRECTORY}/${i} ${TARGETDIRECTORY}/Small/${i}
  echo "--------------------------------------------------------------------------------------------------------------"
done

####### - END - Program Logic
