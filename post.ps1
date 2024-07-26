import ./post.ps1
$OU = "OU=YourOU,DC=yourdomain,DC=com" 
$apiEndpoint = "http://www.example.com/jira/rest/api/2/user" 

Import-Module ActiveDirectory

$users = Get-ADUser -Filter * -SearchBase $OU -Property DisplayName, EmailAddress, SamAccountName

foreach ($user in $users) {
    $userData = @{
        name = $user.SamAccountName
        emailAddress = $user.EmailAddress
        displayName = $user.DisplayName
    }

    $jsonData = $userData | ConvertTo-Json

    $curlCommand = @"
curl -X POST -H "Content-Type: application/json" -d '$jsonData' $apiEndpoint
"@

    Invoke-Expression $curlCommand
}
