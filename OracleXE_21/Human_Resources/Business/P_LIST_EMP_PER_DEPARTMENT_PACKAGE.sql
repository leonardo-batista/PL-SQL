CREATE OR REPLACE PACKAGE P_LIST_EMP_PER_DEPARTMENT_PACKAGE AS

    TYPE listEmpDepartRecord IS RECORD(
        last_name       VARCHAR2(25), 
        first_name      VARCHAR2(20), 
        phone_number    VARCHAR2(20), 
        hire_date       VARCHAR2(10)
    );

    TYPE listEmpDepartTable IS TABLE OF listEmpDepartRecord;

    FUNCTION F_LIST_EMP(p_DepartmentID NUMBER)
        RETURN listEmpDepartTable
        PIPELINED;
END;

CREATE OR REPLACE PACKAGE BODY P_LIST_EMP_PER_DEPARTMENT_PACKAGE AS

    FUNCTION F_LIST_EMP(p_DepartmentID NUMBER)
        RETURN listEmpDepartTable
        PIPELINED IS

    BEGIN
        FOR r_row IN (
                        SELECT
                            last_name
                            , first_name
                            , phone_number
                            , TO_CHAR(hire_date,'YYYY-MM-DD') AS hire_date
                        FROM HR.employees 
                        WHERE department_id = p_DepartmentID
                        ORDER BY hire_date DESC
        )

        LOOP
             PIPE ROW(listEmpDepartRecord
                        (r_row.last_name
                            , r_row.first_name
                            , r_row.phone_number
                            , r_row.hire_date
                        ));
        END LOOP;  

        RETURN;
    END F_LIST_EMP;
END;

