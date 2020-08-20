function Fucky64-Encrypt ([string]$Message, [string]$File, [int]$Key, [switch]$Verbose) 
{
#.SYNOPSIS
# Encrypts / encodes cleartext messages and files.
# ARBITRARY VERSION NUMBER:  3.2
# AUTHOR:  Tyler McCann (@tyler.rar)
#
#.DESCRIPTION
# This function aims to encrypt or encode cleartext messages OR files, and is decrypted / decoded by the 
# 'Fucky64-Decrypt' function.  If -File is used, -Verbose will not work.  If a key was used, the encrypted 
# message will be in a pseudo-numerical output.  If no key was used, the encoded message will be in a 
# modified base64 output.  Maximum key length is ten digits; specifically 2,147,483,647.
#
# Parameters:
#    -Message       -->    The cleartext message to be encrypted or encoded
#    -File          -->    The file to be encrypted / encoded and overwritten; supports ADS
#    -Key           -->    (Optional) The key used to encrypt the cleartext message
#    -Verbose       -->    (Optional) Display the encrypting / encoding process step-by-step
#
# Example Usage:
#    PS C:\Users\Bobby>Fucky64-Encrypt -Message "Test" -Key 123456
#    425.779759590461E441.655877397615E441.655861197512E410.392909214619E410.38952339295E410.391297304303
#    PS C:\Users\Bobby>Fucky64-Encrypt -File C:\FakeFile.txt -Key 123
#    File does not exist.
#    PS C:\Users\Bobby>Fucky64-Encrypt -File C:\RealFile.txt -Key 123
#    File successfully encrypted.
#    PS C:\Users\Bobby>
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