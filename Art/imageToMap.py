#This will need the python imaging library. This can be done with 
# "easy_install Pillow" on windows. 
# (trivially without quotes and through a console)
from PIL import Image
from PIL import ImageColor
import os

FOLDERNAME="\\Maps\\Complete\\" #folder containing images
OUTPUTNAMEFILENAME="map.txt" #File output location
#conversion table:
	##Breaks indicate unused values may be stored there.
	#All:
	# 0xFFFFFF >> " " = 34 >> sky/nothing

	#Background:
	# 0x649696 >> '!' = 33 >> HillSmall_2_0
	# 0x6496c8 >> '#' = 35 >> HillSmall_2_1
	# 0x000096 >> '$' = 36 >> BushDouble_0_0
	# 0x0000c8 >> 'Y' = 88 >> BushDouble_1_0 //Replaced % with Y since % may have caused problems
	# 0x0000fa >> '&' = 38 >> BushDouble_2_0
	# 0x003200 >> ''' = 39 >> BushSingle_0_0
	# 0x003232 >> '(' = 40 >> BushSingle_1_0
	# 0x003264 >> ')' = 41 >> BushTriple_0_0
	# 0x003296 >> '*' = 42 >> BushTriple_1_0
	# 0x0032c8 >> '+' = 43 >> BushTriple_2_0
	# 0x0032fa >> ',' = 44 >> BushTriple_3_0
	# 0x006400 >> '-' = 45 >> Castle_0_0
	# 0x006432 >> '.' = 46 >> Castle_0_1
	# 0x006464 >> '/' = 47 >> Castle_0_2
	# 0x006496 >> '0' = 48 >> Castle_0_3
	# 0x0064c8 >> '1' = 49 >> Castle_0_4
	# 0x0064fa >> '2' = 50 >> Castle_1_0
	# 0x009600 >> '3' = 51 >> Castle_1_1
	# 0x009632 >> '4' = 52 >> Castle_1_2
	# 0x009664 >> '5' = 53 >> Castle_1_3
	# 0x009696 >> '6' = 54 >> Castle_1_4
	# 0x0096c8 >> '7' = 55 >> Castle_2_0
	# 0x0096fa >> '8' = 56 >> Castle_2_1
	# 0x00c800 >> '9' = 57 >> Castle_2_2
	# 0x00c832 >> ':' = 58 >> Castle_2_3
	# 0x00c864 >> ';' = 59 >> Castle_2_4
	# 0x00c896 >> '<' = 60 >> Castle_3_0
	# 0x00c8c8 >> '=' = 61 >> Castle_3_1
	# 0x00c8fa >> '>' = 62 >> Castle_3_2
	# 0x00fa00 >> '?' = 63 >> Castle_3_3
	# 0x00fa32 >> '@' = 64 >> Castle_3_4
	# 0x00fa64 >> 'A' = 65 >> Castle_4_0
	# 0x00fa96 >> 'B' = 66 >> Castle_4_1
	# 0x00fac8 >> 'C' = 67 >> Castle_4_2
	# 0x00fafa >> 'D' = 68 >> Castle_4_3
	# 0x320000 >> 'E' = 69 >> Castle_4_4
	# 0x320032 >> 'F' = 70 >> CloudDouble_0_0
	# 0x320064 >> 'G' = 71 >> CloudDouble_0_1
	# 0x320096 >> 'H' = 72 >> CloudDouble_1_0
	# 0x3200c8 >> 'I' = 73 >> CloudDouble_1_1
	# 0x3200fa >> 'J' = 74 >> CloudDouble_2_0
	# 0x323200 >> 'K' = 75 >> CloudDouble_2_1
	# 0x323232 >> 'L' = 76 >> CloudSingle_0_0
	# 0x323264 >> 'M' = 77 >> CloudSingle_0_1
	# 0x323296 >> 'N' = 78 >> CloudSingle_1_0
	# 0x3232c8 >> 'O' = 79 >> CloudSingle_1_1
	# 0x3232fa >> 'P' = 80 >> CloudTriple_0_0
	# 0x326400 >> 'Q' = 81 >> CloudTriple_0_1
	# 0x326432 >> 'R' = 82 >> CloudTriple_1_0
	# 0x326464 >> 'S' = 83 >> CloudTriple_1_1
	# 0x326496 >> 'T' = 84 >> CloudTriple_2_0
	# 0x3264c8 >> 'U' = 85 >> CloudTriple_2_1
	# 0x3264fa >> 'V' = 86 >> CloudTriple_3_0
	# 0x329600 >> 'W' = 87 >> CloudTriple_3_1
	# Y is in use

	# 0x32c800 >> '^' = 94 >> FlagPoleBeam_0_0
	# 0x32c832 >> '_' = 95 >> FlagPoleFlag_0_0
	# 0x32c864 >> '`' = 96 >> FlagPoleTop_0_0

	# 0x640064 >> 'l' = 108 >> HillLarge_0_0
	# 0x640096 >> 'm' = 109 >> HillLarge_0_1
	# 0x6400c8 >> 'n' = 110 >> HillLarge_0_2
	# 0x6400fa >> 'o' = 111 >> HillLarge_1_0
	# 0x643200 >> 'p' = 112 >> HillLarge_1_1
	# 0x643232 >> 'q' = 113 >> HillLarge_1_2
	# 0x643264 >> 'r' = 114 >> HillLarge_2_0
	# 0x643296 >> 's' = 115 >> HillLarge_2_1
	# 0x6432c8 >> 't' = 116 >> HillLarge_2_2
	# 0x6432fa >> 'u' = 117 >> HillLarge_3_0
	# 0x646400 >> 'v' = 118 >> HillLarge_3_1
	# 0x646432 >> 'w' = 119 >> HillLarge_3_2
	# 0x646464 >> 'x' = 120 >> HillLarge_4_0
	# 0x646496 >> 'y' = 121 >> HillLarge_4_1
	# 0x6464c8 >> 'z' = 122 >> HillLarge_4_2
	# 0x6464fa >> '{' = 123 >> HillSmall_0_0
	# 0x649600 >> '|' = 124 >> HillSmall_0_1
	# 0x649632 >> '}' = 125 >> HillSmall_1_0
	# 0x649664 >> '~' = 126 >> HillSmall_1_1


	#foreground:
	# 0x000032 >> '!' = 33 >> UpMushroom_0_0
	# 0x000064 >> '#' = 35 >> Bricks_0_0
	# 0x6496fa >> '$' = 36 >> MarioClimb1_0_0
	# 0x64c800 >> 'L' = 76 >> MarioClimb2_0_0 //% could be problematic
	# 0x64c832 >> '&' = 38 >> MarioDead_0_0
	# 0x64c864 >> ''' = 39 >> MarioJump_0_0
	# 0x64c896 >> '(' = 40 >> MarioSkid_0_0
	# 0x64c8c8 >> ')' = 41 >> MarioWalk1_0_0
	# 0x64c8fa >> '*' = 42 >> MarioWalk2_0_0
	# 0x64fa00 >> '+' = 43 >> MarioWalk3_0_0
	# 0x64fa32 >> ',' = 44 >> Mario_0_0
	# 0x64fa64 >> '-' = 45 >> Pipe_0_0
	# 0x64fa96 >> '.' = 46 >> Pipe_0_1
	# 0x64fac8 >> '/' = 47 >> Pipe_1_0
	# 0x64fafa >> '0' = 48 >> Pipe_1_1
	# 0x960000 >> '1' = 49 >> QuestionBlock00_0_0
	# 0x960032 >> '2' = 50 >> QuestionBlock01_0_0
	# 0x960064 >> '3' = 51 >> QuestionBlock02_0_0
	# 0x960096 >> '4' = 52 >> SolidBlock_0_0
	# 0x9600c8 >> '5' = 53 >> Starman00_0_0
	# 0x9600fa >> '6' = 54 >> Starman01_0_0
	# 0x963200 >> '7' = 55 >> Starman02_0_0
	# 0x963232 >> '8' = 56 >> Starman03_0_0
	# 0x963264 >> '9' = 57 >> SuperMarioClimb1_0_0
	# 0x963296 >> ':' = 58 >> SuperMarioClimb1_0_1
	# 0x9632c8 >> ';' = 59 >> SuperMarioClimb2_0_0
	# 0x9632fa >> '<' = 60 >> SuperMarioClimb2_0_1
	# 0x966400 >> '=' = 61 >> SuperMarioDuck_0_0
	# 0x966432 >> '>' = 62 >> SuperMarioDuck_0_1
	# 0x966464 >> '?' = 63 >> SuperMarioJump_0_0
	# 0x966496 >> '@' = 64 >> SuperMarioJump_0_1
	# 0x9664c8 >> 'A' = 65 >> SuperMarioSkid_0_0
	# 0x9664fa >> 'B' = 66 >> SuperMarioSkid_0_1
	# 0x969600 >> 'C' = 67 >> SuperMarioWalk1_0_0
	# 0x969632 >> 'D' = 68 >> SuperMarioWalk1_0_1
	# 0x969664 >> 'E' = 69 >> SuperMarioWalk2_0_0
	# 0x969696 >> 'F' = 70 >> SuperMarioWalk2_0_1
	# 0x9696c8 >> 'G' = 71 >> SuperMarioWalk3_0_0
	# 0x9696fa >> 'H' = 72 >> SuperMarioWalk3_0_1
	# 0x96c800 >> 'I' = 73 >> SuperMario_0_0
	# 0x96c832 >> 'J' = 74 >> SuperMario_0_1
	# 0x96c864 >> 'K' = 75 >> SuperMushroom_0_0
	# L is used in this dataset

	# 0x329632 >> 'X' = 88 >> Coin00_0_0
	# 0x329664 >> 'Y' = 89 >> Coin01_0_0
	# 0x329696 >> 'Z' = 90 >> Coin02_0_0
	# 0x3296c8 >> '[' = 91 >> DirtGround_0_0
	# 0x3296fa >> ']' = 93 >> EmptyBlock_0_0
	# 0x32c896 >> 'a' = 97 >> Goomba00_0_0
	# 0x32c8c8 >> 'b' = 98 >> Goomba01_0_0
	# 0x32c8fa >> 'c' = 99 >> Goomba02_0_0
	# 0x32fa00 >> 'd' = 100 >> Goomba03_0_0
	# 0x32fa32 >> 'e' = 101 >> GrassGround_0_0
	# 0x32fa64 >> 'f' = 102 >> GreenKoopaTroopaShell1_0_0
	# 0x32fa96 >> 'g' = 103 >> GreenKoopaTroopaShell2_0_0
	# 0x32fac8 >> 'h' = 104 >> GreenKoopaTroopa00_0_0
	# 0x32fafa >> 'i' = 105 >> GreenKoopaTroopa00_0_1
	# 0x640000 >> 'j' = 106 >> GreenKoopaTroopa01_0_0
	# 0x640032 >> 'k' = 107 >> GreenKoopaTroopa01_0_1

ASCIITOCOLOURKEY={'000032':'!','000064':'#','000096':'$','0000c8':'Y','0000fa':'&','003200':'\'','003232':'(','003264':')','003296':'*','0032c8':'+','0032fa':',','006400':'-','006432':'.','006464':'/','006496':'0','0064c8':'1','0064fa':'2','009600':'3','009632':'4','009664':'5','009696':'6','0096c8':'7','0096fa':'8','00c800':'9','00c832':':','00c864':';','00c896':'<','00c8c8':'=','00c8fa':'>','00fa00':'?','00fa32':'@','00fa64':'A','00fa96':'B','00fac8':'C','00fafa':'D','320000':'E','320032':'F','320064':'G','320096':'H','3200c8':'I','3200fa':'J','323200':'K','323232':'L','323264':'M','323296':'N','3232c8':'O','3232fa':'P','326400':'Q','326432':'R','326464':'S','326496':'T','3264c8':'U','3264fa':'V','329600':'W','329632':'X','329664':'Y','329696':'Z','3296c8':'[','3296fa':']','32c800':'^','32c832':'_','32c864':'`','32c896':'a','32c8c8':'b','32c8fa':'c','32fa00':'d','32fa32':'e','32fa64':'f','32fa96':'g','32fac8':'h','32fafa':'i','640000':'j','640032':'k','640064':'l','640096':'m','6400c8':'n','6400fa':'o','643200':'p','643232':'q','643264':'r','643296':'s','6432c8':'t','6432fa':'u','646400':'v','646432':'w','646464':'x','646496':'y','6464c8':'z','6464fa':'{','649600':'|','649632':'}','649664':'~','649696':'!','6496c8':'#','6496fa':'$','64c800':'L','64c832':'&','64c864':'\'','64c896':'(','64c8c8':')','64c8fa':'*','64fa00':'+','64fa32':',','64fa64':'-','64fa96':'.','64fac8':'/','64fafa':'0','960000':'1','960032':'2','960064':'3','960096':'4','9600c8':'5','9600fa':'6','963200':'7','963232':'8','963264':'9','963296':':','9632c8':';','9632fa':'<','966400':'=','966432':'>','966464':'?','966496':'@','9664c8':'A','9664fa':'B','969600':'C','969632':'D','969664':'E','969696':'F','9696c8':'G','9696fa':'H','96c800':'I','96c832':'J','96c864':'K','ffffff':' '}

def main():
	#Outputs to output.txt
	output = open(OUTPUTNAMEFILENAME, 'w')
	output.write(".section .text\n")
	section="_text"
	getImages(output,section)
	output.write("\n\n.section .data\n")
	section="_data"
	getImages(output,section)
	output.close()

def getImages(output,section):

	#Keep looping for all files in the folder Images
	for fileName in os.listdir(os.getcwd()+FOLDERNAME):
		# print(fileName,FOLDERNAME,output)
		# imageList+=openImage(os.getcwd()+FOLDERNAME+fileName,output)
		output.write(".align 4\n")
		processImage(os.getcwd()+FOLDERNAME+fileName,output,section)

#Opens the image and converts colour data to ascii
def processImage(imgName,output,section):
	img = Image.open(imgName) #Can be many different formats.

	pixels = img.convert('RGBA').load()
	imageSize = img.size #Get the width and hight of the image for iterating over

	memLabel=trimImageName(imgName)+section


	writeToFile(output, pixels, memLabel, imageSize)


def writeToFile(output,pixels, memLabel, imageSize):
	##Write hex values to txt file
	output.write(memLabel+":\n")
	print(".globl "+memLabel)

	# output.write("\t.int: #"+str(imageSize[0])+", #"+str(imageSize[1])+"\n")
	# output.write("\t.int: #32, #32\n")

	for y in range(imageSize[1]):
		output.write("\t.ascii: \"")
		for x in range(imageSize[0]):
			tempAscii=convertToAscii(x, y, pixels)
			#convert to ascii
			output.write(tempAscii)
		output.write("\"\n")

def convertToAscii(x, y, pixels):
	r,g,b,a=pixels[x,y]
	tempHex='{:02x}{:02x}{:02x}'.format(r, g, b)
	# print(tempHex)
	# print(ASCIITOCOLOURKEY.keys())
	return ASCIITOCOLOURKEY[tempHex]


#Trims the filepath to a label friendly string
def trimImageName(imgName):
	trimmedName=""
	tempName=os.path.basename(imgName)
	for i in range(len(tempName)):
		# print (x)
		if tempName[i]!=' ' and tempName[i]!='-':
			if (i == 0) and not tempName[i].isdigit():
				trimmedName+=tempName[i]
			elif (i!=0):
				trimmedName+=tempName[i]
	trimmedName=trimmedName[:-4]
	return trimmedName


if __name__ == '__main__':
	main()