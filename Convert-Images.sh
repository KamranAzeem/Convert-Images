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

# TARGETDIRECTORY is a location where the processed images will be stored, to be used by the web application. This location will hold sub directories BIG, SMALL, MEDIUM and ZOOM. Till now I see a PIC directory inside each of the mentioned directories but I do not see a reason to do that.
TARGETDIRECTORY=/tmp/httpdocs/default_images

# FTPUSERNAME and FTPGROUPNAMES must be specified, so that after the script finishes running, it can update the ownerships of the converted files. If not, the generated files will be owned by the user root. The files may be unreadable, or they may not be deleted from web and FTP interfaces.
FTPUSERNAME=generalimages
FTPGROUPNAME=webmasters

####### - END - User Configuration

# There is nothing for the user to modify below.


###### - START - Program Logic
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

if  [ "${FTPUSERNAME}" == "" ] ||  [ "${FTPGROUPNAME}" == "" ] ; then
  echo "FTPUSERNAME and FTPGROUPNAME cannot be empty. They must be a valid system user id and group id. You can use name or id. Stopping."
else
  echo "FTPUSERNAME=${FTPUSERNAME}"
  echo "FTPGROUPNAME=${FTPGROUPNAME}"
  # Note: Need to introduce the checks to see if the user and groups actually exist.
  echo "FTP User and Group exist; moving forward."
fi  
echo ""

###### - END - Program Logic

