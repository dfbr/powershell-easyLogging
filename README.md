# powershell-easyLogging
Very simple logging function for powershell. Takes an array of strings and outputs them into a csv file along with other information that you'd expect to find in a log.

File is either a default file (one per day) or a filename that you specify. Information logged is:
- dateTime (ISO compatible format)
- the type of message (e.g. INFO, WARNING, ERROR
- the message that you specified (one per line if you passed an array)
- the username of the person running the script
- the name of the script 
- the parameters that were passed with the script

## Example usage
In your script you can...
- `Import-module Log-Data.psm1` to import
- To log something you can `Log-Data -entries "first log entry", "second log entry" -type "WARNING"`

You can also us it with pipes both in and out, e.g.
- `"first Log entry", "second log entry" | Log-Data | Write-Verbose`
or
- `Log-Data -entries "here is my log entry" | Write-Verbose
This way you get to both log data and have it displayed to the console in one line

## License
Just use it. I don't mind.
