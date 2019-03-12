function Get-PSGitaToken
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $ClientID,

        [Parameter(Mandatory = $true)]
        [String]
        $ClientSecret
    )

    $params = @{
        ContentType = 'application/x-www-form-urlencoded'
        Headers = @{'accept'='application/json'}
        Body = "client_id=$ClientID&client_secret=$ClientSecret&grant_type=client_credentials&scope=verse%20chapter"
        Method = 'Post'
        URI = "https://bhagavadgita.io/auth/oauth/token"
    }

    $resp = Invoke-RestMethod @params
    $token = $resp.access_token

    if (!$token)
    {
        throw 'Error retrieving an OAuth token!'
    }
    else
    {
        return $token
    }
}

function Get-PSGitaChapter
{
    [CmdletBinding()]
    
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $GitaToken,
        
        [Parameter()]
        [ValidateRange(1,18)]
        [Int]
        $Chapter
    )

    $uri = 'https://bhagavadgita.io/api/v1/chapters'
    $headers = @{'Authorization'="Bearer $GitaToken"}

    if ($Chapter)
    {
        $uri = "$uri/$Chapter"
    }

    $resp = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -Headers $headers

    if (!$resp)
    {
        throw 'Error retrieving chapter!'
    }
    else
    {
        return $resp
    }
}

function Get-PSGitaVerse
{
    [CmdletBinding()]
    
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $GitaToken,
        
        [Parameter()]
        [ValidateRange(1,18)]
        [Int]
        $Chapter,

        [Parameter()]
        [Int]
        $Verse
    )

    if ($Verse -and !$Chapter)
    {
        throw 'Specifying verse requires a chapter number [1-18] as well!'
    }

    if ($Chapter -and $Verse)
    {
        $uri = ("https://bhagavadgita.io/api/v1/chapters/{0}/verses/{1}" -f $Chapter, $Verse)
    }
    elseif ($Chapter -and !$Verse)
    {
         $uri = ("https://bhagavadgita.io/api/v1/chapters/{0}/verses" -f $Chapter)
    }
    else
    {
        $uri = 'https://bhagavadgita.io/api/v1/verses'
    }

    $headers = @{'Authorization'="Bearer $GitaToken"}

    $resp = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -Headers $headers

    if (!$resp)
    {
        throw 'Error retrieving verse!'
    }
    else
    {
        return $resp
    }
}
