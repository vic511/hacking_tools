# hacking_tools
Here are some tools I created.

## discovery.py
  This python script is designed to discover files in directories you cannot list.
  This is a simple bruteforce algorithm using itertools, feel free to enhance it.
#### Usage
```bash
$ discovery.py -h
Usage: discovery.py [options]

Options:
  -h, --help            show this help message and exit
  -d FOLDER, --directory=FOLDER
                        Directory to dump, default=/tmp
  -l LENGTH, --length=LENGTH
                        Max length (0 is unlimited), default=8
```
#### Example
```bash
$ discovery.py -d ~
drwxr-xr-x 6 vic511 vic511 4096 juin  28  2015 /home/vic511/py
drwxr-xr-x 2 vic511 vic511 4096 mars   6 04:17 /home/vic511/bin
```

## extract0r.sh
  Use this script to boost your productivity while creating shellcodes.
  It outputs the shellcode to the specified file, and generates a C code.   
#### Usage
```bash
$ extract0r.sh 
Usage: extract0r.sh <file> <outfile> [options]
where file is a nasm file

Options:
  -h, --help       show this help message and exit
  -e, --execute    execute given shellcode
  -32, -64         specify shellcode arch
```
####Example
```bash
$ ./extract0r.sh shellcode.asm shellcode.s -e
shellcode.asm.o:     file format elf64-x86-64

int main(int argc, char **argv){

        char *shellcode = // length = 59
                "\xeb\x25\x27\x48\x31\xc0\x48\x31\xdb\x48\x31\xc9\x48\x31\xd2"
                "\x48\x31\xff\x48\x83\xc7\x01\x5e\xb2\x0d\xb0\x01\x0f\x05\x48"
                "\x31\xff\x48\x83\xc7\x2a\xb0\x3c\x0f\x05\xe8\xd6\xff\xff\xff"
                "\x48\x65\x6c\x6c\x6f\x20\x77\x6f\x72\x6c\xa2\x64\x21\x0a";

        void (*exec)();
        exec = (void(*)()) shellcode;
        exec();
        return 0;
}
[+] Execution...
Hello world!
$ hd shellcode.s
00000000  eb 1f 21 48 31 c0 48 31  d2 48 31 ff 48 83 c7 01  |..!H1.H1.H1.H...|
00000010  5e b2 0d b0 01 0f 05 48  31 ff 48 83 c7 2a b0 3c  |^......H1.H..*.<|
00000020  0f 05 e8 dc ff ff ff 48  65 6c 6c 6f 20 77 6f 72  |.......Hello wor|
00000030  6c 9c 64 21 0a                                    |l.d!.|
00000035
```

