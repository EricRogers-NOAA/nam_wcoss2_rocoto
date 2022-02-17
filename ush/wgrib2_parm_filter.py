import re,sys

def extract(flds):
  # Pull out strings in between parentheses
  p=len(flds)
  if p>0:
    for x in range(p):
      fld=flds[x]
      flds[x] = fld.split('(', 1)[1].split(')')[0]
  return flds

def rm_dup_flds(flds,fname):
  # Remove duplicate fields in a list.
  #  Only run as needed.
  my_list = list(set(flds))
  fnodups = open(fname.strip()+'.new','w')
  for fld in my_list:
    fnodups.write(fld+'\n')
  fnodups.close()

if __name__ == '__main__':

  ########################################################################################
  #
  #  Run as: python wgrib2_parm_filter.py list_of_fields_for_output_grid.parm
  #
  #  This scripts requires that neighbor_interp.parm is within the working directory.
  #  This file contains all fields that must undergo neighbor interpolation.
  #  If neighbor_interp.parm is not present then the script will not provide any 
  #   information about neighbor interpolation.
  #   
  #
  #  Budget interpolation is only assumed to take place for APCP and LSPA fields.  No
  #   input file is required.  If you want to add additional fields for budget, just add
  #   to the list of strings where budget_fields is defined below.  We could also just
  #   read this file in if that becomes preferred.
  #
  # ALL input grib2 field names are expected to be containted within
  #  parentheses.  For example:
  #
  #  RADAR REFL AGL (REFD)
  #  SNOW DEPTH (SNOD)
  #
  #########################################################################################

  

  # Read in the list of fields requiring neighbor interpolation 
  try:
    with open('neighbor_interp.parm') as f:
      neighbor_fields=list(map(str.strip, list(f)))
  except:
    #Assuming no neighbor interpolation is needed.
    neighbor_fields=[]

  # - No need to read in a list for fields requiring budget interpolation.
  # - Since it is only just a few, we can specify them here.
  budget_fields=['APCP','LSPA','NCPCP','ACPCP','SNOD','WEASD']

  # - Try opening input file containing all fields for this grid
  try:
    with open(sys.argv[1]) as f3:
      allfields=list(map(str.strip, list(f3)))
  except:
    sys.exit("ERROR! Unable to open input file containing fields for this grid! Exit!")
    
  # - Extract the fields that are listed in parentheses
  neighbor_fields=extract(neighbor_fields)
  allfields=extract(allfields)
  
  # - Find the matches for NEIGHBOR and BUDGET interp and if any exist, print
  # -  the appropriate wgrib2 interp line to the screen
  neighbor=set(neighbor_fields).intersection(allfields)  
  budget=set(budget_fields).intersection(allfields)
  lneighbor=len(neighbor)
  lbudget=len(budget)
  if lneighbor>0:
    fmt = "|".join(neighbor)
#    if lbudget>0:
#      wgrib2_neighbor="-if \":("+fmt+"):\" -new_grid_interpolation neighbor -fi "
#    else:
#      wgrib2_neighbor="-if \":("+fmt+"):\" -new_grid_interpolation neighbor -fi "
    f=open('neighbor.txt','w')
    f.write(fmt)
    f.close()

  if lbudget>0:
    fmt = "|".join(budget)
    #wgrib2_budget="-if \":("+fmt+"):\" -new_grid_interpolation budget -fi "
    #print wgrib2_budget,
    f=open('budget.txt','w')
    f.write(fmt)
    f.close()







