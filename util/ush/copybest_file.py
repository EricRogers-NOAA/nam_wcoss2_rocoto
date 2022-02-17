"""
 Name:  copybest_file.py            Author:  Jacob Carley 

 Abstract:
 This Python script copies a file from a source to a destination directory+name.
 If the copy fails, up to 3 alternative user-provided input files are attempted.
  - If alternates are used, the jlogfile is alerted
 If all attempts at copying fail, the jlogfile is alerted
 Used in NAM GSI jobs
 

 Usage: python copybest_file.py --fname1 [First priority input file] --fname2 [Second priority input file]
                              --fname3 [Third priority input file] --jlogfile [Log File]
                               -o [output file] -h

 --fname1=First priority input file
 --fname2=Second priority input file
 --fname3=Third priority input file 
 --jlogfile=Log file
 -o [output file] = Name of the outputfile

 -h = Prints this output

 History: 2016-04-26    Carley       Initial implementation

"""

import sys,os,getopt,errno,shutil
from datetime import datetime

def usage():
    print ("Usage: python %s --fname1 [First priority input file] --fname2 [Second priority input file] \n"
                    "\t\t\t\t--fname3 [Third priority input file] --jlogfile [Log File] \n"
                    "\t\t\t\t-o [output file] -h") % (sys.argv[0])
    print("")
    print(" --fname1=First priority input file")
    print(" --fname2=Second priority input file (OPTIONAL)")
    print(" --fname3=Third priority input file (OPTIONAL)")
    print(" --jlogfile=Log file (OPTIONAL)")
    print(" -o [output file] = Name of the outputfile")
    print(" -h = Prints this output")
    print("")

def is_non_zero_file(fpath):
    return True if os.path.isfile(fpath) and os.path.getsize(fpath) > 0 else False

def logit(msg,jlogfile):
    getdate=datetime.today().strftime('%m/%d %H:%M:%S')
    try:
        jobid=str(os.environ['jobid'])
    except AttributeError:
        jobid=str(os.getpid())+'.'+sys.argv[0]
    msgline=getdate+"Z "+jobid+"-"+msg+"\n"
    #Add a newline char at the start if logfile already exists
    if is_non_zero_file(jlogfile):  msgline="\n"+msgline
    with open(jlogfile, "a") as myfile:
        myfile.write(msgline)

def main():

    try:
        opts, args = getopt.getopt(sys.argv[1:], "o:h",["fname1=","fname2=","fname3=","jlogfile="])
    except getopt.GetoptError as err:
        # print help information and exit:
        usage()
        sys.exit(str(err))

    # Set the defaults
    jlogfile=None
    ofile=None
    fname1=None
    fname2=None
    fname3=None
    files=[]

    for o, a in opts:
        if o == "-o":
            ofile=str(a)
        elif o == "--fname1":
            fname1=str(a)
            files.append(fname1)
        elif o == "--fname2":
            fname2=str(a)
            files.append(fname2)
        elif o == "--fname3":
            fname3=str(a)
            files.append(fname3)
        elif o == "--jlogfile":
            jlogfile=str(a)
        elif o == "-h":
            usage()
            sys.exit()
        else:           
            usage()
            sys.exit("Unhandled option.")   

    if len(files)==0:
        usage()
        sys.exit("No input files were specified")        
    if fname1 is None:
        usage()
        sys.exit("fname1 must be specified")
    if ofile is None:
        usage()
        sys.exit("-o must be specified")
    if ofile is None:
        usage()
        sys.exit("-o must be specified")

    x=1
    goodfile=None
    for f in files:
        print("Trying to copy "+f+" to "+ofile+" ...")
        if is_non_zero_file(f):
            shutil.copyfile(f,ofile)
            goodfile=f
            break
        else:
            x=x+1

    if x==1:
       suf="st"
    elif x==2:
       suf="nd"
    elif x==3:
       suf="rd"
    else:
       suf="th"

    if x <= len(files) and (goodfile is not None):
        msg="Using "+str(x)+suf+" priority file: "+goodfile
    else:
        msg="Unable to find suitable source input file for "+str(ofile)      
    print(msg)
    if jlogfile is not None and x>1: logit(msg,jlogfile)


if __name__ == '__main__': main()
