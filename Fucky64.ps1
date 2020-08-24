function Fucky64 {
#.SYNOPSIS
# Integer-based key encryption / decryption of strings and files.
# ARBITRARY VERSION NUMBER:  1.0.0
# AUTHOR:  Tyler McCann (@tyler.rar)
#
#.DESCRIPTION
# This function aims to encrypt / encode cleartext messages OR files using the -Encrypt switch, and is 
# decrypted / decoded by the -Decrypt switch.  If -File is used, -Verbose will not work.  If a key was 
# used for encryption, the returned encrypted message will be in a pseudo-numerical output.  If no key 
# was used, the returned message will be encoded the in a modified base64 output.  Maximum key length 
# is ten digits; specifically 2,147,483,647.  -Invoke only works when using the -Decrypt switch.  This
# is a lazy, temporary conglomerate script; in the future I'll create a more efficient version.
#
# Parameters:
#    -Message       -->    The message to be encrypted / decrypted
#    -File          -->    The file to be encrypted / decrypted; supports ADS
#    -Key           -->    (Optional) The key used to encrypt / decrypt the message
#    -Verbose       -->    (Optional) Display the encrypting / decrypting process step-by-step
#    -Invoke        -->    (Optional) Direct invokation of a successfully decrypted command
#    -Help          -->    (Optional) Return Get-Help information
#
# Example Usage:
#    PS C:\Users\Bobby>Fucky64 -Encrypt -Message "Test" -Key 123456
#    425.779759590461E441.655877397615E441.655861197512E410.392909214619E410.38952339295E410.391297304303
#    PS C:\Users\Bobby>Fucky64 -Encrypt -File C:\RealFile.txt -Key 123
#    File successfully encrypted.
#    PS C:\Users\Bobby>$Command = Fucky64 -Encrypt -Message 'mkdir MalwareDir > $NULL; cd MalwareDir' -Key 12345
#    PS C:\Users\Bobby>Fucky64 -Decrypt -Message $Command -Key 54321 -Invoke
#    Incorrect key.
#    PS C:\Users\Bobby>Fucky64 -Decrypt -Message $Command -Key 12345 -Invoke
#    PS C:\Users\Bobby\MalwareDir>

    Param (
        [switch]$Encrypt,
        [switch]$Decrypt,
        [string]$Message,
        [string]$File,
        [int]$Key,
        [switch]$Verbose,
        [switch]$Invoke,
        [switch]$Help
    )

    # Encryption / Decryption Functions
    function Fucky64-Encrypt ([string]$Message, [string]$File, [int]$Key, [switch]$Verbose) {
        $ErrorActionPreference= 'SilentlyContinue'
    
        $ADSbool = $false
        if ( ($File) -and (Test-Path -LiteralPath $File) )
        {

            $Message = ( (Get-Content -LiteralPath $File) -join '!!/NEWLINE\!!' ).replace("`t",'!!/TAB\!!').replace(">",'!!/GT\!!').replace("<",'!!/LT\!!')
            $Stream = (Get-Item -LiteralPath $File).Stream
            if ( ($File -like "*:*") -and ($Stream) )
            {
                $ADSbool = $true
            }
        }
        elseif ( ($File) -and !(Test-Path -LiteralPath $File) )
        {
            Write-Host "File does not exist." -ForegroundColor Red
            break
        }

	    $64text = [convert]::ToBase64String([System.Text.encoding]::Unicode.GetBytes($Message)) 
	    $modifiedtext = $64text.replace("A","+").replace("B","-").replace("=","!")
	    $arraytext = $modifiedtext.ToCharArray()

	    $increment = 0
	    $evenarray = @()
	    $oddarray = @()
	    $flippedarray = @()
	    foreach ($char in $arraytext) 
        {
            if ($increment%2 -eq 0) 
            {
        	    $oddarray += $char
    	    }
    	    else 
            {
        	    $evenarray += $char
    	    }
            $increment += 1
	    }
	    $flippedarray += $evenarray + $oddarray

	    $hextext = @()
	    foreach ($item in $flippedarray) 
        {
    	    $hextext = $hextext + " " + [System.String]::Format("{0:X}", [System.Convert]::ToUInt32($item))
	    }

	    $schmurda = $flippedarray -join ""
	    $bobby = ($hextext -join "").Substring(1)
        $joinedhex = $bobby.replace(" ","")

        if ( !( $Key ) ) 
        {
	        $64ception = [convert]::ToBase64String([System.Text.encoding]::Unicode.GetBytes($joinedhex))
	        $64ceptionmodified = $64ception.replace("A","+").replace("B","-").replace("=","!")

            $64ceptionarray = $64ceptionmodified.ToCharArray()
            $increment = 0
	        $evenarray = @()
	        $oddarray = @()
            $64final = @()
            foreach ($guy in $64ceptionarray)
            {
                if ($increment%2 -eq 0) 
                {
        	        $oddarray += $guy
    	        }
    	        else 
                {
        	        $evenarray += $guy
    	        }
                $increment += 1
            }
            $64final += $evenarray + $oddarray
            $64final = $64final -join ""
        }

        else 
        {
            $death = [byte[]][char[]]$joinedhex
            $deathcount = $death.count

            $deatharray = @()
            $conjoin = ""
            for ($indian = 1; $indian -lt ($death.count + 1); $indian++) 
            {
                $conjoin += $death[$indian - 1]
                if (($indian%4 -eq "0") -or ($indian -eq $death.count)) 
                {
                    $deatharray += $conjoin
                    $conjoin = ""  
                }
            }

            $finalarray = @()
            foreach ($item in $deatharray) 
            {
                $finalarray += $item / $Key
            }

            $finalincrement = 0
	        $finalevenarray = @()
	        $finaloddarray = @()
	        $finalflippedarray = @()
	        foreach ($thing in $finalarray) 
            {
                if ($finalincrement%2 -eq 0) 
                {
        	        $finaloddarray += $thing
    	        }
    	        else 
                {
        	        $finalevenarray += $thing
    	        }
                $finalincrement += 1
	        }
	        $finalflippedarray += $finalevenarray + $finaloddarray
        
            $Joiner = (65..90) | Get-Random | % { [char]$_ }
            $keystring = $finalflippedarray -join "$Joiner"

        }

        if ( ($Verbose) -and !($File) ) 
        {
	        Write-Host "`n Cleartext: " -ForegroundColor Yellow
	        Write-Host " $Message "
            if ( $Key ) 
            {
                Write-Host "`n Key: " -ForegroundColor Yellow
                Write-Host " $key "
            }
	        Write-Host "`n Clear Message  -->  Base64: " -ForegroundColor Yellow
	        Write-Host " $64text "
	        Write-Host "`n Base64  -->  Fucky: " -ForegroundColor Yellow
	        Write-Host " $modifiedtext "
	        Write-Host "`n Fucky  -->  Fucky-Flipped: " -ForegroundColor Yellow
	        Write-Host " $schmurda "
	        Write-Host "`n Fucky-Flipped  -->  Hexadecimal: " -ForegroundColor Yellow
	        Write-Host " $bobby "
            Write-Host "`n Hexadecimal  -->  Conjoined Hex: " -ForegroundColor Yellow
            Write-Host " $joinedhex "
	        if ( !( $Key ) ) 
            {
                Write-Host "`n Conjoined Hex  -->  Base64-Ception: " -ForegroundColor Yellow
	            Write-Host " $64ception "
	            Write-Host "`n Base64-Ception  -->  Fucky-Ception: " -ForegroundColor Yellow
	            Write-Host " $64ceptionmodified "
                Write-Host "`n Fucky64 Encoded Message: " -ForegroundColor Yellow
	            Write-Host " $64final `n"
            }
            else 
            {
                $deathshow = $death -join ""
                Write-Host "`n Conjoined Hex  -->  Conjoined ASCII: " -ForegroundColor Yellow
                Write-Host " $deathshow "
                $deatharrayshow = $deatharray -join " "
                Write-Host "`n Conjoined ASCII  -->  Segregated ASCII: " -ForegroundColor Yellow
                Write-Host " $deatharrayshow "
                Write-Host "`n Segregated ASCII --> Fucky64 Pre-Flip: "-ForegroundColor Yellow
                Write-Host " $finalarray "
                Write-Host "`n Fucky64 Encrypted Message: " -ForegroundColor Yellow
                Write-Host " $keystring `n"
            }
        }
        elseif ( !($File) ) 
        {
            if ( !( $Key ) ) 
            {
	            return $64final
            }
            else 
            {
                return $keystring
            }
        }
        else 
        {
            if ( !( $Key ) -and ( $ADSbool -eq $false ) )
            {
                Write-Output $64final > $File
                Write-Host "File successfully encoded." -ForegroundColor Yellow
            }
            elseif ( !( $Key ) -and ( $ADSbool ) )
            {
                Set-Content -LiteralPath $File -Value $64final
                Write-Host "ADS successfully encoded." -ForegroundColor Yellow
            }
            elseif ( ( $Key ) -and ( $ADSbool -eq $false ) )
            {
                Write-Output $keystring > $File
                Write-Host "File successfully encrypted." -ForegroundColor Yellow
            }
            elseif ( ( $Key ) -and ($ADSbool ) )
            {
                Set-Content -LiteralPath $File -Value $keystring
                Write-Host "ADS successfully encrypted." -ForegroundColor Yellow
            }
        }
    }
    function Fucky64-Decrypt ([string]$Message, [string]$File, [int]$Key, [switch]$Verbose, [switch]$Invoke) {
        $ErrorActionPreference= 'SilentlyContinue'

        $ADSbool = $false
        if ( ($File) -and (Test-Path -LiteralPath $File) )
        {
            $Message = (Get-Content -LiteralPath $File)
            $Stream = (Get-Item -LiteralPath $File).Stream
            if ( ($File -like "*:*") -and ($Stream) )
            {
                $ADSbool = $true
            }
        }
        elseif ( ($File) -and !(Test-Path -LiteralPath $File) )
        {
            Write-Host "File does not exist." -ForegroundColor Red
            break
        }

        if ( !( $Key ) ) 
        {
            $testvar = $Message.ToCharArray()
            $CharCount = $testvar.Count
            $increment = 0
	        $evenarray = @()
	        $oddarray = @()
            $sortedarray = @()
            foreach ($guy in $testvar)
            {
                if ($increment -lt ($CharCount / 2) ) 
                {
                    $evenarray += $guy
                }
                else 
                {
                    $oddarray += $guy
                }
                $increment += 1
            }
            $testunflip = @()
            for ($index = 0; $index -lt $CharCount; $index++) 
            {
                $testunflip += $oddarray[$index]
                $testunflip += $evenarray[$index]
            }
            $testunflip = $testunflip -join ""

            $64ception = $testunflip.replace("+","A").replace("-","B").replace("!","=")
            $showconjoinedhex = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($64ception))

            $fucky64hex = @()
            $tempconarray = $showconjoinedhex.ToCharArray()
            $increment = 0
            for ($indext = 0; $indext -lt $tempconarray.length; $indext++)
            {
                $fucky64hex += $tempconarray[$indext]
                $increment += 1
                if ($increment -eq 2)
                {
                    $fucky64hex += " "
                    $increment = 0
                }
            }
            $fucky64hex = $fucky64hex -join ""
        }

        else 
        {
            $splitmsg = $Message -Replace "[A-Z]", " "
            $splitmsg2 = $splitmsg.split(" ")

            $KeyItemNum = $splitmsg2.count
            $KeyIncrement = 0
            $Keyevenarray = @()
            $Keyoddarray = @()
            foreach ($yucky in $splitmsg2) 
            {
                if ($KeyIncrement -lt ($KeyItemNum / 2) ) 
                {
                    $Keyevenarray += $yucky
                }
                else 
                {
                    $Keyoddarray += $yucky
                }
                $KeyIncrement += 1
            }

            $Keyunflippedarray = @()
            for ($indexk = 0; $indexk -lt $KeyItemNum; $indexk++) 
            {
                $Keyunflippedarray += $Keyoddarray[$indexk]
                $Keyunflippedarray += $Keyevenarray[$indexk]
            }
            $dekeyedarray = @()
            for ($index = 0; $index -lt $splitmsg2.count; $index++) 
            {
                $messagepiece = [double]$Keyunflippedarray[$index]
                $dekeyedpiece = $messagepiece * $Key
                $tinyfix = [math]::Round($dekeyedpiece)
                $dekeyedarray += $tinyfix
            }
    
            $asciiarray = $dekeyedarray -join ""
            $SegregatedAscii = ""

            for ($SegCounter = 1; $SegCounter -le $asciiarray.length; $SegCounter++)
            {
                $SegregatedAscii += $asciiarray[$SegCounter - 1]
                if ($SegCounter%8 -eq "0")
                {
                    $SegregatedAscii += " "
                }
            }

            $counter = 0
            $ascii = ""
            $conjoinedhex = @()
            for ($ind2 = 0; $ind2 -lt $asciiarray.length; $ind2++) 
            {
                $ascii += $asciiarray[$ind2]
                $counter += 1
                if ($counter -eq "2") 
                {
                    $hex = [char[]][byte[]]$ascii
                    $conjoinedhex += $hex
                    $counter = 0
                    $ascii = ""
                }
            }

            $showconjoinedhex = $conjoinedhex -join ""

            $lastcounter = 0
            $fucky64hex = ""
            for ($ind3 = 0; $ind3 -lt $conjoinedhex.Count; $ind3++) 
            {
                $fucky64hex += $conjoinedhex[$ind3]
                $lastcounter += 1
                if ($lastcounter -eq "2") 
                {
                    $fucky64hex += " "
                    $lastcounter = 0
                }
            }
        }
        $flippedfuckyarray = $fucky64hex -split ' ' | ForEach-Object {[char][byte]"0x$_"}
        $flippedfix = $flippedfuckyarray -join ""
        $unflipstart = $flippedfix.ToCharArray()

        $ItemNum = $unflipstart.count
        $increment = 0
        $evenarray = @()
        $oddarray = @()
        foreach ($char in $unflipstart) 
        {
            if ($increment -lt ($ItemNum / 2) ) 
            {
                $evenarray += $char
            }
            else 
            {
                $oddarray += $char
            }
            $increment += 1
        }

        $unflippedarray = @()
        for ($index = 0; $index -lt $ItemNum; $index++) 
        {
            $unflippedarray += $oddarray[$index]
            $unflippedarray += $evenarray[$index]
        }
        $unflippedarray = $unflippedarray -join ""
        $Base64Encoded = $unflippedarray.replace("+","A").replace("-","B").replace("!","=")
        $cleartext = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Base64Encoded))

        $IncorrectKey = $false
        if ( ($Key) -and ( !($cleartext) -or ($showconjoinedhex -notmatch '^[A-Z0-9]+$') ) )
        {
            Write-Host "Incorrect key." -ForegroundColor Red
            $IncorrectKey = $true
        }
        elseif ( !($Key) -and ( !($Cleartext) -or ($showconjoinedhex -notmatch '^[A-Z0-9]+$') ) )
        {
            Write-Host "No key entered." -ForegroundColor Red
            $IncorrectKey = $true
        }

        if ( ($Verbose) -and !($File) -and !($IncorrectKey) ) 
        {
            if ( !( $Key ) ) 
            {
	            Write-Host "`n Fucky64 Encoded Message: " -ForegroundColor Yellow
	            Write-Host " $Message " 
                Write-Host "`n Encoded Message  -->  Fucky-Ception: " -ForegroundColor Yellow
	            Write-Host " $testunflip " 
                Write-Host "`n Fucky-Ception  -->  Base64-Ception: " -Foregroundcolor Yellow
                Write-Host " $64ception "
                Write-Host "`n Base64-Ception  -->  Conjoined Hex: " -ForegroundColor Yellow
            }
            else 
            {
                Write-Host "`n Fucky64 Encrypted Message: " -ForegroundColor Yellow
                Write-Host " $Message " 
                Write-Host "`n Encrypted Message  -->  Fucky64 Pre-Flip:" -ForegroundColor Yellow 
                Write-Host " $Keyunflippedarray " 
                Write-Host "`n Fucky64 Pre-Flip  -->  Segregated ASCII:" -ForegroundColor Yellow 
                Write-Host " $SegregatedAscii "
                Write-Host "`n Segregated ASCII  -->  Conjoined ASCII: " -ForegroundColor Yellow
                Write-Host " $asciiarray " 
                Write-Host "`n Conjoined ASCII  -->  Conjoined Hex: " -ForegroundColor Yellow
            }
            Write-host " $showconjoinedhex "
            Write-Host "`n Conjoined Hex  -->  Hexadecimal: " -ForegroundColor Yellow
	        Write-Host " $fucky64hex " 
	        Write-Host "`n Hexadecimal  -->  Fucky-Flipped: " -ForegroundColor Yellow
	        Write-Host " $flippedfix " 
	        Write-Host "`n Fucky-Flipped  -->  Fucky: " -ForegroundColor Yellow
	        Write-Host " $unflippedarray " 
	        Write-Host "`n Fucky  -->  Base64: " -ForegroundColor Yellow
	        Write-Host " $Base64Encoded " 
            if ( $Key ) 
            {
                Write-Host "`n Key: " -ForegroundColor Yellow
                Write-Host " $Key " 
            }
	        Write-Host "`n Cleartext: " -ForegroundColor Yellow
	        Write-Host " $cleartext `n" 
        }
        elseif ( ($Invoke) -and !($IncorrectKey) ) 
        {
            Invoke-Expression -Command $cleartext
        }
        elseif ( !($File) -and !($IncorrectKey) ) 
        {
            return $cleartext
        }
        elseif ( !($IncorrectKey) )
        {
            $FinalOutput = (Write-Output $cleartext).replace('!!/NEWLINE\!!',"`r`n").replace('!!/TAB\!!',"`t").replace('!!/GT\!!',">").replace('!!/LT\!!',"<")
            if ( $ADSbool -eq $false )
            {
                Write-Output $FinalOutput > $File
                if ( !( $Key ) )
                {
                    Write-Host "File successfully decoded." -ForegroundColor Yellow
                }
                else
                {
                    Write-Host "File successfully decrypted." -ForegroundColor Yellow
                }
            }
            elseif ( $ADSbool )
            {
                Set-Content -LiteralPath $File -Value $FinalOutput
                if ( !( $Key ) )
                {
                    Write-Host "ADS successfully decoded." -ForegroundColor Yellow
                }
                else
                {
                    Write-Host "ADS successfully decrypted." -ForegroundColor Yellow
                }
            }
        }
    }

    # Return help information
    if ($Help) { Get-Help Fucky64 ; return }

    # Start lazy process.
    if (!$Decrypt) { $Encrypt = $TRUE }
    else { $Encrypt = $FALSE }

    if ($Encrypt -and $Verbose) { $ReturnValue = Fucky64-Encrypt -Message $Message -File $File -Key $Key -Verbose }
    elseif ($Encrypt) { $ReturnValue = Fucky64-Encrypt -Message $Message -File $File -Key $Key }


    elseif ($Decrypt -and $Verbose) { $ReturnValue = Fucky64-Decrypt -Message $Message -File $File -Key $Key -Verbose }
    elseif ($Decrypt -and $Invoke) { $ReturnValue = Fucky64-Decrypt -Message $Message -File $File -Key $Key -Invoke }
    elseif ($Decrypt) { $ReturnValue = Fucky64-Decrypt -Message $Message -File $File -Key $Key }

    return $ReturnValue
}