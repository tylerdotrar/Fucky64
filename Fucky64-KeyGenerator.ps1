﻿function Fucky64-KeyGenerator {
#.SYNOPSIS
# Calculates potential decryption keys for messages and files encrypted by 'Fucky64'
# ARBITRARY VERSION NUMBER:  4.0.2
# AUTHOR:  Tyler McCann (@tyler.rar)
#
#.DESCRIPTION
# This function is a test to see how easy it is to brute force keys for 'Fucky64' encrypted messages. Quickly 
# calculates potential keys within digits 1-5. Slowly calculates potential keys within digits 6-9. A lot of 
# false positives may be generated. -Message doesn't need to be specified; set as the default.
#
# Supports alternate data streams (ADS).
#
# Recommendations:
# -- Use 'FuckySuite.psm1' (and included instructions) from the repo to load this script from your $PROFILE.
#
# Parameters:
#    -Message       -->    The encrypted / pseudo-numerical message generated by 'Fucky64'
#    -File          -->    (Optional) The file with encrypted / pseudo-numerical contents from 'Fucky64'
#    -Digits        -->    (Optional) Maximum number of digits for a candidate key; defaults to 9
#    -Keys          -->    (Optional) Maximum number of successful candidate keys before stopping
#    -Verbose       -->    (Optional) Live display of the status of every tested key
#    -VeryVerbose   -->    (Optional) Live display of every test for every iteration and tested key
#    -Pipe          -->    (Optional) Only returns an array of successful candidate keys
#    -Help          -->    (Optional) Return Get-Help information
#
# Example Usage:
#    []  PS C:\Users\Bobby> $hidden = Fucky64 -Encrypt -Message "Joe Biden has dementia." -Key 57422
#
#    []  PS C:\Users\Bobby> Fucky64-KeyGenerator -Message $hidden -Keys 3
#         Successful Candidate Key(s):
#           '28711'
#           '57422'
#           '86133'
#
#    []  PS C:\Users\Bobby> Fucky64-KeyGenerator $hidden -Keys 3 -Pipe | % { Fucky64 -Decrypt $hidden -Key $_ }
#        Incorrect key.
#        Joe Biden has dementia.
#        Incorrect key.
#
#    []  PS C:\Users\Bobby>
#
#.LINK
# https://github.com/tylerdotrar/Fucky64

    Param (
        [string] $Message,
        [string] $File,
        [int]    $Digits = 9,
        [int]    $Keys,
        [switch] $Verbose,
        [switch] $VeryVerbose,
        [switch] $Pipe,
        [switch] $Help
    )

    # Return help information
    if ($Help) { return Get-Help Fucky64-KeyGenerator }

    if ($File) {
        
        if (Test-Path -LiteralPath $File 2>$NULL) { $Message = (Get-Content -LiteralPath $File) }

        else {
            Write-Host " File does not exist." -ForegroundColor Red
            return
        }
    }

    # Remove alphabet delimiters from encrypted message
    $NoAlphabet = $Message -Replace "[A-Z]"," "
    

    # Create array of segregated key-divided ASCII pieces (Message Pieces / Number of Tests)
    $MessageSegments = $NoAlphabet.split(" ")
    $NumberOfTests = $MessageSegments.count
    
    $KeyPassed = 0
    $AlreadyUsedKey = @()
    $SuccessfulKey = @()
    $MaxDigits = $Digits


    # Iterate every digit up to the max number of digits
    for ($Digit = 1; $Digit -le $MaxDigits; $Digit++) {

        $Dig = ("9" * $Digit) -as [int]

        # Iterate through each index of the message segments
        for ($Index = 0; $Index -lt $NumberOfTests; $Index++) {

            $EncSegment = [double]$MessageSegments[$Index]
            $KeyArray = @()
            $PotentialKeys = 0


            # Iterate through every key in the digit range (with Enhanced Speed / Reduced Redundancy)
            for ($Key = ([string]1 + "0" * ($Digit - 1)) -as [int]; $Key -le $Dig; $Key++) {
                
                # Must be (very close to) a whole number for a key to be considered a potential key
                $WholeNum = $EncSegment * $Key

                # Potential key found; Round to remove *most* false negatives
                if (($WholeNum -notlike "*.*") -or ($wholenum -like "*.*0000001") -or ($wholenum -like "*.*0000002") -or ($wholenum -like "*.*9999999") -or ($wholenum -like "*.*9999998")) {

                    $PotentialKeys += 1
                    $KeyArray += $Key
                }
            }

            # Display noisy info
            if ($VeryVerbose) {
                Write-Host "`n $PotentialKeys Potential Key(s) found for Iteration $Digit Index[$index]!" -ForegroundColor Yellow
                Write-Host "   Index[$index] = $EncSegment"
                Write-Host "   Key Digits = $Digit"
            }

            # Skip to next iteration if no potential keys exist for a message index
            if ($PotentialKeys -eq "0") {

                if ( $VeryVerbose ) { Write-Host " Skipping to next iteration." -ForegroundColor Yellow }
                break
            }

            # Start HEAVIER potential key testing
            else {

                # Iterate through every potential key found
                for ($KeyIndex = 0; $KeyIndex -lt $KeyArray.count; $KeyIndex++) { 

                    $RetestKey = $KeyArray[$KeyIndex] -as [int]

                    # Skip key testing if it has already been tested
                    if ($AlreadyUsedKey -contains $RetestKey) { break }

                    $MaxFailAmount = [math]::Round($NumberOfTests / 3)
                    $FailCounter = 0

                    if ($Verbose -or $VeryVerbose) { Write-Host "`n Testing Candidate Key `'$RetestKey`'..." -ForegroundColor Yellow }


                    # Test potential key in every message index
                    for ($RetestIndex = 0; $RetestIndex -lt $NumberOfTests; $RetestIndex++) {

                        $RetestBase = [double]$MessageSegments[$RetestIndex]
                        $WholeNumRetest = $RetestBase * $RetestKey
                        
                        # Increment fail counter if test result is NOT (reasonably close to) a whole number
                        if (($WholeNumRetest -like "*.*") -and ($WholeNumRetest -notlike "*.*0000001") -and ($WholeNumRetest -notlike "*.*9999999") -and ($WholeNumRetest -notlike "*.*0000002") -and ($WholeNumRetest -notlike "*.*9999998")) {
                            
                            $FailCounter += 1
                            if ($VeryVerbose) { Write-Host "   Test $RetestIndex`: `'$RetestBase`' * `'$RetestKey`' = $WholeNumRetest" -ForegroundColor DarkGray }
                        }

                        # Test successful; result was a whole number
                        elseif ($VeryVerbose) { Write-Host "   Test $RetestIndex`: `'$RetestBase`' * `'$RetestKey`' = $WholeNumRetest" }
                    }

                    # Candidate key failed
                    if ($FailCounter -gt $MaxFailAmount) {
                        
                        # DO NOTHING or...
                        if ($Verbose -or $VeryVerbose) {Write-Host " Candidate Failed $FailCounter / $NumberOfTests Tests" -ForegroundColor Red }
                    }

                    # Candidate key passed
                    else {

                        $KeyPassed += 1
                        $SuccessfulKey += $RetestKey

                        if ($Verbose -or $VeryVerbose) {

                            if ($FailCounter -eq 0) {  Write-Host " Candidate Passed All Tests!" -ForegroundColor Green }
                            else { Write-Host " Candidate Passed, but Failed $FailCounter / $NumberOfTests Tests" -ForegroundColor Cyan }
                        }
                    }

                    # Append key to list of tested keys
                    $AlreadyUsedKey += $RetestKey

                    # Exit if successful keys exceeds maximum set keys
                    if ($Keys -and ($KeyPassed -ge $Keys)) {
                        
                        # Exit HEAVIER potential key testing (Part 1)
                        $ExitDeepLayer = $TRUE
                        break
                    } 
                }

                # Exit HEAVIER potential key testing (Part 2) 
                if ( $ExitDeepLayer ) { break }
            }
        }

        # Exit initial FOR loop
        if ($ExitDeepLayer) { break }     
    }

    # Format / print successful keys to screen
    if (($KeyPassed -ge 1) -and !$Pipe) {
        
        # Visual formatting blank line (1)
	    if ($Verbose -or $VeryVerbose) { Write-Host "" }

        Write-Host " Successful Candidate Key(s):" -ForegroundColor Yellow
        foreach ($GoodKey in $SuccessfulKey) { Write-Host "   `'$GoodKey`'" -ForegroundColor Green }

        # Visual formatting blank line (2)
	    if ($Verbose -or $VeryVerbose) { Write-Host "" }
    }

    # Pipe out successful key array
    else { return $SuccessfulKey }
}