# Load settings from config file
$baseDir = Get-Location
$configFile = "\config.json"

try 
{
	$config = Get-Content "$baseDir$configFile" | ConvertFrom-Json
} 
catch 
{
	Write-Error -Message "The config file is missing"
}

$token  = $config.settings.SlackToken

# Login to AWS using supplied credentials
Set-AWSCredentials -AccessKey $config.settings.AccessKey -SecretKey $config.settings.SecretKey
Set-DefaultAWSRegion $config.settings.Region;

foreach ($element in $config.settings.QueueUrls)
{
	$msg = aws sqs get-queue-attributes --queue-url "$element" --attribute-names ApproximateNumberOfMessages | ConvertFrom-Json

	foreach ($anom in $msg.Attributes.ApproximateNumberOfMessages)
	{
		if ($anom -gt 0 -and $element -like '*errors')
		{
			# Notify all teams
			# A notification may be to send an email, message to slack, or push to a webhook API. In this case I will send an email
			Send-MailMessage -To "Team1@domain.nl>" -From "alert@domain.nl>" -Subject "Messages found in SQS error queue"			
		}
		if ($anom -gt 10 -and ($element -like '*new_houses' -or $element -like '*makelaars')) 
		{ 
			# Notify team 1 and 2
			# Here I will use some pseudo code to send a slack message - I am unable to test without a Slack API key
			# You will also need the PSSlack module from the powershell gallery
			$token = 'YOURSLACKAPITOKEN'

			Send-SlackMessage -Token $token 
                  -Channel '@team1and2'
                  -Parse full
                  -Text 'More than 10 messages in new houses or makelaars queues'
		}
		if ($anom -gt 25 -and $element -notlike '*errors')
		{
			# Notify team 3
			Send-MailMessage -To "Team3@domain.nl>" -From "alert@domain.nl>" -Subject "High number of messages found in non-error queues"
		}
		else
		{
			Write-Host "0 messages visible"
		}
	}
}