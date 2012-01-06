C MODULE QMEAN
C-----------------------------------------------------------------------
C
C  ROUTINE QMEAN CONVERTS OBSERVED MEAN DATA INTO A TIME SERIES.
C
C  ORIGINALLY CODED BY DEBBIE VAN DEMARK - 6/7/84
C  MODIFIED BY ED VANBLARGAN - JULY 85 TO CORRECTLY HANDLE
C     WHEN NO MISSING ALLOWED
C
C-----------------------------------------------------------------------
C
C  INPUT ARGUMENTS:
C        STAID - STATION ID
C        DTYPE - DATA TYPE CODE
C       UNITOT - OUTPUT DATA UNITS
C       UNITIN - INPUT DATA UNITS
C       NCOUNT - NUMBER OF VALUES IN OBS ARRAY
C        FHOUR - HOUR OF THE FIRST OBS IN THE WORK ARRAY
C        LWORK - LENGTH OF THE WORK ARRAY
C         WORK - WORK ARRAY (HOURLY ESTIMATED VALUES)
C       LWKBUF - LENGTH OF ARRAY IWKBUF
C       IWKBUF - TIME SERIES WORK ARRAY
C       INTVAL - TIME INTERVAL
C       ITSREC - RECORD NUMBER OF TIME SERIES IN PROCESSED DATA BASE
C        IMISS - MISSING ALLOWED:
C                 0=YES
C                 1=NO
C       INTERP - INTERPOLATION OPTION:
C                 0=RETAIN PREVIOUS
C                 1=INTERPOLATE
C        EXTRP - RECESSION CONSTANT
C       LERDTP - LENGTH OF ARRAY ERDTP
C        ERDTP - ARRAY OF DATA TYPES WITH ERRORS
C       NERDTP - NUMBER OF DATA TYPES IN ARRAY ERDTP
C
C  OUTPUT ARGUMENTS:
C        JHOUR - FIRST HOUR OF DATA IN TSDAT
C       LTSDAT - LENGTH OF TSDAT ARRAY
C        TSDAT - TIME SERIES DATA ARRAY
C
C-----------------------------------------------------------------------
C
      SUBROUTINE QMEAN (STAID,DTYPE,INTVAL,UNITIN,UNITOT,NCOUNT,FHOUR,
     $ LWORK,WORK,LWKBUF,IWKBUF,LTSDAT,TSDAT,JHOUR,NSTEP,ITSREC,
     $ IMISS,INTERP,EXTRP,LERDTP,ERDTP,NERDTP)
C
      INTEGER FHOUR
      DIMENSION STAID(2)
      DIMENSION WORK(LWORK),TSDAT(LTSDAT),IWKBUF(LWKBUF),ERDTP(LERDTP)
      DIMENSION OLDOPN(2)
C      
      INCLUDE 'common/ionum'
      INCLUDE 'common/pudbug'
      INCLUDE 'common/pptime'
      INCLUDE 'prdcommon/pdatas'
      INCLUDE 'common/fctim2'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_rrs/RCS/qmean.f,v $
     . $',                                                             '
     .$Id: qmean.f,v 1.5 2000/03/14 12:28:23 page Exp $
     . $' /
C    ===================================================================
C
C
      IF (IPTRCE.GT.0) WRITE (IOPDBG,*) 'ENTER QMEAN'
C
      IOPNUM=-3
      CALL FSTWHR ('QMEAN   ',IOPNUM,OLDOPN,IOLDOP)
C
C  CHECK DEBUG CODES
      IBUG=IPBUG('QMEA')
C
C  CHECK IF THE DATA WILL REQUIRE UNITS CONVERSION
      ICONVT=0
      IF (UNITIN.NE.UNITOT) ICONVT=1
C
C  DETERMINE THE NUMBER OF TIME STEPS TO PROCESS
      NSTEP=((IDERUN-IDSRUN)+1)/INTVAL
      IF (IBUG.GT.0) WRITE (IOPDBG,120) NSTEP,STAID,DTYPE
C
C  CHECK IF ANY DATA WAS READ FROM THE PPDB
C  IF NO DATA WERE RETURNED - SET THE TIME SERIES TO MISSING
C
      IF (NCOUNT.GT.0) GO TO 20
C      
      DO 10 I=1,NSTEP
         TSDAT(I)=-999.
10       CONTINUE         
      GO TO 80
C
20    DO 70 I=1,NSTEP
         ISTEP=INTVAL*I
         IF (FHOUR.LT.IDSRUN) ISTEP=ISTEP+(IDSRUN-FHOUR)
C     DETERMINE THE LOWER LIMIT FOR THE INTERVAL
         LRANGE=(ISTEP-INTVAL)+1
C     DETERMINE THE NUMBER OF VALID OBSERVATIONS IN THE TIME INTERVAL
         SUM=0.
         ICOUNT=0
         IF (IBUG.GT.0) WRITE (IOPDBG,180) (WORK(J),J=LRANGE,ISTEP)
         DO 50 J=LRANGE,ISTEP
            IF (WORK(J).GT.-999.) GO TO 40
C        OBSEVATIONS WITHIN THE INTERVAL ARE MISSING
            IF (IBUG.GT.0) WRITE (IOPDBG,140) J,LRANGE,ISTEP
C        SET THE VALUE OF TSDAT TO MISSING
            TSDAT(I)=-999.
C        FOR TS WITH NO MISSING ALLOWED CHECK THE
C        HOURLY VALUES IN THE FIST TS INTERVAL. EVEN IF SOME ARE MISSING
C        COMPUTE AN AVERAGE OF THE NONMISSING HOURLIES TO GET A VALUE
C        FOR TSDAT(1) SO DO NOT HAVE TO GO GET A PREOBS FROM PDB IN
C        QMEANM. OF COURSE IF ALL HOURLIES ARE MISSING THEN TSDAT(1)
C        IS -999.
C        NOTE FOR FUTURE-PROBABLY A BETTER WAY TO FIX IS TO CALL QMEANM
C        FURTHER UP AND PASS IT HOURLY VALUES IN WORK RATHER THAN
C        TSDAT VALUES AS IS CASE FURTHER BELOW. THEN QMEANM COULD
C        INTERPOLATE AND FILL ENTIRE WORK ARRAY WITH NONMISSING BEFORE
C        COMPUTING TSDAT.
            IF (I.NE.1) GO TO 70
            SUM=0.0
            ICOUNT=0
            DO 30 JZ=LRANGE,ISTEP
               IF (IFMSNG(WORK(JZ)).EQ.1) GO TO 30
               SUM=SUM+WORK(JZ)
               ICOUNT=ICOUNT+1
30             CONTINUE
            IF (ICOUNT.NE.0) GO TO 60
            GO TO 70
C        OBS WAS NOT MISSING
40          ICOUNT=ICOUNT+1
            SUM=SUM+WORK(J)
50          CONTINUE
         IF (IBUG.GT.0) WRITE (IOPDBG,130) LRANGE,ISTEP,ICOUNT,SUM
C     IF THERE ARE NO OBSERVATIONS WITHIN THE TIME INTERVAL
C     SET THE VALUE IN THE TSDAT ARRAY TO MISSING
         IF (ICOUNT.GT.0) GO TO 60
            TSDAT(I)=-999.
            IF (IBUG.GT.0) WRITE (IOPDBG,150) LRANGE,ISTEP
            GO TO 70
60       TSDAT(I)=SUM/ICOUNT 
C     CONVERT THE DATA FROM CFS TO CFSD IF NECESSARY
         IF (ICONVT.EQ.0) GO TO 70
            TSDATO=TSDAT(I)
            IF (TSDAT(I).GT.-999) TSDAT(I)=TSDAT(I)*(INTVAL/24.)
            IF (IBUG.GT.0) WRITE (IOPDBG,160) TSDATO,TSDAT(I),INTVAL
70       CONTINUE
C
C  NX IS THE AMOUNT OF EXTRA SPACE NEEDED IN THE TIME SERIES HEADER
C  NPDTX IS THE NUMBER OF VALUES PER TIME STEP
80    NX=0
      NPDTX=1
      MAXDAY=IPRDMD(DTYPE)
      LWBUFF=((((24/INTVAL)*NPDTX*MAXDAY+22+NX-1)/LRECLT)+1)*LRECLT
      IF (LWBUFF.GT.LWKBUF) THEN
         WRITE (IPR,170) (STAID(I),I=1,2),DTYPE,LWBUFF,LWKBUF
         CALL WARN
         GO TO 100
         ENDIF
C
      IF (IBUG.GT.0) THEN
         WRITE (IOPDBG,190)
         WRITE (IOPDBG,200) (TSDAT(I),I=1,NSTEP)
         ENDIF
C      
C  CALL INTERPOLATION ROUTINE IF MISSING IF NEEDED
      IF (IMISS.EQ.1) THEN
         CALL QMEANM (STAID,DTYPE,INTVAL,UNITOT,NCOUNT,
     $      LWKBUF,IWKBUF,INTERP,EXTRP,TSDAT,NSTEP,IER)
         IF (IER.GT.0) GO TO 100
         ENDIF
C
C  DETERMINE THE HOUR OF THE FIRST DATA TO BE WRITTEN TO THE PDB
      JHOUR=IDSRUN+INTVAL+NHOPDB
C      
C  DETERMINE THE FIRST HOUR OF FUTURE DATA
      IF (IFPTR.LT.ISTRUN+NHOPDB) IFPTR=JHOUR
      IF (IFPTR.GT.IDERUN+NHOPDB) IFPTR=0
C
      CALL QXWPRD (STAID,DTYPE,JHOUR,INTVAL,UNITOT,NSTEP,
     $  LTSDAT,TSDAT,IFPTR,LWKBUF,IWKBUF,ITSREC,LERDTP,ERDTP,NERDTP)
C
100   CALL FSTWHR (OLDOPN,IOLDOP,OLDOPN,IOLDOP)
C
      IF (IPTRCE.GT.0) WRITE (IOPDBG,*) 'EXIT QMEAN'
C
120   FORMAT(' NSTEP= ',I5,'  STAID= ',2A4,' DTYPE=',A4,I5)
130   FORMAT(' FROM ',I6, ' TO ',I6,' THERE WERE ',I3,' OBSERVATIONS.',
     $ ' THE SUM OF THE OBSERVATIONS IS ',G15.7)
140   FORMAT(' THE OBSERVATION AT ',I6,' WAS -999. SO THE PERIOD FROM',
     $ I6,' TO ',I6,' WILL BE SET TO MISSING(-999.)')
150   FORMAT(' THERE ARE NO OBSERVATIONS FROM ',I6,' TO ',I6,' THE',
     $' PERIOD WILL BE SET TO MISSING (-999.)')
160   FORMAT(' ',G15.7,' CFS IS CONVERTED TO ',G15.7,' CFSD WITH A',
     $ ' TIME INTERVAL OF ',I2)
170   FORMAT('0**WARNING** THE TIME SERIES WORK ARRAY FOR STATION ',2A4,
     $    ' AND DATA,TYPE ',A4,' IS TOO SMALL.' /
     $ 13X,'THE ARRAY IS DIMENSIONED TO ',I5,
     $    ' AND THE SIZE NEEDED ',I5,
     $    ' PROCESSING WILL CONTINUE WITH THE NEXT DATA TYPE.')
180   FORMAT(' ',10F12.0)
190   FORMAT(' THE VALUES IN THE TSDAT ARRARY ')
200   FORMAT(' ',5G15.7)
C
      RETURN
C      
      END
