'''
  This is a simple tool for converting the listing produced by the
  A09 assembler into Epson HX-20 BASIC statements.
  
  The resulting BASIC program loads the machine code into memory.
  The code can then be executed by an EXEC statement or by 
  calling a USR function.
  
  In the DATA statement, starting addresses for a range of opcodes
  or data are identified by a length of four characters. 
  All opcodes or data bytes are two characters long.
'''

import sys

# ------------------------------------------
def go ( s ):
	'''
   For Epson HX-20.
	Convert 6301 assembler listing file "s" into BASIC.
   '''

	# grab all (listing files are small)
	fIn = open(s);
	ss = fIn.readlines();
	fIn.close();
	
	nLines = len(ss);

	# values have to be adapted
	# RETURN is placed
	nStop  = 1070
	
	n = 10
	print (str(n)+' REM --- Epson HX-20      ---')
	n = n+10
	print (str(n)+' REM --- M. Hepperle 2024 ---')
	n = n+10
	print (str(n)+' REM --- adjust BASIC starting address')

	# skip MEMSET line 
	n = n+10
	nMemSet = n

	n = n+10
	print (str(n)+' REM --- load the code bytes')
	n = n+10
	print (str(n)+' GOSUB 1000')
	n = n+10
	print (str(n)+' REM --- install driver')
	n = n+10
	print (str(n)+' GOSUB 2000')
	n = n+10
	nDefFn = n
	n = n+10
	print (str(n)+' REM --- application example')

	# -----
	n = n+10
	print (str(n)+' OPEN "O",#1,"COM0:(68N1D)"')
	n = n+10
	#print (str(n)+' PRINT USR1(CHR$(0)+CHR$(32)+CHR$(0)+CHR$(64)+"Hello World")')
	print (str(n)+' PRINT USR1("Hello World")')
	n = n+10
	print (str(n)+' CLOSE #1')
	# -----

	n = n+10
	print (str(n)+' REM --- if no parameters, then use:')
	n = n+10
	print (str(n)+' REM   EXEC &H0A40')
	n = n+10
	print (str(n)+' END')

	n = 1000
	print (str(n)+' REM --- Hex Code Loader ---')
	
	n = n+10
	print (str(n)+' N%=0')
	
	n = n+10
	nLoop = n
	print (str(n)+' READ C$')
	
	n = n+10
	print (str(n)+' IF C$="DONE" THEN '+str(n+50))
	
	n = n+10
	print (str(n)+' N%=N%+1 : IF N%=8 THEN PRINT "."; : N%=0')
	
	# new address, DATA MUST start with an address!
	n = n+10
	print (str(n)+' C%=VAL("&H"+C$)')

	# new address, DATA MUST start with an address!
	n = n+10
	print (str(n)+' IF LEN(C$)=4 THEN A%=C% : GOTO '+str(nLoop))
	
	# new opcode
	n = n+10
	print (str(n)+' POKE A%,C% : A%=A%+1 : GOTO '+str(nLoop))

	# 
	n = n+10
	print (str(n)+' PRINT')

	#
	n = n+10
	print (str(n)+' RETURN')

	n = 2000
	print (str(n)+' REM --- Device Installer ---')
	n = n+10
	print (str(n)+' DCBTAB%=&H0657')
	n = n+10
	print (str(n)+' FOR A%=DCBTAB% TO DCBTAB%+30 STEP 2')
	n = n+10
	print (str(n)+' C%=PEEK(A%)*256+PEEK(A%+1)')
	n = n+10
	print (str(n)+' IF C%=&H0A40 THEN GOTO '+str(n+60))
	n = n+10
	print (str(n)+' IF C%=&H0000 THEN GOTO '+str(n+20))
	n = n+10
	print (str(n)+' NEXT A%')
	n = n+10
	print (str(n)+' IF A%>DCBTAB%+28 THEN GOTO '+str(n+50))
	n = n+10
	print (str(n)+' POKE A%,&H0A : REM HIGH')
	n = n+10
	print (str(n)+' POKE A%+1,&H40 : REM LOW')
	n = n+10
	print (str(n)+' PRINT "STAT: at";A%;"installed"')
	n = n+10
	print (str(n)+' RETURN')
	n = n+10
	print (str(n)+' PRINT "Cannot install STAT:"')
	n = n+10
	print (str(n)+' STOP')
	n = n+10


	line=0;
	address = 0

	startAddress = 65536
	endAddress = 0

	sLine = ''

	while line < nLines:
		l = ss[line].replace("\n","")

		# this is the End
		if l.startswith('SYMBOL TABLE'):
			break

		# continuation line has no blank in the first column
		if l[0:1] != ' ':
		#{
			# skip
			line = line+1
			continue
		#}

		addr = l[1:5].strip()
		
		if len(addr) == 4:
		#{
			try:
			#{
				addrDec = int(addr,16)

				if addrDec < startAddress:
				#{
					startAddress = addrDec
				#}

				if addrDec > endAddress:
				#{
					endAddress = addrDec
				#}

				if addrDec != address:
				#{
					# a step in addresses - 
					# output new start address
					address = addrDec
					sLine = sLine + addr + ','
				#}

				opcodes = l[6:20].strip()
				i = 0

				while i < len(opcodes):
				#{
					sLine = sLine + opcodes[i:i+2] + ','
					i = i+2

					# update high water mark
					if address > endAddress:
					#{
						endAddress = address
					#}

					# next free address or start of BASIC for MEMSET
					address = address+1

					if len(sLine)>57:
					#{
						n = n+1
						print (str(n) + ' DATA ' + sLine[0:len(sLine)-1])
						sLine = ''
					#}
				#}
			#}
			except:
			#{
				addrDec = 0
			#}
		#}

		line = line+1
		if line > 50000:
		#{
			break
		#}

	# flush DATA line
	sLine = sLine + 'DONE'
	n = n+1
	print (str(n) + ' DATA ' + sLine[0:len(sLine)])


	# insert MEMSET line above
	print (str(nMemSet) + ' MEMSET &H' + hex(endAddress+1).upper()[2:])
	print (str(nDefFn)+' DEFUSR1=&H'+hex(startAddress).upper()[2:])

	# terminate transfer with ^Z
	print ('\032')

	if 1==1:
		print ('Comments:')
		print ('=========')
		print ('The binary code is loaded into RAM between &H'+hex(startAddress).upper()[2:]+' and &H' + hex(endAddress).upper()[2:]+'.')
		print ('Thus we need to use MEMSET to shift the start of the BASIC')
		print ('program and data area up:')
		print (' MEMSET &H' + hex(endAddress+1).upper()[2:])
		print ('')
		print ('If the code requires no parameters, and returns nothing, you can execute it with')
		print (' EXEC &H' + hex(startAddress).upper()[2:])
		print ('')
		print ('If it takes one parameter, or returns a value, define it as a USR function:')
		print (' DEFUSR1=&H' + hex(startAddress).upper()[2:])
		print ('(Note that USR functions can have only one parameter.')
		print (' Multiple parameters can often be packed into a string or array)')
		print ('Call the function with its parameter and grab the return value:')
		print (' I%=USR1(...parameter...)')
		print ('')			
		print ('The generic Hex Code loader at the end of the program reads DATA statements')
		print ('containing either four or two digit hexadecimal numbers.')
		print ('If the number has 4 digits it is interpreted as the "current address".')
		print ('Any following data bytes will be loaded starting at this address.')
		print ('If the number has two digits, it is a data byte which will be loaded')
		print ('to the "current address" and the address is incremented by one.')
		print ('This scheme allows loading data to arbitrary addresses, if desired.')
		print ('Reading the data stream is terminated by the data item DONE.')
		print ('')			
		print ('If nothing changes, the data has to be read only once, so that')
		print ('you could add a test for e.g. the first and last bytes and skip loading.')
		print ('The assembler code should usually end with an RTS instruction (&H39).')
		
# ------------------------------------------

if __name__ == "__main__":
   if len(sys.argv)>1:
      basePath = "D:\\HP\\Epson HX-20\\ASM\\"
      basePath = './'
      fileName = sys.argv[1]
      go(basePath + fileName)
   else:
      print ('Usage: LST2BAS listing.lst')

