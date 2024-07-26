       IDENTIFICATION DIVISION.
       PROGRAM-ID. 1brc.
       AUTHOR. Trey Bastian.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT measurements-file ASSIGN TO "./measurements.txt"
           ORGANIZATION IS RECORD SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD measurements-file.
         01 measurement-chunk PIC X(10700000).

       WORKING-STORAGE SECTION.
       01 results-table.
         02 stations OCCURS 10000 TIMES INDEXED BY idx.
           03 name PIC X(100).
           03 min-temp PIC S9(2)V9 VALUE ZEROS.
           03 max-temp PIC S9(2)V9 VALUE ZEROS.
           03 temp-count PIC 9(10) VALUE ZEROS.
           03 total PIC S9(10)V9(2) VALUE ZEROS.

       01 measurement-lines OCCURS 1000000 TIMES.
         02 line-item PIC X(106).

       01 working-measurements.
         02 name PIC X(100).
         02 min-temp PIC S9(2)V9 VALUE ZEROS.
         02 max-temp PIC S9(2)V9 VALUE ZEROS.
         02 temp-count PIC 9(10) VALUE ZEROS.
         02 total PIC S9(10)V9(2) VALUE ZEROS.

       77 last-idx PIC 9(6) VALUE 1.
       77 line-index PIC 9(7) VALUE 1.
       77 line-value PIC X(106).
       77 line-ptr PIC 9(10).
       77 station-name PIC X(100).
       77 temperature PIC S9(2)V9 VALUE ZEROS.
       77 temp-str PIC -(2)9.9 VALUE ZEROS.
       77 mean-calc PIC S9(2)V9 VALUE ZEROS.
       77 line-count PIC 9(10) VALUE 0.
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
               MOVE 1 TO line-ptr
               MOVE SPACE TO line-value
               MOVE 1 TO line-index
               MOVE 0 TO line-count
               PERFORM VARYING line-index FROM 1 BY 1
                 UNTIL line-index = 1000001
                   MOVE SPACE to measurement-lines(line-index)
               END-PERFORM
               MOVE 1 to line-index
               INSPECT measurement-chunk TALLYING line-count
               FOR ALL X'0A'
               PERFORM line-count TIMES
                 UNSTRING measurement-chunk DELIMITED BY X'0A'
                 INTO line-value WITH POINTER line-ptr
                 ON OVERFLOW
                   MOVE line-value to line-item(line-index)
                   ADD 1 to line-index
                 END-UNSTRING
               END-PERFORM
               PERFORM VARYING line-index FROM 1 BY 1
                 UNTIL line-index = 1000001
                   UNSTRING line-item(line-index) DELIMITED BY ";"
                     INTO station-name, temperature
                   END-UNSTRING
                   IF name OF working-measurements = station-name THEN
                     ADD temperature TO total OF working-measurements
                     ADD 1 TO temp-count OF working-measurements
                     IF min-temp OF working-measurements > temperature
                     THEN
                       MOVE temperature TO min-temp OF
                       working-measurements
                     END-If
                     IF max-temp OF working-measurements < temperature
                     THEN
                       MOVE temperature TO max-temp OF
                       working-measurements
                     END-IF
                   ELSE
                     IF name OF working-measurements NOT = SPACE THEN
                          SEARCH stations
                           AT END
                             MOVE name OF working-measurements TO name
                             OF stations(last-idx)
                             MOVE min-temp OF working-measurements TO
                             min-temp OF stations(last-idx)
                             MOVE max-temp OF working-measurements TO
                             max-temp OF stations(last-idx)
                             MOVE total of working-measurements TO total
                             OF stations(last-idx)
                             MOVE temp-count OF working-measurements TO
                             temp-count OF stations(last-idx)
                             ADD 1 to last-idx
                           WHEN name OF stations(idx) = name OF
                             working-measurements
                             IF min-temp OF stations(idx) > min-temp OF
                               working-measurements THEN
                               MOVE min-temp OF working-measurements TO
                               min-temp OF stations(idx)
                             END-IF
                             IF max-temp OF stations(idx) < max-temp OF
                               working-measurements THEN
                               MOVE max-temp OF working-measurements TO
                               max-temp OF stations(idx)
                             END-IF
                             ADD temp-count OF working-measurements TO
                             temp-count OF stations(idx)
                             ADD total OF working-measurements TO total
                             OF stations(idx)
                          END-SEARCH
                          MOVE 1 to idx
                     END-IF
                     MOVE station-name TO name OF working-measurements
                     MOVE temperature TO min-temp OF
                     working-measurements
                     MOVE temperature TO max-temp OF
                     working-measurements
                     MOVE temperature TO total OF working-measurements
                     MOVE 1 TO temp-count OF working-measurements
                   END-IF
               END-PERFORM
            END-READ
            END-PERFORM.
           CLOSE measurements-file.

           SORT stations ASCENDING name OF stations.
           PERFORM VARYING idx FROM 1 BY 1 UNTIL idx = 10001
            IF name OF stations(IDX) NOT EQUAL SPACES THEN
              DISPLAY FUNCTION TRIM(name OF stations(idx) TRAILING)
                WITH NO ADVANCING
              DISPLAY ";" WITH NO ADVANCING
              MOVE min-temp OF stations(idx)TO temp-str
              DISPLAY FUNCTION TRIM(temp-str LEADING)
                WITH NO ADVANCING
              DISPLAY ";" WITH NO ADVANCING
              COMPUTE mean-calc ROUNDED = total OF stations(idx) /
                 temp-count OF stations(idx)
              MOVE mean-calc TO temp-str
              DISPLAY FUNCTION TRIM(temp-str LEADING)
                WITH NO ADVANCING
              DISPLAY ";" WITH NO ADVANCING
              MOVE max-temp OF stations(idx) TO temp-str
              DISPLAY FUNCTION TRIM(temp-str LEADING)
            END-IF
           END-PERFORM.
       STOP-RUN.







