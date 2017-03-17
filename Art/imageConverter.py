##Python 2 file since PIL is only for Py -2
from PIL import Image
from PIL import ImageColor
import os

def main():
	#Outputs to output.txt
	output = open("output.txt", 'w')

	#Keep looping for all files in the folder Images
	for fileName in os.listdir(os.getcwd()+"\\Images"):
		openImage(os.getcwd()+"\\Images\\"+fileName,output)

	output.close()

#Trims the filepath to a label friendly string
def trimImageName(imgName):
	trimmedName=""
	tempName=os.path.basename(imgName)
	for x in tempName:
		# print (x)
		if x!=' ' and x!='-':
			trimmedName+=x
	trimmedName=trimmedName[:-4]
	return trimmedName

#Opens the image and converts to hex
def openImage(imgName,output):
	img = Image.open(imgName) #Can be many different formats.

	trimmedName=trimImageName(imgName)

	pixels = img.convert('RGBA').load()
	# debuggingString = ""
	imageSize = img.size #Get the width and hight of the image for iterating over

	output.write(trimmedName+":\n")
	# r, g, b, a=pixels[16,10]
	# print(r,g,b,a)

	for x in range(imageSize[0]):
		output.write("\t.int: ")
		for y in range(imageSize[1]):
			r,g,b,a=pixels[x,y]
			tempHex='{:02x}{:02x}{:02x}{:02x}'.format(a, r, g, b)
			tempInt=int(tempHex,16)
			# tempHex=hex(a+r+g+b)
			if(y>0):
				output.write(", ")
			output.write("#0x"+tempHex)
			# debuggingString+=","+str(tempInt) #Get the RGBA Value of the a pixel of an image
	# 		# output.writeline()
		# debuggingString+="\n"
		output.write("\n")
	# print debuggingString
	# pix[x,y] = value # Set the RGBA Value of the image (tuple)
	output.write(trimmedName+"_End:\n\n")

if __name__ == '__main__':
	main()