# Fucky64
Custom convoluted PowerShell based encoding and encryption algorithm; able to encode strings and
text files, or even encrypt them using an integer based key.

# Preface
I made this about two months ago, before I started developing better commenting and scripting
habits.  Eventually plan on creating a streamlined variant -- with more efficient code, comments,
and build the encryption and decryption functionality into one function.

First and foremost, the encryption process is **VERY** slow -- this is **NOT** time efficient -- I
simply deem it *security via tedium*.  I started working on this one day after work with zero
intention of it going this far, it just slowly progressed into more and more unncessarily complex
and convoluted obfuscation mostly out of humor.

# Description
For encryption, the key is an integer (**max of 2,147,483,647**) and goes through convoluted steps
to make it as obfuscated and "secure" as possible.  However, because the encryption is mostly just 
different forms of encoding, conversion, replacement, and rudimentary math, a brute force key
generator is possible (and fairly simple).

The brute force function can be very time consuming if the key is large enough and no special
parameters were used.  The brute force function also includes different verbosity parameters -- the
most verbose option is **VERY NOISY**, but is excellent for showing how the brute force worksm without
having to read through the source code.

The key generator doesn't know the correct key for encrypted messages / files, but it is able to tell
you what keys could POTENTIALLY be the correct key -- meaning lots of false positives.  Despite this,
only 1 key properly decrypts messages. 

Files can be input into the functions rather than messages, and they will be encoded or encrypted --
just keep in mind large files will take time.  Messages are near instantaneous, but because of how
convoluted the process is, large files can be time consuming.

When using **Fucky64**, use the **-Verbose** parameter to go step-by-step through the encoding/encryption or decoding/decryption process.

# Egregious Output

**ENCODING EXAMPLE**

**Syntax:**

PS C:\Users\Bobby> *Fucky64 -Encrypt -Message 'Joe Biden has dementia.'*

**Output:**

*g3D+g0D+gCD+g0D++3D+gyE+gDD+wyE+gCD+g0D+gCD+w2D++3D+g1D+w0D+wyE+g3D++0D+gCD+Q3D+gCD+Q1D+gED+g1D++5D++yE+gCD+QyE+gCD++0D+gED+g0D+gzD+gyE+QxD+QyE+gCD+Q2D+gED+g2E+Q5D+gyE+gx+!N++cN++cM-+IQ++MN++IQ++IN-+QN++IM-+YR++cM-+cN++cN++IQ++EN++QN++IN++MM++cM-+UM++UM-+IM++MM-+IQ++UN++IR++IN-+UQ++QM-+MN++kM-+IQ++UN++IQ++IN++UQ++QM-+UN++IM-+IQ++IN++IQ++IM++!*

**ENCRYPTION EXAMPLE**

**Syntax:**

PS C:\Users\Bobby> *Fucky64-Encrypt -Message 'Joe Biden has dementia.' -Key 54321*

**Output:**

*967.490767843007T967.490767843007T967.490767843007T967.490767843007T967.490767843007T967.490767843007T967.490767843007T932.697280977891T932.702877340255T932.704957567055T932.699177113823T932.701036431583T932.702803703908T932.702877340255T932.704957567055T932.697280977891T1004.31792492774T932.700999613409T932.704975976142T932.705031203402T1022.72518915337T984.804256180851T1004.31045083853T984.804274589938T985.16352791738T967.858986395685T987.740800058909T967.858986395685T1003.57257782441T987.740800058909T1003.38852377534T986.268036302719*

# Encryption Process

(1) Cleartext

(2) Base64

(3) Replace specific characters inside Base64

(4) Separate the modified Base64 into even / odd character arrays

(5) Concatenate the even and odd arrays

(6) Convert new flipped, modified Base64 into hexadecimal

(7) Base64 the hexadecimal

(8) Convert new Base64 to ASCII

(9) Separate large ASCII string into an array of 8 character ASCII integers

(10) Divide each 8 character ASCII integer by the integer-based key

(11) Separate new divided array into even / odd arrays

(12) Concatenate the even and odd arrays (using a randomly generated capital letter delimiter)
