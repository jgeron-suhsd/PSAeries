Function Get-AeriesStudent{
<#
.SYNOPSIS
    Gets one or more Aeries Students
.DESCRIPTION
    The Get-AeriesStudent function gets a student object or performs a search to retrieve multiple student objects.
.EXAMPLE
    Get-ADUser -SchoolCode 1
    Get all users under the school matching school code 1.
    .PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including -Verbose
    Param(
        [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            # HelpMessage='HelpMessage',
            Position=0)]
        [ValidatePattern('[0-9]')] #Validate that the string only contains letters
        [Alias("User", "StudentID")]
        [String[]]$ID,

        # School Code under whitch to search for students
        [Parameter(Mandatory=$True)]
            [String]$SchoolCode,

        # Grade level of students
        [Parameter(Mandatory=$False)]
        [String]$Grade,

        # StudentNumber by which to search for the student
        [Parameter(Mandatory=$False)]
        [String]$StudentNumber
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        
        Write-Verbose "Using Config: $Config"
        # URL to access Aeries API
        $APIURL = $Config.APIURL
        Write-Verbose "APIURL: $APIURL"
        
        #Headers for Aeries API
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add('AERIES-CERT', $APIKey.GetNetworkCredential().Password)
        $headers.Add('accept', 'application/json')
    }
    Process{
        # If no users are specified, get all students
        try{ #Error handling
            if ($ID.Count -lt 1 -and !$Grade -and !$StudentNumber) {
                Write-Verbose -Message "Listing all students..."
                $path = $APIURL + 'schools/' + $SchoolCode + '/students/'
                $result = Invoke-RestMethod $path -Headers $headers
                return $result
                }
            elseif ($grade) {
                Write-Verbose -Message "Listing all students in grade $Grade..."
                $path = $APIURL + 'schools/' + $SchoolCode + '/students/grade/' + $Grade
                $result = Invoke-RestMethod $path -Headers $headers
                return $result
            }
        }
        catch{
            Write-Error -Message "$_ went wrong."
        }
        
        if ($ID.Count -gt 0)
        {
            ForEach($stu in $ID){ #Pipeline input
                try{
                    Write-Verbose -Message "Searching for Student with ID Number $stu..."
                    $path = $APIURL + 'schools/' + $SchoolCode + '/students/' + $stu
                    $result = Invoke-RestMethod $path -Headers $headers
                    return $result
                }
                catch{
                    Write-Error -Message "$_ went wrong on $stu"
                }
            }
        }
        

        ForEach($stu in $StudentNumber){ 
            try{
                Write-Verbose -Message "Searching for Student with Student Number $stu..."
                $path = $APIURL + 'schools/' + $SchoolCode + '/students/sn/' + $stu
                $result = Invoke-RestMethod $path -Headers $headers
                return $result
            }
            catch{
                Write-Error -Message "$_ went wrong on $stu"
            }
        }
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}