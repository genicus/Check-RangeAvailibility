
<#
.SYNOPSIS
  Name: Check-Range.ps1
  This script checks the availibility (of a range) of phone numbers.
  
.PARAMETER Start
  The start phone number, in international format, without the plus (+) sign : example 3222742840
.PARAMETER End
  The end phone number, in international format, without the plus (+) sign : example 3222742860

.NOTES
  Release: 2017-10-10
   
  Author: Leendert De Cae

.EXAMPLE
 .\Check-RangeAvailibility.ps1 -Start 3216279600 -End 3216279699

#>

param(
    [double]$Start,
    [double]$End = $start
)

function lookup($start, $end)
{
    if($start -le $end)
    {
        $workflows = Get-CsRgsWorkflow

        for($i = $start; $i -le $end; $i++)
        {
            $sipuri = "tel:+$i"
            $user = Get-CsUser -Filter {LineUri -eq $sipuri}
            $endpoint = Get-CsTrustedApplicationEndpoint -Filter {LineUri -eq $sipuri}
            $workflow = $workflows | Where-Object {$_.LineUri -eq $sipuri}
            $DispNumbr = "+$i"
            $caphone = Get-CsCommonAreaPhone -Filter {DisplayNumber -like $DispNumbr}
            $analogp = Get-CsAnalogDevice -Filter {LineURI -eq $sipuri}
            $name = $user.displayname
            if($user)
            {
                $samaccount = $user.samaccountname
                $name = $user.displayname
                Write-Host "+$i is in use by a user ($samaccount  $name)"
            }
            elseif($endpoint)
            {
                $display = $endpoint.DisplayName
                Write-Host "+$i is in use by an endpoint ($display)" -ForegroundColor Yellow
            }
            elseif($workflow)
            {
                $display = $workflow.Name
                Write-Host "+$i is in use by a response group ($display)" -ForegroundColor Red
            }elseif($caphone)
            {
                $display = $caphone.DisplayName
                Write-Host "+$i is in use by a Common Area Phone ($display)"
            }elseif($analogp)
            {
                $display = $analogp.DisplayName + " -> " + $analogp.Gateway
                Write-Host "+$i is in use by an Analog Phone ($display)"
            }
            else
            {
                Write-Host "+$i is not in use" -ForegroundColor Green
            }
        }
    }
    else
    {
        Write-Host "ERROR: end is lower than start."
    }
}
lookup -start $Start -end $End
