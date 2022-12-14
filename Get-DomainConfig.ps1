#Requires -Version 5.1

param (
    [Parameter(
        Mandatory = $True,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True,
        HelpMessage = "Specifies the domain."
    )][string]$Name
)

# DKIM First
$DkimSelectors = @(
    'selector1' # Microsoft
    'selector2' # Microsoft
    'google', # Google
    'everlytickey1', # Everlytic
    'everlytickey2', # Everlytic
    'eversrv', # Everlytic OLD selector
    'k1', # Mailchimp / Mandrill
    'mxvault' # Global Micro
    'dkim' # Hetzner
)

foreach ($DkimSelector in $DkimSelectors) {
    $request = Resolve-DnsName -Type TXT -Name "$($DkimSelector)._domainkey.$($Name)"
    if ($request.Type -eq "CNAME") {
        while ($request.Type -eq "CNAME") {
            $DKIMCname = $DKIM.NameHost
            $dkim = Resolve-DnsName -Type TXT -name "$DKIMCname"
            $DKIMResult = $dkim.Strings

            # If we find a result
            if ($DKIMResult -match "v=DKIM1" -or $DKIMResult -match "k=") { $dkimFound = $true; break }
        }
    }
    
    if ($dkimFound -ne $true) {
        $dkimFound = $false
        $DKIMSelector = $null
        $DKIMResult = $null
    }
}

$dkim = [PSCustomObject]@{
    Domain = $Name
    DKIMResult = $dkimFound
    DKIMSelector = $DKIMCname
    DKIMRecord = $DKIMResult
}