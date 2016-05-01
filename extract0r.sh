#!/bin/bash
# generating shellcode from nasm files
# by vic511

PATH="/bin:/usr/bin"

usage(){
	cat >&2 <<USAGE
Usage: $(basename $0) <file> <outfile> [options]
where file is a nasm file

Options:
  -h, --help       show this help message and exit
  -e, --execute    execute given shellcode
  -32, -64         specify shellcode arch
USAGE
	exit
}

(($# < 2)) && usage
execute=false
asmfile="$1"
outfile="$2"
[ "$(uname -m)" == "x86_64" ] && myarch="64" || myarch="32"
arch="$myarch"

while (($# > 2 )); do
    case "$3" in
        -h|--help)      usage;;
        -e|--execute)   execute=true;;
        -32)            arch="32";;
        -64)    		arch="64";;
        *)          echo "'$3': unknown option" >&2 && exit;;
    esac
    shift
done

nasm -f "elf${arch}" "$asmfile" -o "${asmfile}.o" || exit
data="$(objdump -d "${asmfile}.o")" || exit
echo "$data" | head -n2 | tail -n1

hex="$(for i in $data; do
	echo $i;
done | grep -E "^[0-9a-f]{2}$")"
x=0
shellcode=''
for i in $hex; do
	if [ "$i" == "00" ]; then
		echo "[-] Shellcode contains null bytes !" >&2
		exit
	fi
	if ((x % 15 == 0)) && ((x != 0)); then
		shellcode="${shellcode}"$'"\n\t\t"'
	fi
	shellcode="${shellcode}\\x$i"
	x=$((x+1))
done

echo "$hex" | xxd -r -p > "$outfile"
echo

src="int main(int argc, char **argv){

	char *shellcode = // length = $x
		\"$shellcode\";

	void (*exec)();
	exec = (void(*)()) shellcode;
	exec();
	return 0;
}"
echo "$src"

if $execute; then
	((myarch < arch)) && echo "[-] Execution error: target host is 32 bits !" >&2 && exit
	echo "[+] Execution..."
	ld -o "${asmfile}.bin" "${asmfile}.o" 2>&-
	eval "./${asmfile}.bin"
	rm "${asmfile}.bin"
fi
rm "${asmfile}.o"
