using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

function ParseTimestamp {
    param (
        $Timestamp,
        $StartDate,
        $EndDate
    )
    # TODO: Handle streams that go into the next day
    # TODO: Handle timezones
    (Get-Date "$StartDate $Timestamp").ToString()
}

# Form data comes in as a byte array. Parse it to a string and split by newlines
$formText = [System.Text.Encoding]::UTF8.GetString($Request.Body, 0, $Request.Body.Length) -split "`n"

# The date is in the file name so we find the filename in the headers
$fileNameLocation = 0
while ($formText[$fileNameLocation] -notlike "*filename=`"*") { $fileNameLocation++ }

# And parse out the start and end dates
$splitFileName = ($formText[$fileNameLocation] -split "filename=`"Stream Session from")[1]
$startDate = ($splitFileName -split " to ")[0].Trim()
$endDate = (($splitFileName -split " to ")[1] -split ".csv")[0].Trim()

# Find the top of the csv and throw out the HTTP headers and wrappers
$top = 0
while ($formText[$top] -notlike "Timestamp*") { $top++ }

# Find the bottom of the csv and throw out the HTTP headers and wrappers
$bottom = $top
while ($formText[$bottom] -like "*,*,*,*") { $bottom++ }

$fileText = $formText | Select-Object -Skip $top | Select-Object -SkipLast ($formText.Length - $bottom) | ConvertFrom-Csv

# Format the CSV by parsing ints and doubles and having default values
$formatedObjects = $fileText | ForEach-Object {
    $_.Timestamp =              ParseTimestamp -Timestamp $_.Timestamp -StartDate ($startDate -replace "_","-") -EndDate ($endDate -replace "_","-")
    $_.Viewers =                if ($_.Viewers) {               [double]::Parse($_.Viewers) }               else { 0 }
    $_."Live Views" =           if ($_."Live Views") {          [int]::Parse($_."Live Views") }             else { 0 }
    $_."New Followers" =        if ($_."New Followers") {       [int]::Parse($_."New Followers") }          else { 0 }
    $_.Chatters =               if ($_.Chatters) {              [int]::Parse($_.Chatters) }                 else { 0 }
    $_."Chat Messages" =        if ($_."Chat Messages") {       [int]::Parse($_."Chat Messages") }          else { 0 }
    $_."Ad Breaks" =            if ($_."Ad Breaks") {           [int]::Parse($_."Ad Breaks") }              else { 0 }
    $_.Subscriptions =          if ($_.Subscriptions) {         [int]::Parse($_.Subscriptions) }            else { 0 }
    $_."Clips Created" =        if ($_."Clips Created") {       [int]::Parse($_."Clips Created") }          else { 0 }
    $_."All Clip Views" =       if ($_."All Clip Views") {      [int]::Parse($_."All Clip Views") }         else { 0 }
    $_."Twitch Clip Views" =    if ($_."Twitch Clip Views") {   [int]::Parse($_."Twitch Clip Views") }      else { 0 }
    $_."Reddit Clip Views" =    if ($_."Reddit Clip Views") {   [int]::Parse($_."Reddit Clip Views") }      else { 0 }
    $_."Facebook Clip Views" =  if ($_."Facebook Clip Views") { [int]::Parse($_."Facebook Clip Views") }    else { 0 }
    $_."Twitter Clip Views" =   if ($_."Twitter Clip Views") {  [int]::Parse($_."Twitter Clip Views") }     else { 0 }
    $_."Other Clip Views" =     if ($_."Other Clip Views") {    [int]::Parse($_."Other Clip Views") }       else { 0 }
    $_
}

Push-OutputBinding -Name OutQueue -Value $formatedObjects
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = 200
    Body = "Submitted!"
})
