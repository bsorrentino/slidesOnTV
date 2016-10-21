## Check if framework is full bitcode(d)

```
otool -arch arm64 -l <framework path>  | grep LLVM
```
```
BITCODE_GENERATION_MODE=bitcode
ENABLE_BITCODE=YES

Other C Flags       = -fembed-bitcode
Other Linker Flags  = -fembed-bitcode
```
