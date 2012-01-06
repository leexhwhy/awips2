C MODULE DFPOST
C-----------------------------------------------------------------------
C
      SUBROUTINE DFPOST (MSHPDB,ISHPDB,NSHPDB,IRFLG,IERNPR,USERID,
     *   JPRINT)
C
C  THIS ROUTINE READS THE SHEFOUT FILE AND WRITES THE DATA TO THE
C  PREPROCESSOR DATA BASE.
C
C  ARGUMENT LIST:
C
C    NAME    TYPE   I/O   DIM   DESCRIPTION
C    ------  ----   ---   ---   -----------
C    IRFLG    I      I     1    REVISION INDICATOR:
C                                 0 = USE REVISION FLAG AS INTENTED
C                                 1 = IGNORE REVISION FLAG -
C                                     ALWAYS POST VALUE
C    IERNPR   I      I     1    ERROR PRINT INDICATOR
C    USERID   A8     I     1    USER IDENTIFIER
C
      DIMENSION ISHPDB(9,MSHPDB)
C
      INCLUDE 'uiox'
      INCLUDE 'udebug'
      INCLUDE 'dfcommon/dfunts'
      INCLUDE 'dacommon/darpts'
      INCLUDE 'hclcommon/hdflts'
C
      CHARACTER*(*) USERID
      CHARACTER*8   STAID
      DOUBLE PRECISION  DPR
      DIMENSION  ISHBUF(32),ISCODE(2),VALBUF(1000),MINS(1000),
     *           JULTME(1000),IDSRCE(2),IDURH(1000),NSHBUF(32),
     *           ICHECK(9),LCHECK(5),LPTYPE(5,10)
      EQUIVALENCE (ISHBUF(3),KYR)
      EQUIVALENCE (ISHBUF(4),KMO)
      EQUIVALENCE (ISHBUF(5),KDA)
      EQUIVALENCE (ISHBUF(6),KHR)
      EQUIVALENCE (ISHBUF(7),KMIN)
      EQUIVALENCE (ISHBUF(21),RBUF)
      INTEGER TSFLAG
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/shefpost/RCS/dfpost.f,v $
     . $',                                                             '
     .$Id: dfpost.f,v 1.9 2005/08/12 14:51:12 dws Exp $
     . $' /
C    ===================================================================
C

      DATA JBLNK  / 4h     /, JTA01 / 4hTA01 /, JTA03 / 4hTA03 /
      DATA JTA06  / 4hTA06 /
      DATA LETF   / 4hF    /, LETA  / 4hA    /, LETU  / 4hU    /
      DATA LTFMX  / 4hTFMX /, LTFMN / 4hTFMN /
      DATA ICHECK / 1,2,9,10,11,12,13,14,25 /
      DATA LCHECK / 15,16,17,19,20 /
      DATA IZCZC  / 4hZCZC /
      DATA IPP06  / 4hPP06 /

      IF (IDETR.GT.0) WRITE (IOGDB,'('' *** ENTER DFPOST'')')

      CALL UMEMST (JBLNK,ISHBUF,32)
      TSFLAG=0
      NUMOBS=0
      IFUT=0
      IFFLAG=0
      ISKIP=0
      IFIRST=0
      NUM=0
      LOOP=0
      IEND=0
C
C  REWIND SHEFOUT FILE
      IF (IDEDB.GT.0) WRITE (IOGDB,420) KFSOUT
      REWIND KFSOUT
      IF (IDEDB.NE.0) WRITE (LP,430)

      IDBDUM(3)=0

      WRITE (LP,440)
C
C  READ SHEFOUT FILE
20    READ (KFSOUT,ERR=360,END=380) ISHBUF
C
C  CONVERT YEAR NUMBERS TO TWO DIGITS
CCC      ISHBUF(3) = ISHBUF(3) - ( (ISHBUF(3)/100) * 100 )
      ISHBUF(9) = ISHBUF(9) - ( (ISHBUF(9)/100) * 100 )
C
      IDBDUM(3)=IDBDUM(3)+1
      IF (IDEDB.GT.0.AND.IDBDUM(3).EQ.0) WRITE (IOGDB,450)
      IF (IDEDB.GT.0.AND.ISHBUF(1).EQ.IZCZC) WRITE (LP,460)
      IF (ISHBUF(1).EQ.IZCZC) GO TO 380
      IF (TSFLAG.NE.0) GO TO 50
C
C  PACK THE DATA CODES INTO ONE WORD TO MAKE THE SHEF EXPANDED PARAMETER
C  CODE
30    CALL DFCODE (ISHBUF,ISCODE,ITRNCK)
      IF (IDEDB.GT.0.AND.ITRNCK.EQ.1) WRITE (LP,40)
40    FORMAT (' GOES OR CADAS SITE ENCOUNTERED')
C
C  GET THE PPDB DATA TYPE FOR POSTING
      CALL DFMTCH (MSHPDB,ISHPDB,NSHPDB,ISCODE,ITYPE,INDEX)
      IF (ITYPE.EQ.0.AND.ISHBUF(28).NE.0) ITYPE=-1
C
C  CHECK IF PARAMETER CODE WAS FOUND
      IF (ITYPE.EQ.0.OR.ITYPE.EQ.-1) GO TO 60
C
      IDX=IPDCKD(ITYPE)
C
C  CHECK IF DAILY DATA TYPE
50    IF (ITYPE.EQ.-1.OR.ITYPE.EQ.-2) GO TO 60
      IF (IDX.EQ.0) GO TO 60
C
C  DAILY TYPE - ADJUST TO NEAREST HOUR
      IF (ITYPE.NE.IPP06.AND.KMIN.EQ.30) THEN
         ISYNT=MOD(KHR,3)
         IF (IDEDB.GT.0) WRITE (LP,*) 'ISYNT = ',ISYNT
         IF (ISYNT.EQ.0) GO TO 60
         ENDIF
      IF (ITYPE.NE.IPP06.AND.KMIN.GE.30) THEN
         KMIN = 0
         CALL DDICH1 (KYR, KMO, KDA, KHR)
         ENDIF
      IF (ITYPE.EQ.IPP06) THEN
         IHRMOD=MOD(KHR,6)
         IF (IHRMOD.EQ.2 .AND. KMIN.GT.0) THEN
            KMIN = 0
            CALL DDICH1 (KYR, KMO, KDA, KHR)
            ENDIF
         ENDIF
C
C  CONVERT OBSERVATION DATE TO BE POSTED
60    CONTINUE
      IYRT = ISHBUF(3)
      CALL DDYCDL (IYRT,ISHBUF(4),ISHBUF(5))
      CALL DDGCH2 (JLHR,IYRT,ISHBUF(4),ISHBUF(5),ISHBUF(6))
C
C  MOVE IN DATA SOURCE AND VALUE
      CALL UMEMOV (ISHBUF(26),IDSRCE,2)
      CALL UMEMOV (ISHBUF(22),DPR,2)
C
C  CALL FILTER TO CHECK QUALITY CODE THAT MAY RESET DPR TO MISSING
      CALL DFQCHK (ITYPE,DPR,ISHBUF(24))
C
      IF (ITYPE.EQ.0) GO TO 70
C
      IF (IFFLAG.EQ.1) GO TO 100
      IF (ITYPE.EQ.-1.OR.ITYPE.EQ.-2) GO TO 80
C
C  CHECK PROBABILITY VALUE
      IF (RBUF.EQ.-1.0) GO TO 80
      IF (ISHBUF(18).NE.LETF.AND.ISHBUF(28).EQ.0) GO TO 70
      ITYPE=-2
      GO TO 80
C
C  DO NOT PROCESS THIS RECORD - GET NEXT ONE
70    CALL JLMDYH (JLHR,JMO,JDAY,JYR,JHR)
      IF (ITYPE.NE.0) WRITE (LP,470) ISCODE
      WRITE (LP,480) (ISHBUF(I),I=1,2),JMO,JDAY,JYR,JHR,TIME(3)
      IF (LP.EQ.LP) CALL ULINE(LP,5)
      GO TO 20
C
C  CHECK IF TIMES SERIES
80    IF (TSFLAG.EQ.0) GO TO 100
      IF (ISHBUF(28).EQ.2) GO TO 100
C
C  POST THIS STATION
      IF (ITYPE.EQ.-1.OR.ITYPE.EQ.-2) GO TO 350
      CALL DFWPDB (STAID,ITYPE,JULTME,MINS,IREV,VALBUF,NUMOBS,
     *      ISCODE,ISHBUF(24),IDSRCE,ITME,IFUT,IRFLG,IERNPR,IDURH,
     *      USERID,IERR,JPRINT)
90    TSFLAG=0
      NUMOBS=0
      IFUT=0
      GO TO 30
C
100   IF (IFFLAG.EQ.1.AND.(ITYPE.EQ.-1.OR.ITYPE.EQ.-2)) GO TO 150
      IF (ITYPE.EQ.-1.OR.ITYPE.EQ.-2) GO TO 120
C
C  ADJUST HOUR TO BE SYNOPTIC IF NECESSARY
      CALL DFADJH (MSHPDB,ISHPDB,NSHPDB,JLHR,INDEX,ITYPE,ISCODE,IERR)
C
      IF (IFFLAG.EQ.1) GO TO 150
C
C  SEE IF DAILY DATA TYPE
      IF (IDX.EQ.0) GO TO 110
C
C   CHANGE JULIAN HOUR TO JULIAN DAY TO CHECK DATES
      JDY=(JLHR+NHOPDB-1)/24+1
      CALL RPDDTE (ITYPE,JEDATE,JLDATE,ISTAT)
      IF (ISTAT.NE.0) GO TO 330
C
C  CHECK IF BEFORE FIRST DAY ON PPDB
      IF (JDY.LT.JEDATE) GO TO 320
C
C  CHECK REVISION FLAG, IF REVISION FLAG=0, SET IREV=1 OTHERWISE
C  GET IREV FROM RECORD
110   IF (IRFLG.EQ.0) THEN
         IREV=ISHBUF(25)
         ELSE
            IREV=1
         ENDIF
C
C  CHECK FUTURE FLAG
120   IF (ISHBUF(18).EQ.LETF) IFUT=1
C
C  CHECK TIME SERIES INDICATOR IN RECORD
C  CHECK IF A CONTINUATION
      IF (TSFLAG.EQ.0 .OR. ISHBUF(28).NE.2) THEN
C
C  SET UP CALL FOR FIRST RECORD
      JJ=1
      CALL UMEMOV (ISHBUF(1),STAID,2)
      JULTME(JJ)=JLHR
      VALBUF(JJ)=DPR
C
C  SAVE TIME SERIES FLAG, MINUTES AND DURATION
      ITME=ISHBUF(28)
      MINS(JJ)=ISHBUF(7)
      IDURH(JJ)=ISHBUF(17)
      NUMOBS=1
C
C  CHECK IF START OF A TIME SERIES
      IF (ISHBUF(28).EQ.0) GO TO 160
      TSFLAG=1
      GO TO 20
      ENDIF
C
C  CONTINUATION OF TIME SERIES - SAVE HOUR, MINUTES AND VALUE
150   IF (JJ.GE.1000) GO TO 340
      JJ=JJ+1
      JULTME(JJ)=JLHR
      VALBUF(JJ)=DPR
      MINS(JJ)=ISHBUF(7)
      IDURH(JJ)=ISHBUF(17)
C
C  IF TYPE IS TA01 MUST RESET TO MATCH HOUR. IF HOUR IS 3, THEN TYPE
C  MUST BE TA03, 6 HOUR DATA MUST BE TA06
      IF (ITYPE.EQ.JTA01) THEN
         KK=JULTME(JJ)-JULTME(JJ-1)
         IF (KK.EQ.3) ITYPE=JTA03
         IF (KK.EQ.6) ITYPE=JTA06
      ENDIF
      NUMOBS=NUMOBS+1
      IF (IFFLAG.EQ.1) GO TO 170
      GO TO 20
C
C  FOR FUTURE DATA, CHECK NEXT SHEFOUT RECORD FOR MATCH
160   IF (IFUT.EQ.0) GO TO 290
C
C  READ NEXT SHEFFOUT RECORD
170   READ (KFSOUT,ERR=370,END=390) NSHBUF
C
C  CONVERT YEAR NUMBERS TO TWO DIGITS
      NSHBUF(3) = NSHBUF(3) - ( (NSHBUF(3)/100) * 100 )
      NSHBUF(9) = NSHBUF(9) - ( (NSHBUF(9)/100) * 100 )
C
      IF (NSHBUF(1).EQ.IZCZC) GO TO 270
      IF (NSHBUF(18).NE.LETF) GO TO 270
      DO 180 I=1,9
         J=ICHECK(I)
         IF (NSHBUF(J).NE.ISHBUF(J)) GO TO 270
180      CONTINUE
C
C  PART OF SAME FORECAST MESSAGE FOR CURRENT STATION - CHECK IF
C  SAME DATA TYPE
      DO 200 I=1,5
         J=LCHECK(I)
         IF (I.NE.4) GO TO 190
         IF ((ITYPE.NE.LTFMX).AND.(ITYPE.NE.LTFMN)) GO TO 190
         IF ((ISHBUF(19).EQ.LETU).AND.(NSHBUF(19).EQ.LETA))
     *      GO TO 200
190      IF (NSHBUF(J).NE.ISHBUF(J)) GO TO 220
200      CONTINUE
C
C  THERE IS A COMPLETE MATCH
      DO 210 I=1,32
         ISHBUF(I)=NSHBUF(I)
210      CONTINUE
      IFFLAG=1
      IFIRST=0
      IF (NUM.GT.0) ISKIP=ISKIP+1
      GO TO 50
C
C  SAME FORECAST, DIFFERENT DATA TYPE
220   IF (NUM.EQ.0.AND.LOOP.EQ.0) IFIRST=1
      IF (IFIRST.NE.0) THEN
         IF (NUM.NE.0) THEN
            DO 240 N=1,NUM
               DO 230 I=1,5
                  J=LCHECK(I)
                  IF (NSHBUF(J).NE.LPTYPE(I,N)) GO TO 240
230            CONTINUE
               GO TO 260
240            CONTINUE
            ENDIF
         NUM=NUM+1
         DO 250 I=1,5
            J=LCHECK(I)
            LPTYPE(I,NUM)=NSHBUF(J)
250         CONTINUE
         ENDIF
260   IF (NUM.GT.0) ISKIP=ISKIP+1
      GO TO 170
C
C  EITHER FORECAST OVER, NEW FORECAST, NEW STATION OR EOF ('ZCZC')
C  IF SKIP=0, NO MATCH - POST, RESET FLAG, AND CONTINUE
270   IF (ISKIP.EQ.0) THEN
         DO 280 I=1,32
            ISHBUF(I)=NSHBUF(I)
280         CONTINUE
         ELSE
            IF (NUM.GT.0) ISKIP=ISKIP+1
         ENDIF
      IFFLAG=1

290   IF (ITYPE.EQ.-1.OR.ITYPE.EQ.-2) GO TO 350
C
C  POST TO PPDB
      CALL DFWPDB (STAID,ITYPE,JULTME,MINS,IREV,VALBUF,NUMOBS,
     *      ISCODE,ISHBUF(24),IDSRCE,ITME,IFUT,IRFLG,IERNPR,IDURH,
     *      USERID,IERR,JPRINT)
300   TSFLAG=0
      NUMOBS=0
      IFUT=0
      IF (IFFLAG.EQ.0) GO TO 20
      IFIRST=0
      IFFLAG=0
      IF (ISKIP.EQ.0) THEN
         LOOP=0
         IF (ISHBUF(1).EQ.IZCZC) GO TO 400
         GO TO 30
         ENDIF
C
C  BACKSPACE LOOP
      DO 310 I=1,ISKIP
         BACKSPACE KFSOUT
310      CONTINUE
      NUM=NUM-1
      LOOP=1
      ISKIP=0
      GO TO 20
C
C   DATE OUT OF RANGE
320   CALL JLMDYH (JLHR,JMO,JDAY,JYR,JHR)
      CALL MDYH2 (JEDATE,0,IMO,IDAY,IYR,IHR,ITZ,IDSAV,TIME(3))
      IYR=MOD(IYR,100)
      WRITE (LP,490,IOSTAT=IER) JMO,JDAY,JYR,JHR,IMO,IDAY,IYR,IHR,
     *   (ISHBUF(I),I=1,2),ITYPE
      GO TO 20
C
C  ILLEGAL DATA TYPE
330   WRITE (LP,500) ITYPE
      GO TO 20
C
C  WORK BUFFER FULL
340   WRITE (LP,510) STAID,ITYPE
      GO TO 400
C
C  INVALID TYPE OR PROBABILITY CODE USED WHEN POSTING TIME SERIES
C  OR FORECAST VALUES
350   CALL JLMDYH (JULTME(1),IMO,IDAY,IYR,IHR)
      CALL JLMDYH (JULTME(NUMOBS),LMO,LDAY,LYR,LHR)
      IF (ITYPE.EQ.-2) THEN
         WRITE (LP,470) ISCODE
         ELSE
            IF (IFUT.EQ.1) WRITE (LP,520) ISCODE
         ENDIF
      WRITE (LP,530) STAID,IMO,IDAY,IYR,IHR,LMO,LDAY,LYR,LHR,TIME(3)
      CALL ULINE (LP,3)
      IF (IEND.EQ.1) GO TO 400
      IF (IFFLAG.EQ.1) GO TO 300
      IF (TSFLAG.EQ.1) GO TO 90
      GO TO 400
C
C  READ ERRORS
360   WRITE (LP,540) KFSOUT
      GO TO 400
370   WRITE (LP,550) KFSOUT
      GO TO 400

380   IF (TSFLAG.NE.1) GO TO 400
390   IEND=1
      IF (ITYPE.EQ.-1.OR.ITYPE.EQ.-2) GO TO 350
C
C  POST THE LAST RECORD
      CALL DFWPDB (STAID,ITYPE,JULTME,MINS,IREV,VALBUF,NUMOBS,
     *      ISCODE,ISHBUF(24),IDSRCE,ITME,IFUT,IRFLG,IERNPR,IDURH,
     *      USERID,IERR,JPRINT)

400   IF (IDETR.GT.0) WRITE (IOGDB,*) 'EXIT DFPOST'

      RETURN
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

420   FORMAT (' KFSOUT=',I4)
430   FORMAT (' REWIND COMPLETE.  ABOUT TO READ FIRST RECORD')
440   FORMAT ('0',5('*** DATA POSTED TO PPDB '),'***')
450   FORMAT (' FIRST RECORD READ INTO ISHBUF')
460   FORMAT (' ZCZC FOUND')
470   FORMAT ('0**ERROR** PROBABILITY VALUE SPECIFIED IN SHEF ',
     *   'PARAMETER CODE ',2A4,'. NO DATA POSTED.')
480   FORMAT (5X,'*** STATION: ',2A4,2X,' DATE: ',1X,
     *    I2.2,'/',I2.2,'/',I2.2,'-',I2.2,1X,A3)
490   FORMAT ('0**ERROR** INPUT DATE ',I2.2,'/',I2.2,'/',I2.2,
     *        ':',I2.2,' PRIOR TO EARLIEST DATE ',
     *        I2.2,'/',I2.2,'/',I2.2,':',I2,' ON PPDB. NO DATA ',
     2       'POSTED FOR STATION: ',2A4,'  TYPE:',A4,'.')
500   FORMAT ('0**ERROR** IN DFPOST. DAILY DATA TYPE ',A4,' NOT FOUND',
     *       ' ON PPDB.')
510   FORMAT ('0**ERROR** IN DFPOST FOR STATION :',A,2X,'TYPE:',
     *   A4,', WORK BUFFER FULL. CALL O/H TO HAVE ENLARGED IF ',
     *   'NECESSARY.' /
     *   11X,'A MAXIMUM OF 1000 TIME SERIES VALUES CAN BE POSTED AT ',
     *   'ONE TIME.')
520   FORMAT ('0**WARNING** SHEF PARAMETER CODE ',2A4,1X,
     *   'CANNOT BE POSTED TO THE PPDB.')
530   FORMAT (5X,'*** STATION: ',A,3X,'DATE: ',2(I2,'/'),I2,'-',
     *   I2,' TO ',2(I2,'/'),I2,'-',I2,1X,A3)
540   FORMAT (' ERROR READING FROM UNIT',I3,' INTO ISHBUF IN DFPOST')
550   FORMAT (' ERROR READING FROM UNIT',I3,' INTO NSHBUF IN DFPOST')

      END
