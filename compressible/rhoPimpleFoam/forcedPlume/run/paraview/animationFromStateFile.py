from paraview.simple import *

import sys, getopt

 
# reading arg
def main(argv):
    inputfile = ''
    outputfile = 'anim.ogv'
    mag=1
    fps=15.0
    try:
       opts, args = getopt.getopt(argv,"h:i:o:f:",["ifile=","ofile=","fps="])
    except getopt.GetoptError:
       print 'franco'
       print 'test.py -i <inputfile> -o <outputfile>'
       sys.exit(2)
    for opt, arg in opts:
       if opt == '-h':
          print 'test.py -i <inputfile> -o <outputfile>'
          sys.exit()
       elif opt in ("-i", "--ifile"):
          inputfile = arg
       elif opt in ("-o", "--ofile"):
          outputfile = arg
       elif opt in ("-f", "--frameRate"):
          fps = arg
    print 'Input file is "', inputfile
    print 'Output file is "', outputfile
    print 'frame rate per sec. "', fps
    # Load paraview state file
    LoadState(inputfile)
    
    # Save screenshot
    # render_view = paraview.simple.FindView('ViewName')
    # SaveScreenshot('image.png',render_view)
    # Write animation 
    WriteAnimation(outputfile, Magnification=mag, FrameRate=fps, Compression=True)

if __name__ == "__main__":
    main(sys.argv[1:])
