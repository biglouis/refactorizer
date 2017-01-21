CREATE OR REPLACE PACKAGE PK_REFACTORIZER AS 

  PROCEDURE pr_x;

END PK_REFACTORIZER;
/


CREATE OR REPLACE PACKAGE BODY PK_REFACTORIZER AS

  TYPE tySource IS TABLE OF VARCHAR2(4000);

  /**
   *
   */
  FUNCTION fk_get_source(i_vcOwner iN VARCHAR2, i_vcPackage IN VARCHAR2)
  RETURN tySource
  IS
    ntSource tySource;
  BEGIN
    SELECT text
    BULK COLLECT INTO ntSource
    FROM all_source
    WHERE owner = i_vcOwner AND name = i_vcPackage AND type = 'PACKAGE BODY' ORDER BY line;
    
    RETURN ntSource;
  END fk_get_source;
  
  /**
   *
   */
  PROCEDURE pr_show(i_ntSource IN tySource)
  IS
  BEGIN
    FOR i IN 1..i_ntSource.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE(i_ntSource(i));
    END LOOP;
  END pr_show;
  
  /**
   *
   */
  PROCEDURE pr_append(io_ntSource IN OUT NOCOPY tySource, i_vcLine IN VARCHAR2)
  IS
  BEGIN
    io_ntSource.EXTEND();
    io_ntSource(io_ntSource.LAST) := i_vcLine;
  END pr_append;
  /**
   *
   */
  PROCEDURE pr_x
  IS
    ntSourceOld tySource;
    ntSourceNew tySource := tySource();

    c_vcProcedure VARCHAR2(30) := 'pr_new';
	  c_nProcedureLFirstLine CONSTANT PLS_INTEGER := 3;
	  c_nProcedureLLastLine CONSTANT PLS_INTEGER := 12;
    c_nExtractFirstLine CONSTANT PLS_INTEGER := 8;
    c_nExtractLastLine CONSTANT PLS_INTEGER := 10;
    
    i PLS_INTEGER := 1;
  BEGIN
    ntSourceOld := fk_get_source(i_vcOwner => 'SYSTEM', i_vcPackage => 'PK_TEST');
    
	  WHILE i <= ntSourceOld.LAST LOOP
	  
	    IF i < c_nProcedureLFirstLine THEN
	      pr_append(ntSourceNew, ntSourceOld(i));
	    ELSIF i = c_nProcedureLFirstLine THEN
	      pr_append(ntSourceNew, 'PROCEDURE '||c_vcProcedure);
	      pr_append(ntSourceNew, 'IS');
	      pr_append(ntSourceNew, 'BEGIN');
	      FOR j IN c_nExtractFirstLine..c_nExtractLastLine LOOP
  	      pr_append(ntSourceNew, ntSourceOld(j));
	      END LOOP;
	      -- OutParameter setzen fehlt hier
	      pr_append(ntSourceNew, 'END '||c_vcProcedure||';');
	      pr_append(ntSourceNew, NULL);
	      -- Jetzt die eigentliche Zeile setzen
	      pr_append(ntSourceNew, ntSourceOld(i));
	    ELSIF i < c_nExtractFirstLine THEN
	      pr_append(ntSourceNew, ntSourceOld(i));
	    ELSIF i = c_nExtractFirstLine THEN
	      pr_append(ntSourceNew, c_vcProcedure);
	      i := c_nExtractLastLine;
	    ELSE
	      pr_append(ntSourceNew, ntSourceOld(i));
	    END IF;
	      
	    i := i+1;
	  END LOOP;

    pr_show(ntSourceNew);
  END pr_x;
  
END PK_REFACTORIZER;
/
