C MODULE FCFASINC
C-----------------------------------------------------------------------
C
C                             LAST UPDATE: 11/29/95.10:24:01 BY $WC20SV
C
C @PROCESS LVL(77)
C
C  ROUTINE TO ASSIGN THE SLOTS TO SAVE CARRYOVER ON PERMANENT FILES
C
      SUBROUTINE FASINC (JSAVE)
C
C............................................................
C
C  ROUTINE FASINC PERFORMS SEVERAL FUNCTIONS:
C   1. REMOVES ANY USER ASSIGNED CARRYOVER DATES THAT MATCH OR PRECEDE
C      THE INITIAL RUN DATE OR EXCEED THE END DATE.
C   2. ASSIGNS CARRYOVER SLOTS TO SAVE CARRYOVER:
C       A) USES ANY SLOT WHOSE DATE MATCHES ANY USER ASSIGNED DATE
C       B) ASSIGNS THE CARRYOVER REQUESTED BY THE USER IN THE
C          FOLLOWING ORDER:
C           1. ASSIGN THE SLOTS THAT ARE INCOMPLETE VOLATILE AND
C              OUTSIDE THE RUN PERIOD
C           2. ASSIGN THE SLOTS THAT ARE INCOMPLETE VOLATILE AND
C              WITHIN THE RUN PERIOD
C           3. ASSIGN THE SLOTS THAT ARE COMPLETE VOLATILE AND
C              OUTSIDE THE RUN PERIOD
C           4. ASSIGN THE SLOTS THAT ARE COMPLETE VOLATILE AND
C              WITHIN THE RUN PERIOD
C         THESE STEPS ARE PERFORMED BY ASSIGNING SLOTS IN ASCENDING
C         ASCENDING CHRONOLOGICAL ORDER.
C         PROTECTED SLOTS (EITHER COMPLETE OR INCOMPLETE) ARE NOT USED
C         ARE NOT USED WHEN ASSIGING SLOTS.
C.......................................................................
C
C  INPUT -- JSAVE - ARRAY TO HOLD THE SLOT NUMBERS ASSIGNED TO SAVE
C                   CARRYOVER.
C
C......................................................................
C
      INCLUDE 'common/ionum'
      INCLUDE 'common/where'
      INCLUDE 'common/sysbug'
      INCLUDE 'common/fdbug'
      INCLUDE 'common/fccgd1'
      INCLUDE 'common/fcio'
      INCLUDE 'common/fcary'
      INCLUDE 'common/fccgd'
      INCLUDE 'common/fccvp'
      INCLUDE 'common/fctime'
C
      DIMENSION OPNOLD(2),JSAVE(10),ICVIN(20),ICVOUT(20),
     *   IIVIN(20),IIVOUT(20),ISLUSE(20),ITEMP(10),IHTEMP(10)
C
      LOGICAL UPDATE,INUSE(20)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_top/RCS/fasinc.f,v $
     . $',                                                             '
     .$Id: fasinc.f,v 1.4 1996/03/21 16:16:54 page Exp $
     . $' /
C    ===================================================================
C
C
      DATA IEQ,ILT,IGT/2HEQ,2HLT,2HGT/
C
C
      MCSTOR=10
C
      IOPNUM=-1
      CALL UMEMOV (OPNAME,OPNOLD,2)
      CALL UMEMOV ('FASINC  ',OPNAME,2)
C
      IBUG=0
      IF (IFBUG('COTR').EQ.1) IBUG=1
      IF (IFBUG('COBG').EQ.1) IBUG=2
C
      IF (IBUG.GE.1) WRITE (IODBUG,10)
10    FORMAT (' *** ENTER FASINC')
C
C  INITIALIZE COUNTERS AND ARRAYS FOR CARRYOVER SAVE BOOKKEEPING
      DO 20 K=1,10
         JSAVE(K)=0
20       CONTINUE
      NSLU=0
      NMATCH=0
      NPRTIO=0
C
C  IF NCSTOR IS -1 THIS IS AN UPDATE RUN - THERE ARE NO USER
C  ASSIGNED CARRYOVER DATES. ALL CARRYOVER ON THE CARRYOVER FILE
C  WITHIN THE RUN PERIOD WILL BE UPDATED.
      UPDATE=.FALSE.
      IF (NCSTOR.EQ.-1) UPDATE=.TRUE.
      IF (IBUG.GE.2) WRITE (IODBUG,*)
     *   ' UPDATE=',UPDATE,
     *   ' '
C
      IF (UPDATE) NCSTOR=0
C
C  FIND THE SLOT THAT HOLDS THE INITIAL CARRYOVER FOR THIS RUN, AND
C  PROTECT IT FROM BEING OVERWRITTEN
      DO 40 I=1,NSLOTS
         IIVOUT(I)=0
         ICVOUT(I)=0
         IIVIN(I)=0
         ICVIN(I)=0
         ISLUSE(I)=0
         INUSE(I)=.FALSE.
         CALL FDATCK (ICODAY(I),ICOTIM(I),IDARUN,IHRRUN,IEQ,JSW)
         IF (JSW.EQ.0) GO TO 40
         NSLU=1
         ISLUSE(NSLU)=I
         IF (IBUG.GE.2) WRITE (IODBUG,30) I,ICODAY(I),ICOTIM(I)
30    FORMAT (' SLOT ',I2,' HOLDS CO FOR THE INITIAL DATE AND TIME ',
     *   I7,I3,' AND WILL NOT BE OVERWRITTEN')
40       CONTINUE
C
      IF (UPDATE) GO TO 450
C
C  CHECK FOR AND REMOVE ANY DUPLICATE USER ASSIGNED CARRYOVER DATES.
C   THIS MAY OCCUR WHEN SEEMINGLY UNMATCHING DATES ARE CONVERTED TO
C   JULIAN DATES. FOR EXAMPLE, THE TWO DATES, 3/21/1980 HOUR 24 AND
C   3/22/1980 HOUR 0, WHEN CONVERTED TO JULIAN DATES, WILL BOTH BE
C   SET TO (IN INTERNAL DATE AND TIME) 3/21/1980 HOUR 24.
      IF (IBUG.GE.2) WRITE (IODBUG,50) NCSTOR
50    FORMAT (' START SEARCH FOR DUPLICATE SAVE CO DATES - NCSTOR=',I2)
      NM=0
      JSTOR=NCSTOR-1
      IF (JSTOR.EQ.0) GO TO 100
      DO 70 I=1,JSTOR
         IF (ICDAY(I).EQ.0.AND.ICHOUR(I).EQ.0) GO TO 70
         JJ=I+1
         DO 60 J=JJ,NCSTOR
            CALL FDATCK (ICDAY(I),ICHOUR(I),ICDAY(J),ICHOUR(J),IEQ,IM)
            IF (IM.EQ.0) GO TO 60
            NM=NM+1
            ICDAY(J)=0
            ICHOUR(J)=0
60          CONTINUE
70       CONTINUE
C
C  REMOVE THOSE MATCHING DATES FROM THE LIST OF CO SAVE DATES
      IF (NM.EQ.0) GO TO 100
      KXJ=0
      DO 80 M=1,NCSTOR
         IF (ICDAY(M).EQ.0.AND.ICHOUR(M).EQ.0) GO TO 80
         KXJ=KXJ+1
         ITEMP(KXJ)=ICDAY(M)
         IHTEMP(KXJ)=ICHOUR(M)
80       CONTINUE
      DO 90 L=1,KXJ
         ICDAY(L)=ITEMP(L)
         ICHOUR(L)=IHTEMP(L)
90       CONTINUE
      NCSTOR=KXJ
100   IF (IBUG.GT.2) WRITE (IODBUG,*)
     *   ' NCSTOR=',NCSTOR,
     *   ' '
C
C  CHECK FOR AND REMOVES ANY USER ASSIGNED CARRYOVER DATES
C  THAT EITHER PRECEDE OR MATCH THE STARTING FORECAST RUN DATE OR
C  EXCEED THE ENDING RUN DATE
      IF (IBUG.GE.2) WRITE (IODBUG,*)
     *   ' BEFORE CALL TO FCHKCO -',
     *   ' NCSTOR=',NCSTOR,
     *   ' '
      CALL FCHKCO
      IF (IBUG.GE.2) WRITE (IODBUG,*)
     *   ' AFTER CALL TO FCHKCO -',
     *   ' NCSTOR=',NCSTOR,
     *   ' '
      IF (NCSTOR.GE.1) GO TO 120
      WRITE (IPR,110)
110   FORMAT ('0**WARNING** ALL USER ASSIGNED CARRYOVER SAVE DATES ',
     *   'HAVE BEEN REMOVED FOR THE ABOVE REASONS.')
      CALL WARN
      UPDATE=.TRUE.
      GO TO 450
C
C  NOW HAVE VALID LIST OF DATES FOR WHICH TO STORE CARRYOVER. THE
C  MAKE SURE THAT HAVE ENOUGH SLOTS TO SAVE THE CARRYOVER DATES BY:
C   1. TOTAL UP THE NUMBER OF DATES INPUT THAT MATCH DATES ON FILE,
C   2. TOTAL UP THE NUMBER OF PROTECTED SLOTS WITHIN THE RUN PERIOD
C      THAT HAVE NOT BEEN ACCOUNTED FOR IN STEP 1),
C   3. TOTAL UP THE NUMBER OF PROTECTED SLOTS OUTSIDE THE RUN PERIOD,
C   4. COMPUTE THE NUMBER OF SLOTS AVAILABLE FOR SAVING CARRYOVER FOR
C      THE USER REQUESTED DATES, BY
C        NAVAIL=NSLOTS-#1)-#2)-#3)-1
C   5. COMPUTE THE NUMBER OF DATES STILL TO BE ASSIGNED,
C        NYET= NCSTOR-#1)
C   6. IF NYET GT NAVAIL THEN NOT ENOUGH SLOTS ARE AVAILABLE TO STORE
C      THE USER REQUESTED DATES OF CARRYOVER;
C      IF NYET LE NAVAIL THEN CAN START GIVING OUT THE SLOTS.
C
C  FIND THE NUMBER OF MATCHING DATES
120   DO 140 I=1,NCSTOR
         DO 130 J=1,NSLOTS
            IF (INUSE(J)) GO TO 130
            CALL FDATCK (ICDAY(I),ICHOUR(I),ICODAY(J),ICOTIM(J),IEQ,
     *         ITSW)
            IF (ITSW.EQ.0) GO TO 130
            INUSE(J)=.TRUE.
            NMATCH=NMATCH+1
            GO TO 140
130         CONTINUE
140      CONTINUE
C
C  FIND UNUSED PROTECTED SLOTS BOTH WITHIN AND OUTSIDE THE RUN PERIOD
      DO 150 K=1,NSLOTS
         IF (IPC(K).LT.2.OR.INUSE(K)) GO TO 150
         INUSE(K)=.TRUE.
         NPRTIO=NPRTIO+1
150      CONTINUE
C
C  COMPUTE THE NUMBER OF AVAILABLE SLOTS
      NAVAIL=NSLOTS-NMATCH-NPRTIO-1
C
C  COMPUTE THE NUMBER OF DATES STILL TO BE GIVEN OUT (I.E. THOSE STILL
C  IN THE LIST OF DATES THAT DO NOT MATCH ANY DATES ON THE SLOTS)
      NYET=NCSTOR-NMATCH
C
      IF (IBUG.GE.2) WRITE (IODBUG,*)
     *   ' NCSTOR=',NCSTOR,
     *   ' NSLOTS=',NSLOTS,
     *   ' NMATCH=',NMATCH,
     *   ' NPRTIO=',NPRTIO,
     *   ' NAVAIL=',NAVAIL,
     *   ' NYET=',NYET,
     *   ' '
C
C  CHECK IF CAN STORE ALL USER REQUESTED DATES OF CARRYOVER
      IF (NYET.LE.NAVAIL) GO TO 170
C
C  CANNOT STORE ALL DATES REQUESTED BY USER
      WRITE (IPR,160) NCSTOR,NMATCH,NPRTIO,NSLOTS,NAVAIL,NYET
160   FORMAT ('0**WARNING** THERE ARE NOT ENOUGH VOLATILE SLOTS ',
     *      'WITH DATES NOT MATCHING ANY REQUESTED DATES TO ',
     *      'SAVE CARRYOVER.' /
     *   13X,'OF THE ',I2,' VALID REQUESTED DATES, ',I2,
     *       ' MATCH DATES ALREADY ON FILE AND ',I2,
     *       ' ARE PROTECTED AND CANNOT BE USED.' /
     *   13X,'OF THE TOTAL OF ',I2,' SLOTS ON FILE ',I2,
     *       ' ARE AVAILABLE FOR STORING REQUESTED CARRYOVER ',
     *       'NOT MATCHING ANY DATES ON FILE ' /
     *   13X,'BUT ',I2,' DATES OF CARRYOVER REMAIN TO BE ALLOCATED.' /
     *   13X,'NO CARRYOVER WILL BE SAVED.')
      CALL WARN
      NCSTOR=0
      GO TO 590
C
C  SLOTS ARE FIRST ASSIGNED BY MATCHING USER ASSIGNED CARRYOVER
C  DATES WITH DATES EXISTING ON THE SLOTS
170   IF (IBUG.GE.2) WRITE (IODBUG,180) (I,ICDAY(I),ICHOUR(I),
     *   I=1,NCSTOR)
180   FORMAT(34H  SAVE DATE NO.  ICDAY    ICHOUR  /(I10,2X,I10,4X,I10))
      IF (IBUG.GE.2) WRITE (IODBUG,190) (J,ICODAY(J),ICOTIM(J),
     *   J=1,NSLOTS)
190   FORMAT(36H  SLOT NO.      ICODAY      ICOTIM  /(5X,I3,4X,I10,3X,I1
     *   0))
      IF (IBUG.GE.2) WRITE (IODBUG,200)
200   FORMAT (' CHECK FOR A MATCH BETWEEN DATE ON SLOT AND DATE ',
     *   'ASSIGNED BY USER')
      DO 240 I=1,NCSTOR
         DO 230 J=1,NSLOTS
            IF (NSLU.EQ.0) GO TO 220
               DO 210 L=1,NSLU
                  IF (ISLUSE(L).EQ.J) GO TO 230
210               CONTINUE
220            CALL FDATCK (ICDAY(I),ICHOUR(I),ICODAY(J),ICOTIM(J),IEQ,
     *             ITSW)
               IF (ITSW.EQ.0) GO TO 230
               JSAVE(I)=J
               NSLU=NSLU+1
               IPROT(I)=0
               IF (IPC(J).EQ.2.OR.IPC(J).EQ.3) IPROT(I)=1
               ISLUSE(NSLU)=J
               GO TO 240
230         CONTINUE
240      CONTINUE
C
      NSLU1=NSLU-1
      IF (IBUG.GE.2) WRITE (IODBUG,250) NSLU1,(JSAVE(I),I=1,NSLU1)
250   FORMAT (' NUMBER OF MATCHING DATES=',I2,' SLOTS=',10I3)
C
      IF (NSLU1.EQ.NCSTOR) GO TO 450
C
C
C  THE HIERARCHY FOR CHOOSING REMAINING AVAILABLE SLOTS TO ASSIGN USER
C  REQUESTED CARRYOVER DATES IS:
C     1. USE ALL INCOMPLETE VOLATILE OUTSIDE THE RUN PERIOD,
C     2. USE ALL INCOMPLETE VOLATILE WITHIN THE RUN PERIOD,
C     3. USE ALL COMPLETE VOLATILE OUTSIDE THE RUN PERIOD,
C     4. USE ALL COMPLETE VOLATILE WITHIN THE RUN PERIOD
C     5. LEAVE ALL PROTECTED (COMPLETE OR INCOMPLETE) ALONE
C  THE STATUS OF A SLOT IS FOUND INT THE IPC VARIABLE IN COMMON FCCGD1:
C       IPC=0 - SLOT IS VOLATILE AND INCOMPLETE
C       IPC=1 - SLOT IS VOLATILE AND COMPLETE
C       IPC=2 - SLOT IS PROTECTED AND INCOMPLETE
C       IPC=3 - SLOT IS PROTECTED AND COMPLETE
      IF (IBUG.GE.2) WRITE (IODBUG,260)
260   FORMAT (' BEGIN SORT OF UNASSIGNED VOLATILE SLOTS')
      NVIO=0
      NVII=0
      NVCO=0
      NVCI=0
      DO 330 I=1,NSLOTS
         IF (NSLU.EQ.0) GO TO 280
            DO 270 K=1,NSLU
               IF (I.EQ.ISLUSE(K)) GO TO 330
270            CONTINUE
280      MULT=IFRUN(ICODAY(I),ICOTIM(I))
         M=IPC(I)*2+MULT+1
         IF (IBUG.GE.2) WRITE (IODBUG,*)
     *      ' I=',I,
     *      ' IPC(I)=',IPC(I),
     *      ' M=',M,
     *      ' '
         GO TO (290,300,310,320,330,330,330,330),M
290      NVIO=NVIO+1
         IIVOUT(NVIO)=I
         GO TO 330
300      NVII=NVII+1
         IIVIN(NVII)=I
         GO TO 330
310      NVCO=NVCO+1
         ICVOUT(NVCO)=I
         GO TO 330
320      NVCI=NVCI+1
         ICVIN(NVCI)=I
330      CONTINUE
      IF (IBUG.GE.2) WRITE (IODBUG,*)
     *   ' INCOMPLETE VOLATILE SLOTS OUT - ',
     *   ' NVIO=',NVIO,
     *   ' IIVOUT=',IIVOUT,
     *   ' '
      IF (IBUG.GE.2) WRITE (IODBUG,*)
     *   ' INCOMPLETE VOLATILE SLOTS IN - ',
     *   ' NVII=',NVII,
     *   ' IIVIN=',IIVIN,
     *   ' '
      IF (IBUG.GE.2) WRITE (IODBUG,*)
     *   ' COMPLETE VOLATILE SLOTS OUT - ',
     *   ' NVCO=',NVCO,
     *   ' ICVOUT=',ICVOUT,
     *   ' '
      IF (IBUG.GE.2) WRITE (IODBUG,*)
     *   ' COMPLETE VOLATILE SLOTS IN - ',
     *   ' NVCI=',NVCI,
     *   ' ICVIN=',ICVIN,
     *   ' '
C
C  SORT THE COMPLETE AND INCOMPLETE VOLATILE SLOTS BOTH WITHIN AND
C  OUTSIDE THE RUN PERIOD IN ASCENDING CHRONOLOGICAL ORDER
C  (OLDEST DATE IS IN FIRST ARRAY POSITION)
      IF (NVIO.LE.1) GO TO 340
      CALL FCSORT (IIVOUT,ICODAY,ICOTIM,NVIO)
         IF (IBUG.GE.2) WRITE (IODBUG,*) ' AFTER CALL TO FCSORT'
         IF (IBUG.GE.2) WRITE (IODBUG,*)
     *      ' NVIO=',NVIO,
     *      ' IIVOUT=',IIVOUT,
     *      ' '
340   IF (NVII.LE.1) GO TO 350
         CALL FCSORT (IIVIN,ICODAY,ICOTIM,NVII)
         IF (IBUG.GE.2) WRITE (IODBUG,*) ' AFTER CALL TO FCSORT'
         IF (IBUG.GE.2) WRITE (IODBUG,*)
     *      ' NVII=',NVII,
     *      ' IIVIN=',IIVIN,
     *      ' '
350   IF (NVCO.LE.1) GO TO 360
         CALL FCSORT (ICVOUT,ICODAY,ICOTIM,NVCO)
         IF (IBUG.GE.2) WRITE (IODBUG,*) ' AFTER CALL TO FCSORT'
         IF (IBUG.GE.2) WRITE (IODBUG,*)
     *      ' NVCO=',NVCO,
     *      ' ICVOUT=',ICVOUT,
     *      ' '
360   IF (NVCI.LE.1) GO TO 370
         CALL FCSORT (ICVIN,ICODAY,ICOTIM,NVCI)
         IF (IBUG.GE.2) WRITE (IODBUG,*) ' AFTER CALL TO FCSORT'
         IF (IBUG.GE.2) WRITE (IODBUG,*)
     *      ' NVCI=',NVCI,
     *      ' ICVOUT=',ICVOUT,
     *      ' '
C
C  IF THE REQUESTED NUMBER OF SLOTS HAVE BEEN NOT ASSIGNED ASSIGN THEM
C  IN THIS ORDER:
C      1. OLDEST INCOMPLETE VOLATILE OUTSIDE RUN PERIOD
C      2. OLDEST INCOMPLETE VOLATILE WITHIN RUN PERIOD
C      3. OLDEST COMPLETE VOLATILE OUTSIDE RUN PERIOD
C      4. OLDEST COMPLETE VOLATILE WITHIN RUN PERIOD
370   LCIO=1
      LCII=1
      LCCO=1
      LCCI=1
      IF (NVII.EQ.0) LCII=-1
      IF (NVIO.EQ.0) LCIO=-1
      IF (NVCO.EQ.0) LCCO=-1
      IF (NVCI.EQ.0) LCCI=-1
      LXI=0
      LXV=0
      LSI=0
      LSV=0
      IF (IBUG.GE.2) WRITE (IODBUG,*)
     *   ' LCII=',LCII,
     *   ' LCIO=',LCIO,
     *   ' LCCI=',LCCI,
     *   ' LCCO=',LCCO,
     *   ' '
C
      DO 440 I=1,NCSTOR
         IF (JSAVE(I).NE.0) GO TO 430
C        ASSIGN THE INCOMPLETE VOLATILE OUTSIDE THE RUN PERIOD
            IF (LCIO.EQ.-1) GO TO 380
            JSAVE(I)=IIVOUT(LCIO)
            IPROT(I)=0
            NSLU=NSLU+1
            ISLUSE(NSLU)=IIVOUT(LCIO)
            LCIO=LCIO+1
            LXI=LCIO-1
            IF (LCIO.GT.NVIO) LCIO=-1
            GO TO 430
380      IF (LCII.EQ.-1) GO TO 390
C        ASSIGN THE INCOMPLETE VOLATILE WITHIN THE RUN PERIOD
            JSAVE(I)=IIVIN(LCII)
            IPROT(I)=0
            NSLU=NSLU+1
            ISLUSE(NSLU)=IIVIN(LCII)
            LCII=LCII+1
            LXV=LCII-1
            IF (LCII.GT.NVII) LCII=-1
            GO TO 430
390      IF (LCCO.EQ.-1) GO TO 400
C        ASSIGN THE COMPLETE VOLATILE OUTSIDE THE RUN PERIOD
            JSAVE(I)=ICVOUT(LCCO)
            IPROT(I)=0
            NSLU=NSLU+1
            ISLUSE(NSLU)=ICVOUT(LCCO)
            LCCO=LCCO+1
            LSI=LCCO-1
            IF (LCCO.GT.NVCO) LCCO=-1
            GO TO 430
C        ASSIGN THE COMPLETE VOLATILE WITHIN THE RUN PERIOD
400      IF (LCCI.EQ.-1) GO TO 430
            JSAVE(I)=ICVIN(LCCI)
            IPROT(I)=0
            NSLU=NSLU+1
            ISLUSE(NSLU)=ICVIN(LCCI)
            NS=ICVIN(LCCI)
            LCCI=LCCI+1
            LSV=LCCI-1
            IF (LCCI.GT.NVCI) LCCI=-1
            IF (IFRUN(ICODAY(NS),ICOTIM(NS)).EQ.1) GO TO 410
            GO TO 430
C     PRINT WARNING THAT A SLOT THAT HAS NOT BEEN SPECIFIED BY THE USER
C     AND IS WITHIN THE RUN PERIOD IS BEING USED TO SAVE CARRYOVER AND
C     THE OLD CARRYOVER AND DATE WILL BE LOST.
410      CALL MDYH1(ICODAY(NS),ICOTIM(NS),IZM,IZD,IZY,IZH,NOUTZ,NOUTDS,
     *      TZC)
         CALL MDYH1(ICDAY(I),ICHOUR(I),IRM,IRD,IRY,IRH,NOUTZ,NOUTDS,
     *      RTZC)
         WRITE (IPR,420) NS,IZM,IZD,IZY,IZH,TZC,IRM,IRD,IRY,IRH,RTZC
420   FORMAT ('0**WARNING** A SLOT OF COMPLETE VOLATILE CARRROVER ',
     *      'WITHIN THE RUN PERIOD WILL BE LOST. ' /
     *   13X,'SLOT NUMBER ',I2,' HOLDING CARRYOVER FOR ',
     *      I2.2,'/',I2.2,'/',I4,'-',I2.2,A4,
     *      ' WILL BE OVERWRITTEN TO STORE ' /
     *   13X,'CARRYOVER FOR THE USER-REQUESTED DATE ',
     *      I2.2,'/',I2.2,'/',I4,'-',I2.2,A4,'.')
         CALL WARN
430      IF (IBUG.GE.2) WRITE (IODBUG,*)
     *      ' I=',I,
     *      ' JSAVE(I)=',JSAVE(I),
     *      ' LXI=',LXI,
     *      ' LXV=',LXV,
     *      ' LSI=',LSI,
     *      ' LSV=',LSV,
     *      ' NSLU=',NSLU,
     *      ' '
440      CONTINUE
C
C  ANY EXISTING DATES ON THE SLOTS THAT ARE WITHIN THE
C  RUN INTERVAL ARE USED PROVIDED THEY HAVE NOT ALREADY BEEN USED
C
450   IF (IBUG.GE.2) WRITE (IODBUG,460)
460   FORMAT (' CHECK FOR ANY UNASSIGNED SLOT IN THE RUN PERIOD')
      NSLT1=NSLOTS-1
      DO 520 J=1,NSLOTS
         IF (NSLU.EQ.0) GO TO 480
         DO 470 K=1,NSLU
            IF (ISLUSE(K).EQ.J) GO TO 520
470         CONTINUE
480      IF (IFRUN(ICODAY(J),ICOTIM(J)).EQ.1) GO TO 490
         GO TO 520
490      NCSTOR=NCSTOR+1
         IF (IBUG.GE.2) WRITE (IODBUG,500) NCSTOR
500   FORMAT (' NCSTOR CHANGED TO ',I2)
         ISTOR=0
         IF (NCSTOR.GT.MCSTOR) ISTOR=1
         IF (NCSTOR.GT.NSLT1) ISTOR=2
         IF (NCSTOR.GT.MCSTOR.AND.NCSTOR.GT.NSLT1) ISTOR=3
         I2=ISTOR+1
         GO TO (510,520,520,520),I2
510      JSAVE(NCSTOR)=J
         ICDAY(NCSTOR)=ICODAY(J)
         ICHOUR(NCSTOR)=ICOTIM(J)
         NSLU=NSLU+1
         ISLUSE(NSLU)=J
         IPROT(NCSTOR)=0
         IF (IPC(J).EQ.2.OR.IPC(J).EQ.3) IPROT(NCSTOR)=1
         IF (IBUG.GE.2) WRITE (IODBUG,*)
     *      ' NCSTOR=',NCSTOR,
     *      ' J=',J,
     *      ' ICODAY(J)=',ICODAY(J),
     *      ' ICOTIM(J)=',ICODAY(J),
     *      ' '
520      CONTINUE
C
      IF (NCSTOR.GT.0) GO TO 540
C
      WRITE (IPR,530)
530   FORMAT ('0**WARNING** NO CARRYOVER EXISTS ON FILE FOR UPDATING ',
     *   'AND NO VALID DATES HAVE BEEN ASSIGNED BY THE USER.' /
     *   13X,'NO CARRYOVER WILL BE SAVED.')
      CALL WARN
      NCSTOR=0
      GO TO 590
C
540   NSLT1=NSLOTS-1
      ISTOR=0
C
      IF (NCSTOR.GT.MCSTOR) ISTOR=1
      IF (NCSTOR.GT.NSLT1) ISTOR=2
      IF (NCSTOR.GT.MCSTOR.AND.NCSTOR.GT.NSLT1) ISTOR=3
      I2=ISTOR+1
C
      GO TO (590,550,570,550),I2
C
550   WRITE (IPR,560) NCSTOR,MCSTOR
560   FORMAT ('0**WARNING** COMBINED NUMBER OF USER ASSIGNED AND ',
     *      'EXISTING INTERMEDIATE CARRYOVER DATES (',I2,')' /
     *   13X,'EXCEEDS THE MAXIMUM NUMBER ALLOWED PER CARRYOVER ',
     *      'SAVE RUN (',I2,').' /
     *   13X,'NO CARRYOVER WILL BE SAVED.')
      NCSTOR=0
      CALL WARN
      IF (I2.EQ.4) GO TO 570
      GO TO 590
C
570   WRITE (IPR,580) NCSTOR,NSLT1
580   FORMAT ('0**WARNING** COMBINED NUMBER OF USER ASSIGNED AND ',
     *      'EXISTING INTERMEDIATE CARRYOVER DATES (',I2,')' /
     *   13X,'EXCEEDS THE MAXIMUM AVALIABLE FOR ',
     *      'SAVING CARRYOVER (',I2,').'/
     *   13X,'NO CARRYOVER WILL BE SAVED.')
      NCSTOR=0
      CALL WARN
C
590   CALL UMEMOV (OPNOLD,OPNAME,2)
C
      IF (IBUG.GE.1) WRITE (IPR,600) NCSTOR
600   FORMAT (' *** EXIT FASINC - NCSTOR=',I2)
C
      RETURN
C
      END
