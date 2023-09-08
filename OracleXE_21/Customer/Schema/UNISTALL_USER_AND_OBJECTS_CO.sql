
DECLARE
   user_does_not_exist EXCEPTION;
   pragma exception_init(user_does_not_exist, -1918);
BEGIN
   EXECUTE IMMEDIATE 'DROP USER CO CASCADE';
   -- The next line will only be reached if the CO schema already exists.
   -- Otherwise the statement above will trigger an exception.
   DBMS_OUTPUT.PUT_LINE('CO schema has been dropped.');
EXCEPTION
   WHEN user_does_not_exist THEN
      -- Ignore error as the user to be dropped does not exist anyway
      DBMS_OUTPUT.PUT_LINE('CO schema does not exist, no actions performed.');
END;
