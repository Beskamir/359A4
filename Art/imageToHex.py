#http://www.barth-dev.de/online/rgb565-color-picker/ use this

#This will need the python imaging library. This can be done with 
# "easy_install Pillow" on windows. 
# (trivially without quotes and through a console)
from PIL import Image
from PIL import ImageColor
import os

FOLDERNAME="\\Ready\\ImagesTest\\" #folder containing images
OUTPUTNAMEFILENAME="output.txt" #File output location
SPLIT=True #Change this to either generate several 32*32 images or 1 unspecified image size. 
	#*for 32^2 generation to work, (x and y) % 32 must be 0
CELLSIZE=32 #in theory should determine image size for the above mentioned split.
	#Not actually tested with anything other than 32


def getAllImages():
	#Outputs to output.txt
	output = open(OUTPUTNAMEFILENAME, 'w')
	output.write(".section .text\n")

	imageList=""
	#Keep looping for all files in the folder Images
	for fileName in os.listdir(os.getcwd()+FOLDERNAME):
		# print(fileName,FOLDERNAME,output)
		# imageList+=openImage(os.getcwd()+FOLDERNAME+fileName,output)
		processImage(os.getcwd()+FOLDERNAME+fileName,output)

	output.close()
	# print("Copy paste the following to the top of the image file:\n")
	# print(imageList)

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

#Opens the image and converts to hex
def processImage(imgName,output):
	img = Image.open(imgName) #Can be many different formats.

	pixels = img.convert('RGBA').load()
	imageSize = img.size #Get the width and hight of the image for iterating over

	trimmedName=trimImageName(imgName)

	if SPLIT:

		# pixelsOff = [imageSize[0]%32, imageSize[1]%32]

		zones = [0, 0]

		# print(trimmedName)
		while imageSize[0]>=(CELLSIZE*(zones[0]+1)):
			# print(trimmedName)
			zones[1]=0
			x = (zones[0]*32)
			boundX=(32*(zones[0]+1))

			while imageSize[1]>=(CELLSIZE*(zones[1]+1)):
				# print(trimmedName)
				y = (zones[1]*32)
				memLabel=trimmedName+"_"+str(zones[0])+"_"+str(zones[1])
				boundY=(32*(zones[1]+1))
				writeToFile(output, pixels,x,y,memLabel,boundX,boundY, zones[0])
				# print(trimmedName,zones[0],zones[1])
				zones[1]+=1
			zones[0]+=1

	else:
		x=y=0
		# zones=[imageSize[0]//32, imageSize[1]//32]
		memLabel=trimmedName
		writeToFile(output, pixels,x,y,memLabel,imageSize[0],imageSize[1])

	# zones = [imageSize[0]//32, imageSize[1]//32]
	# for zoneY in range(zones[1]):
	# 	for zoneX in range(zones[0]):
	# 		writeToFile(output, trimmedName, pixels, zoneX, zoneY)

	# return ("\n.globl\t"+trimmedName)

	# output.write(".globl\t"+trimmedName+"_End\n"+trimmedName+"_End:\n\n")

def writeToFile(output,pixels,x,y,memLabel,imageSizeX,imageSizeY,zoneX=0):
	##Write hex values to txt file
	output.write(memLabel+":\n")
	print(".globl "+memLabel)

	# output.write("\t.int: #"+str(imageSize[0])+", #"+str(imageSize[1])+"\n")
	output.write("\t.int: #32, #32\n")

	# for x in range(imageSize[0]):
	while y < imageSizeY:
		output.write("\t.int: ")
		x=zoneX*32
		# for y in range(imageSize[1]):
		while x < imageSizeX:
			tempHex=convertToHex(x, y, pixels)
			# tempHex=hex(a+r+g+b)
			if(x%32!=0):
				output.write(", ")
			output.write(tempHex)
			x+=1
		y+=1

		output.write("\n")

def convertToHex(x, y, pixels):

	# print(x,y)
	
	# if zoneX==0 and (x<=32-pixelsOff[0]) and pixelsOff[0]!=0:
	# 	r,g,b,a=[0,0,0,0]
	# if zoneY==0 and (y<=32-pixelsOff[1]) and pixelsOff[1]!=0:
	# 	r,g,b,a=[0,0,0,0]

	# else:
	r,g,b,a=pixels[x,y]


	#Following ugly mess converts image to proper hex value taking into 
	# account the possibility of an alpha map.
	# if there an alpha map the first value is F
	# otherwise the first value doesn't exist
	#	Thus in assembly just bit clear the last 4 bits and if the output is 0 
	#	then pass the hex value to be displayed, otherwise ignore the hex value
	if a==255:
		tempHex=("#0x0%0.4X" % ((int(r / 255 * 31) << 11) | (int(g / 255 * 63) << 5) | (int(b / 255 * 31))))

	else:
		tempHex=("#0xF%0.4X" % ((int(r / 255 * 31) << 11) | (int(g / 255 * 63) << 5) | (int(b / 255 * 31))))

	# tempInt=int(tempHex,16)
	return tempHex

if __name__ == '__main__':
	getAllImages()