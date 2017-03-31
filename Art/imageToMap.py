#This will need the python imaging library. This can be done with 
# "easy_install Pillow" on windows. 
# (trivially without quotes and through a console)
from PIL import Image
from PIL import ImageColor
import os

FOLDERNAME="\\Maps\\Complete\\" #folder containing images
OUTPUTNAMEFILENAME="map.txt" #File output location
CONVERSIONKEYUSED = """
.globl t_mapBackground
.globl t_mapMiddleground
.globl t_mapForeground
.globl d_mapBackground
.globl d_mapMiddleground
.globl d_mapForeground
/*

Notes: 
	Data ordered in following order and should 
		be usually stored on the following layers:

	//background: background layer
	//Enemies: foreground layer
	//Foreground: foreground layer
	//Items: middle layer
	//Mario: foreground layer

conversion table:
	In all maps:	
	'0' >> sky/nothing
	Only displayed to the screen from values 10 to 255 
		(assuming 245 sprites and bounds are inclusive)
		meaning that values 0 to 9 are invisible to the player. 
		Thus feel free to use them as a temp invisible storage system

	//background: background layer
	'10' >> t_Background_Castle_0_0
	'11' >> t_Background_Castle_0_1
	'12' >> t_Background_Castle_0_2
	'13' >> t_Background_Castle_0_3
	'14' >> t_Background_Castle_0_4
	'15' >> t_Background_Castle_1_0
	'16' >> t_Background_Castle_1_1
	'17' >> t_Background_Castle_1_2
	'18' >> t_Background_Castle_1_3
	'19' >> t_Background_Castle_1_4
	'20' >> t_Background_Castle_2_0
	'21' >> t_Background_Castle_2_1
	'22' >> t_Background_Castle_2_2
	'23' >> t_Background_Castle_2_3
	'24' >> t_Background_Castle_2_4
	'25' >> t_Background_Castle_3_0
	'26' >> t_Background_Castle_3_1
	'27' >> t_Background_Castle_3_2
	'28' >> t_Background_Castle_3_3
	'29' >> t_Background_Castle_3_4
	'30' >> t_Background_Castle_4_0
	'31' >> t_Background_Castle_4_1
	'32' >> t_Background_Castle_4_2
	'33' >> t_Background_Castle_4_3
	'34' >> t_Background_Castle_4_4
	'35' >> t_Background_HillSmall_0_0
	'36' >> t_Background_HillSmall_0_1
	'37' >> t_Background_HillSmall_1_0
	'38' >> t_Background_HillSmall_1_1
	'39' >> t_Background_HillSmall_2_0
	'40' >> t_Background_HillSmall_2_1
	'41' >> t_Background_HillLarge_0_0
	'42' >> t_Background_HillLarge_0_1
	'43' >> t_Background_HillLarge_0_2
	'44' >> t_Background_HillLarge_1_0
	'45' >> t_Background_HillLarge_1_1
	'46' >> t_Background_HillLarge_1_2
	'47' >> t_Background_HillLarge_2_0
	'48' >> t_Background_HillLarge_2_1
	'49' >> t_Background_HillLarge_2_2
	'50' >> t_Background_HillLarge_3_0
	'51' >> t_Background_HillLarge_3_1
	'52' >> t_Background_HillLarge_3_2
	'53' >> t_Background_HillLarge_4_0
	'54' >> t_Background_HillLarge_4_1
	'55' >> t_Background_HillLarge_4_2
	'56' >> t_Background_Bush1_0_0
	'57' >> t_Background_Bush1_1_0
	'58' >> t_Background_Bush2_0_0
	'59' >> t_Background_Bush2_1_0
	'60' >> t_Background_Bush2_2_0
	'61' >> t_Background_Bush3_0_0
	'62' >> t_Background_Bush3_1_0
	'63' >> t_Background_Bush3_2_0
	'64' >> t_Background_Bush3_3_0
	'65' >> t_Background_Cloud1_0_0
	'66' >> t_Background_Cloud1_0_1
	'67' >> t_Background_Cloud1_1_0
	'68' >> t_Background_Cloud1_1_1
	'69' >> t_Background_Cloud2_0_0
	'70' >> t_Background_Cloud2_0_1
	'71' >> t_Background_Cloud2_1_0
	'72' >> t_Background_Cloud2_1_1
	'73' >> t_Background_Cloud2_2_0
	'74' >> t_Background_Cloud2_2_1
	'75' >> t_Background_Cloud3_0_0
	'76' >> t_Background_Cloud3_0_1
	'77' >> t_Background_Cloud3_1_0
	'78' >> t_Background_Cloud3_1_1
	'79' >> t_Background_Cloud3_2_0
	'80' >> t_Background_Cloud3_2_1
	'81' >> t_Background_Cloud3_3_0
	'82' >> t_Background_Cloud3_3_1

	//Enemies: foreground layer
	'83' >> t_Enemies_0GoombarightfootV1_0_0
	'84' >> t_Enemies_1GoombaBothV1_0_0
	'85' >> t_Enemies_2GoombaleftfootV1_0_0

	'86' >> t_Enemies_3GoombarigtfootV2_0_0
	'87' >> t_Enemies_4GoombaBothV2_0_0
	'88' >> t_Enemies_5GoombaleftfootV2_0_0

	'89' >> t_Enemies_6GoombaDead_0_0

	'90' >> t_Enemies_0enemy201V1_0_0
	'91' >> t_Enemies_1enemy200V1_0_0
	'92' >> t_Enemies_2enemy202V1_0_0

	'93' >> t_Enemies_3enemy201V2_0_0
	'94' >> t_Enemies_4enemy200V2_0_0
	'95' >> t_Enemies_5enemy202V2_0_0

	'96' >> t_Enemies_6enemy203_0_0

	//Foreground: foreground layer
	'97' >> t_Foreground_Bricks_Breakable_0_0
	'98' >> t_Foreground_Dirt_Ground_0_0
	'99' >> t_Foreground_QuestionBlock00_0_0
	'100' >> t_Foreground_QuestionBlock01_0_0
	'101' >> t_Foreground_QuestionBlock02_0_0
	'102' >> t_Foreground_EmptyBlock_0_0
	'103' >> t_Foreground_Pipe_0_0
	'104' >> t_Foreground_Pipe_0_1
	'105' >> t_Foreground_Pipe_1_0
	'106' >> t_Foreground_Pipe_1_1
	'107' >> t_Foreground_SolidBlock_0_0
	'108' >> t_Foreground_GrassGround_0_0

	//Items: middle layer
	'109' >> t_Items_SuperMushroom_0_0
	'110' >> t_Items_UpMushroom_0_0
	'111' >> t_Items_Coin00_0_0
	'112' >> t_Items_Coin01_0_0
	'113' >> t_Items_Coin02_0_0

	//Mario: foreground layer
	'114' >> t_Player_Mario_0_0
	'115' >> t_Player_MarioWalk1_0_0
	'116' >> t_Player_MarioWalk2_0_0
	'117' >> t_Player_MarioWalk3_0_0
	'118' >> t_Player_MarioJump_0_0
	'119' >> t_Player_MarioSkid_0_0
	'120' >> t_Player_MarioDead_0_0

	'121' >> t_Player_SuperMario_0_0
	'122' >> t_Player_SuperMario_0_1
	'123' >> t_Player_SuperMarioWalk1_0_0
	'124' >> t_Player_SuperMarioWalk1_0_1
	'125' >> t_Player_SuperMarioWalk2_0_0
	'126' >> t_Player_SuperMarioWalk2_0_1
	'127' >> t_Player_SuperMarioWalk3_0_0
	'128' >> t_Player_SuperMarioWalk3_0_1
	'129' >> t_Player_SuperMarioJump_0_0
	'130' >> t_Player_SuperMarioJump_0_1
	'131' >> t_Player_SuperMarioSkid_0_0
	'132' >> t_Player_SuperMarioSkid_0_1
*/
"""


ASCIITOCOLOURKEY={'000032':'10','000064':'11','000096':'12','0000c8':'13','0000fa':'14','003200':'15','003232':'16','003264':'17','003296':'18','0032c8':'19','0032fa':'20','006400':'21','006432':'22','006464':'23','006496':'24','0064c8':'25','0064fa':'26','009600':'27','009632':'28','009664':'29','009696':'30','0096c8':'31','0096fa':'32','00c800':'33','00c832':'34','00c864':'35','00c896':'36','00c8c8':'37','00c8fa':'38','00fa00':'39','00fa32':'40','00fa64':'41','00fa96':'42','00fac8':'43','00fafa':'44','320000':'45','320032':'46','320064':'47','320096':'48','3200c8':'49','3200fa':'50','323200':'51','323232':'52','323264':'53','323296':'54','3232c8':'55','3232fa':'56','326400':'57','326432':'58','326464':'59','326496':'60','3264c8':'61','3264fa':'62','329600':'63','329632':'64','329664':'65','329696':'66','3296c8':'67','3296fa':'68','32c800':'69','32c832':'70','32c864':'71','32c896':'72','32c8c8':'73','32c8fa':'74','32fa00':'75','32fa32':'76','32fa64':'77','32fa96':'78','32fac8':'79','32fafa':'80','640000':'81','640032':'82','640064':'83','640096':'84','6400c8':'85','6400fa':'86','643200':'87','643232':'88','643264':'89','643296':'90','6432c8':'91','6432fa':'92','646400':'93','646432':'94','646464':'95','646496':'96','6464c8':'97','6464fa':'98','649600':'99','649632':'100','649664':'101','649696':'102','6496c8':'103','6496fa':'104','64c800':'105','64c832':'106','64c864':'107','64c896':'108','64c8c8':'109','64c8fa':'110','64fa00':'111','64fa32':'112','64fa64':'113','64fa96':'114','64fac8':'115','64fafa':'116','960000':'117','960032':'118','960064':'119','960096':'120','9600c8':'121','9600fa':'122','963200':'123','963232':'124','963264':'125','963296':'126','ffffff':'0'}

def main():
	#Outputs to output.txt
	output = open(OUTPUTNAMEFILENAME, 'w')

	output.write('''//Contains all the map information in an array of bytes:
//Foreground is where all the action happens and collisions are calculated
//Middleground is where all the coins, value packs, etc are. 
	In theory this could also be where sprites (mario+enemies) go to die.
//Background is where nobody cares about collisions
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

	if section=="_data":
		memLabel="d_"+trimImageName(imgName)
	else:
		memLabel="t_"+trimImageName(imgName)


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
	numericValue=int(ASCIITOCOLOURKEY[tempHex])
	# if (numericValue>=103 and numericValue<=107):
	# 	# print(tempHex,numericValue)
	# 	numericValue-=102
	if (numericValue>86): #hack for making space
		# print(tempHex,numericValue)
		if (numericValue>89):
			numericValue+=3
		numericValue+=3
	return str(numericValue)

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