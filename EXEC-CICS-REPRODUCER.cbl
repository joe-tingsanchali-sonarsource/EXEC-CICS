       IDENTIFICATION DIVISION.
       PROGRAM-ID. EXECREPR.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-QUEUE-NAME            PIC X(08) VALUE 'MYQUEUE '.
       01  WS-QUEUE-DATA            PIC X(20) VALUE 'SAMPLE DATA'.
       01  WS-QUEUE-LEN             PIC S9(4) COMP VALUE 20.
       01  WS-ITEM-NUM              PIC S9(4) COMP VALUE 1.
       01  WS-STATUS                PIC S9(9) COMP VALUE 0.
       01  WSC-STR-FINAL            PIC X(30) VALUE 'FINAL PROCESSING'.

       PROCEDURE DIVISION.
       0-MAIN.
      *    First EXEC CICS - WRITEQ TS
           EXEC CICS WRITEQ TS
                QUEUE(WS-QUEUE-NAME)
                FROM(WS-QUEUE-DATA)
                LENGTH(WS-QUEUE-LEN)
                RESP(WS-STATUS)
           END-EXEC
           PERFORM 3-FINAL

      *    Second EXEC CICS - READQ TS
           EXEC CICS READQ TS
                QUEUE(WS-QUEUE-NAME)
                INTO(WS-QUEUE-DATA)
                LENGTH(WS-QUEUE-LEN)
                ITEM(WS-ITEM-NUM)
                RESP(WS-STATUS)
           END-EXEC
           PERFORM 3-FINAL

      *    Third EXEC CICS - DELETEQ TS
           EXEC CICS DELETEQ TS
                QUEUE(WS-QUEUE-NAME)
                RESP(WS-STATUS)
           END-EXEC
           PERFORM 3-FINAL

           GOBACK.

       3-FINAL.
           DISPLAY WSC-STR-FINAL.

       END PROGRAM EXECREPR.
