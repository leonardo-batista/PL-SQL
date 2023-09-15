/*
    REPORT / RAPPORT :  Overview some information about stores.
                        Aperçu sur les magasins.
                        
    SUBJECT / SUJET :   Simulation for report creation.
                        Simulation de création de rapport.
    
    Key Words / Mots Clés :  Temporaty Table, Execute Immediate, Statistic (basic)
                            , COUNT, SUM, AVG, MEDIAN, STATS_MODE
                            , Cursor, Handling Exception. 
*/

DECLARE

v_name_table_temp       VARCHAR2(30);
v_store_id              INTEGER;
v_store_name            VARCHAR(50);
v_total_lines           INTEGER;
v_total_item            INTEGER;
v_mean_rating           NUMBER;
v_median_rating         NUMBER;
v_mode_rating           INTEGER;
v_total_price           NUMBER;
v_table_does_not_exist  EXCEPTION;

PRAGMA EXCEPTION_INIT(v_table_does_not_exist, -942);

CURSOR cur_stores IS
    SELECT 
        store_id
        , TRIM(store_name) store_name
    FROM CO.STORES
    ORDER BY store_id;

BEGIN
    DBMS_OUTPUT.ENABLE(20000);
    DBMS_OUTPUT.PUT_LINE('PL-SQL started...');
    v_name_table_temp := 'STATISTIC_TEMP';
    
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE ' || v_name_table_temp;
    
        EXCEPTION
            WHEN v_table_does_not_exist THEN
                DBMS_OUTPUT.PUT_LINE(SQLERRM);
                DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(SQLCODE ||' -ERROR- '|| SQLERRM);
                DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
                RAISE_APPLICATION_ERROR(-20000, 'Exectution was aborted...');
    END;
 
    EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE '|| v_name_table_temp 
        || '(store_id       INTEGER '
        || ', store_name    VARCHAR(50) '
        || ', total_lines   INTEGER '        
        || ', total_item    INTEGER '
        || ', mean_rating   NUMBER '
        || ', median_rating NUMBER '
        || ', mode_rating   INTEGER '   
        || ', total_price   NUMBER '          
        || ') '
        || ' ON COMMIT DELETE ROWS';

    DBMS_OUTPUT.PUT_LINE('Table ' || v_name_table_temp || ' was created'); 
    
    OPEN cur_stores;
        LOOP
            FETCH cur_stores INTO v_store_id, v_store_name;
                EXIT WHEN cur_stores%NOTFOUND;
                BEGIN
                    SELECT
                        COUNT(ori.quantity) total_lines
                        , SUM(ori.quantity) total_item
                        , AVG(ori.quantity) mean_rating
                        , MEDIAN(ori.quantity) median_rating
                        , STATS_MODE(quantity) mode_
                        , SUM(ori.quantity * ori.unit_price) total_price
                        INTO v_total_lines, v_total_item, v_mean_rating, v_median_rating, v_mode_rating, v_total_price
                    FROM co.orders ord
                        INNER JOIN co.order_items ori
                            ON (ord.order_id = ori.order_id)
                        INNER JOIN co.stores sto
                            ON (ord.store_id = sto.store_id)
                    WHERE ord.order_status = 'COMPLETE' 
                        AND sto.store_id = v_store_id;
                
                    EXECUTE IMMEDIATE 'INSERT INTO ' || v_name_table_temp || ' VALUES (:1, :2, :3, :4, :5, :6, :7, :8) ' 
                        USING v_store_id, v_store_name, v_total_lines, v_total_item, v_mean_rating, v_median_rating, v_mode_rating, v_total_price;                    
                END;
        END LOOP;
    CLOSE cur_stores;
    
    DBMS_OUTPUT.PUT_LINE('PL-SQL finished...'); 
END;
/

SELECT * FROM STATISTIC_TEMP;
