C MEMBER XMDRPL
C  (from old member PPXMDRCV)
C***********************************************************************
C
      SUBROUTINE XMDRPL(STBDY,MDR6,MISSM,IWORK,PLOT)
C
C       XMDRPL : PLOTS MDR VALUES ON STATE BOUNDARIES
C
C SUBROUTINE ORIGINALLY BY ED VANBLARGAN - HRL - APRIL,1983
C.......................................................................
C
C OUTLINE OF PLOT
C   HEADER(ALREADY WRITTEN BY CALLING PROG)
C   BLANK LINE
C   BLANK
C   COLUMN NUMBERS
C   MDR BOXES (BLANK)
C           (VALUES FOR EACH COL. WITH ROW NUMBER AT BEGINNING AND END)
C           (BLANK)
C   REPEAT MDR BOX FOR ALL ROWS
C   COLUMN NUMBERS
C
C STEPS:
C A. WRITE OUT COL NUMBERS
C B. LOOP THRU EACH ROW AND
C C. FOR EACH COLUMN
C  1 IF MDR IS NON-ZERO THEN CONVERT TO A3 FORMAT.
C       AND PUT IN PLOT. LOAD IN REVERSE ORDER
C       SINCE MDR STARTS AT SOUTH END. IF MISSING PRINT AN M.
C  2. PUT STATE OUTLINES IN PLOT ARRAY (OUTLINES ARE IN A3 AND START AT
C       NORTH END) IF MDR IS 0.
C  3. PRINT OUT THE ROW IN PLOT
C D. AT END OF EACH ROW PRINT OUT THE ROW (NOW IN PLOT ARRAY).
C
C ARGUMENT LIST
C
C NAME  I/O TYPE DIM DESC
C ----  --- ---- --- ------------------------------------------
C STBDY  I   R*4 VAR STATE BOUNDARY POINTS ARRAY
C                      1-N=BOUNDARY POINTS (IN A3 FORMAT)
C                          START AT NORTH MOST ROW AND GO ACROSS ROWS
C                          FROM WEST (N=NUM. OF COLS*NUM. OF ROWS)
C MDR6   I   I*2 VAR DATA ARRAY CONTAINING 6-HR SUMMED MDR VALUES
C                    TO BE PLOTTED. VALUES START AT SOUTH MOST ROW
C MISSM  I   I*2  1  MISSING MDR VALUE (CAN BE EQUAL TO MSNG6 OR
C                    MSGMDR DEPENDING ON WHETHER MDR WAS CONVERTED
C                    TO PRECIP YET).
C IWORK  I   I*4 VAR WORK SPACE ARRAY TO HOLD COLUMN NUMBERS
C PLOT   I   R*4 VAR WORK ARRAY FOR PLOTTING POSITIONS IN A3
C **NOTE** PLOT AND STBDY ARE DECLARED LOGICAL*1 TO WORK BYTE BY BYTE.
C          PLOT AND IWORK BOTH REQUIRE A SIZE OF (NCMDR*2+1) FULL WORDS
C
C
C INTERNAL VARIABLES
C ------------------
C NPUSE  - NUMBER OF SPACES(COLUMNS) USED IN PLOT ARRAY
C LOCSTB - LOCATION IN STATE BOUNDARY ARRAY
C LOCP   - LOCATION IN PLOT ARRAY
C MDRVAL - FULL 4 BYTE INTEGER TO HOLD MDR VALUE FROM MDR6 ARRAY
C
C.......................................................................
C
      LOGICAL*1 STBDY,PLOT,AM
      INTEGER*2 MDR6,MISSM
      DIMENSION IWORK(1),STBDY(1),MDR6(1),PLOT(1),AM(3)
C
      INCLUDE 'common/ionum'
      INCLUDE 'common/pudbug'
      INCLUDE 'common/xmdr'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_map/RCS/xmdrpl.f,v $
     . $',                                                             '
     .$Id: xmdrpl.f,v 1.1 1995/09/17 18:59:50 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA AM/1H ,1HM,1H /
      DATA SNAME/4HXMDR/
C
C INITIALIZE VARIABLES
C FOR NPUSE;ADD 1 SINCE ROW NUMBER WILL BE INSERTED AT END AND USE *3
C SINCE WORKING WITH 3 BYTES
C
      IBUG=IPBUG(SNAME)
      IF (IPTRCE.GE.1) WRITE(IOPDBG,805)
      NPUSE=(NCMDR+1)*3
      IER=0
C
C........DEBUG TIME.....................................................
C
      IF (IBUG.EQ.0) GO TO 190
      WRITE(IOPDBG,891)
      NCOL=NCMDR*4
      LOCSTB=0
      DO 150 N=1,NRMDR
      WRITE(IOPDBG,893) (STBDY(LOCSTB+I),STBDY(LOCSTB+I+1),
     $ STBDY(LOCSTB+I+2),I=1,NCOL,4)
      LOCSTB=LOCSTB+NCOL
150   CONTINUE
C.......................................................................
C
C STEP A. PUT COL. NUMBERS IN IWORK AND PRINT THEM
C
190   LOCSTB=1
      NCOL=ICMDR
      DO 200 N=1,NCMDR
      IWORK(N)=NCOL
200   NCOL=NCOL+1
      WRITE(IPR,815) (IWORK(N),N=1,NCMDR)
C
C STEP B.
C LOOP THRU EACH ROW
C
      NROW=IRMDR + NRMDR -1
      DO 750 NR=1,NRMDR
C CONVERT ROW NUM. TO A3 AND PUT AT END OF PLOT
      CALL UINTCH(NROW,3,PLOT(NPUSE-2),NUSE,IERSUB)
      IER=IER+IERSUB
C ADJUST LOCMDR (GO BACKWARDS)
      LOCMDR=NMDR - NCMDR*NR + 1
C
C NESTLED LOOP TO GO THRU EACH COLUMN
      LOCP=1
      DO 700 N=1,NCMDR
C STEP C1.
C IF MDR IS 0 THEN JUMP AHEAD AND PUT IN STATE BOUNDARY.
      MDRVAL=MDR6(LOCMDR)
      IF (MDRVAL.EQ.0) GO TO 500
C SET UP PLOT LOCATION TO BE MISSING. THEN IF MDR IS MISSING JUST
C JUMP AHEAD. OTHERWISE CONVERT TO A3 AND PUT THAT IN PLOT.
      PLOT(LOCP)  =AM(1)
      PLOT(LOCP+1)=AM(2)
      PLOT(LOCP+2)=AM(3)
      IF (MDR6(LOCMDR).EQ.MISSM) GO TO 600
      CALL UINTCH(MDRVAL,3,PLOT(LOCP),NUSE,IERSUB)
      IER=IER+IERSUB
      GO TO 600
C STEP C2.
C COMES HERE IF MDR VALUE NO GOOD, SO PUT STATE BOUNDARY POINT INTO
C PLOT INSTEAD (NOTE STATE POINT IS BLANK-DOT-BLANK BUT WE ADJUST TO
C BE BLANK-BLANK-DOT)
500   PLOT(LOCP)=STBDY(LOCSTB)
      PLOT(LOCP+1)=STBDY(LOCSTB+2)
      PLOT(LOCP+2)=STBDY(LOCSTB+1)
C INCREMENT COUNTERS
600   LOCSTB=LOCSTB+4
      LOCP  =LOCP+3
      LOCMDR=LOCMDR+1
700   CONTINUE
C **END NESTLED COLUMN LOOP**
C
C STEP C3.
C PRINT OUT ROW (IN PLOT ARRAY)
      WRITE(IPR,825) NROW,(PLOT(N),N=1,NPUSE)
      NROW=NROW-1
750   CONTINUE
C **END ROW LOOP**
C
C STEP E.
C NOW AT END, SO PRINT COL. NUMBERS
C
      WRITE(IPR,815) (IWORK(N),N=1,NCMDR)
C
C CHECK FOR ERRORS
      IF (IER.EQ.0) GO TO 999
      WRITE(IPR,835) IER
      CALL ERROR
C DONE
999   RETURN
C
C................FORMATS................................................
C
805   FORMAT(1H0,21H *** ENTER XMDRPL ***)
C
815   FORMAT(// 4X,42I3)
C
825   FORMAT(// 1X,I3,129A1 )
C
835   FORMAT(1HO,10X,9H**ERROR**,I3,29H ERRORS OCCURED IN INTEGER TO,
     $ 29H CHARACTER CONVERSION OF MDR.)
C
891   FORMAT(1H0,13HSTBDY ARRAY :)
893   FORMAT(1X,132A1)
C.......................................................................
C
      END
