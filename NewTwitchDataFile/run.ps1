using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$body = html -Style 'text-align:center' {
    head {
        meta -charset 'utf-8'
        meta -name viewport -content_tag 'width=device-width, initial-scale=1'
        Link 'https://cdnjs.cloudflare.com/ajax/libs/bulma/0.7.4/css/bulma.min.css' -rel stylesheet
        Title 'Twitch Data Processing'
    }
    Body {
        header -Style 'padding:10px; background-color:#6441a5; color:#FFF' {
            H1 'Twitch data processing'
        }
        Form AddTwitchDataFile post _self -Id uploadbanner -Attributes @{ 
            enctype='multipart/form-data'
        } -Style '
            margin:10px auto;
            padding: 10px;
            max-width:350px;
            background-color:#EEE;
        ' -Content {
            input -Id fileupload -name myfile -type file
            input -Id submit -name submit -type submit
        }
    }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    ContentType = 'text/html'
    Body = $body
})
