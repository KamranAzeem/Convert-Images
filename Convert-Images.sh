#!/bin/bash
# Author: Muhammad Kamran Azeem
# License: GPL v2
# Created: 2013-04-30
# Summary: Loads images from one location, converts them and stores in a different location. Pretty simple haan!
#          This may run through cron.
################################################################################################################

####### - START - User Configuration


# IMAGESOURCEDIRECTORY is the location where the raw images are uploaded through FTP.
# The images will be inside separate brand-id subdirectories such as 635, 874, etc. 
# The images files may have strange characters in the filenames such as space, + % etc. 
# The image may contain a mix of uppercase and lowercase characters. Need to fix that all too.
IMAGESOURCEDIRECTORY=/tmp/UploadedImages

# POSTPROCESSDIRECTORY is the location where the original image will be moved to instead of deleting it.
POSTPROCESSDIRECTORY=/tmp/PostProcessImages

# TARGETDIRECTORY is a location where the processed images will be stored, to be used by the web application. This location will hold sub directories Big, Small, Medium and Zoom. Till now I see a PIC directory inside each of the mentioned directories but I do not see a reason to do that.
# The target directory also stores images as per brand-ids, under separate sub-directories. . 
TARGETDIRECTORY=/tmp/httpdocs/default_images

# FTPUSERNAME and FTPGROUPNAMES must be specified, so that after the script finishes running, it can update the ownerships of the converted files. If not, the generated files will be owned by the user root. The files may be unreadable, or they may not be deleted from web and FTP interfaces.
# FTPUSERNAME=generalimages
FTPUSERNAME=kamran
# FTPGROUPNAME=webmasters
FTPGROUPNAME=kamran

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

if [ "$1" == "-v" ] ; then
  VERBOSE="-verbose"
fi


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
  echo "This is silly. To do this, a conversion program is needed. Please provide the correct path in the CONVERT variable. Stopping."
  exit 9
fi
echo ""
####### - END - Sanity Checks


####### - START - Program Logic

# List of Directories:
# ls -l  --time-style=long-iso /tmp/UploadedImages/  | grep ^d | cut -d " " -f8
# Sometimes you need to use field number 8, and sometimes 9, depending on the underlying OS version / environment.
# To make sure that you don't have to fix your script on different systems, you need to make sure the time format of ls is always the same. The solution is to use ls -l --time-style="long-iso" .
# Cut is pathetic. Results are not always the same. Better use awk

## BRANDLIST=$(ls -l --time-style=long-iso ${IMAGESOURCEDIRECTORY} | grep ^d | cut -d " " -f8)
BRANDLIST=$(ls -l --time-style=long-iso ${IMAGESOURCEDIRECTORY} | grep ^d | awk '{print $8}')

if [ -z ${BRANDLIST} ] ; then 
  echo "There are no images of any brands in the image source directory ${IMAGESOURCEDIRECTORY}. Nothing to do. Stopping."
  echo ""
fi

for BRAND in ${BRANDLIST}; do

  if [ ! -d ${TARGETDIRECTORY}/Big/${BRAND}/ ] || [ ! -d ${TARGETDIRECTORY}/Medium/${BRAND}/ ] || [ ! -d ${TARGETDIRECTORY}/Small/${BRAND}/ ] || [ ! -d ${TARGETDIRECTORY}/Zoom/${BRAND}/ ] ; then
    echo "The brand-id directory ${BRAND} does not exist inside ${TARGETDIRECTORY}/{Big,Medium,Small,Zoom}"
    echo "I will create this for you, as will as the PIC directory inside each brand-id directory. Take it as a favor!"
    echo "Executing: mkdir -p ${TARGETDIRECTORY}/{Big,Medium,Small,Zoom}/${BRAND}/PIC"
    mkdir -p ${TARGETDIRECTORY}/{Big,Medium,Small,Zoom}/${BRAND}/PIC
  else
    echo "The brand-id directory ${BRAND} already exist inside ${TARGETDIRECTORY}/{Big,Medium,Small,Zoom}; moving forward."
  fi
  echo ""


  # First rename the image files in the source directory by converting its name from uppercase to lowercase.
  for FILE in $(/bin/find ${IMAGESOURCEDIRECTORY}/${BRAND}/ -maxdepth 1 -type f -printf '%P\n') ; do
  ## cd ${IMAGESOURCEDIRECTORY}/${BRAND}/
  ## for FILE in * ; do
    LOWERCASENAME="$( echo ${FILE} | tr '[:upper:]' '[:lower:]' )" 
    echo "Renaming file ${FILE} to ${LOWERCASENAME}"
    echo "mv ${IMAGESOURCEDIRECTORY}/${BRAND}/${FILE} ${IMAGESOURCEDIRECTORY}/${BRAND}/${LOWERCASENAME} "
    mv ${IMAGESOURCEDIRECTORY}/${BRAND}/"${FILE}" ${IMAGESOURCEDIRECTORY}/${BRAND}/"${LOWERCASENAME}"
  done
  ## cd -

  # Generate list of files for processing in this directory
  LISTOFIMAGES=$(ls ${IMAGESOURCEDIRECTORY}/${BRAND}/)
  
  for IMAGE in ${LISTOFIMAGES}; do 
    echo "Processing Image file: ${IMAGE}"
    echo "---------------------"
    convert ${VERBOSE} -resize ${SIZEZOOM}x   ${IMAGESOURCEDIRECTORY}/${BRAND}/${IMAGE} ${TARGETDIRECTORY}/Zoom/${BRAND}/PIC/${IMAGE}
    convert ${VERBOSE} -resize ${SIZEBIG}x    ${IMAGESOURCEDIRECTORY}/${BRAND}/${IMAGE} ${TARGETDIRECTORY}/Big/${BRAND}/PIC/${IMAGE}
    convert ${VERBOSE} -resize ${SIZEMEDIUM}x ${IMAGESOURCEDIRECTORY}/${BRAND}/${IMAGE} ${TARGETDIRECTORY}/Medium/${BRAND}/PIC/${IMAGE}
    convert ${VERBOSE} -resize ${SIZESMALL}x  ${IMAGESOURCEDIRECTORY}/${BRAND}/${IMAGE} ${TARGETDIRECTORY}/Small/${BRAND}/PIC/${IMAGE}
  done

  # Time to move the processed image's source to a safe location. This way cron will not waste time re-processing it again and again.
  # Also instead of deleting, moving to a different location is better. We don't have to re-upload through FTP in case of problem.

  echo ""
  echo "Brand images processed. Moving brand-id ${BRAND} to Post-process location: ${POSTPROCESSDIRECTORY}"
  mv ${IMAGESOURCEDIRECTORY}/${BRAND}  ${POSTPROCESSDIRECTORY}/
  echo ""
  echo "==================================================================================================="

done

chown ${FTPUSERNAME}:${FTPGROUPNAME} ${TARGETDIRECTORY} -R




####### - END - Program Logic
