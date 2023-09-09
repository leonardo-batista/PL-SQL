CREATE OR REPLACE TYPE T_TABLE_EMP IS OBJECT
(
    last_name       VARCHAR(25)
    , first_name    VARCHAR(20)
    , phone_number  VARCHAR(20)
    , hire_date     VARCHAR(10)
);

CREATE OR REPLACE TYPE T_TABLE_EMP_COLL IS TABLE OF T_TABLE_EMP;

CREATE OR REPLACE FUNCTION F_LIST_EMP_PER_DEPARTMENT_TABLE(p_DepartmentID NUMBER)
    RETURN T_TABLE_EMP_COLL
IS
    v_res_coll T_TABLE_EMP_COLL;
    v_index NUMBER;
BEGIN
    v_res_coll := T_TABLE_EMP_COLL();
    FOR i IN (SELECT
                    last_name
                    , first_name
                    , phone_number
                    , hire_date
                FROM HR.employees 
                WHERE department_id = p_DepartmentID
                ORDER BY hire_date DESC)
    LOOP
        v_res_coll.extend;
        v_index := v_res_coll.count; 
        v_res_coll(v_index) := T_TABLE_EMP(i.last_name, i.first_name, i.phone_number, TO_CHAR(i.hire_date, 'YYYY-MM-DD'));
    END LOOP;

    RETURN v_res_coll;
END;
/
