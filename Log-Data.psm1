<#
.SYNOPSIS
Very simple function for logging

.DESCRIPTION
Takes a message and then appends it to a file for later analysis. Stores these in the log file (csv format) with additional information...
dateTime,entry,username,scriptname,commandlineOptions

.PARAMETER entries
The string (or array of strings) that you want to log

.PARAMETER type
String. Either "INFO", "WARNING" or "ERROR"

.PARAMETER logFile
String. The name of the logfile if you don't want it going to the default. If it doesn't exist we'll try and create it.

.OUTPUTS
Returns the entries so that you can pipe them into something like write-host or write-verbose

#>

Function Log-Data {
    Param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String[]] $entries,
        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet("INFO","WARNING","ERROR")]
        [String] $type = "INFO",
        [Parameter(Mandatory = $false, Position = 2)]
        [String] $logFile
    )

    #region set logfile
    BEGIN {
        # did the user specify a logfile?
        if (-not $PSBoundParameters.ContainsKey('logFile'))
        {
            # no value for logFile was set so we need to define it here
            # default logfile, one per day in our logging directory
            $logFilePrefix = "C:\sikkerhetsInformasjon\logs\"
            $logFilePrefix = ".\"                               # temp fix for local development
            $logFileName = (get-date -format yyyyMMdd) + ".log"
            $logFile = $logFilePrefix + $logFileName
        }
        if (-Not(Test-Path $logFile -PathType Leaf))
        {
            # try and create the file if it doesn't already exist...
            try 
            {
                New-Item $logFile    
            }
            catch 
            {
                Write-Error ("File '{0}' doesn't exist and I couldn't create it.")

                #pass the entries through onto the command line pipe
                return $entries
            }
        }
        # setup an array to put the returning variables in
        $toReturn = @()
    }
    #endregion
    
    #region process for each entry
    PROCESS {
        foreach ($entry in $entries)
        {
            # construct the command line parameters into a string
            $parameters = ""
            foreach ($key in $MyInvocation.BoundParameters.keys)
            {
                
                $parameters += ('-{0} ' -f $key)
                foreach ($value in $MyInvocation.BoundParameters[$key])
                {
                    $parameters += ('"{0}", ' -f $value)
                }
                $parameters = $parameters.Substring(0,$parameters.Length-2) + " "
            }

            # create the object that will be the line in the logfile
            $toLog = New-Object psobject -Property @{
                dateTime = (Get-Date -Format o);
                type = $type;
                entry = $entry;
                username = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name);
                scriptname = ($MyInvocation.MyCommand);
                commandlineOptions = $parameters
            }
        
            # now output the details to the logfile
            $toLog | Export-Csv -Path $logFile -Append
        }
        # add the log message to the return array
        $toReturn += $entry
    }
    #end region

    #region return the entries so that the next command can deal with them
    END {
        # return the array
        return $toReturn
    }   
    #endregion
    
}
