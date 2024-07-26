# Define the OU variable
$OU = "OU=YourOU,DC=yourdomain,DC=com"  # Replace with your actual OU

# Define the output CSV file path
$outputCSV = "C:\path\to\output\users.csv"  # Replace with your desired file path

# Import the Active Directory module
Import-Module ActiveDirectory

# Get the user data from the specified OU
$users = Get-ADUser -Filter * -SearchBase $OU -Property DisplayName, EmailAddress, SamAccountName

# Select the required properties and create a new object for CSV export
$userData = $users | Select-Object @{Name="Email";Expression={$_.EmailAddress}},
                                   @{Name="DisplayName";Expression={$_.DisplayName}},
                                   @{Name="Username";Expression={$_.SamAccountName}}

# Export the user data to a CSV file
$userData | Export-Csv -Path $outputCSV -NoTypeInformation

Write-Host "User data exported to $outputCSV"
