       IDENTIFICATION DIVISION.
       PROGRAM-ID. 1brc.
       AUTHOR. Trey Bastian.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT measurements-file ASSIGN TO "./measurements.txt"
           ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD measurements-file.
         01 measurement-line PIC X(106).

       WORKING-STORAGE SECTION.
       01 results-table.
         02 stations OCCURS 10000 TIMES INDEXED BY idx.
           03 name PIC A(100).
           03 min-temp PIC S9(2)V9 VALUE ZEROS.
           03 mean-temp PIC S9(2)V9 VALUE ZEROS.
           03 max-temp PIC S9(2)V9 VALUE ZEROS.
           03 temp-count PIC 9(10) VALUE ZEROS.
           03 total PIC S9(10)V9(2) VALUE ZEROS.

       77 last-idx PIC 9(6) VALUE 1.
       77 station-name PIC A(100).
       77 temperature PIC S9(2)V9 VALUE ZEROS.
       77 temp-str PIC -(2)9.9 VALUE ZEROS.
       01 pic x.
             88 eof VALUE "Y".
             88 eof-n VALUE "N".

       PROCEDURE DIVISION.
           OPEN INPUT measurements-file.
           SET eof-n TO TRUE.
           PERFORM UNTIL eof
             READ measurements-file AT END
                 SET eof TO TRUE
             NOT AT END
               UNSTRING measurement-line DELIMITED BY ";"
                 INTO station-name, temperature
               END-UNSTRING
              MOVE 1 to idx
              SEARCH stations
                AT END
                  MOVE station-name TO name(last-idx)
                  MOVE temperature TO min-temp(last-idx)
                  MOVE temperature TO mean-temp(last-idx)
                  MOVE temperature TO max-temp(last-idx)
                  MOVE temperature TO total(last-idx)
                  ADD 1 TO temp-count(last-idx)
                  ADD 1 TO last-idx
                WHEN name(idx) = station-name
                  ADD 1 TO temp-count(idx)
                  IF min-temp(idx) > temperature THEN
                    MOVE temperature TO min-temp(idx)
                  END-IF
                  IF max-temp(idx) < temperature THEN
                   MOVE temperature TO max-temp(idx)
                  END-IF
                  ADD temperature TO total(idx)
                  COMPUTE mean-temp(idx) ROUNDED = total(idx) /
                  temp-count(idx)
               END-SEARCH

             END-READ
           END-PERFORM.
           CLOSE measurements-file.

           SORT stations ASCENDING name.
           PERFORM VARYING idx FROM 1 BY 1 UNTIL idx = 10001
             IF name(idx) NOT EQUAL SPACES THEN
               DISPLAY FUNCTION TRIM(name(idx) TRAILING)
                 WITH NO ADVANCING
               DISPLAY ";" WITH NO ADVANCING
               MOVE min-temp(idx) TO temp-str
               DISPLAY FUNCTION TRIM(temp-str LEADING)
                 WITH NO ADVANCING
               DISPLAY ";" WITH NO ADVANCING
               MOVE mean-temp(idx) TO temp-str
               DISPLAY FUNCTION TRIM(temp-str LEADING)
                 WITH NO ADVANCING
               DISPLAY ";" WITH NO ADVANCING
               MOVE max-temp(idx) TO temp-str
               DISPLAY FUNCTION TRIM(temp-str LEADING)
             END-IF
           END-PERFORM.

       STOP-RUN.







