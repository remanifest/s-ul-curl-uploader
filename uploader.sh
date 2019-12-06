#!/bin/bash

#### Script for uploading to s-ul.eu using personal key.
#### Depends upon jq to parse the JSON response from s-ul.eu, and curl to execute the API call.
#### Executed by calling ./uploader.sh /path/to/file.ext or simply ./uploader.sh file.ext
#### Script will iterate, so you can list multiple files while calling the script once. E.g., ./uploader.sh image1.png image2.png image3.png
#### After upload, a URL will be printed to the terminal, pointing to the file that was just uploaded.
#### Many items have been turned into variables to make updating this as easy as possible for an end-user.
#### Realistically, the only thing that needs to be updated is the key, which comes from s-ul.eu

######## Insert API key below
key=

# Make sure the API key was provided. If no key is provided, tell the user and exit.
if [ -z "$key" ];
then
	{ echo -e >&2 "\nYou must input your API key from \033[4;32mhttps://s-ul.eu/account/configurations\033[0m into this script. Do that, then try again.\n"; exit 1; }
fi

## Check for the existence of curl. If curl exists, proceed. If it doesn't exist, tell the user to install it and exit.
command -v curl >/dev/null 2>&1 || { echo -e >&2 "\n\tcurl is required to execute the API call.\n\n\tPlease install it using using your package manager and try again.\n\n\t\t\033[1mmacOS\033[0m: Download the MacPorts installer from \033[4;32mhttps://www.macports.org/install.php\033[0m, then execute \033[3msudo port install curl\033[0m in the terminal\n\t\t\tAlternatively, you may install homebrew by following the instructions at \033[4;32mhttps://brew.sh\033[0m, then executing \033[3mbrew install curl\033[0m in the terminal\n\n\t\t\033[1mLinux\033[0m: Use your package manager, e.g. \033[3msudo aptitude install curl\033[0m or \033[3msudo pacman -S curl\033[0m\n"; exit 1; }

## Check for the existence of jq. If jq exists, proceed. If it doesn't exist, tell the user to install it and exit.
command -v jq >/dev/null 2>&1 || { echo -e >&2 "\n\tjq is required to parse the JSON response.\n\n\tPlease install it using using your package manager and try again.\n\n\t\t\033[1mmacOS\033[0m: Download the MacPorts installer from \033[4;32mhttps://www.macports.org/install.php\033[0m, then execute \033[3msudo port install jq\033[0m in the terminal\n\t\t\tAlternatively, you may install homebrew by following the instructions at \033[4;32mhttps://brew.sh\033[0m, then executing \033[3mbrew install jq\033[0m in the terminal\n\n\t\t\033[1mLinux\033[0m: Use your package manager, e.g. \033[3msudo aptitude install jq\033[0m or \033[3msudo pacman -S jq\033[0m\n"; exit 1; }

method=POST
postURL=https://s-ul.eu/api/v1/upload
wizard=true
file=$@

# Make sure that an argument was provided for a file to upload. If not, tell the user and exit. If it was, grab the size and store it into $actualsize.
if [ -z "$file" ];
then
	{ echo -e >&2 "\nPlease specify a file to upload.\n"; exit 1; }
fi

actualsize=$(wc -c <"$file")
maxsize=209714177

# Make sure the file being uploaded isn't too large. If it's too big, it'll be rejected by the s-ul.eu server, so we'll make sure we don't try.
if [ $actualsize -ge $maxsize ];
then
	{ echo -e >&2 "\nSorry, your file is too large to be uploaded. Please try a smaller file.\n"; exit 1; }
fi

# For any given file or file(s)...
for file in "$@"
do
# create (read) the url variable, then echo the result of the curl execution & parsed jq value into that newly created variable
	read url < <(echo $(curl -s -X ""$method"" """$postURL""?key=""$key""&wizard=""$wizard""" -F"file=@\"""$file""\"" | jq -r '.url'))
# Make sure the upload happened, and the json was parsed into the url variable. If not, tell the user and exit. If it was, return the value.
	if [ -z "$url" ];
	then
		{ echo -e >&2 "\nIt looks like there was an error uploading your file. Please check your connection and try again.\n"; exit 1; }
 	else
		echo -e "\n\033[3mFile successfully uploaded\033[0m\n\033[4;32m$url\033[0m\n"
	fi
# If the uploaded file is an image, return the thumbnail URL as well.
	if [[ $file =~ \.png$ ]] || [[ $file =~ \.jpg$ ]] || [[ $file =~ \.jpeg$ ]] || [[ $file =~ \.gif$ ]] || [[ $file =~ \.bmp$ ]] || [[ $file =~ \.tiff$ ]];
	then 
		echo -e "\t\033[1mThumbnail\033[0m: \033[4;32m$url?thumb=1""\033[0m\n"
	fi
# Provide the delete URL by returning the string following the last slash in the $url variable.
		echo -e "\t\033[1mDelete\033[0m: \033[4;31mhttp://s-ul.eu/delete.php?key=""$key""&file=""${url##*/}""\033[0m\n"
done