# Optionally populate the queue URLs
$baseDir = Get-Location
$configFile = "\blank.json"

try 
{
	$config = Get-Content "$baseDir$configFile" | ConvertFrom-Json
} 
catch 
{
	Write-Error -Message "The config file is missing"
}
# Login to AWS using supplied credentials
Set-AWSCredentials -AccessKey $config.settings.AccessKey -SecretKey $config.settings.SecretKey
Set-DefaultAWSRegion $config.settings.Region;

$queuelist = aws sqs list-queues | ConvertFrom-Json
if ($null -eq $queuelist)
{
    Write-Host 'No queues found for the given AWS profile'
}
else
{
	Write-Host "The following queue URLs have been found that ars not in the config file - "
	foreach($item in $queuelist.QueueUrls)
	{
		$writeflag = 1
		foreach ($element in $config.settings.QueueUrls)
		{
			if ($element -eq $item)
			{
				$writeflag = 0
			}
		}
		if ($writeflag -eq 1)
		{
			Write-Host $item
		}
	}
}
