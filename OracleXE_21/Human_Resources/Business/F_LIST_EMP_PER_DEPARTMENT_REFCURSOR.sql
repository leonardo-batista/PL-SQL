CREATE OR REPLACE FUNCTION F_LIST_EMP_PER_DEPARTMENT_REFCURSOR(p_DepartmentID NUMBER)
    RETURN SYS_REFCURSOR
IS
    v_resultListEmp SYS_REFCURSOR;
BEGIN
    OPEN v_resultListEmp FOR
        SELECT
            last_name
            , first_name
            , phone_number
            , TO_CHAR(hire_date,'YYYY-MM-DD') hire_date
        FROM HR.employees 
        WHERE department_id = p_DepartmentID
        ORDER BY hire_date DESC;

    RETURN v_resultListEmp;
END;
