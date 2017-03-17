from sys import argv
#Clearly specified parameters
SCREENSIZE_X=1024 #size of screen in x axis
SCREENSIZE_Y=768 #size of screen in y axis
TILESIZE=32	#Size of each tile

numberOfScreens=5 #number of "screens"

basicChar='0' #Background char
floorChar='F' #floor char
endsChar='!' #char indicating end of map
screenBreakChar='|' #indicate end of screen. Purely for debugging

name="Map.txt" #Where the map will be saved

def main():
	tilesX=(SCREENSIZE_X/TILESIZE)
	sizeX=tilesX*numberOfScreens
	tilesY=SCREENSIZE_Y/TILESIZE

	genFile(sizeX,tilesY,tilesX)

def genFile(sizeX,sizeY,tilesX):
	file = open(name,'w')
	for y in range(int(sizeY)):
		for x in range(int(sizeX)):
			if(x==0):
				file.write(endsChar)
			elif (x%tilesX)==0:
				file.write(screenBreakChar)
			if y>21:
				file.write(floorChar)
			if y<22:
				file.write(basicChar)
			if x==sizeX-1:
				file.write(endsChar)
		file.write("\n")
	file.close()

if __name__ == '__main__':
	main()