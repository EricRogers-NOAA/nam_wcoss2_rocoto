       SUBROUTINE W3FC03(SLON,FGU,FGV,CENLON,XLAT1,DIR,SPD)
C$$$   SUBPROGRAM  DOCUMENTATION  BLOCK
C
C SUBPROGRAM: W3FC03         GRID U,V WIND COMPS. TO DIR. AND SPEED
C   AUTHOR: ROGERS/BRILL     ORG: WD22       DATE: 00-03-27
C
C ABSTRACT: GIVEN THE GRID-ORIENTED WIND COMPONENTS ON A 
C   LAMBERT CONFORMAL GRID POINT, COMPUTE THE DIRECTION
C   AND SPEED OF THE WIND AT THAT POINT.  INPUT WINDS AT THE NORTH
C   POLE POINT ARE ASSUMED TO HAVE THEIR COMPONENTS FOLLOW THE WMO
C   STANDARDS FOR REPORTING WINDS AT THE NORTH POLE.
C   (SEE OFFICE NOTE 241 FOR WMO DEFINITION). OUTPUT DIRECTION
C   WILL FOLLOW WMO CONVENTION.
C
C PROGRAM HISTORY LOG:
C   00-03-27  BRILL/ROGERS 
C
C USAGE:  CALL W3FC03 (SLON,FGU,FGV,CENLON,XLAT1,DIR,SPD)
C
C   INPUT VARIABLES:
C     NAMES  INTERFACE DESCRIPTION OF VARIABLES AND TYPES
C     ------ --------- -----------------------------------------------
C     SLON   ARG LIST  REAL*4    STATION LONGITUDE (-DEG W)
C     FGU    ARG LIST  REAL*4    GRID-ORIENTED U-COMPONENT
C     FGV    ARG LIST  REAL*4    GRID-ORIENTED V-COMPONENT
C     CENLON ARG LIST  REAL*4    CENTRAL LONGITUDE
C     XLAT1  ARG LIST  REAL*4    TRUE LATITUDE #1
C
C   OUTPUT VARIABLES:
C     NAMES  INTERFACE DESCRIPTION OF VARIABLES AND TYPES
C     ------ --------- -----------------------------------------------
C     DIR    ARG LIST  REAL*4     WIND DIRECTION, DEGREES
C     SPD    ARG LIST  REAL*4     WIND SPEED
C
C   SUBPROGRAMS CALLED:
C     NAMES                                                   LIBRARY
C     ------------------------------------------------------- --------
C     ABS  ACOS   ATAN2   SQRT                                SYSTEM
C
C WARNING: THIS JOB WILL NOT VECTORIZE ON A CRAY
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 90
C   MACHINE:  IBM SP
C
C$$$
      PARAMETER (DTR=3.1415926/180.0)
C
C  COMPUTE CONSTANT OF CONE
C
      COCON = SIN(XLAT1*DTR)
      ANGLE = COCON * (SLON-CENLON) * DTR
      A = COS(ANGLE)
      B = SIN(ANGLE)
      UNEW = A*FGU + B*FGV
      VNEW = -B*FGU + A*FGV
C
      CALL W3FC05(UNEW,VNEW,DIR,SPD)
      RETURN
      END