#!/bin/bash
# extracting shellcode from ELF/nasm files
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
arch="$(uname -m)"
[ "$(uname -m)" == "x86_64" ] && arch="64" || arch="32"

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
		echo "Shellcode contains null bytes !" >&2
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
	echo "[+] Execution..."
	ld -o "${asmfile}.bin" "${asmfile}.o" 2>&-
	eval "./${asmfile}.bin"
fi
rm "${asmfile}".{bin,o}
