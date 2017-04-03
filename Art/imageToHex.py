#http://www.barth-dev.de/online/rgb565-color-picker/ use this

#This will need the python imaging library. This can be done with 
# "easy_install Pillow" on windows, google for other OSes 
# (trivially without quotes and through a console/terminal)
from PIL import Image
from PIL import ImageColor
import os
import random

FOLDERNAME="\\EndScreens\\Complete\\" #folder containing images
OUTPUTNAMEFILENAME="imageOutputsTitle.txt" #creates an assembly file with all the image data
KEYOUTPUTFILENAME="keyOutputsTitle.txt" #stores the dictionary for generating the map tiles
SPLIT=False #Change this to either generate several 32*32 images or 1 unspecified image size. 
	#*for 32^2 generation to work, (x and y) % 32 must be 0
CELLSIZE=32 #in theory should determine image size for the above mentioned split.
	#Not actually tested with anything other than 32

#used in creating the map tiles
staticColours=[0,0,0]
staticCounter=1


#opens all the images in a given folder
def getAllImages():
	#imageOutputss to imageOutputs.txt
	imageOutputs = open(OUTPUTNAMEFILENAME, 'w')
	imageOutputs.write(".section .text\n")

	keyOutput = open(KEYOUTPUTFILENAME,'w')
	keyOutput.write("ASCIITOCOLOURKEY={")	

	#Keep looping for all files in the folder Images
	for fileName in os.listdir(os.getcwd()+FOLDERNAME):
		# print(fileName,FOLDERNAME,imageOutputs)
		# imageList+=openImage(os.getcwd()+FOLDERNAME+fileName,imageOutputs)
		processImage(os.getcwd()+FOLDERNAME+fileName,imageOutputs,keyOutput)

	keyOutput.write("}")
	keyOutput.close()
	imageOutputs.close()
	print("\n")
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
def processImage(imgName,imageOutputs,keyOutput):
	img = Image.open(imgName) #Can be many different formats.

	pixels = img.convert('RGBA').load()
	imageSize = img.size #Get the width and hight of the image for iterating over

	trimmedName=trimImageName(imgName)

	if SPLIT:

		expectedZones=[imageSize[0]//32, imageSize[1]//32]
		newImage=Image.new('RGBA',(expectedZones[0],expectedZones[1]))
		# for x in range(400):
		# 	for y in range(400):
		# 		newImage.putpixel((x,y), (0,0,200))
		# newImagePixels=newImage.load()

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
				imageOutputs.write(".align 4\n")
				memLabel="s_"+trimmedName+"_"+str(zones[0])+"_"+str(zones[1])
				boundY=(32*(zones[1]+1))
				
				newImage.putpixel((zones[0],zones[1]), genPixel(memLabel,keyOutput))
	
				writeToFile(imageOutputs, pixels,x,y,memLabel,boundX,boundY, zones[0])
				# print(trimmedName,zones[0],zones[1])
				zones[1]+=1
			zones[0]+=1

		newImage.save(os.getcwd()+"\\ImageOutput\\"+trimmedName+".png")
	else:
		x=y=0
		# zones=[imageSize[0]//32, imageSize[1]//32]
		memLabel=trimmedName
		writeToFile(imageOutputs, pixels,x,y,memLabel,imageSize[0],imageSize[1])

def genPixel(memLabel,keyOutput):
	global staticColours
	global staticCounter
	r,g,b=staticColours
	b+=50
	if b>255:
		b=0
		g+=50
		if g>255:
			g=0
			r+=50
	staticColours=[r,g,b]
	tempHex='{:02x}{:02x}{:02x}'.format(r, g, b)
	print("0x"+tempHex+" >> '"+str(staticCounter)+"' >> "+memLabel)
	# print("'"+tempHex+"':'"+chr(staticASCII)+"',",end="")
	keyOutput.write("'"+tempHex+"':'"+str(staticCounter)+"',")
	staticCounter+=1
	# if staticASCII>126:
	# 	# print("\n\n")
	# 	staticASCII=33
	# if staticASCII==92 or staticASCII==34:
	# 	staticASCII+=1
	return r,g,b

def writeToFile(imageOutputs,pixels,x,y,memLabel,imageSizeX,imageSizeY,zoneX=0):
	##Write hex values to txt file
	imageOutputs.write(memLabel+":\n")
	print(".globl "+memLabel)

	imageOutputs.write("\t.int "+str(imageSizeX)+", "+str(imageSizeY)+"\n")
	#If breaking images down into 32*32 portions, use code below instead of the code above
	# imageOutputs.write("\t.int 32, 32\n")

	# for x in range(imageSize[0]):
	while y < imageSizeY:
		imageOutputs.write("\t.int ")
		x=zoneX*32
		# for y in range(imageSize[1]):
		while x < imageSizeX:
			tempHex=convertToHex(x, y, pixels)
			# tempHex=hex(a+r+g+b)
			if(x%32!=0 or not (SPLIT and x!=imageSizeY-1)):
				imageOutputs.write(", ")
			imageOutputs.write(tempHex)
			x+=1
		y+=1

		imageOutputs.write("\n")

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
	#	Thus in assembly just bit clear the last 4 bits and if the imageOutputs is 0 
	#	then pass the hex value to be displayed, otherwise ignore the hex value
	if a==255:
		tempHex=("0x0%0.4X" % ((int(r / 255 * 31) << 11) | (int(g / 255 * 63) << 5) | (int(b / 255 * 31))))

	else:
		tempHex=("0xF%0.4X" % ((int(r / 255 * 31) << 11) | (int(g / 255 * 63) << 5) | (int(b / 255 * 31))))

	# tempInt=int(tempHex,16)
	return tempHex

if __name__ == '__main__':
	getAllImages()