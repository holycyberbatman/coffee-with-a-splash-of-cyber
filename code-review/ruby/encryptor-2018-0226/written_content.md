# Challenge post content
## Challenge
This week's challenge is a code review snippet as seen below.

# Solution post content
Challenge type: Code review
Affected: [encryptor](https://github.com/attr-encrypted/encryptor)
Fixed in: version 3.0
Original code: [found here](https://www.hackyourcybercareer.com/blogs/coffee-with-a-splash-of-cyber/code-review)

## Description
This week's challenge was a code review challenge that presented an encryption library, specifically an AES function that uses GCM ([Galois Counter Mode](https://en.wikipedia.org/wiki/Galois/Counter_Mode)). For those unfamiliar, AES has several modes of operation that can be used, these inform how exactly to apply the original functions single-block cryptographic operations over a piece of data (the input) that is larger than a single block. 

cipher.iv = options[:iv]
The initialization vector (IV) is set using the line of code above. Where the IV is set makes a great deal of difference in the encryption process. The IV is intended to serve as a randomized input to the block cipher encryption process; this means that the same input data encrypted twice would result in a different ciphertext. This resulting difference is intended to take away an attacker's ability to learn something about the original input data by analyzing the resulting ciphertext. 

## Solution
The fix for this particular library was a simple one, even though the bug was a subtle one, as almost all issues with encryption tend to be. The developer simply sets the IV, using the same code as above, after the encryption key is set (the original code sets the IV before the key).

Take a look at the code below to see how it came together in practice.
