create or replace function get_age_years (pd_dt_nasc in date, 
										  pd_dt_compare in date default sysdate) 
return integer 
is
	li_age	integer;
begin
	if pd_dt_nasc is null or pd_dt_nasc > sysdate 
	then 
		return -1; 
	end if;
	
	li_age := trunc(months_between(pd_dt_compare, pd_dt_nasc)/12);
	
	return li_age;

exception
	when others 
	then
		raise;
end get_age_years;