# Fucky64
Custom convoluted PowerShell based encoding and encryption algorithm; able to encode strings and
text files, or even encrypt them using an integer based key.

# Preface
First and foremost, the encryption process is **VERY** slow -- this is **NOT** time efficient -- I
simply deem it *"security via tedium"*.  I started working on this one day after work with zero
intention of it going this far; it just slowly progressed into more and more unncessarily complex
and convoluted obfuscation mostly out of humor.

For encryption, the key is an integer (**max of 2,147,483,647**) and goes through convoluted steps
to make it as obfuscated and *"secure"* as possible.  However, because the encryption is mostly just 
different forms of encoding, conversion, replacement, and rudimentary mathematics, I went ahead and
created a brute force key generator to test the *"security"* of it.

# Fucky64
Highly recommend reading the Get-Help information at the beginning of the script.  Key take aways are
that files (and even alternate data streams) can be encoded / encrypted.  Messages are near instantaneous,
just keep in mind large files might take some time because of how convoluted the process is.

Parameters include `-Encrypt`, `-Decrypt`, `-Message`, `-File`, `-Key`, `-Verbose`, `-Invoke`, and `-Help`.

The `-Invoke` parameter inside of the decryption functionality invokes successfully decrypted commands. 

![Fucky64 Invoke](https://cdn.discordapp.com/attachments/620986290317426698/755530848362692729/unknown.png)

The `-Verbose` parameter goes step-by-step through the encoding/encryption or decoding/decryption process.

![Fucky64 Verbose](https://cdn.discordapp.com/attachments/620986290317426698/755526248930869410/unknown.png)

# Fucky64-KeyGenerator
Again, highly recommend reading the Get-Help information.

The brute force function can be very time consuming if the key is large enough and no special
parameters were used.  The brute force function also includes different verbosity parameters -- the
most verbose option is **VERY NOISY**, but is excellent for showing how the brute force works without
having to read through the source code (gif down below).

The key generator doesn't know the correct key for encrypted messages / files, but it is able to tell
you what keys could POTENTIALLY be the correct key -- meaning lots of false positives.  Despite this,
only 1 key properly decrypts messages.

Parameters include `-Message`, `-File`, `-Digits`, `-Keys`, `-Verbose`, `-VeryVerbose`, `-Pipe`, and `-Help`.

`-Verbose` Parameter:

![Key-Generator Pic](https://cdn.discordapp.com/attachments/620986290317426698/755507707305263245/unknown.png)

`-VeryVerbose` Parameter:

![Key-Generator Gif](https://cdn.discordapp.com/attachments/620986290317426698/755518403233710130/Fucky64-KeyGenerator.gif)

**Higher Res GIF: https://gfycat.com/weegrippingfirefly**

# Recommendations
To automatically load `Fucky64.ps1` and `Fucky64-KeyGenerator.ps1` into every PowerShell session, I
included simple script module called `FuckySuite.psm1` -- just pull the Fucky64 repository into a directory
of your choice and copy the command in the note header of **FuckySuite** into your user **$PROFILE**.

# Encryption Process

`(1) Cleartext` **-->**
`(2) Base64` **-->**
`(3) Replace specific characters inside Base64` **-->**
`(4) Separate the modified Base64 into even / odd character arrays` **-->**
`(5) Concatenate the even and odd arrays` **-->**
`(6) Convert new flipped, modified Base64 into hexadecimal` **-->**
`(7) Base64 the hexadecimal` **-->**
`(8) Convert Base64'd hexadecimal to ASCII` **-->**
`(9) Separate ASCII string into an array of 8-character ASCII substrings` **-->**
`(10) Divide each ASCII substring / "integer" by the integer-based key` **-->**
`(11) Separate key-divided substrings into even / odd arrays` **-->**
`(12) Concatenate the even and odd arrays using a randomly generated capital letter delimiter`

# Output
**Encoding:**

`PS C:\Users\Bobby> Fucky64 'Joe Biden has dementia.'`

`g3D+g0D+gCD+g0D++3D+gyE+gDD+wyE+gCD+g0D+gCD+w2D++3D+g1D+w0D+wyE+g3D++0D+gCD+Q3D+gCD+Q1D+gED+g1D++5D++yE+gCD+QyE+gCD++0D+gED+g0D+gzD+gyE+QxD+QyE+gCD+Q2D+gED+g2E+Q5D+gyE+gx+!N++cN++cM-+IQ++MN++IQ++IN-+QN++IM-+YR++cM-+cN++cN++IQ++EN++QN++IN++MM++cM-+UM++UM-+IM++MM-+IQ++UN++IR++IN-+UQ++QM-+MN++kM-+IQ++UN++IQ++IN++UQ++QM-+UN++IM-+IQ++IN++IQ++IM++!`

**Encryption:**

`PS C:\Users\Bobby> Fucky64 'Joe Biden has dementia.' -Key 54321`

`967.490767843007T967.490767843007T967.490767843007T967.490767843007T967.490767843007T967.490767843007T967.490767843007T932.697280977891T932.702877340255T932.704957567055T932.699177113823T932.701036431583T932.702803703908T932.702877340255T932.704957567055T932.697280977891T1004.31792492774T932.700999613409T932.704975976142T932.705031203402T1022.72518915337T984.804256180851T1004.31045083853T984.804274589938T985.16352791738T967.858986395685T987.740800058909T967.858986395685T1003.57257782441T987.740800058909T1003.38852377534T986.268036302719`
