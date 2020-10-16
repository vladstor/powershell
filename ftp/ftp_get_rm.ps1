# Read params from json
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$jsonFile = $scriptPath + '/param.json'
$json = (Get-Content $jsonFile -Raw) | ConvertFrom-Json

$ftp = $json.ftp.Addr
$ftpPath = $json.ftp.Path
$user = $json.ftp.User
$localPath = $json.local.Path
$fileExt = $json.fileEXT

# Read password 
$aes32key_file = $scriptPath + '/aes32.key'
$pass_file = $scriptPath + '/pass.txt'
$pass = Get-Content $pass_file | ConvertTo-SecureString -Key (get-content $aes32key_file)

# Check path
if(!(Test-Path $localPath)){ New-Item -ItemType directory -Path $localPath }

#Register get FTP Directory function
function Get-FtpDir ($url, $credentials) {
	$request = [Net.WebRequest]::Create($url)
	$request.Method = [System.Net.WebRequestMethods+FTP]::ListDirectory

	if ($credentials) { $request.Credentials = $credentials }
	
	$response = $request.GetResponse()
	$reader = New-Object IO.StreamReader $response.GetResponseStream() 
	
	while(-not $reader.EndOfStream) {
		$reader.ReadLine()
	}
	
	$reader.Close()
	$response.Close()
}

#Register Delete function
function Remove-FtpFile ($source, $credentials) {
    $source2 = [system.URI] $source
	
    $ftp = [System.Net.FtpWebRequest]::create($source2)
	if ($credentials) { $ftp.Credentials = $credentials }

    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
	'Delete: ' + $source
    $ftp.GetResponse()
}

#set Crednetials
$credentials = new-object System.Net.NetworkCredential($user, $pass)

#set folder path
$ftpFolderPath= $ftp + "/" + $ftpPath + "/"

$files = Get-FTPDir -url $ftpFolderPath -credentials $credentials

$webclient = New-Object System.Net.WebClient 
$webclient.Credentials = $credentials 

foreach ($file in ($files | Where-Object {$_ -like $fileExt})){
	$source = $ftpFolderPath + $file  
	$destination = $localPath + $file 

	#copy file
	$webclient.DownloadFile($source, $destination)
	'Copy: ' + $source + ' -> ' + $destination

	#delete file
	Remove-FtpFile -source $source -credentials $credentials
}