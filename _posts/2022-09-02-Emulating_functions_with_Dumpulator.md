---
title: "Emulating functions with Dumpulator"
draft: false
description: "Emulating functions to decrypt strings and flag in Flare-On 2022"
date: 2023-09-02
tags: Dumpulator, Flare-On
categories: Study
---
Table of contents
- [1. Overview](#1-overview)
- [2. Create MiniDump file.](#2-create-minidump-file)
- [3. Code Analysis.](#3-code-analysis)
	- [3.1 Decrypting api name.](#31-decrypting-api-name)
	- [3.2 Decrypting flag.](#32-decrypting-flag)
- [4. Using Dumpulator.](#4-using-dumpulator)
	- [4.1 Emulating Functions to decrypt api name.](#41-emulating-functions-to-decrypt-api-name)
	- [4.2 Emulating Functions to decrypt flag.](#42-emulating-functions-to-decrypt-flag)

## 1. Overview    
- [Dumpulator](https://github.com/mrexodia/dumpulator/)
- [Flare-On 2022 Challenge 6](https://github.com/fareedfauzi/Flare-On-Challenges/tree/master/Challenges/2022)
- [Write-Up](https://www.elastic.co/flare-on-9-solutions-burning-down-the-house)

## 2. Create MiniDump file.
The first thing that we need to do the emulation is to create the memmory dump of the dll file. Using x32dbg to do this task.

Open x32dbg and load **HowDoesThisWork.dll** (PE32 executable DLL). Run until the program stops at the DllEntryPoint **_CorDllMain**. 

![EntryPoint](/assets/images/2022-09-02-Emulating_functions_with_Dumpulator/dllentrypoint.png)

Using this command to create minidump ```Minidump <filename>.dmp``` and saved in **release/x32dbg**.

![Create Minidump](/assets/images/2022-09-02-Emulating_functions_with_Dumpulator/dump_command.png)

The next step is to get the **base address** from the memmory dump, this is important in order to allow we rebase the image entry point in IDA so that we can have same addressing between IDA and Memory dump. 

```python
# check base address in memmory dump
from dumpulator import Dumpulator

if __name__ == "__main__":
	dp = Dumpulator('minidump.dmp', trace=False)
```

![Check base address](/assets/images/2022-09-02-Emulating_functions_with_Dumpulator/check_base.png)

## 3. Code Analysis.
### 3.1 Decrypting api name.

Upon quickly examining at the **Strings tab**, we came across numerous strings in the following format:

![Strings](/assets/images/2022-09-02-Emulating_functions_with_Dumpulator/strings.png)

Going through the code snippet using an arbitrary string. 

![](/assets/images/2022-09-02-Emulating_functions_with_Dumpulator/code_analysis.png)

Based on the image above, it is easy to see:
- The **decrypt_strings** function takes two parameters in the stack.
- First parameter is the encrypted strings.

### 3.2 Decrypting flag.
This function uses a new string encryption function and string comparison (lstrcmpA) when the connection occurs. If true, the function will retrieve the decrypted flag go through **sub_10001187** function.

![Decrypt function](/assets/images/2022-09-02-Emulating_functions_with_Dumpulator/decrypt_flag.png)

## 4. Using Dumpulator.
### 4.1 Emulating Functions to decrypt api name.
To emulate the function by using **Dumpulator**, we need to get the function address and encrypted strings address: 
- The **decrypt_strings** function address: **0x100014AE**. 
- All the encrypted strings address: **0x10015060, 0x10015070, 0x10015084, 0x10015098, 0x100150A8, 0x100150BC, 0x100150D0, 0x100150E0, 0x100150F0, 0x100150FC, 0x10015108**

```python
from dumpulator import Dumpulator

decrypt_strings_address = 0x100014AE
enc_strings_address_lst = [0x10015060, 0x10015070, 0x10015084, 0x10015098, 0x100150A8, 0x100150BC, 0x100150D0, 0x100150E0, 0x100150F0, 0x100150FC, 0x10015108]

def decrypt_api(enc_strings_address: int):
	dp.call(decrypt_strings_address, [enc_strings_address, tmp_address])
	decrypted = dp.read_str(tmp_address)
	print(f'Encrypted string at address: {hex(enc_strings_address)}\nDecrypted string: {decrypted}\n')

if __name__ == "__main__":
	dp = Dumpulator('minidump.dmp', trace=False)
	tmp_address = dp.allocate(64)

	for i in enc_strings_address_lst:
		decrypt_api(i)
```

![result](/assets/images/2022-09-02-Emulating_functions_with_Dumpulator/decrypt_api.png)

### 4.2 Emulating Functions to decrypt flag. 

This is the code to emulate function to decrypt the flag. Based on the pseudocode code in sections **3.2**.

```python
from dumpulator import Dumpulator

enc_flag_address = 0x10015008
enc_pass_address = 0x10015028

def decrypt_flag():
	dp.call(0x100011EF, [tmp_address, 0x10015000, 8])
	dp.call(decrypt_function_address, [tmp_address, enc_pass_address, 9])
	dp.call(decrypt_function_address, [tmp_address, enc_flag_address, 31])
	
	print(f'Pass: {dp.read_str(enc_pass_address)}\nFlag: {dp.read_str(enc_flag_address)}')
if __name__ == "__main__":
	dp = Dumpulator('minidump.dmp', trace=False)
	tmp_address = dp.allocate(64)

    decrypt_flag()
```
![](/assets/images/2022-09-02-Emulating_functions_with_Dumpulator/flag.png)

```flag: M1x3d_M0dE_4_l1f3@flare-on.com```