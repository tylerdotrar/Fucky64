function Fucky64 {
#.SYNOPSIS
# Convoluted integer-based key encryption / decryption of strings and files.
# ARBITRARY VERSION NUMBER:  2.4.7
# AUTHOR:  Tyler McCann (@tyler.rar)
#
#.DESCRIPTION
# This function aims to encrypt / encode cleartext messages OR files using the -Encrypt switch, and is 
# decrypted / decoded by the -Decrypt switch.  If -File is used, neither -Verbose nor -Invoke will work; if
# -Verbose is used is used, -Invoke will not work.  If a key was used for encryption, the returned encrypted
# message will be in a pseudo-numerical output.  If no key was used, the returned message will be encoded the
# in a heavily modified base64 output.  If a key was used, the decryption will return an error until the 
# proper decryption key is used. Maximum key length is ten digits; specifically 2,147,483,647.  The -Invoke 
# parameter only works when using the -Decrypt switch.  The -Encrypt and -Message parameters don't need to be
# specified; set as the default.
#
# Supports alternate data streams (ADS).
#
# Recommendations:
# -- Use 'FuckySuite.psm1' (and included instructions) from the repo to load this script from your $PROFILE.
#
# Parameters:
#    -Encrypt       -->    Utilize encoding / encryption functionality
#    -Decrypt       -->    (Optional) Utilize decoding / decryption functionality
#    -Message       -->    The message to be encrypted / decrypted
#    -File          -->    (Optional) The file to be encrypted / decrypted; supports ADS
#    -Key           -->    (Optional) The key used to encrypt / decrypt the message
#    -Verbose       -->    (Optional) Display the encrypting / decrypting process step-by-step
#    -Invoke        -->    (Optional) Direct invokation of a successfully decrypted command
#    -Help          -->    (Optional) Return Get-Help information
#
# Example Usage:
#    []  PS C:\Users\Bobby> Fucky64 -Encrypt -Message 'Test' -Key 123456
#        425.779759590461E441.655877397615E441.655861197512E410.392909214619E410.38952339295E410.391297304303
#    
#    []  PS C:\Users\Bobby> Fucky64 -Encrypt -File C:\RealFile.txt -Key 123
#        File successfully encrypted.
#
#    []  PS C:\Users\Bobby> $Command = Fucky64 'mkdir MalwareDir > $NULL; cd MalwareDir' -Key 12345
#
#    []  PS C:\Users\Bobby> Fucky64 -Decrypt $Command -Key 54321 -Invoke
#        Incorrect key.
#
#    []  PS C:\Users\Bobby> Fucky64 -Decrypt $Command -Key 12345 -Invoke
#
#    []  PS C:\Users\Bobby\MalwareDir>
#
#.LINK
# https://github.com/tylerdotrar/Fucky64

    Param (
        [switch] $Encrypt = $TRUE,
        [switch] $Decrypt,
        [string] $Message,
        [string] $File,
        [int]    $Key,
        [switch] $Verbose,
        [switch] $Invoke,
        [switch] $Help
    )

    # Encryption / Decryption Functions
    function Fucky64-Encrypt {

        if ($File) {
            
            $Verbose = $FALSE

            # Set $Message variable to file contents; convert formatting into unique strings for decrypting / decoding back into the original format
            if (Test-Path -LiteralPath $File 2>$NULL) {

                $Message = ((Get-Content -LiteralPath $File) -join '!!/NEWLINE\!!' ).replace("`t",'!!/TAB\!!').replace(">",'!!/GT\!!').replace("<",'!!/LT\!!')

                # Detect if input $File is an Alternate Data Stream
                if ((Get-Item -LiteralPath $File).PSChildName -like "*:*") { $ADSbool = $TRUE }
            }

            else {
                Write-Host "File does not exist." -ForegroundColor Red
                break
            }
        }


        # Convert message contents to base64 and modify output
	    $64text = [convert]::ToBase64String([System.Text.encoding]::Unicode.GetBytes($Message))
	    $ModifiedText = $64text.replace("A","+").replace("B","-").replace("=","!")
        

        # Segregate modified base64 into even and odd character arrays and append into a string
	    $EvenArray = @()
	    $OddArray = @()
        
        for ($CharIndex = 0; $CharIndex -lt $ModifiedText.Length; $CharIndex += 2) {
            
            $OddArray += $ModifiedText[$CharIndex]
            $EvenArray += $ModifiedText[$CharIndex + 1]
        }
        
        $Segregated = ($EvenArray + $OddArray) -join ""


        # Convert segregated string to hexadecimal strings (spaced and conjoined)
	    $HexArray = @()

        for ($CharIndex = 0; $CharIndex -lt $Segregated.Length; $CharIndex++) {
            $HexArray += [System.String]::Format("{0:X}", [System.Convert]::ToUInt32($Segregated[$CharIndex]))
	    }

        $SpacedHex = $HexArray -join " "
        $JoinedHex = $SpacedHex -replace " ",""


        ### Encoding and encryption split into different processes ###


        # Start Encryption Process
        if ($Key) {
            
            # Create ASCII strings (spaced and conjoined)
            $SpacedASCII = [byte[]][char[]]$JoinedHex
            $JoinedASCII = $SpacedASCII -join ""


            # Create 8 character ASCII substrings
            $ASCIIarray = @()

            for ($CharIndex = 0; $CharIndex -lt $JoinedASCII.Length; $CharIndex += 8) {
                $ASCIIarray += $JoinedASCII[$CharIndex..($CharIndex+7)] -join ""
            }
            

            # Divide each substring by the key and segregate into even and odd arrays.
            $FuckyPreFlip = @()

            foreach ($Substring in $ASCIIarray) { $FuckyPreFlip += $Substring / $Key }

	        $FinalEvenArray = @()
	        $FinalOddArray = @()
            
            for ($SubstringIndex = 0; $SubstringIndex -lt $FuckyPreFlip.Count; $SubstringIndex += 2) {
            
                $FinalOddArray += $FuckyPreFlip[$SubstringIndex]
                $FinalEvenArray += $FuckyPreFlip[$SubstringIndex + 1]
            }

            $FinalFlippedArray = $FinalEvenArray + $FinalOddArray


            # Generate random alphabetical delimiter and create final message
            $Delim = (65..90) | Get-Random | % { [char]$_ }
            $EncryptedMsg = $FinalFlippedArray -join "$Delim"
        }

        # Start Encoding Process
        else {
            
            # Convert conjoined hexadecimal string to second base64 and modify output
	        $64ception = [convert]::ToBase64String([System.Text.encoding]::Unicode.GetBytes($JoinedHex))
	        $Modified64ception = $64ception.replace("A","+").replace("B","-").replace("=","!")

            
            # Create second even and odd array mix and create final message
	        $FinalEvenArray = @()
	        $FinalOddArray = @()
            
            for ($CharIndex = 0; $CharIndex -lt $Modified64ception.Length; $CharIndex += 2) {
            
                $FinalOddArray += $Modified64ception[$CharIndex]
                $FinalEvenArray += $Modified64ception[$CharIndex + 1]
            }

            $EncodedMsg = ($FinalEvenArray + $FinalOddArray) -join ""
        }


        # Return (MESSAGE)
        if (!$File) {
            
            # Display step-by-step encryption / encoding process (messages only)
            if ($Verbose) {

                Write-Host "`n Cleartext:"       -ForegroundColor Yellow ;  Write-Host " $Message"
                if ($Key) { Write-Host "`n Key:" -ForegroundColor Yellow ;  Write-Host " $Key" }

	            Write-Host "`n Message             -->   Base64: "          -ForegroundColor Yellow ;         Write-Host " $64text"
	            Write-Host "`n Base64              -->   Modified Base64: " -ForegroundColor Yellow ;         Write-Host " $ModifiedText"
	            Write-Host "`n Modified Base64     -->   Segregated-64: "   -ForegroundColor Yellow ;         Write-Host " $Segregated"
	            Write-Host "`n Segregated-64       -->   Hexadecimal: "     -ForegroundColor Yellow ;         Write-Host " $SpacedHex"
                Write-Host "`n Hexadecimal         -->   Conjoined Hex: "   -ForegroundColor Yellow ;         Write-Host " $JoinedHex"

                if ($Key) {
                    Write-Host "`n Conjoined Hex       -->   Conjoined ASCII:"   -ForegroundColor Yellow ;    Write-Host " $JoinedASCII"
                    Write-Host "`n Conjoined ASCII     -->   ASCII Substrings:"  -ForegroundColor Yellow ;    Write-Host " $ASCIIarray"
                    Write-Host "`n ASCII Substrings    -->   Fucky64 Pre-Flip: " -ForegroundColor Yellow ;    Write-Host " $FuckyPreFlip"
                    Write-Host "`n Fucky64 Encrypted Message: "                  -ForegroundColor Yellow ;    Write-Host " $EncryptedMsg `n"
                }

	            else {
                    Write-Host "`n Conjoined Hex       -->   64-Ception:"          -ForegroundColor Yellow ;  Write-Host " $64ception"
	                Write-Host "`n 64-Ception          -->   Modified 64-Ception:" -ForegroundColor Yellow ;  Write-Host " $Modified64ception"
                    Write-Host "`n Fucky64 Encoded Message:"                       -ForegroundColor Yellow ;  Write-Host " $EncodedMsg `n"
                }
            }


            # Only return the final encrypted / encoded message
            else {

                if ($Key) { return $EncryptedMsg }
                else { return $EncodedMsg } 
            }
        }


        # Return (FILE)
        else {
            
            # Encrypted File
            if ($Key) {

                if ($ADSbool) {
                    Set-Content -LiteralPath $File -Value $EncryptedMsg
                    Write-Host "ADS successfully encrypted." -ForegroundColor Yellow
                }    

                else {
                    Write-Output $EncryptedMsg > $File
                    Write-Host "File successfully encrypted." -ForegroundColor Yellow
                }
            }
            

            # Encoded File
            else {

                if ($ADSbool) {
                    Set-Content -LiteralPath $File -Value $EncodedMsg
                    Write-Host "ADS successfully encoded." -ForegroundColor Yellow
                }
                else {
                    Write-Output $EncodedMsg > $File
                    Write-Host "File successfully encoded." -ForegroundColor Yellow
                }
            }
        }
    }
    function Fucky64-Decrypt {

        if ($File) {
            
            $Verbose = $FALSE

            # Set $Message variable to encoded / encrypted file contents
            if (Test-Path -LiteralPath $File 2>$NULL) {

                $Message = (Get-Content -LiteralPath $File)
                
                # Detect if input $File is an Alternate Data Stream
                if ((Get-Item -LiteralPath $File).PSChildName -like "*:*") { $ADSbool = $TRUE }
            }

            else {
                Write-Host "File does not exist." -ForegroundColor Red
                break
            }
        }


        # Start Decryption Process
        if ($Key) {

            $EncryptedMsg = $Message
            
            # Remove alphabet delimiters from encrypted message and create array (segregated key-divided ASCII pieces)
            $NoAlphabet = $EncryptedMsg -Replace "[A-Z]", " "
            $KeyedSegments = $NoAlphabet.split(" ")


            # Create even and odd (key-divided ASCII) substring array and create unsegregated (aka original order) array
            $KeyEvenArray = @()
            $KeyOddArray = @()
            $FuckyPreFlip = @()

            for ($Substring = 0; $Substring -lt $KeyedSegments.Count; $Substring++ ) {

                if ($Substring -lt ($KeyedSegments.Count / 2) ) { $KeyEvenArray += $KeyedSegments[$Substring] }
                else { $KeyOddArray += $KeyedSegments[$Substring] }
            }

            for ($Substring = 0; $Substring -lt $KeyedSegments.count; $Substring++) {

                $FuckyPreFlip += $KeyOddArray[$Substring]
                $FuckyPreFlip += $KeyEvenArray[$Substring]
            }


            # Multiply each keyed ASCII substring by the key to get original ASCII string
            $DekeyedASCII = @()

            for ($Substring = 0; $Substring -lt $KeyedSegments.count; $Substring++) {

                $KeyedSubstring = [double]$FuckyPreFlip[$Substring]
                $DekeyedSubstring = $KeyedSubstring * $Key

                $TinyFix = [math]::Round($DekeyedSubstring)
                $DekeyedASCII += $TinyFix
            }
            
            $JoinedASCII = $DekeyedASCII -join ""


            # Split conjoined ASCII string into 8 character arrays; ONLY used for verbosity
            if ($Verbose) {

                $ASCIIarray = @()

                for ($CharIndex = 0; $CharIndex -lt $JoinedASCII.Length; $CharIndex += 8) {
                    $ASCIIarray += $JoinedASCII[$CharIndex..($CharIndex+7)] -join ""
                }
            }


            # Convert ASCII to conjoined hexadecimal string
            $JoinedHex = @()

            for ($ASCIIchar = 0; $ASCIIchar -lt $JoinedASCII.Length; $ASCIIchar += 2) {
                
                $ASCIIbyte = $JoinedAscii[$ASCIIchar..($ASCIIchar+1)] -join ""
                $HexCharacter = [char[]][byte[]]$ASCIIbyte
                $JoinedHex += $HexCharacter
            }

            $JoinedHex = $JoinedHex -join ""
        }


        # Start Decoding Process
        else {

            $EncodedMsg = $Message

            # Spit encoded message in half (creating even and odd character arrays)
	        $EvenArray = @()
	        $OddArray = @()

            for ($CharIndex = 0; $CharIndex -lt $EncodedMsg.Length; $CharIndex++) {

                if ($CharIndex -lt ($EncodedMsg.Length / 2) ) { $EvenArray += $EncodedMsg[$CharIndex] }
                else { $OddArray += $EncodedMsg[$CharIndex] }
            }


            # Create unsegregated modified base64 message (Original Order)
            $Modified64ception = @()

            for ($Index = 0; $Index -lt $EncodedMsg.Length; $Index++) {

                $Modified64ception += $OddArray[$Index]
                $Modified64ception += $EvenArray[$Index]
            }

            $Modified64ception = $Modified64ception -join ""


            # Unmodify base64 and convert to hexadecimal
            $64ception = $Modified64ception.replace("+","A").replace("-","B").replace("!","=")
            $JoinedHex = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($64ception))
        }


        ### Decoding and decryption converge into the same process ###


        # Split conjoined hexadecimal string into separated hex bytes
        $SpacedHex = @()

        for ($HexIndex = 0; $HexIndex -lt $JoinedHex.Length; $HexIndex += 2) {
            $SpacedHex += $JoinedHex[$HexIndex..($HexIndex+1)] -join ""
        }

        $SpacedHex = $SpacedHex -join " "


        # Convert hexadecimal bytes back into segregated modified base64
        $Segregated = $SpacedHex -split ' ' | % {[char][byte]"0x$_"}
        $Segregated = $Segregated -join ""


        # Split segregated modified base64 array in half (creating even and odd arrays)
        $FinalEvenArray = @()
        $FinalOddArray = @()

        for ($CharIndex = 0; $CharIndex -lt $Segregated.Length; $CharIndex++) {

            if ($CharIndex -lt ($Segregated.Length / 2) ) { $FinalEvenArray += $Segregated[$CharIndex] }
            else { $FinalOddArray += $Segregated[$CharIndex] }
        }


        # Create unsegregated modified base64 string (Original Order)
        $ModifiedText = @()

        for ($Index = 0; $Index -lt $Segregated.Length; $Index++) {

            $ModifiedText += $FinalOddArray[$Index]
            $ModifiedText += $FinalEvenarray[$Index]
        }

        $ModifiedText = $ModifiedText -join ""


        # Unmodify to original base64 and convert to original message
        $64text = $ModifiedText.replace("+","A").replace("-","B").replace("!","=")
        $Cleartext = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($64text))


        # If message isn't cleartext OR initial hex string not valid characters, decryption failed
        if (!$Cleartext -or ($JoinedHex -notmatch '^[A-Z0-9]+$')) {

            if ($Key) { Write-Host "Incorrect key." -ForegroundColor Red }
            else { Write-Host "No key entered." -ForegroundColor Red }

            return
        }


        # Return (MESSAGE)
        if (!$File) {
            
            # Display step-by-step decryption / decoding process (messages only)
            if ($Verbose) {

                if ($Key) {
                    Write-Host "`n Fucky64 Encrypted Message:"                  -ForegroundColor Yellow ;     Write-Host " $EncryptedMsg"
                    Write-Host "`n Encrypted Message   -->   Fucky64 Pre-Flip:" -ForegroundColor Yellow ;     Write-Host " $FuckyPreFlip" 
                    Write-Host "`n Fucky64 Pre-Flip    -->   ASCII Substrings:" -ForegroundColor Yellow ;     Write-Host " $ASCIIarray"
                    Write-Host "`n ASCII Substrings    -->   Conjoined ASCII:"  -ForegroundColor Yellow ;     Write-Host " $JoinedASCII"
                    Write-Host "`n Conjoined ASCII     -->   Conjoined Hex:"    -ForegroundColor Yellow ;     Write-Host " $JoinedHex"
                }

                else {
	                Write-Host "`n Fucky64 Encoded Message:"                       -ForegroundColor Yellow ;  Write-Host " $EncodedMsg"
                    Write-Host "`n Encoded Message     -->   Modified 64-Ception:" -ForegroundColor Yellow ;  Write-Host " $Modified64ception"
                    Write-Host "`n Modified 64-Ception -->   64-Ception:"          -Foregroundcolor Yellow ;  Write-Host " $64ception"
                    Write-Host "`n 64-Ception          -->   Conjoined Hex:"       -ForegroundColor Yellow ;  Write-Host " $JoinedHex"
                }

                Write-Host "`n Conjoined Hex       -->   Hexadecimal:"     -ForegroundColor Yellow ;          Write-Host " $SpacedHex"
	            Write-Host "`n Hexadecimal         -->   Segregated-64:"   -ForegroundColor Yellow ;          Write-Host " $Segregated"
	            Write-Host "`n Segregated-64       -->   Modified Base64:" -ForegroundColor Yellow ;          Write-Host " $ModifiedText"
	            Write-Host "`n Modified Base64     -->   Base64:"          -ForegroundColor Yellow ;          Write-Host " $64text"

                if ($Key) { Write-Host "`n Key:" -ForegroundColor Yellow ;  Write-Host " $Key" }
	            Write-Host "`n Cleartext:"       -ForegroundColor Yellow ;  Write-Host " $Cleartext `n"
            }


            # Invoke successfully decrypted / decoded PowerShell code
            elseif ($Invoke) { Invoke-Expression -Command $Cleartext }


            # Only return decrypted / decoded message contents.
            else { return $Cleartext }
        }
        

        # Return (FILE)
        else {
            
            # Replace unique formatting strings with original file formatting.
            $FinalOutput = (Write-Output $Cleartext).replace('!!/NEWLINE\!!',"`r`n").replace('!!/TAB\!!',"`t").replace('!!/GT\!!',">").replace('!!/LT\!!',"<")


            # Alternate Data Stream
            if ($ADSbool) {
                Set-Content -LiteralPath $File -Value $FinalOutput

                if ($Key) { Write-Host "ADS successfully decrypted." -ForegroundColor Yellow }
                else { Write-Host "ADS successfully decoded." -ForegroundColor Yellow }
            }

            # Normal File
            else {
                Write-Output $FinalOutput > $File

                if ($Key) {  Write-Host "File successfully decrypted." -ForegroundColor Yellow }
                else { Write-Host "File successfully decoded." -ForegroundColor Yellow }
            }
        }
    }


    # Return help information
    if ($Help) { return Get-Help Fucky64 }


    $ErrorActionPreference = 'SilentlyContinue'
    if ($Decrypt) { $Encrypt = $FALSE }


    if ($Encrypt) { return Fucky64-Encrypt }
    elseif ($Decrypt) { return Fucky64-Decrypt }
}