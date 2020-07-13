#Requires -Module VMware.VimCommon.Core
<#
.SYNOPSIS
    This script checks one or more VMs Tools status
.DESCRIPTION 
    Checks on the status of VMware tools for chosen Virtual Machines. 
    Can be modified to export to a file or print to the screen. 
.LINK
    https://github.com/justin-leopold/vmware_tools
.PARAMETER VMName
 	Name of the Virtual Machine
.PARAMETER vCenterServer
    Name of the vCenter server where the VM(s) resides
.EXAMPLE
    Get-VmTools "virtualmachinename" -vCenterServer "Vcenter1"
    #>

Function Get-VMTools {
    [CmdletBinding()]
    param
    (
        #Virtual machine name
        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True)]
        [Alias("Name", "VM", "VirtualMachine", "HostName")]
        [string[]]$VmName,
    
        #vCenter Server Name
        [Parameter(Mandatory)]
        [ValidateSet('vcenter1', 'vcenter2')]
        [string]$vCenterServer,

        #Output Option
        [Parameter(Mandatory)]
        [ValidateSet('File', 'Console')]
        [string]$Output
                    
    ) 
    BEGIN {    
        #Connect to vCenter
        if ($credential) {
            Write-Verbose "Credential variable already defined"
        }
        else {
            $credential = Get-Credential
        }

        TRY {
            $Connection = Connect-VIServer -Server $vCenterServer -Credential $credential -ErrorAction Stop
        }
        CATCH {
            Write-Error "Connection to $vCenterServer failed, please check credentials and vCenter spelling"
        }
    }#BEGIN

    PROCESS {
        #Gather VM Names
        <#$Vm = ForEach ($Node in $VmName) {
        Get-VM -Name $Node.Name
    }#>
        if($Null -eq $Connection){

        }
        TRY{
            $VM = Get-Vm $VmName
        }
        CATCH{
            Write-Error "Empty or invalid value specified for VM"
        }
        
    
       
        #Information gathering begins here
        Foreach ($V in $Vm) {
            $VMTools = Get-View -ViewType VirtualMachine -Filter @{"name" = "$V" } -ErrorAction Stop 
            TRY {
                $Computertable = [ordered]@{Vm = ($VMTools.summary.guest.HostName | Out-String).Trim()
                    Status                     = 'VMTools Responded'                                
                    OS                         = ($VMTools.summary.guest.GuestFullName | Out-String).Trim()
                    Tools                      = ($VMTools.summary.guest.toolsstatus | Out-String).Trim()
                }#close hash table
            }
            CATCH {
                $Computertable = [ordered]@{$Vm = ($VMTools.summary.guest.HostName | Out-String).Trim()
                    Status                      = 'VMTools Did not respond'                                
                    OS                          = "Failed"
                    Tools                       = "Failed"
                }#close hash table
                                        
            }
            FINALLY {                             
           
                $computerobjecttable = New-Object -TypeName PSObject -Property $Computertable
                if ($Output -eq "Console") {
                    Write-Output $computerobjecttable
                }
                else {
                    $Location = Get-Location
                    $computerobjecttable | Export-Csv $Location -append -NoTypeInformation
                }
            
                
            }
        }#close for each
    }#PROCESS

    END {
        Disconnect-VIServer $vCenterServer -Confirm:$false
    }
    

} #close function