use finance_project;
select * from finance_1;
select * from finance_2;

# Year wise Loan Amount Stats
select year(issue_d) as Year, sum(loan_amnt) as Sum_of_loan_amount, round((loan_amnt),2) as Avg_of_loan_amount, count(loan_amnt) as Count_of_loan_amount, min(loan_amnt) as Min_loan_amount, max(loan_amnt) as Max_loan_amount
from finance_1
group by year(issue_d)
order by year(issue_d) asc;


# Grade and Sub Grade wise revol_util

select grade, sub_grade, revol_bal	
			from finance_1
            left join finance_2
            on finance_1.id = finance_2.id
            group by grade, sub_grade
            order by grade, sub_grade;
            
            
# Total Payment for verified status and Non verified status
    
    with cte as (with e as  (SELECT 
    finance_1.verification_status AS status,
    round(sum(finance_2.total_pymnt),2) AS total_payment
FROM 
    finance_1
    JOIN finance_2 ON finance_2.id = finance_1.id
    -- where finance_1.verification_status in ('verified', 'not verified')
GROUP BY status) SELECT status, total_payment, 
round(total_payment * 100 / (SELECT SUM(total_payment) AS s FROM e)) AS `percent_of_total`
FROM e) select status, total_Payment, concat(percent_of_total,'%') as percentage from cte;

# State wise and last_credit_pull_d wise loan status

select addr_state, last_credit_pull_d, loan_status
		from finance_1 
        JOIN finance_2 ON finance_1.id = finance_2.id
        order by addr_state;
        
        select f1.addr_state, year(f5.last_credit_pull_d) as Last_credit_pull,
count(case when f1.loan_status = 'Charged Off' then f3.Fin2  end) as Charged_Off,
count(case when f1.loan_status = 'Current' then f4.Fin3 end) as Current_1,
count(case when f1.loan_status = 'Fully Paid' then  f2.Fin1  end) as Fully_Paid
from finance_1 f1  join 
(
	select addr_state, count(Loan_status) as Fin1 from finance_1
	where loan_status='Fully Paid'
	group by addr_state
) f2 on f2.addr_state=f1.addr_state
 join
(
	select addr_state, count(Loan_status) as Fin2 from finance_1
	where loan_status='Charged Off'
	group by addr_state
) f3 on f3.addr_state=f1.addr_state
 join
(
	select addr_state, count(Loan_status) as Fin3 from finance_1
	where loan_status='Current'
	group by addr_state
) f4 on f4.addr_state=f1.addr_state

join finance_2 f5 on f5.id=f1.id
group by f1.addr_state, year(f5.last_credit_pull_d)
order by f1.addr_state,year(f5.last_credit_pull_d);              

 # Home ownership Vs last payment date stats

select home_ownership, last_pymnt_d
		from finance_1
        JOIN finance_2 ON finance_1.id = finance_2.id;