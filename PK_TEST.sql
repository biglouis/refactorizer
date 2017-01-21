CREATE OR REPLACE PACKAGE PK_TEST AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 

END PK_TEST;
/


CREATE OR REPLACE package body pk_test
is
procedure pr_test
is
nNummer NUMBER;
begin
nNummer := 0;
for i in 1..10 LOOP
nNummer := nNummer +1;
end looP;
dbms_output.put_line(nNummer);
end pr_test;
end pk_test;
/
