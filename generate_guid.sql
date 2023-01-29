/**
*	function that receives no parameters
*	returns an UUID
*	
*	uses the available Oracle SYS_GUID function and transforms it
*	useful for generating accepted UUID values
**/
create or replace function generate_guid
return varchar2
is
	cursor c_guid
	is
		select	substr(guid,1,8)||'-'||
				substr(guid,9,4)||'-'||
				substr(guid,13,4)||'-'||
				substr(guid,17,4)||'-'||
				substr(guid,20)
		from 	(select sys_guid() guid from dual);
		
	lv_guid	varchar2(37);
begin
	
	open c_guid;
    fetch c_guid into lv_guid;
    close c_guid;
	
	return lv_guid;
	
end generate_guid;