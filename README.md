This powershell script is designed to monitor SQS queues for messages. 
It is designed to be run periodically - either as a scheduled task or as a lambda function.

If messages are found in these queues, it will notify the relevant teams of the issue.

The notification implementation can be email or optionally to a slack channel - you will need to provide a valid API token in the case of the latter.

Prerequisites


-The PSSlack module from the powershell gallery if using the slack notifier

-The AWS powershell tools

-Powershell v3 or later

When first populating the config file, you may want to find the queue URLs. The optional discoverUrls script will output the URLs that are returned by the API key specified in the config file