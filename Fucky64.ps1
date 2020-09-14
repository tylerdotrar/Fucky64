function Fucky64 {
#.SYNOPSIS
# Convoluted integer-based key encryption / decryption of strings and files.
# ARBITRARY VERSION NUMBER:  2.0.1
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
        
        Param (
            [string] $Message,
            [string] $File,
            [int]    $Key,
            [switch] $Verbose
        )

        $ErrorActionPreference = 'SilentlyContinue'

        if ($File) {
            
            # Disable -Verbose switch
            $Verbose = $FALSE

            # Set $Message variable to file contents; convert formatting into unique strings for decrypting / decoding back into the original format
            if (Test-Path -LiteralPath $File 2>$NULL) {

                $Message = ( (Get-Content -LiteralPath $File) -join '!!/NEWLINE\!!' ).replace("`t",'!!/TAB\!!').replace(">",'!!/GT\!!').replace("<",'!!/LT\!!')

                # Detect if input $File is an Alternate Data Stream
                if ((Get-Item -LiteralPath $File).PSChildName -like "*:*") { $ADSbool = $TRUE }
            }

            # File location not found.
            else {
                Write-Host "File does not exist." -ForegroundColor Red
                break
            }
        }

        # Convert message contents to base64
	    $64text = [convert]::ToBase64String([System.Text.encoding]::Unicode.GetBytes($Message))

        # Convert base64 to modified base64
	    $ModifiedText = $64text.replace("A","+").replace("B","-").replace("=","!")

        # Convert modifed base64 to a character array
	    $ArrayText = $ModifiedText.ToCharArray()
        
	    $Increment = 0
	    $EvenArray = @()
	    $OddArray = @()
	    $FlippedArray = @()
        
        # Segregate modified base64 into even and odd character arrays
	    foreach ($Char in $ArrayText) {

            if ($Increment%2 -eq 0) { $OddArray += $Char }
    	    else { $EvenArray += $Char }

            $Increment += 1
	    }
        

        # Append even and odd character arrays
	    $FlippedArray += $EvenArray + $OddArray
        $Segregated = $FlippedArray -join ""


        # Convert segregated string to hexadecimal array
	    $HexText = @()
	    foreach ($Char in $FlippedArray) {
            $HexText += " " + [System.String]::Format("{0:X}", [System.Convert]::ToUInt32($Char))
	    }

        
        # Create hexadecimal strings (spaced and conjoined)
	    $SpacedHex = ($HexText -join "").Substring(1)
        $JoinedHex = $SpacedHex.replace(" ","")

        ### Encoding and encryption split into different processes ###

        # Start Encryption Process
        if ($Key) {
            
            # Create ASCII strings (spaced and conjoined)
            $SpacedASCII = [byte[]][char[]]$JoinedHex
            $JoinedASCII = $SpacedASCII -join ""

            # Create 8 character ASCII substrings
            $ASCIIarray = @()
            $Conjoin = ""
            for ($Index = 1; $Index -lt ($SpacedASCII.count + 1); $Index++) {

                $Conjoin += $SpacedASCII[$Index - 1]

                if (($Index%4 -eq "0") -or ($Index -eq $SpacedASCII.count)) {
                    $ASCIIarray += $Conjoin
                    $Conjoin = ""  
                }
            }

            # Divide each substring by the key
            $FuckyPreFlip = @()
            foreach ($Section in $ASCIIarray) { $FuckyPreFlip += $Section / $Key }

            $FinalIncrement = 0
	        $FinalEvenArray = @()
	        $FinalOddArray = @()
	        $FinalFlippedArray = @()
            
            # Segregate key-divided substrings into even and odd arrays
	        foreach ($Item in $FuckyPreFlip) {

                if ($FinalIncrement%2 -eq 0) { $FinalOddArray += $Item }
    	        else { $FinalEvenArray += $Item }

                $FinalIncrement += 1
	        }

	        $FinalFlippedArray += $FinalEvenArray + $FinalOddArray
            
            # Randomly generate alphabetical delimiter
            $Joiner = (65..90) | Get-Random | % { [char]$_ }

            # Final encrypted string
            $EncryptedMsg = $FinalFlippedArray -join "$Joiner"
        }

        # Start Encoding Process
        else {
            
            # Convert conjoined hexadecimal string to second base64
	        $64ception = [convert]::ToBase64String([System.Text.encoding]::Unicode.GetBytes($JoinedHex))

            # Convert second base64 to modified second base64
	        $Modified64ception = $64ception.replace("A","+").replace("B","-").replace("=","!")

            $FinalIncrement = 0
	        $FinalEvenArray = @()
	        $FinalOddArray = @()
            $Final64 = @()
            $Modified64Array = $Modified64ception.ToCharArray()

            # Segregate second modified base64 array into even and odd character arrays
            foreach ($Item in $Modified64Array) {

                if ($FinalIncrement%2 -eq 0) { $FinalOddarray += $Item }
    	        else { $FinalEvenArray += $Item }

                $FinalIncrement += 1
            }

            # Final encoded string
            $Final64 += $FinalEvenArray + $FinalOddArray
            $EncodedMsg = $Final64 -join ""
        }

        # Return (MESSAGE)
        if (!$File) {
            
            # Display step-by-step encryption / encoding process (messages only)
            if ($Verbose) {

                Write-Host "`n Cleartext:" -ForegroundColor Yellow ;       Write-Host " $Message"
                if ($Key) { Write-Host "`n Key:" -ForegroundColor Yellow ; Write-Host " $Key" }

	            Write-Host "`n Message             -->   Base64: " -ForegroundColor Yellow ;          Write-Host " $64text"
	            Write-Host "`n Base64              -->   Modified Base64: " -ForegroundColor Yellow ; Write-Host " $ModifiedText"
	            Write-Host "`n Modified Base64     -->   Segregated-64: " -ForegroundColor Yellow ;   Write-Host " $Segregated"
	            Write-Host "`n Segregated-64       -->   Hexadecimal: " -ForegroundColor Yellow ;     Write-Host " $SpacedHex"
                Write-Host "`n Hexadecimal         -->   Conjoined Hex: " -ForegroundColor Yellow ;   Write-Host " $JoinedHex"

                if ($Key) {
                    Write-Host "`n Conjoined Hex       -->   Conjoined ASCII:" -ForegroundColor Yellow ;  Write-Host " $JoinedASCII"
                    Write-Host "`n Conjoined ASCII     -->   ASCII Substrings:" -ForegroundColor Yellow ; Write-Host " $ASCIIarray"
                    Write-Host "`n ASCII Substrings    -->   Fucky64 Pre-Flip: "-ForegroundColor Yellow ; Write-Host " $FuckyPreFlip"
                    Write-Host "`n Fucky64 Encrypted Message: " -ForegroundColor Yellow ;                 Write-Host " $EncryptedMsg `n"
                }

	            else {
                    Write-Host "`n Conjoined Hex       -->   64-Ception:" -ForegroundColor Yellow ;          Write-Host " $64ception"
	                Write-Host "`n 64-Ception          -->   Modified 64-Ception:" -ForegroundColor Yellow ; Write-Host " $Modified64ception"
                    Write-Host "`n Fucky64 Encoded Message:" -ForegroundColor Yellow ;                       Write-Host " $EncodedMsg `n"
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
        
        Param (
            [string] $Message,
            [string] $File,
            [int]    $Key,
            [switch] $Verbose,
            [switch] $Invoke
        )

        $ErrorActionPreference= 'SilentlyContinue'

        if ($File) {
            
            # Disable -Verbose switch
            $Verbose = $FALSE

            # Set $Message variable to encoded / encrypted file contents
            if (Test-Path -LiteralPath $File 2>$NULL) {

                $Message = (Get-Content -LiteralPath $File)
                
                # Detect if input $File is an Alternate Data Stream
                if ((Get-Item -LiteralPath $File).PSChildName -like "*:*") { $ADSbool = $TRUE }
            }

            # File location not found.
            else {
                Write-Host "File does not exist." -ForegroundColor Red
                break
            }
        }

        # Start Decryption Process
        if ($Key) {

            $EncryptedMsg = $Message
            
            # Remove alphabet delimiters from encrypted message
            $NoAlphabet = $EncryptedMsg -Replace "[A-Z]", " "

            # Create array of segregated key divided ASCII pieces
            $MixedKeyArray = $NoAlphabet.split(" ")

            $KeyedItemNum = $MixedKeyArray.count
            $KeyIncrement = 0
            $KeyEvenArray = @()
            $KeyOddArray = @()

            # Create even and odd arrays from segregated key divided ASCII array
            foreach ($Piece in $MixedKeyArray) {

                if ($KeyIncrement -lt ($KeyedItemNum / 2) ) { $KeyEvenArray += $Piece }
                else { $KeyOddArray += $Piece }

                $KeyIncrement += 1
            }

            # Create unsegregated key divided ASCII array (Original Order)
            $FuckyPreFlip = @()

            for ($Index = 0; $Index -lt $KeyedItemNum; $Index++) {
                $FuckyPreFlip += $KeyOddArray[$Index]
                $FuckyPreFlip += $KeyEvenArray[$Index]
            }

            # Multiply each keyed ASCII piece by the key to get original ASCII value
            $DekeyedASCII = @()

            for ($Index = 0; $Index -lt $KeyedItemNum; $Index++) {

                $KeyedMsgPiece = [double]$FuckyPreFlip[$Index]
                $DekeyedMsgPiece = $KeyedMsgPiece * $Key

                $TinyFix = [math]::Round($DekeyedMsgPiece)
                $DekeyedASCII += $TinyFix
            }
            
            # Create conjoined dekeyed ASCII string
            $JoinedASCII = $DekeyedASCII -join ""

            # Split conjoined ASCII string into 8 character arrays; ONLY used for verbosity
            if ($Verbose) {

                $ASCIIarray = ""
                for ($Index = 1; $Index -le $JoinedASCII.length; $Index++) {

                    $ASCIIarray += $JoinedASCII[$Index - 1]
                    if ($Index%8 -eq "0") { $ASCIIarray += " " }
                }
            }

            $Counter = 0
            $ASCII = ""
            $JoinedHex = @()

            # Convert ASCII to conjoined hexadecimal string
            for ($Index = 0; $Index -lt $JoinedASCII.length; $Index++) {

                $ASCII += $JoinedASCII[$Index]
                $Counter += 1

                if ($Counter -eq "2") {
                    $Hex = [char[]][byte[]]$ASCII
                    $JoinedHex += $Hex
                    $Counter = 0
                    $ASCII = ""
                }
            }

            $JoinedHex = $JoinedHex -join ""
            $Counter = 0
            $SpacedHex = ""

            # Split conjoined hexadecimal string into separated hex bytes
            for ($Index = 0; $Index -lt $JoinedHex.length; $Index++) {

                $SpacedHex += $JoinedHex[$Index]
                $Counter += 1

                if ($Counter -eq "2") {
                    $SpacedHex += " "
                    $Counter = 0
                }
            }
        }

        # Start Decoding Process
        else {

            $EncodedMsg = $Message

            # Create character array from encoded message
            $MessageContents = $EncodedMsg.ToCharArray()
            $CharCount = $MessageContents.Count

            $Increment = 0
	        $EvenArray = @()
	        $OddArray = @()
            
            # Create even and odd character arrays from encoded message array
            foreach ($Char in $MessageContents) {

                if ($Increment -lt ($CharCount / 2) ) { $EvenArray += $Char }
                else { $OddArray += $Char }

                $Increment += 1
            }

            # Create unsegregated modified base64 message (Original Order)
            $Modified64ception = @()

            for ($Index = 0; $Index -lt $CharCount; $Index++) {

                $Modified64ception += $OddArray[$Index]
                $Modified64ception += $EvenArray[$Index]
            }

            $Modified64ception = $Modified64ception -join ""

            # Convert Modified Base64 to Normal Base64
            $64ception = $Modified64ception.replace("+","A").replace("-","B").replace("!","=")

            # Convert Base64 to hexadecimal
            $JoinedHex = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($64ception))

            # Split conjoined hexadecimal string into separated hex bytes
            $SpacedHex = @()
            $TempConjoinedArr = $JoinedHex.ToCharArray()
            $Increment = 0

            for ($Index = 0; $Index -lt $TempConjoinedArr.length; $Index++) {

                $SpacedHex += $TempConjoinedArr[$Index]
                $Increment += 1

                if ($Increment -eq 2) {
                    $SpacedHex += " "
                    $Increment = 0
                }
            }

            $SpacedHex = $SpacedHex -join ""
        }

        ### Decoding and decryption converge into the same process ###

        # Convert hexadecimal bytes back into segregated modified base64
        $Segregated = $SpacedHex -split ' ' | % {[char][byte]"0x$_"}
        $Segregated = $Segregated -join ""

        # Create even and odd arrays from segregated modified base64
        $TempSegArray = $Segregated.ToCharArray()

        $CharNum = $TempSegArray.count
        $FinalIncrement = 0
        $FinalEvenArray = @()
        $FinalOddArray = @()

        foreach ($Char in $TempSegArray) {

            if ($FinalIncrement -lt ($CharNum / 2) ) { $FinalEvenArray += $Char }
            else { $FinalOddArray += $Char }

            $FinalIncrement += 1
        }


        # Create unsegregated modified base64 string (Original Order)
        $ModifiedText = @()

        for ($Index = 0; $Index -lt $CharNum; $Index++) {
            $ModifiedText += $FinalOddArray[$Index]
            $ModifiedText += $FinalEvenarray[$Index]
        }

        $ModifiedText = $ModifiedText -join ""

        # Convert modified base64 to original base64
        $64text = $ModifiedText.replace("+","A").replace("-","B").replace("!","=")

        # Convert base64 message to cleartext
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
                    Write-Host "`n Fucky64 Encrypted Message:" -ForegroundColor Yellow ;                  Write-Host " $EncryptedMsg"
                    Write-Host "`n Encrypted Message   -->   Fucky64 Pre-Flip:" -ForegroundColor Yellow ; Write-Host " $FuckyPreFlip" 
                    Write-Host "`n Fucky64 Pre-Flip    -->   ASCII Substrings:" -ForegroundColor Yellow ; Write-Host " $ASCIIarray"
                    Write-Host "`n ASCII Substrings    -->   Conjoined ASCII:" -ForegroundColor Yellow ;  Write-Host " $JoinedASCII"
                    Write-Host "`n Conjoined ASCII     -->   Conjoined Hex:" -ForegroundColor Yellow ;    Write-Host " $JoinedHex"
                }

                else {
	                Write-Host "`n Fucky64 Encoded Message:" -ForegroundColor Yellow ;                       Write-Host " $EncodedMsg"
                    Write-Host "`n Encoded Message     -->   Modified 64-Ception:" -ForegroundColor Yellow ; Write-Host " $Modified64ception"
                    Write-Host "`n Modified 64-Ception -->   64-Ception:" -Foregroundcolor Yellow ;          Write-Host " $64ception"
                    Write-Host "`n 64-Ception          -->   Conjoined Hex:" -ForegroundColor Yellow ;       Write-Host " $JoinedHex"
                }

                Write-Host "`n Conjoined Hex       -->   Hexadecimal:" -ForegroundColor Yellow ;     Write-Host " $SpacedHex"
	            Write-Host "`n Hexadecimal         -->   Segregated-64:" -ForegroundColor Yellow ;   Write-Host " $Segregated"
	            Write-Host "`n Segregated-64       -->   Modified Base64:" -ForegroundColor Yellow ; Write-Host " $ModifiedText"
	            Write-Host "`n Modified Base64     -->   Base64:" -ForegroundColor Yellow ;          Write-Host " $64text"

                if ($Key) { Write-Host "`n Key:" -ForegroundColor Yellow ; Write-Host " $Key" }
	            Write-Host "`n Cleartext:" -ForegroundColor Yellow ;       Write-Host " $Cleartext `n"
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


    # Probably not the most efficient way of doing this.
    if ($Decrypt) { $Encrypt = $FALSE }


    # Invoke Encoding / Encryption
    if ($Encrypt) {
        
        $Command = 'Fucky64-Encrypt -Message $Message -File $File -Key $Key'
        if ($Verbose) { $Command += ' -Verbose' }


        $Output = Invoke-Expression $Command
    }


    # Invoke Decoding / Decryption
    elseif ($Decrypt) {

        $Command = 'Fucky64-Decrypt -Message $Message -File $File -Key $Key'
        if ($Verbose) { $Command += ' -Verbose' }
        elseif ($Invoke) { $Command += ' -Invoke' }


        $Output = Invoke-Expression $Command
    }

    return $Output
}