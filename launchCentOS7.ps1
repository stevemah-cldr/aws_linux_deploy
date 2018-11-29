# Script to Create Linux instances from a specified ami template
# Customize the VM with UserData shell script

# Declare Instance Variables
# ImageID template last update using: Win10
$ImageId = "ami-00f7c900d2e7133e1"
$KeyName = "autonomic-official-id_rsa"
$InstanceType = "t2.small"
$SubnetId = "subnet-0f6c04d7b5e8b1946"
$SecurityGroupId = "sg-0afbf649fe41843b7"
$owner = Read-Host -Prompt 'Type the name of the Instance onwer: '
$InstanceName = Read-Host -Prompt 'Input the name of the instance: '
$Tags = @( @{key="Name";value="$InstanceName"},
           @{key="AutoOff";value="True"},
           @{key="owner";value="$owner"} )

#$UserDataFile = 'C:\autonomic_workarea\autonomic-software_producteng\AWS\powershell\linux_deployment_scripts\linux-userdata_base64.txt'

$UserDataTemplate = 'C:\autonomic_workarea\autonomic-software_producteng\AWS\powershell\linux_deployment_scripts\linux-userdata.txt'
$UserDataTempFile = Join-Path $env:temp \$InstanceName-linux-userdata.txt

#Make instanceName entry in post_deployment Script
(Get-Content $UserDataTemplate).replace('InstanceName', $InstanceName) | Set-Content $UserDataTempFile

#UserData:
$userDataString = Get-Content -Path $UserDataTempFile | Out-String
$userDataString = @"
<powershell>
$userDataString
</powershell>
"@

$EncodeUserData = [System.Text.Encoding]::UTF8.GetBytes($userDataString)
$userData = [System.Convert]::ToBase64String($EncodeUserData)


# create instance
#$NewInstanceResponse = New-EC2Instance -ImageId "$ImageId" -KeyName "$KeyName" -InstanceType "$InstanceType" -SubnetId "$SubnetId" -UserDataFile "$UserDataFile"
$NewInstanceResponse = New-EC2Instance -ImageId "$ImageId" -KeyName "$KeyName" -InstanceType "$InstanceType" -SubnetId "$SubnetId" -UserData $userData

#Retrieve Instance id(s)
$Instances = ($NewInstanceResponse.Instances).InstanceId

#Apply tags to instances
New-EC2Tag -ResourceId $Instances -Tags $Tags

Write-Host "Finished deploying instance: $InstanceName with instanceID $Instances"

# use certitil in windows or base64 in linux to convert the shell script to base64
# for example: certutil -encode .\linux-userdata.txt .\linux-userdata_base64.txt
# Before you can use this file with the AWS CLI, you must remove the first (BEGIN CERTIFICATE) and last (END CERTIFICATE) lines!!!!
