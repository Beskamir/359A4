#http://www.barth-dev.de/online/rgb565-color-picker/ use this

#This will need the python imaging library. This can be done with 
# "easy_install Pillow" on windows. 
# (trivially without quotes and through a console)
from PIL import Image
from PIL import ImageColor
import os

FOLDERNAME="\\Images\\"
OUTPUTNAMEFILENAME="output.txt"


def main():
	#Outputs to output.txt
	output = open(OUTPUTNAMEFILENAME, 'w')
	output.write(".section .text\n")

	imageList=""
	#Keep looping for all files in the folder Images
	for fileName in os.listdir(os.getcwd()+FOLDERNAME):
		imageList+=openImage(os.getcwd()+FOLDERNAME+fileName,output)

	output.close()
	print("Copy paste the following to the top of the image file:\n")
	print(imageList)

#Trims the filepath to a label friendly string
def trimImageName(imgName):
	trimmedName=""
	tempName=os.path.basename(imgName)
	for x in tempName:
		# print (x)
		if x!=' ' and x!='-' and not x.isdigit():
			trimmedName+=x
	trimmedName=trimmedName[:-4]
	return trimmedName

#Opens the image and converts to hex
def openImage(imgName,output):
	img = Image.open(imgName) #Can be many different formats.
	pixels = img.convert('RGBA').load()
	imageSize = img.size #Get the width and hight of the image for iterating over

	trimmedName=trimImageName(imgName)

	##Write hex values to txt file
	output.write(trimmedName+":\n")

	output.write("\t.int: #"+str(imageSize[0])+", #"+str(imageSize[1])+"\n")

	for x in range(imageSize[0]):
		output.write("\t.int: ")
		for y in range(imageSize[1]):
			tempHex=convertToHex(x, y, pixels)
			# tempHex=hex(a+r+g+b)
			if(y>0):
				output.write(", ")
			output.write(tempHex)

		output.write("\n")

	return ("\n.globl\t"+trimmedName)
	# output.write(".globl\t"+trimmedName+"_End\n"+trimmedName+"_End:\n\n")

def convertToHex(x, y, pixels):
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
	main()