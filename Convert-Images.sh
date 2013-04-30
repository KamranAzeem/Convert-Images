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

####### - END - User Configuration

There is nothing for the user to modify below.


###### - START - Program Logic

if [ -d ${IMAGESOURCEDIRECTORY} ] && [ -d $POSTPROCESSDIRECTORY ] && [ $[TARGETDIRECTORY ] ; then
  echo "Directories exit; moving forward."
else
  echo "Please configure the directories correctly in the script."
  exit 9
fi




###### - END - Program Logic

