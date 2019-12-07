# s-ul-curl-uploader

Simple bash script for uploading files to your Seion Upload (s-ul.eu) account. Requires cURL and jq. Should work on any UNIX-based system, including macOS.

Usage:
- Place anywhere you want (/usr/bin/local/ works nicely)
- chmod +x ./uploader.sh
- uploader.sh file1 file2 file3

Includes logic checks to ensure:
- An API key was added to the script
- The dependencies (cURL and jq) are installed
- A file (or files) was provided for upload
- The file isn't too big to be uploaded to s-ul.eu
- That the file was uploaded

Returns:
- URL of the uploaded file
- If it's an image file, a thumbnail URL
- A delete link for removing the file from s-ul.eu

