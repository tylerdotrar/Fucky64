function Fucky64-Decrypt ([string]$Message, [string]$File, [int]$Key, [switch]$Verbose, [switch]$Invoke) 
{
#.SYNOPSIS
# Decrypts / decodes messages and files generated from 'Fucky64-Encrypt' and can optionally invoke a 
# decrypted or decoded command.
# ARBITRARY VERSION NUMBER:  3.2
# AUTHOR:  Tyler McCann (@tyler.rar)
#
#.DESCRIPTION
# This function aims to decrypt or decode messages and files generated from the 'Fucky64-Encrypt' 
# function.  If -File is used, -Verbose will not work.  If a key was used, the decryption will return
# an error until the proper decryption key is used. 
#
# Parameters:
#    -Message       -->    The 'Fucky64-Encrypt' generated message to be decrypted or decoded
#    -File          -->    The file to be decrypted / decoded and overwritten
#    -Key           -->    (Optional) The key used to encrypt the original cleartext message
#    -Verbose       -->    (Optional) Display the decrypting / decoding process step-by-step
#    -Invoke        -->    (Optional) Direct invokation of a successfully decrypted / decoded command
#
# Example Usage:
#    PS C:\Users\Bobby>$command = Fucky64-Encrypt -Message 'mkdir MalwareDir > $null; cd MalwareDir' -Key 12345
#    PS C:\Users\Bobby>Fucky64-Decrypt -Message $command -Key 54321 -Invoke
#    Incorrect key.
#    PS C:\Users\Bobby>Fucky64-Decrypt -Message $command -Key 12345 -Invoke
#    PS C:\Users\Bobby\MalwareDir>

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