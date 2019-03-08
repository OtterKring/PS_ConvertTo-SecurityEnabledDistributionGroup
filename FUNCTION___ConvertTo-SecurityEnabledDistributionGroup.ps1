<#
.SYNOPSIS
Convert a security group to a mail enabled universal security group for use with Exchange 2013+

.DESCRIPTION
Convert a security group to a mail enabled universal security group for use with Exchange 2013+

Prerequisite is an AD group created as security group. If it was created as distribution group in AD, the function will refuse the transformation, because Exchange requires the groups to be created as security groups and then transformed to distribution groups to e.g. be able to use them for mailbox folder permissions.

The function requires to be run with Exchange Cmdlets (Get-Group, Set-Group, Enable-DistributionGroup) loaded (Exchange Management Console or Powershell with imported session from Exchange)

.PARAMETER Identity
Takes the Identity parameter of a group, ValueFromPipelineByPropertyName supported

.PARAMETER SamAccountName
Use the SamAccountName instead of Identity, pipelinesupport, but without property name

.EXAMPLE
ConvertTo-SecurityEnabledDistributionGroup -SamAccountName HRGroup

.EXAMPLE
Get-Group HRGroup | ConvertTo-SecurityEnabledDistributionGroup

.NOTES
v1 by Maximilian Otter, 20190308
#>
#
function ConvertTo-SecurityEnabledDistributionGroup {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        $Identity,
        [Parameter(ValueFromPipeline)]
        $SamAccountName
    )
    
    begin {

        # check if exchange cmdlets are available
        if (-not(Get-Command -Name Get-Group)) {
            Throw 'Exchange Cmdlets required'
        }

    }
    
    process {

        # initialize used variables
        $ID = $null
        $Group = $null

        # only do something, if one or our parameters is available
        if ($PSBoundParameters.count -eq 0) {
            Write-Error 'Identity or SamAccountName not defined.'
        } else {

            # collect whatever parameter value was set
            if ($PSBoundParameters.ContainsKey('Identity')) {
                $ID = $Identity
            } elseif ($PSBoundParameters.ContainsKey('SamAccountName')) {
                $ID = $SamAccountName
            }

            # get the group and complain on whatever error occurs
            try {
                $Group = Get-Group $ID
            } catch {
                Write-Error $Error[0].Exception
            }

            # found a group? Great, continue...
            if ($Group) {

                # group not already what we want?
                if ($Group.RecipientTypeDetails -ne 'MailUniversalSecurityGroup') {

                    # only do something for security groups. if this must always be set when creating the group,
                    # otherwise Exchange won't accept the MailUniversalSecurityGroup
                    if ($Group.GroupType -clike '*SecurityEnabled') {

                        # group not yet universal? set it...
                        if ($Group.GroupType -cnotlike 'Universal*') {

                            Write-Information "Setting group $($Group.Name) to type `"Universal`" ..."
                            try {
                                Set-Group $Group -Universal
                            } catch {
                                Write-Error $Error[0].Exception
                            }

                        }

                        # group universal (already or set before)? mail-enable ...
                        if ($Group.GroupType -clike 'Universal*') {

                            Write-Information "Mail-enabling group $($Group.Name) ..."
                            try {
                                Enable-DistributionGroup -Identity $Group.Identity
                            } catch {
                                Write-Error $Error[0].Exception
                            }
                        }

                    } else {
                        Write-Error "Group $($Group.Name) is not security enabled. This is a base requirement for creating mail enabled security groups."
                    }

                } else {
                    # the group already is what we want, nothing else to do
                    Write-Information "Group $($Group.Name) already is of type MailUniversalSecurityGroup. Nothing else to do."
                }
            }
        }
    }
    
    end {
        # nothing yet
    }
}