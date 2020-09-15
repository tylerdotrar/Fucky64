function Fucky64-Encrypt {
#.SYNOPSIS
# Encrypts / encodes cleartext messages and files.
# ARBITRARY VERSION NUMBER:  4.2.0
# AUTHOR:  Tyler McCann (@tyler.rar)
#
#.DESCRIPTION
# This function aims to encrypt or encode cleartext messages OR files, and is decrypted / decoded by the 
# 'Fucky64-Decrypt' function.  If -File is used, -Verbose will not work.  If a key was used, the encrypted 
# message will be in a pseudo-numerical output.  If no key was used, the encoded message will be in a 
# modified base64 output.  Maximum key length is ten digits; specifically 2,147,483,647. -Message doesn't 
# need to be specified; set as the default.
#
# Supports alternate data streams (ADS).
#
# Parameters:
#    -Message       -->    The cleartext message to be encrypted or encoded
#    -File          -->    (Optional) The file to be encrypted / encoded and overwritten; supports ADS
#    -Key           -->    (Optional) The key used to encrypt the cleartext message
#    -Verbose       -->    (Optional) Display the encrypting / encoding process step-by-step
#
# Example Usage:
#    []  PS C:\Users\Bobby> Fucky64-Encrypt -Message "Test" -Key 123456
#        425.779759590461E441.655877397615E441.655861197512E410.392909214619E410.38952339295E410.391297304303
#
#    []  PS C:\Users\Bobby> Fucky64-Encrypt -File C:\FakeFile.txt -Key 123
#        File does not exist.
#
#    []  PS C:\Users\Bobby> Fucky64-Encrypt -File C:\RealFile.txt -Key 123
#        File successfully encrypted.
#
#    []  PS C:\Users\Bobby>
#
#.LINK
# https://github.com/tylerdotrar/Fucky64
        
    Param (
        [string] $Message,
        [string] $File,
        [int]    $Key,
        [switch] $Verbose
    )

    $ErrorActionPreference = 'SilentlyContinue'

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