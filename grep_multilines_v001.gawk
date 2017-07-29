#!/usr/bin/gawk -f
#\File: /usr/local/bin/gm
#\Usage: AWK Script to locate your pattern between specific context
#\Version: v0.01 Kan.Qiu <gbqiukan@gmail.com>

function dealCase(string) {
	if (isIgnoreCase == 1) {
		return tolower(string)
	}
	else {
		return string
	}
}



BEGIN {
	#print "ARGC=",ARGC
	#No Effect??
	#IGNORECASE = 1
	isIgnoreCase = 0
	isSmartCase = 0
	contextLines = 0
	keysIsReady = 0
	argCtxReady = 0
	argICsReady = 0
	argSCsReady = 0
	key1 = ""
	key2 = ""
	key3 = ""
	inBlock = 0
	block = ""
	preBlock = ""
	matchedkey1 = 0
	matchedkey1key2 = 0
	for (i = 1; i < ARGC-1; )
	{
		#if ((argSCsReady ==1 || argICsReady == 1) && argCtxReady == 1 && keysIsReady == 1) {
		#	break
		#}
		if (argCtxReady == 0 && (ARGV[i] ~ "^-[cC]$")) {
			delete ARGV[i]
			contextLines = ARGV[++i]
			argCtxReady = 1
			#print "Context readAroundLines:", contextLines
			delete ARGV[i]
			++i
		}
		else if (argICsReady == 0 && (ARGV[i] ~ "^-[iI]$")) {
			delete ARGV[i]
			isIgnoreCase = 1
			argICsReady = 1
			++i
		}
		else if (argSCsReady == 0 && (ARGV[i] ~ "^-[sS]$")) {
			delete ARGV[i]
			isSmartCase = 1
			argSCsReady = 1
			++i
		}
		else if (keysIsReady == 0) {
			if (key1 == "") {
				key1 = dealCase(ARGV[i])
				#print "Key 1:", key1
				delete ARGV[i]
			}
			else if (key2 == "") {
				key2 = dealCase(ARGV[i])
				#print "Key 2:", key2
				delete ARGV[i]
			}
			else if (key3 == "") {
				key3 = dealCase(ARGV[i])
				#print "Key 3:", key3
				delete ARGV[i]
			}
			++i
		}

	}
	if (key1 == "") {
		printf "Usage: %s [-c SCOPE] Pattern1 [Pattern2] [Pattern3]", ARGV[i]
		exit 1
	}
	#if (key2 == "") {
	#	key2 = key1
	#	key1 = ""
	#}
	if (argCtxReady == 0) {
		contextLines = 0
	}
}

{
	#if (NF == 0) {
	#    next
	#}
	if (FNR == 1) {
		if (block != "") {
			printf "%s", fileTitle block
			block = ""
		}
		fileTitle = "=========="ORS"<<"FILENAME">>"ORS
		inBlock = 0
		preBlock = ""
		matchedkey1 = 0
		matchedkey1key2 = 0
	}
	line = dealCase($0)
	if (inBlock == 0) {
		if (key3 == "") {
			if (key2 == "") {
				if (line ~ key1) {
					block = block FNR"@1:"$0 ORS
				}
			}
			else {
				if (line ~ key1 ".*" key2) {
					block = block FNR "@12:" $0 ORS
					block = block "-----" ORS
				}
				else if (line ~ key2 ".*" key1) {
					block = block FNR "@21:" $0 ORS
					block = block "-----" ORS
				}
				else if (line ~ key1) {
					preBlock = preBlock FNR "@1:" $0 ORS
					inBlock = 1
					readAroundLines = 1
					matchedKey1 = 1
				}
			}
		}
		else {
			if (line ~ key1 ".*" key2 ".*" key3)
			{
				block = block FNR "@123:" $0 ORS
				block = block "-----" ORS
			}
			else if (line ~ key1 ".*" key2) {
				preBlock = preBlock FNR "@12:" $0 ORS
				inBlock = 1
				readAroundLines = 1
				matchedKey1Key2 = 1
			}
			else if (line ~ key1) {
				preBlock = preBlock FNR "@1:" $0 ORS
				inBlock = 1
				readAroundLines = 1
				matchedKey1 = 1
			}
		}
	}
	#In block state
	else {
		if (key3 == "") {
			if (line ~ key1 ".*" key2)
			{
				preBlock = preBlock FNR "@12:" $0 ORS
				preBlock = preBlock "-----" ORS
				block = block preBlock
				preBlock = ""
				inBlock = 0
				matchedKey1 = 0
				readAroundLines = 0
				next
			}
			else if (line ~ key2) {
				preBlock = preBlock FNR "@2:" $0 ORS
				preBlock = preBlock "-----" ORS
				block = block preBlock
				preBlock = ""
				inBlock = 0
				matchedKey1Key2 = 0
				matchedKey1 = 0
				next
			}
			else if (line ~ key1) {
				preBlock = preBlock FNR "@1:" $0 ORS
				readAroundLines = 1
				next
			}
		}
		else if (matchedKey1Key2) {
			if (line ~ key3) {
				preBlock = preBlock FNR "@3:" $0 ORS
				preBlock = preBlock "-----" ORS
				block = block preBlock
				preBlock = ""
				inBlock = 0
				matchedKey1Key2 = 0
				matchedKey1 = 0
				next
			}
			else if (line ~ key2) {
				preBlock = preBlock FNR "@2:" $0 ORS
				readAroundLines = 1
				next
			}
		}
		else if (matchedKey1) {
			if (line ~ key1) {
				preBlock = ""
				if (line ~ key1 ".*" key2 ".*" key3)
				{
					preBlock = preBlock FNR "@123:" $0 ORS
					preBlock = preBlock "-----" ORS
					block = block preBlock
					preBlock = ""
					inBlock = 0
					matchedKey1Key2 = 0
					matchedKey1 = 0
					readAroundLines = 0
					next
				}
				else if (line ~ key1 ".*" key2) {
					preBlock = preBlock FNR "@12:" $0 ORS
					readAroundLines = 1
					matchedKey1Key2 = 1
					next
				}
				else {
					preBlock = preBlock FNR "@1:" $0 ORS
					readAroundLines = 1
					next
				}
			}
			else if (line ~ key2".*"key3) {
				preBlock = preBlock FNR "@23:" $0 ORS
				preBlock = preBlock "-----" ORS
				block = block preBlock
				preBlock = ""
				inBlock = 0
				matchedKey1Key2 = 0
				matchedKey1 = 0
				readAroundLines = 0
				next
			}
			else if (line ~ key2) {
				preBlock = preBlock FNR "@2:" $0 ORS
				readAroundLines = 1
				matchedKey1Key2 = 1
				next
			}
		}

		if (readAroundLines+1 > contextLines) {
			#if (matchedKey1Key2) {
			#	printf "%s", block
			#}
			preBlock = ""
			inBlock = 0
			matchedKey1Key2 = 0
			matchedKey1 = 0
			readAroundLines = 0
			next
		}

		#else {
		#    next
		#}
		readAroundLines++
		preBlock = preBlock FNR"-"$0 ORS
	}
}
END {
	if (block != "") {
		printf "%s", fileTitle block
	}
}
