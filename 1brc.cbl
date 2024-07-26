       IDENTIFICATION DIVISION.
       PROGRAM-ID. 1brc.
       AUTHOR. Trey Bastian.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT measurements-file ASSIGN TO "./measurements.txt"
           ORGANIZATION IS LINE SEQUENTIAL.
       SELECT sorted-measurements ASSIGN TO OUTPUT1.
       SELECT workfile ASSIGN TO WORK1.
       DATA DIVISION.
       FILE SECTION.
       FD measurements-file.
       01 measurement.
           02 line-item PIC X(106).
       FD sorted-measurements.
       01 measurement.
           02 line-item PIC X(106).
       SD workfile.
       01 measurement.
           02 line-item PIC X(106).

       WORKING-STORAGE section.
       01 pic x.
             88 eof VALUE "Y".
             88 eof-n VALUE "N".

       01 pic x.
             88 is-first VALUE "Y".
             88 not-first VALUE "N".

       77 s-name PIC X(100).
       77 temp PIC S9(2)V9.

       77 station-name PIC X(100).
       77 min-temp PIC S9(2)V9 VALUE ZEROS.
       77 max-temp PIC S9(2)V9 VALUE ZEROS.
       77 total PIC S9(11)V9(2) VALUE ZEROS.
       77 cnt PIC S9(11) VALUE ZEROS.

       77 temp-str PIC -(2)9.9 VALUE ZEROS.
       77 mean-calc PIC S9(2)V9 VALUE ZEROS.


       PROCEDURE DIVISION.
           SET is-first TO TRUE.
           OPEN INPUT measurements-file.
           SORT workfile ON ASCENDING line-item OF workfile
           USING measurements-file
           GIVING sorted-measurements

           OPEN INPUT sorted-measurements.
           SET eof-n TO TRUE.
           PERFORM UNTIL eof
             READ sorted-measurements AT END
                 SET eof TO TRUE
             NOT AT END

               UNSTRING line-item of sorted-measurements DELIMITED BY
               ";" INTO s-name, temp
               END-UNSTRING

               IF s-name = station-name THEN
                 IF min-temp > temp THEN
                   MOVE temp to min-temp
                  END-IF
                  IF max-temp < temp THEN
                    MOVE temp to max-temp
                  END-IF
                  ADD temp TO total
                  ADD 1 TO cnt
               ELSE
                 IF not-first THEN
                 PERFORM display-procedure
                 END-IF
                 MOVE s-name TO station-name
                 MOVE temp TO min-temp
                 MOVE temp TO max-temp
                 MOVE temp to total
                 MOVE 1 to cnt
                 IF is-first THEN
                   SET not-first TO TRUE
                 END-IF
               END-IF
             END-READ
           END-PERFORM.
           ClOSE sorted-measurements.
       STOP-RUN.

       display-procedure.
           DISPLAY FUNCTION TRIM(station-name TRAILING)
                WITH NO ADVANCING
              DISPLAY ";" WITH NO ADVANCING
              MOVE min-temp TO temp-str
              DISPLAY FUNCTION TRIM(temp-str LEADING)
                WITH NO ADVANCING
              DISPLAY ";" WITH NO ADVANCING
              COMPUTE mean-calc ROUNDED = total / cnt
              MOVE mean-calc TO temp-str
              DISPLAY FUNCTION TRIM(temp-str LEADING)
                WITH NO ADVANCING
              DISPLAY ";" WITH NO ADVANCING
              MOVE max-temp TO temp-str
              DISPLAY FUNCTION TRIM(temp-str LEADING).




