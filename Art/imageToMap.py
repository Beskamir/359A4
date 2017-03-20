#This will need the python imaging library. This can be done with 
# "easy_install Pillow" on windows. 
# (trivially without quotes and through a console)
from PIL import Image
from PIL import ImageColor
import os

FOLDERNAME="\\Maps\\Complete\\" #folder containing images
OUTPUTNAMEFILENAME="map.txt" #File output location
CONVERSIONKEYUSED = """
/*
conversion table:
	#Breaks indicate change from foreground to background or vice versa
	All:
	0xFFFFFF >> '0' >> sky/nothing

	0x000032 >> '1' >> s_UpMushroom_0_0
	0x000064 >> '2' >> s_Bricks_0_0

	0x000096 >> '3' >> s_BushDouble_0_0
	0x0000c8 >> '4' >> s_BushDouble_1_0
	0x0000fa >> '5' >> s_BushDouble_2_0
	0x003200 >> '6' >> s_BushSingle_0_0
	0x003232 >> '7' >> s_BushSingle_1_0
	0x003264 >> '8' >> s_BushTriple_0_0
	0x003296 >> '9' >> s_BushTriple_1_0
	0x0032c8 >> '10' >> s_BushTriple_2_0
	0x0032fa >> '11' >> s_BushTriple_3_0
	0x006400 >> '12' >> s_Castle_0_0
	0x006432 >> '13' >> s_Castle_0_1
	0x006464 >> '14' >> s_Castle_0_2
	0x006496 >> '15' >> s_Castle_0_3
	0x0064c8 >> '16' >> s_Castle_0_4
	0x0064fa >> '17' >> s_Castle_1_0
	0x009600 >> '18' >> s_Castle_1_1
	0x009632 >> '19' >> s_Castle_1_2
	0x009664 >> '20' >> s_Castle_1_3
	0x009696 >> '21' >> s_Castle_1_4
	0x0096c8 >> '22' >> s_Castle_2_0
	0x0096fa >> '23' >> s_Castle_2_1
	0x00c800 >> '24' >> s_Castle_2_2
	0x00c832 >> '25' >> s_Castle_2_3
	0x00c864 >> '26' >> s_Castle_2_4
	0x00c896 >> '27' >> s_Castle_3_0
	0x00c8c8 >> '28' >> s_Castle_3_1
	0x00c8fa >> '29' >> s_Castle_3_2
	0x00fa00 >> '30' >> s_Castle_3_3
	0x00fa32 >> '31' >> s_Castle_3_4
	0x00fa64 >> '32' >> s_Castle_4_0
	0x00fa96 >> '33' >> s_Castle_4_1
	0x00fac8 >> '34' >> s_Castle_4_2
	0x00fafa >> '35' >> s_Castle_4_3
	0x320000 >> '36' >> s_Castle_4_4
	0x320032 >> '37' >> s_CloudDouble_0_0
	0x320064 >> '38' >> s_CloudDouble_0_1
	0x320096 >> '39' >> s_CloudDouble_1_0
	0x3200c8 >> '40' >> s_CloudDouble_1_1
	0x3200fa >> '41' >> s_CloudDouble_2_0
	0x323200 >> '42' >> s_CloudDouble_2_1
	0x323232 >> '43' >> s_CloudSingle_0_0
	0x323264 >> '44' >> s_CloudSingle_0_1
	0x323296 >> '45' >> s_CloudSingle_1_0
	0x3232c8 >> '46' >> s_CloudSingle_1_1
	0x3232fa >> '47' >> s_CloudTriple_0_0
	0x326400 >> '48' >> s_CloudTriple_0_1
	0x326432 >> '49' >> s_CloudTriple_1_0
	0x326464 >> '50' >> s_CloudTriple_1_1
	0x326496 >> '51' >> s_CloudTriple_2_0
	0x3264c8 >> '52' >> s_CloudTriple_2_1
	0x3264fa >> '53' >> s_CloudTriple_3_0
	0x329600 >> '54' >> s_CloudTriple_3_1

	0x329632 >> '55' >> s_Coin00_0_0
	0x329664 >> '56' >> s_Coin01_0_0
	0x329696 >> '57' >> s_Coin02_0_0
	0x3296c8 >> '58' >> s_DirtGround_0_0
	0x3296fa >> '59' >> s_EmptyBlock_0_0

	0x32c800 >> '60' >> s_FlagPoleBeam_0_0
	0x32c832 >> '61' >> s_FlagPoleFlag_0_0
	0x32c864 >> '62' >> s_FlagPoleTop_0_0

	0x32c896 >> '63' >> s_Goomba00_0_0
	0x32c8c8 >> '64' >> s_Goomba01_0_0
	0x32c8fa >> '65' >> s_Goomba02_0_0
	0x32fa00 >> '66' >> s_Goomba03_0_0
	0x32fa32 >> '67' >> s_GrassGround_0_0
	0x32fa64 >> '68' >> s_GreenKoopaTroopaShell1_0_0
	0x32fa96 >> '69' >> s_GreenKoopaTroopaShell2_0_0
	0x32fac8 >> '70' >> s_GreenKoopaTroopa00_0_0
	0x32fafa >> '71' >> s_GreenKoopaTroopa00_0_1
	0x640000 >> '72' >> s_GreenKoopaTroopa01_0_0
	0x640032 >> '73' >> s_GreenKoopaTroopa01_0_1

	0x640064 >> '74' >> s_HillLarge_0_0
	0x640096 >> '75' >> s_HillLarge_0_1
	0x6400c8 >> '76' >> s_HillLarge_0_2
	0x6400fa >> '77' >> s_HillLarge_1_0
	0x643200 >> '78' >> s_HillLarge_1_1
	0x643232 >> '79' >> s_HillLarge_1_2
	0x643264 >> '80' >> s_HillLarge_2_0
	0x643296 >> '81' >> s_HillLarge_2_1
	0x6432c8 >> '82' >> s_HillLarge_2_2
	0x6432fa >> '83' >> s_HillLarge_3_0
	0x646400 >> '84' >> s_HillLarge_3_1
	0x646432 >> '85' >> s_HillLarge_3_2
	0x646464 >> '86' >> s_HillLarge_4_0
	0x646496 >> '87' >> s_HillLarge_4_1
	0x6464c8 >> '88' >> s_HillLarge_4_2
	0x6464fa >> '89' >> s_HillSmall_0_0
	0x649600 >> '90' >> s_HillSmall_0_1
	0x649632 >> '91' >> s_HillSmall_1_0
	0x649664 >> '92' >> s_HillSmall_1_1
	0x649696 >> '93' >> s_HillSmall_2_0
	0x6496c8 >> '94' >> s_HillSmall_2_1

	0x6496fa >> '95' >> s_MarioClimb1_0_0
	0x64c800 >> '96' >> s_MarioClimb2_0_0
	0x64c832 >> '97' >> s_MarioDead_0_0
	0x64c864 >> '98' >> s_MarioJump_0_0
	0x64c896 >> '99' >> s_MarioSkid_0_0
	0x64c8c8 >> '100' >> s_MarioWalk1_0_0
	0x64c8fa >> '101' >> s_MarioWalk2_0_0
	0x64fa00 >> '102' >> s_MarioWalk3_0_0
	0x64fa32 >> '103' >> s_Mario_0_0
	0x64fa64 >> '104' >> s_Pipe_0_0
	0x64fa96 >> '105' >> s_Pipe_0_1
	0x64fac8 >> '106' >> s_Pipe_1_0
	0x64fafa >> '107' >> s_Pipe_1_1
	0x960000 >> '108' >> s_QuestionBlock00_0_0
	0x960032 >> '109' >> s_QuestionBlock01_0_0
	0x960064 >> '110' >> s_QuestionBlock02_0_0
	0x960096 >> '111' >> s_SolidBlock_0_0
	0x9600c8 >> '112' >> s_Starman00_0_0
	0x9600fa >> '113' >> s_Starman01_0_0
	0x963200 >> '114' >> s_Starman02_0_0
	0x963232 >> '115' >> s_Starman03_0_0
	0x963264 >> '116' >> s_SuperMarioClimb1_0_0
	0x963296 >> '117' >> s_SuperMarioClimb1_0_1
	0x9632c8 >> '118' >> s_SuperMarioClimb2_0_0
	0x9632fa >> '119' >> s_SuperMarioClimb2_0_1
	0x966400 >> '120' >> s_SuperMarioDuck_0_0
	0x966432 >> '121' >> s_SuperMarioDuck_0_1
	0x966464 >> '122' >> s_SuperMarioJump_0_0
	0x966496 >> '123' >> s_SuperMarioJump_0_1
	0x9664c8 >> '124' >> s_SuperMarioSkid_0_0
	0x9664fa >> '125' >> s_SuperMarioSkid_0_1
	0x969600 >> '126' >> s_SuperMarioWalk1_0_0
	0x969632 >> '127' >> s_SuperMarioWalk1_0_1
	0x969664 >> '128' >> s_SuperMarioWalk2_0_0
	0x969696 >> '129' >> s_SuperMarioWalk2_0_1
	0x9696c8 >> '130' >> s_SuperMarioWalk3_0_0
	0x9696fa >> '131' >> s_SuperMarioWalk3_0_1
	0x96c800 >> '132' >> s_SuperMario_0_0
	0x96c832 >> '133' >> s_SuperMario_0_1
	0x96c864 >> '134' >> s_SuperMushroom_0_0

*/
"""


ASCIITOCOLOURKEY={'000032':'1','000064':'2','000096':'3','0000c8':'4','0000fa':'5','003200':'6','003232':'7','003264':'8','003296':'9','0032c8':'10','0032fa':'11','006400':'12','006432':'13','006464':'14','006496':'15','0064c8':'16','0064fa':'17','009600':'18','009632':'19','009664':'20','009696':'21','0096c8':'22','0096fa':'23','00c800':'24','00c832':'25','00c864':'26','00c896':'27','00c8c8':'28','00c8fa':'29','00fa00':'30','00fa32':'31','00fa64':'32','00fa96':'33','00fac8':'34','00fafa':'35','320000':'36','320032':'37','320064':'38','320096':'39','3200c8':'40','3200fa':'41','323200':'42','323232':'43','323264':'44','323296':'45','3232c8':'46','3232fa':'47','326400':'48','326432':'49','326464':'50','326496':'51','3264c8':'52','3264fa':'53','329600':'54','329632':'55','329664':'56','329696':'57','3296c8':'58','3296fa':'59','32c800':'60','32c832':'61','32c864':'62','32c896':'63','32c8c8':'64','32c8fa':'65','32fa00':'66','32fa32':'67','32fa64':'68','32fa96':'69','32fac8':'70','32fafa':'71','640000':'72','640032':'73','640064':'74','640096':'75','6400c8':'76','6400fa':'77','643200':'78','643232':'79','643264':'80','643296':'81','6432c8':'82','6432fa':'83','646400':'84','646432':'85','646464':'86','646496':'87','6464c8':'88','6464fa':'89','649600':'90','649632':'91','649664':'92','649696':'93','6496c8':'94','6496fa':'95','64c800':'96','64c832':'97','64c864':'98','64c896':'99','64c8c8':'100','64c8fa':'101','64fa00':'102','64fa32':'103','64fa64':'104','64fa96':'105','64fac8':'106','64fafa':'107','960000':'108','960032':'109','960064':'110','960096':'111','9600c8':'112','9600fa':'113','963200':'114','963232':'115','963264':'116','963296':'117','9632c8':'118','9632fa':'119','966400':'120','966432':'121','966464':'122','966496':'123','9664c8':'124','9664fa':'125','969600':'126','969632':'127','969664':'128','969696':'129','9696c8':'130','9696fa':'131','96c800':'132','96c832':'133','96c864':'134','ffffff':'0'}

def main():
	#Outputs to output.txt
	output = open(OUTPUTNAMEFILENAME, 'w')

	output.write('''//Contains all the map information in an array of bytes:
//Foreground is where all the action happens and collisions are calculated
//Background is where nobody cares about collisions


//NOTE:
//Currently the flagpole is in the background layer since mario will be overlayed 
//	on it even though we care about collisions with the flagpole... 
//	maybe move the flag to the foreground and use that to figure out where the flagpole is? 
''')

	output.write(CONVERSIONKEYUSED)

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

	memLabel="s_"+trimImageName(imgName)+section


	writeToFile(output, pixels, memLabel, imageSize)


def writeToFile(output,pixels, memLabel, imageSize):
	##Write hex values to txt file
	output.write(memLabel+":\n")
	print(".globl "+memLabel)

	# output.write("\t.int: #"+str(imageSize[0])+", #"+str(imageSize[1])+"\n")
	# output.write("\t.int: #32, #32\n")

	for y in range(imageSize[1]):
		output.write("\t.byte ")
		for x in range(imageSize[0]):
			tempAscii=convertToAscii(x, y, pixels)
			#convert to ascii
			if x!=0:
				output.write(",")
			output.write(tempAscii)
		output.write("\n")

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