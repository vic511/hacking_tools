#!/usr/bin/env python
# coding: UTF-8
from optparse import OptionParser, OptionGroup
import itertools
import string
from os import path, system

parser = OptionParser()
parser.add_option(
	"-d", "--directory",
	dest="folder",
	help="Directory to dump, default=/tmp",
	default="/tmp"
)
parser.add_option(
	"-l", "--length",
	dest="length",
	help="Max length (0 is unlimited), default=8",
	default="8",
	type="int"
)

(options, args) = parser.parse_args()

folder = options.folder.rstrip("/") + "/"
length = options.length if options.length != 0 else -1
charset = string.letters
found = [folder + x for x in ("", ".", "..")]

x = 1
while x != length + 1:
	for name in itertools.combinations_with_replacement(charset, x):
		name = "".join(name).rstrip("/")
		file = folder + name
		if file in found:
			continue
		if path.exists(file):
			system("ls -lad " + file)
			found.append(file)
	x += 1
