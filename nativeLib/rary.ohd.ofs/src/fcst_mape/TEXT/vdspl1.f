C MODULE VDSPL1
C-------------------------------------------------------------------
C
C  THIS ROUTINE PRINTS THE PE ESTIMATES.
C
C  INPUTS:
C    - TECHNIQUE VALUES
C    - THE COMPUTED VALUES OF POINT PE FOR EACH STATION OR THE
C      MAPE FOR EACH AREA.
C    - THE STATION AND AREA NAMES.
C    - THE DATES OF THE RUN.
C    - THE NUMBER OF STATIONS AND BASINS.
C    - THE INPUT DATA IN THE CASE OF THE OPTION TO LIST THE
C
      SUBROUTINE VDSPL1 (JPTN,PECOMP,KDISP1,KDISP2,MXDDIM,
     1 PEPARM,MXPDIM,ESTSYM,JPNTRS,LSTDY)
C
      CHARACTER*4 UNITS
      INTEGER*2 JPNTRS(MRY)
      DIMENSION PECOMP(MXDDIM),PEPARM(MXPDIM),KDAY(30),ESTSYM(30)
      DIMENSION NUPTR(100),P(25),MONAM(2,12)
      CHARACTER*2  BFMT(31)
      CHARACTER*76 AFMT
      CHARACTER*96 DAYFMT

      COMMON /VFIXD/ LRY,MRY,NDAYS,NDAYOB,LARFIL,LPDFIL
      COMMON /VTIME/ JDAY,IYRS,MOS,JDAMOS,IHRO,IHRS,JDAMO,JDAYYR
      COMMON /VMODAS/ LSTDAM(13)
      COMMON /VSTUP/ PTYPE,DTYPE,METRIC,CPETIM(2),UTYPE,BTYPE,EST(3)
      COMMON /FCTIM2/ INPTZC,NHOPDB,NHOCAL,NHROFF(8)
      INCLUDE 'common/ionum'
      INCLUDE 'common/pudbug'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_mape/RCS/vdspl1.f,v $
     . $',                                                             '
     .$Id: vdspl1.f,v 1.3 2000/12/19 16:04:54 jgofus Exp $
     . $' /
C    ===================================================================
C
      DATA AFMT/'(       X,5A4,2X,2A4,       (F6.2),1X,5A4,1X,   2A4,   
     $ (F6.2))         '/

      DATA BFMT/' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 9','10','11',
     $          '12','13','14','15','16','17','18','19','20','21','22',
     $          '23','24','25','26','27','28','29','30','38'/

      DATA DAYFMT/'(       X,4X,''DESCRIPTION'',6X,''STATION '',        
     $(I6),5X,''DESCRIPTION'',7X,''STATION'',     (I6))  '/

      DATA MONAM/4HJANU,4HARY ,4HFEBR,4HARY ,4HMARC,4HH   ,4HAPRI,
     1 4HL   ,4HMAY ,4H    ,4HJUNE,4H    ,4HJULY,4H    ,4HAUGU,4HST  ,
     2 4HSEPT,4HMBER,4HOCTO,4HBER ,4HNOVE,4HBER ,4HDECE,4HBER /
C
C
      IF (IPTRCE.GT.0) WRITE (IOPDBG,*) 'ENTER VDSPL1'
C
      IDEBUG=IPBUG('VDS1')
C
      IOPNUM=-1
      CALL FSTWHR ('VDSPL1  ',IOPNUM,OLDOPN,IOLDOP)
C
      IF(IDEBUG.GT.0)WRITE(IOPDBG,10)JPTN,KDISP1,KDISP2
     1 ,NDAYS,NDAYOB
10    FORMAT(' IN VDSPL:  ',
     1 ' SNPEONLY OPTION=',I4/
     2 ' 1ST STATION=',I4,' 2ND STATION=',I4,' NDAYS=',I8,
     3 ' NDAYOB=',I8)
C
      IF(JPTN.LT.1) GO TO 510
C
      MISSTA=0
      K=0
      DO 30 J=KDISP1,KDISP2
         K=K+1
         IF(JPNTRS(J).GT.0)GO TO 20
            MISSTA=MISSTA+1
            GO TO 30
20       NUPTR(K-MISSTA)=J
30       CONTINUE
      NSTA=KDISP2-KDISP1+1
      NDAYK=NDAYOB
C
C  SET THE LOOP STARTING INDEX TO ONE FOR REGULAR PRINTING AND TO 
C  NUMBER OF OBSERVED DAYS FOR LAST DAY ONLY PRINTING
      LSTPRT=1
C
C  CHECK IF OPTION TO PRINT ONLY THE LAST DAY OF OBSERVED DATA IS SET
      IF(LSTDY.GT.0)NDAYK=1
      IF(LSTDY.GT.0)LSTPRT=NDAYOB
C
C  NSTB IS HALF OF THE STATIONS FOR WHICH PE VALUES ARE TO BE PRINTED
      NSTB=(NSTA-MISSTA)/2
C  SET FLAG FOR AN ODD NUMBER OF STATIONS
      IODD=0
      IF(2*NSTB.LT.(NSTA-MISSTA))IODD=1
C  DETERMINE THE LOCAL CURRENT DAY OF THE FIRST DAY OF THE RUN -
C  FIRST CHECK IF OPTION TO PRINT ONLY THE LAST DAY OF OBSERVED DATA IS ON
      IHROO=0
      CALL MDYH2(JDAY,IHROO,JCURMO,JCURDA,JCURYR,JCURHR,XD1,XD2,INPTZC)
      IF(IDEBUG.GT.0)WRITE(IOPDBG,40)JCURDA,JCURMO,JCURYR
40    FORMAT(' AT THE DAY SETTING LOOP IN VDSPL1: JCURDA=',I5,
     1 ' JCURMO=',I4,' AND JCURYR=',I6)
      IF (METRIC.EQ.0) THEN
         UNITS='IN'
         ELSE
            UNITS='MM'
         ENDIF
      WRITE(IPR,50)NDAYOB,MONAM(1,JCURMO),MONAM(2,JCURMO),JCURYR,JCURHR,
     1 INPTZC,UNITS
50    FORMAT('0',
     1 6X,'STATION ESTIMATES OF DAILY POTENTIAL EVAPORATION FOR ',I4,
     1 ' HYDROLOGIC DAYS DURING ',2A4,2X,I4,' ENDING AT ',I2.2,A4,3X,
     3 '(UNITS=',A,')')
C  PREPARE FOR MONTH AND DAY WHEN RUN OVERLAPS INTO A NEW MONTH
      MONU=JCURMO
      MO1=JCURMO
      NUYR=JCURYR
      JNUDA=JCURDA
      DO 80 N=1,NDAYOB
C     CHECK FOR DAY NUMBERING PAST THE END OF THE MONTH
         IF(JNUDA-1+N.LE.LSTDAM(MO1))GO TO 80
         IF(JCURMO.NE.2)GO TO 70
            JYR=JCURYR
            AYR=JYR
            YRDIF=(AYR/4.)-JYR/4
            IF(YRDIF.LT.0.01)MO1=13
70       JNUDA=2-N
         MONU=JCURMO+1
         IF(MONU.GT.12)NUYR=JCURYR+1
         IF(MONU.GT.12)MONU=1
         KDAY(N)=JNUDA+N-1
80       CONTINUE
      IF(NDAYK.GT.10)GO TO 160
      IF(NDAYK.GT.5)GO TO 140
C  SET UP HEADING FOR RUNS OF 5 DAYS OR LESS
      IF(IDEBUG.GT.0)WRITE(IOPDBG,90)NDAYK,BFMT(NDAYK)
90    FORMAT(' IN VDSPL1: BFMT(',I5,') =',A2)
C  SET UP SPACING FOR BORDERS OF TITLES
C  MAKE A SPECIAL SETTING WHEN LAST DAY ONLY IS PRINTED
      IF(NDAYK.EQ.1)GO TO 100
      JBORD=31-NDAYK*6
      GO TO 110
100   DAYFMT(7:8)=BFMT(31)
      GO TO 120
110   DAYFMT(7:8)=BFMT(JBORD)
120   DAYFMT(48:49)=BFMT(NDAYK)
      DAYFMT(89:90)=BFMT(NDAYK)
      IF(IDEBUG.GT.0)WRITE(IOPDBG,130)DAYFMT,LSTPRT,NDAYOB
130   FORMAT(' IN VDSPL1: DAYFMT=',A,' LSTPRT=',I5,' NDAYOB=',I5)
      WRITE(IPR,DAYFMT)(KDAY(N),N=LSTPRT,NDAYOB),(KDAY(N),N=LSTPRT,
     1 NDAYOB)
      GO TO 200
C  SET UP HEADINGS FOR RUNS OF 6 TO 10 DAYS
140   WRITE(IPR,150)(KDAY(N),N=LSTPRT,NDAYOB)
150   FORMAT(30X,'DESCRIPTION    STATION ',6X,10I7)
      GO TO 190
C  SET UP HEADINGS FOR RUNS OF 10 DAYS OR MORE
C  CHECK IF THERE ARE MORE THAN 15 DAYS IN THE RUN
160   IF(NDAYK.GT.15)GO TO 180
      WRITE(IPR,170)(KDAY(N),N=1,NDAYK)
170   FORMAT(//4X,'DESCRIPTION',4X,'STATION',2X,16F6.2/)
      GO TO 190
180   MNYDYS=0
190   NSTB=NSTA
      IODD=0
      IF(NSTA.EQ.MISSTA)GO TO 485
200   JSTA=KDISP1-1
      DO 480 JSTAX=1,NSTB
C  JPTR IS THE LAST ELEMENT IN THE PARAMETER ARRAY FOR ANY GIVEN STATION
      JSTA=JSTA+1
      JPTR=(JSTA-1)*7
C  JDPARM IS THE POINTER IN THE PARAMETER ARRAY
      JDPARM=JPTR+1
      JDPRM7=JDPARM+6
C  JPNTR IS THE POINTER TO THE NEXT STATION IN THE PECOMP ARRAY
      JPNTR=(NUPTR(JSTA)-1)*NDAYOB+LSTPRT
C  JPEND IS THE HIGH INDEX OR THE LAST VALUE OF POTENTIAL EVAPORATION 
C  IN THE PECOMP FOR ANY GIVEN STATION
      JPEND=(NUPTR(JSTA)-1)*NDAYOB+NDAYOB
      IF(NDAYK-6)210,310,310
C  KDPARM IS THE PARAMETER POINTER FOR THE RIGHT SIDE OF THE PRINTOUT
210   KDPARM=(NSTB*7)+JDPARM
      KDPRM7=KDPARM+6
C  KDPNTR IS THE PE DATA POINTER FOR THE RIGHT SIDE OF THE PRINTOUT
      KDPNTR=NSTB*NDAYOB+JPNTR
C  KPEND IS THE HIGH ELEMENT FOR EACH STATION IN THE PECOMP ARRAY
      KEND=JPEND+NSTB*NDAYOB
C
C SET BORDERS FOR WHEN ONLY  LAST DAY OF OBSERVED DATA IS TO BE PRINTED
      IF(NDAYK.EQ.1)GO TO 220
         JBORD=31-NDAYK*6
         GO TO 230
220   AFMT(7:8)=BFMT(31)
      GO TO 240
230   AFMT(7:8)=BFMT(JBORD)
240   AFMT(27:28)=BFMT(NDAYK)
      AFMT(59:60)=BFMT(NDAYK)
      IF(IDEBUG.GT.0)WRITE(IOPDBG,250)AFMT,JPNTR,JPEND,KDPNTR,KEND,
     1 JDPARM,KDPARM
250   FORMAT(' IN VDSPL1: AFMT=',A,' JPNTR=',I5,
     1 ' JPEND=',I5,' KDPNTR=',I5,' KEND=',I5,' JDPARM=',I5,
     2 ' KDPARM=',I5)
C
C  CHECK ENGLISH/METRIC OPTION
      MQ=0
      IF (METRIC.GT.0 )GO TO 280
         DO 260 M=JPNTR,JPEND
            MQ=MQ+1
            P(MQ)=PECOMP(M)
            IF(PECOMP(M).LT.0.001)GO TO 260
            P(MQ)=PECOMP(M)/25.4
260         CONTINUE
        DO 270 M=KDPNTR,KEND
           MQ=MQ+1
           P(MQ)=PECOMP(M)
           IF(PECOMP(M).LT.0.001)GO TO 270
           P(MQ)=PECOMP(M)/25.4
270        CONTINUE
         MQE=JPEND-JPNTR+1
         MQE2=2*MQE
         MQE21=MQE+1
         WRITE (IPR,AFMT) (PEPARM(JZ),JZ=JDPARM,JDPRM7),
     1     (P(M),M=1,MQE),(PEPARM(LZ),LZ=KDPARM,KDPRM7),
     1     (P(N),N=MQE21,MQE2)
         GO TO 290
280   WRITE(IPR,AFMT)(PEPARM(JZ),JZ=JDPARM,JDPRM7),
     1 (PECOMP(M),M=JPNTR,JPEND),(PEPARM(LZ),LZ=KDPARM,KDPRM7),
     2 (PECOMP(N),N=KDPNTR,KEND)
290   IF(IDEBUG.GT.0)WRITE(IOPDBG,300)JDPARM,PEPARM(JDPARM),KDPNTR,
     1 KEND,PEPARM(KDPARM)
300   FORMAT(' IN VDSPL1: PEPARM(',I3,')=',A4,' KDPNTR=',I5,
     1 ' KEND=',I6,' PEPARM(KDPARM)=',A4)
      GO TO 480
310   IF(IDEBUG.GT.0)WRITE(IOPDBG,320)JPNTR,JPEND,JDPARM
320   FORMAT(' IN VDSPL1: ',
     1 ' MORE THAN 6 DAYS. JPNTR=',I5,' JPEND=',I5,' JDPARM=',I5)
      IODD=0
      IF(NDAYK.GT.10)GO TO 360
      IF (METRIC.GT.0) GO TO 340
         MQ=0
         DO 330 M=JPNTR,JPEND
            MQ=MQ+1
            P(MQ)=PECOMP(M)
            IF(PECOMP(M).LT.0.001)GO TO 330
            P(MQ)=PECOMP(M)/25.4
330         CONTINUE
         MQE=JPEND-JPNTR+1
         WRITE(IPR,350)(PEPARM(JZ),JZ=JDPARM,JDPRM7),
     1    (P(M),M=1,MQE)
         GO TO 480
340   WRITE(IPR,350)(PEPARM(JZ),JZ=JDPARM,JDPRM7),
     1 (PECOMP(M),M=JPNTR,JPEND)
350   FORMAT(27X,5A4,2X,2A4,3X,10F7.2)
      GO TO 480
C
360   IF (NDAYK.GT.15) GO TO 400
      IF (METRIC.GT.0) GO TO 380
         MQ=0
         DO 370 M=JPNTR,JPEND
            MQ=MQ+1
            P(MQ)=PECOMP(M)
            IF(PECOMP(M).LT.0.001)GO TO 370
            P(MQ)=PECOMP(M)/25.4
370         CONTINUE
         MQE=JPEND-JPNTR+1
         WRITE(IPR,390)(PEPARM(JZ),JZ=JDPARM,JDPRM7),
     1    (P(M),M=1,MQE)
         GO TO 480
380   WRITE(IPR,390)(PEPARM(JZ),JZ=JDPARM,JDPRM7),
     1 (PECOMP(M),M=JPNTR,JPEND)
390   FORMAT(2X,7A4,16F6.2)
      GO TO 480
400   MNYDYS=MNYDYS+1
      IF(MNYDYS.GT.1)GO TO 420
      WRITE(IPR,410)(PEPARM(JZ),JZ=JDPARM,JDPRM7)
410   FORMAT(52X,7A4)
420   NSTRT=(MNYDYS-1)*21+1
      NEND=(MNYDYS-1)*21
      WRITE(IPR,440)(KDAY(N),N=NSTRT,NEND)
440   FORMAT(2X,21I6)
      MBGIN=JPNTR+(MNYDYS-1)*21
      MEND=JPNTR+MNYDYS+21
      IF (METRIC.GT.0) GO TO 460
         MQ=0
         DO 450 M=MBGIN,MEND
            MQ=MQ+1
            P(MQ)=PECOMP(M)
            IF(PECOMP(M).LT.0.001)GO TO 450
            P(MQ)=PECOMP(M)/25.4
450         CONTINUE
         MQE=MEND-MBGIN+1
         WRITE (IPR,470) (P(MQ),M=1,MQE)
         GO TO 480
460   WRITE (IPR,470)(PECOMP(M),M=JPNTR,JPEND)
470   FORMAT (2X,21F6.1)
480   CONTINUE
485   IF(IODD.LT.1)GO TO 510
      JDPARM=(NSTA-1)*7+1
      JDPRM7=JDPARM+6
      JPNTR=(NSTA-1)*NDAYOB+LSTPRT
      JPEND=JPNTR+NDAYOB-1
      IF (METRIC.GT.0) GO TO 500
         MQ=0
         DO 490 JZ=JPNTR,JPEND
            MQ=MQ+1
            P(MQ)=PECOMP(JZ)
            IF(PECOMP(M).LT.0.001)GO TO 490
            P(MQ)=PECOMP(M)/25.4
490         CONTINUE
         MQE=JPEND-JPNTR+1
         WRITE(IPR,AFMT)(PEPARM(JZ),JZ=JDPARM,JDPRM7),
     1    (P(M),M=1,MQE)
         GO TO 510
500   WRITE(IPR,AFMT)(PEPARM(JZ),JZ=JDPARM,JDPRM7),
     1 (PECOMP(M),M=JPNTR,JPEND)
510   IF(KDISP2.GE.LPDFIL)JPTN=0
C
      IF (IPTRCE.GT.0 )WRITE (IOPDBG,*) 'EXIT VDSPL1'
C
      RETURN
C
      END
