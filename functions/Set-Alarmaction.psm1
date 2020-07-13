#Requires -Modules Vmware.VimAutomation.Core

function Set-AlarmActionState {
    <#  
    .SYNOPSIS  Enables or disables Alarm actions for an object
    .DESCRIPTION The function will enable or disable
      alarm actions on a vSphere entity itself or recursively
      on the object and all its children.
    .NOTES  
      Author:  Justin Leopold
    .LINK
      https://github.com/justin-leopold/vmware_tools
    .PARAMETER Entity
      The vSphere object.
    .PARAMETER Enabled
      Switch that indicates if the alarm actions should be
      enabled ($true) or disabled ($false), Boolean.
    .PARAMETER Recurse
      Switch that indicates if the action shall be taken on the
      entity alone or on the entity and all its children.
    .EXAMPLE
      PS> Get-VmHost vmhostname | Set-AlarmActionState -Enabled:$false
    #>
     
      param(
        [CmdletBinding()]
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.InventoryItemImpl]$Entity,
        [switch]$Enabled,
        [switch]$Recurse
      )
     
      BEGIN{
        $alarmMgr = Get-View AlarmManager
      }
     
      PROCESS{
        if($Recurse){
          $objects = @($Entity)
          $objects += Get-Inventory -Location $Entity
        }
        else{
          $objects = $Entity
        }
        $objects | ForEach-Object{
          $alarmMgr.EnableAlarmActions($_.Extensiondata.MoRef,$Enabled)
        }
      }
    }