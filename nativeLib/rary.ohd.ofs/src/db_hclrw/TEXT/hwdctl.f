C MEMBER HWDCTL
C  (from old member HCLIO1)
C-----------------------------------------------------------------------
C
C                             LAST UPDATE: 09/07/94.11:46:02 BY $WC20SV
C
C @PROCESS LVL(77)
C
      SUBROUTINE HWDCTL (ISTAT)
C
C          ROUTINE:  HWDCTL
C
C             VERSION:  1.0.0
C
C                DATE: 8-7-81
C
C              AUTHOR:  JIM ERLANDSON
C                       DATA SCIENCES INC
C
C***********************************************************************
C
C          DESCRIPTION:
C
C    ROUTINE TO WRITE THE CONTENTS OF COMMON HCNTRL TO THE FIRST
C    RECORDS OF THE HCL DEFINITION FILES
C
C***********************************************************************
C
C          ARGUMENT LIST:
C
C         NAME    TYPE  I/O   DIM   DESCRIPTION
C
C
C       ISTAT       I    O     1      STATUS INDICATOR
C                                      0=NORMAL
C                                      OTHER=READ ERROR
C
C***********************************************************************
C
C          COMMON:
C
      INCLUDE 'uio'
      INCLUDE 'udebug'
      INCLUDE 'hclcommon/hcntrl'
      INCLUDE 'hclcommon/hunits'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/db_hclrw/RCS/hwdctl.f,v $
     . $',                                                             '
     .$Id: hwdctl.f,v 1.1 1995/09/17 18:43:16 dws Exp $
     . $' /
C    ===================================================================
C
C
C***********************************************************************
C
C
      IUNIT=KDEFNL
      CALL UWRITT (IUNIT,1,HCNTL,ISTAT)
      IF (ISTAT.NE.0) GO TO 10
C
      IUNIT=KDEFNG
      CALL UWRITT (IUNIT,1,HCNTL(1,2),ISTAT)
      IF (ISTAT.NE.0) GO TO 10
      GO TO 30
C
10    WRITE (LP,20) IUNIT
20    FORMAT ('0**ERROR** IN HWDCTL - WRITING TO UNIT ',I3,'.')
      CALL ERROR
C
30    IF (IHCLTR.EQ.2) WRITE (IOGDB,40) ISTAT
40    FORMAT (' EXIT HWDCTL - ISTAT=',I2)
C
      RETURN
C
      END
