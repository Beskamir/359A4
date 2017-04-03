#This will need the python imaging library. This can be done with 
# "easy_install Pillow" on windows. 
# (trivially without quotes and through a console)

def main():
	#Outputs to output.txt
	output = open("generatedScreen.txt", 'w')

	for y in range (24):
		output.write(".byte ")
		for x in range (32):
			if x!=0:
				output.write(",")
			output.write("0")
		output.write("\n")
	output.close()


if __name__ == '__main__':
	main()