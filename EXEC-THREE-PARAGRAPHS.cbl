       IDENTIFICATION DIVISION.
       PROGRAM-ID. EXECTHRE.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-QUEUE-NAME            PIC X(08) VALUE 'MYQUEUE '.
       01  WS-QUEUE-DATA            PIC X(20) VALUE 'SAMPLE DATA'.
       01  WS-QUEUE-LEN             PIC S9(4) COMP VALUE 20.
       01  WS-ITEM-NUM              PIC S9(4) COMP VALUE 1.
       01  WS-STATUS                PIC S9(9) COMP VALUE 0.
       01  WSC-STR-FINAL            PIC X(30) VALUE 'FINAL PROCESSING'.
       01  WS-RETRY-COUNT           PIC S9(4) COMP VALUE 0.
       01  WS-MAX-RETRIES           PIC S9(4) COMP VALUE 3.
       01  WS-PROCESS-FLAG          PIC X(01) VALUE 'N'.
           88  PROCESSING-DONE      VALUE 'Y'.
           88  PROCESSING-PENDING   VALUE 'N'.
       01  WS-ERROR-MSG             PIC X(40) VALUE SPACES.
       01  WS-TIMESTAMP             PIC X(26) VALUE SPACES.

       PROCEDURE DIVISION.
       0-MAIN.

           MOVE 0 TO WS-RETRY-COUNT
           MOVE 'N' TO WS-PROCESS-FLAG

           EXEC CICS ASKTIME
                ABSTIME(WS-TIMESTAMP)
           END-EXEC

           DISPLAY 'START TIME: ' WS-TIMESTAMP

       RETRY-LOOP.
           IF WS-RETRY-COUNT >= WS-MAX-RETRIES
               MOVE 'MAX RETRIES REACHED' TO WS-ERROR-MSG
               DISPLAY WS-ERROR-MSG
               GO TO CLEANUP-SECTION
           END-IF

           ADD 1 TO WS-RETRY-COUNT

           EXEC CICS READQ TS
                QUEUE(WS-QUEUE-NAME)
                INTO(WS-QUEUE-DATA)
                LENGTH(WS-QUEUE-LEN)
                ITEM(WS-ITEM-NUM)
                RESP(WS-STATUS)
           END-EXEC

           IF WS-STATUS NOT EQUAL 0
               MOVE 'READ FAILED - RETRYING' TO WS-ERROR-MSG
               DISPLAY WS-ERROR-MSG
               GO TO RETRY-LOOP
           END-IF

           DISPLAY WSC-STR-FINAL. *> Secondary location would point here
                                      *> but in this case it is quite obvious

           EXEC CICS WRITEQ TS
                QUEUE(WS-QUEUE-NAME)
                FROM(WS-QUEUE-DATA)
                LENGTH(WS-QUEUE-LEN)
                RESP(WS-STATUS)
           END-EXEC

           IF WS-STATUS EQUAL 0
               MOVE 'Y' TO WS-PROCESS-FLAG
           ELSE
               MOVE 'WRITE FAILED' TO WS-ERROR-MSG
               DISPLAY WS-ERROR-MSG
           END-IF

           PERFORM FIRST-PARAGRAPH

       CLEANUP-SECTION.
           IF PROCESSING-DONE
               DISPLAY 'PIPELINE COMPLETED SUCCESSFULLY'
           ELSE
               DISPLAY 'PIPELINE ENDED WITH ERRORS'
           END-IF

           GOBACK.

       FIRST-PARAGRAPH.
           PERFORM SECOND-PARAGRAPH.

       SECOND-PARAGRAPH.
           PERFORM THIRD-PARAGRAPH.

       THIRD-PARAGRAPH.
           DISPLAY WSC-STR-FINAL.  *> Secondary location would point here without
                                      *> showing the 'intermediate' paragraphs
                                      *> which could be a bit confusing

       END PROGRAM EXECTHRE.
