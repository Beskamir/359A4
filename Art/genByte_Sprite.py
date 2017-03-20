###Generate assembly code since I'm lazy
# from PIL import Image
# from PIL import ImageColor
# import os
# import random

# FOLDERNAME="\\Sprites\\ImagesConvert\\" #folder containing images
MAPGRAPHICS="MapToGraphics.s" #File imageOutputs location
MAPCOLISIONS="MapCollisions.s" #File imageOutputs location
# SPLIT=True #Change this to either generate several 32*32 images or 1 unspecified image size. 
# 	#*for 32^2 generation to work, (x and y) % 32 must be 0
# CELLSIZE=32 #in theory should determine image size for the above mentioned split.
# 	#Not actually tested with anything other than 32
# staticColours=[0,0,0]
# staticCounter=1


def main():
	#imageOutputss to imageOutputs.txt
	graphicsMap = open(MAPGRAPHICS, 'w')
	collisionsMap = open(MAPCOLISIONS,'w')

	##Code here:



	keyOutput.close()
	imageOutputs.close()

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

def writeToFile(imageOutputs,pixels,x,y,memLabel,imageSizeX,imageSizeY,zoneX=0):
	##Write hex values to txt file
	imageOutputs.write(memLabel+":\n")
	# print(".globl "+memLabel)

	# imageOutputs.write("\t.int: #"+str(imageSize[0])+", #"+str(imageSize[1])+"\n")
	imageOutputs.write("\t.int: #32, #32\n")

	# for x in range(imageSize[0]):
	while y < imageSizeY:
		imageOutputs.write("\t.int: ")
		x=zoneX*32
		# for y in range(imageSize[1]):
		while x < imageSizeX:
			tempHex=convertToHex(x, y, pixels)
			# tempHex=hex(a+r+g+b)
			if(x%32!=0):
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
		tempHex=("#0x0%0.4X" % ((int(r / 255 * 31) << 11) | (int(g / 255 * 63) << 5) | (int(b / 255 * 31))))

	else:
		tempHex=("#0xF%0.4X" % ((int(r / 255 * 31) << 11) | (int(g / 255 * 63) << 5) | (int(b / 255 * 31))))

	# tempInt=int(tempHex,16)
	return tempHex

if __name__ == '__main__':
	getAllImages()