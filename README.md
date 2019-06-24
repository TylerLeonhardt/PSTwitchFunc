# Twitch data processing - a PowerShell Azure Function app

An Azure Function app that I use to analyze stream stats.

This ingests
`csv`'s
from Twitch's Stream Summary page and puts cleaned up rows into an Azure Storage Queue.

![image](https://user-images.githubusercontent.com/2644648/59991475-6593e800-95fc-11e9-90fd-e7fb567ee2fb.png)

From there,
I have a Logic App that takes those rows and puts them in an excel spreadsheet that is the backing of a PowerBI dashboard. The only reason I need the Logic App is because the [Microsoft Graph bindings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-microsoft-graph) weren't working last I tried.

![image](https://user-images.githubusercontent.com/2644648/59991377-01712400-95fc-11e9-919c-e16458b8c273.png)

## What's inside

Two functions:
* `/NewTwitchDataFile` - A simple file upload page that accepts only the
`csv`'s
from Twitch's Stream Summary page.
* `/AddTwitchDataFile` - The backend to
`/NewTwitchDataFile`
that takes in the
`csv`
file,
parses and cleans up the data and then adds each row of the `csv` data to an Azure Storage Queue.

## Future

* Figure out how to handle timezones...
When you download the
`csv`'s
from Twitch,
it downloads it relative to your timezone which means if you upload a file from Seattle or Miami,
the time will be different.
* Revisit [Microsoft Graph bindings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-microsoft-graph) which weren't working last I tried (Mar 2019).
* Simplify code and cleaner UI... lol.
