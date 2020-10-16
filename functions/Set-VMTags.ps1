<#  
    .SYNOPSIS  
        Sets VMs to a certain tag. 
    .DESCRIPTION  
        Sets VMs to a certain tag
    .NOTES  
        File Name   : Set-VMTags.ps1  
        Author      : Justin Leopold - 3/12/2018
        Written on  : Powershell 6.2
        Tested on   : Powershell 6.2
        Requires    : PowerCLI
    .LINK 
    .EXAMPLE
        $VM = server1
        Get-VM $VM | Set-VMTags -Tag "Production"

        
    #>

#This only works with powershell 6 or greater
Class TagNames : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $TagNames = (Get-Tag).Name
                        
        return [string[]] $TagNames
    }
}
Function Set-VMTags {
    [CmdletBinding()]
    param
    (
        #Virtual machine name
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string[]]$Vms,
    
        #vCenter Server Name
        [Parameter]
        [string]$vcenterserver,

        #Tags, class above gathers info
        [ValidateSet([TagNames])]
        [String]$Tag
    )

    If($null -eq $vcenterserver){
        $vCenter = Read-Host -Prompt "Enter the name of the vCenter server to execute this command against"
    }
    TRY{
        Connect-VIServer -Server $vCenter
    }
    CATCH{
        Write-Error "Credentials were not correct or the SSL certificate is not trusted"
    }

    Foreach ($Vm in $VMs) {
        New-TagAssignment -Tag $Tag -Entity $Vm -Server $vcenterserver
    }
} 