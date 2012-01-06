C MODULE VPTR
C-----------------------------------------------------------------------
C
C  THIS ROUTINE:
C    - COMPUTES VARIABLE DIMENSIONS FOR THE DAILY DATA ARRAY, 
C      THE COMPUTED STATION PE ARRAY AND THE STATION PARAMETER ARRAY
C    - DETERMINES IF THERE IS ENOUGH ROOM IN THE MASTER ARRAY TO STORE 
C      ALL OF THE STATION PARAMETERS FOR ALL THE STATIONS AND THUS READ 
C      THE STATION PARAMETERS ONLY ONCE OR TO READ EACH STATION 
C      PARAMETER EACH DAY AND COMPUTE THE STATION POINT PE ON A 
C      TATION BY STATION BASIS
C    - CHECKS THAT THERE IS ROOM ENOUGH TO STORE AT LEAST THE COMPUTED 
C      VALUES FROM ONE STATION FOR THE NUMBER OF DAYS THAT HAVE BEEN 
C
C  INPUTS:
C    - MAXIMUM DIMENSIONS AVAILABLE FOR DATA ARRAYS
C    - NUMBER OF PE STATIONS OR SLOTS FOR PE STATIONS
C    - NUMBER OF DAYS THAT THE RUN IS TO BE CARRIED ON
C
C  ARRAYS THAT ARE PASSED THROUGH:
C    - DDATA   THE DAILY DATA INPUT ARRAY.
C    - PEPP    THE MASTER ARRAY TO HOLD THE PARAMETER VALUES AND THE
C              COMPUTED DAILY STATION VALUES OF PE
C
C  OUTPUTS:
C    - THE SIZE OF THE ARRAY REQUIRED FOR THE COMPUTED STATION
C      PE. THE SIZE OF THE ARRAY TO STORE STATION PARAMETERS.
C      THE DECISION TO EITHER READ AND STORE ALL STATION
C      PARAMETERS ONCE OR TO READ THEM DAILY DEPENDING UPON
C      THE SPACE AVAILABLE.
C    - PEPP(1)     THE BEGINNING ADDRESS OF THE COMPUTED STATION PE
C                  ARRAY WITHIN THE PEPP MASTER ARRAY
C    - PEPP(JPPTR) THE BEGINNING ADDRESS OF THE STATION PARAMETERS
C    - JPTR        THE POINTER TO THE BEGINNING OF THE PARAMETER FILE
C                  READ IN THE THE PEPP MASTER ARRAY
C    - MXPDIM      THE MAXIMUM VALUE OR VARIABLE DIMENSION FOR THE
C                  PARAMETRIC SUBARRAY
C    - MXDDIM      THE MAXIMUM VALUE OR VARIABLE DIMENSION OF THE
C                  COMPUTED STATION PE ARRAY
C
C  SUBROUTINES CALLED
C    - VRPLLP    CONTROLS COMPUTATION OF THE STATION POINT PE WHEN 
C                THERE IS NOT ROOM IN THE MASTER ARRAY TO HOLD ALL THE 
C                COMPUTED PE VALUES AND THE ALL PARAMETER VALUES FOR 
C                ALL OF THE STATIONS
C    - VLOOP     CONTROLS OMPUTATION OF THE STATION POINT PE WHEN WHEN
C                THE MASTER ARRAY CAN HOLD ALL OF THE COMPUTED PE VALUES
C                AND ALL OF THE THE PARAMETER VALUES FOR EACH STATION
C.......................................................................
C
      SUBROUTINE VPTR (DDATA,LPEPP,PEPP,JPNTRS)
C
      CHARACTER*8 OLDOPN
      INTEGER*2 DDATA(LRY),JPNTRS(100)
      DIMENSION PEPP(LPEPP)
      PARAMETER (MPECF=200)
      DIMENSION PECF(MPECF)
      COMMON /VFIXD/ LRY,MRY,NDAYS,NDAYOB,LARFIL,LFDFIL
      COMMON /VTIME/ JDAY,IYRS,MOS,JDAMOS,IHRO,IHRS,JDAMO,JDAYYR
      INCLUDE 'common/ionum'
      INCLUDE 'common/pudbug'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_mape/RCS/vptr.f,v $
     . $',                                                             '
     .$Id: vptr.f,v 1.4 2000/07/21 19:17:51 page Exp $
     . $' /
C    ===================================================================
C
C
      IF (IPTRCE.GT.0) WRITE (IOPDBG,*) 'ENTER VPTR'
C
      IOPNUM=-1
      CALL FSTWHR ('VPTR    ',IOPNUM,OLDOPN,IOLDOP)
C
      IBUG=IPBUG('VPTR')
C
      IF (IBUG.GT.0) WRITE (IOPDBG,10) LRY,LPEPP,MRY
10    FORMAT (' LRY=',I8,' LPEPP=',I8,' MRY=',I8)
C
C  COMPUTE THE MAXIMUM DIMENSION REQUIRED FOR STATION PARAMETERS
      MXPDIM=LFDFIL*58
      IF (MXPDIM.LT.60 )MXPDIM=116
C
C  COMPUTE THE AREA REQUIRED FOR COMPUTED POINT PE DATA
      MXDDIM=LFDFIL*NDAYOB
C
C  COMPUTE POINTER TO FIRST ELEMENT IN THE PARAMETER ARRAY
      JFPTR=MXDDIM+1
C
C  COMPUTE THE MINIMUM DIMENSION FOR THE MASTER ARRAY 
      MINDIM=MXDDIM+58
C
C  CHECK IF THE MASTER ARRAY WILL HOLD SUFFICIENT DATA
      IF (MINDIM.LT.LPEPP) GO TO 40
         WRITE (IPR,20) LPEPP,MINDIM
20    FORMAT ('0**ERROR** THE DIMENSION OF THE MASTER ARRAY WILL NOT ',
     1     'ACCOMODATE THIS MANY STATIONS FOR THIS MANY DAYS.' /
     2 ' THE MASTER ARRAY WILL HOLD ',I8,' VALUES BUT ',I8,
     3     ' VALUES ARE REQUIRED TO RUN AND HOLD ',
     4     'THE PARAMETERS FOR JUST ONE STATION.')
         CALL ERROR
         GO TO 90
C
40    NPECF=0
C
C  CHECK IF THE STATION PARAMETERS NEED TO BE READ GROUPS OR IF 
C  THEY CAN READ READ IN ONCE FOR THE RUN
      JDIF=LPEPP-(MXDDIM+MXPDIM)
      IF(JDIF.GT.1)GO TO 60
C
C  RUN POINT PE COMPUTATIONS WHEN STATION PARAMETERS WILL NOT ALL FIT 
C  IN THE MASTER ARRAY
      JDIF=LPEPP-MXDDIM+1
      MXPDIM=JDIF-1
      IF(IBUG.GT.0)WRITE(IOPDBG,45)
45    FORMAT (' BEFORE CALL TO VPRLLP')
      CALL VPRLLP (PEPP(1),PEPP(JFPTR),JDIF,JPNTRS,MXPDIM,DDATA,MXDDIM,
     1 MPECF,NPECF,PECF)
      IF(IBUG.GT.0)WRITE(IOPDBG,50)
50    FORMAT (' AFTER CALL TO VPRLLP')
      GO TO 90
C
60    IF(IBUG.GT.0)WRITE(IOPDBG,70)LPEPP,LRY,MRY,IYRS
70    FORMAT (' BEFORE CALL TO VLOOP: LPEPP=',I8,' LRY=',I8,
     1  ' MRY=',I8,' IYRS=',I8)
      CALL VLOOP (PEPP(1),PEPP(JFPTR),DDATA,MXPDIM,MXDDIM,JPNTRS,
     1 MPECF,NPECF,PECF)
      IF(IBUG.GT.0)WRITE(IOPDBG,80)JFPTR
80    FORMAT (' AFTER CALL TO VLOOP: JPPTR=',I8)
C
90    CALL FSTWHR (OLDOPN,IOLDOP,OLDOPN,IOLDOP)
C
      IF (IPTRCE.GT.0) WRITE (IOPDBG,*) 'EXIT VPTR'
C
      RETURN
C
      END
