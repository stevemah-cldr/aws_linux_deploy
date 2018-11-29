use the following to encode the script with base64:
certutil -encode linux-userdata.txt linux-userdata_base64.txt
 Before you can use this file with the AWS CLI, you must remove the first (BEGIN CERTIFICATE) and last (END CERTIFICATE) lines.
------BEGIN CERTIFICATE