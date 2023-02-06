/**
*	function that receives a XML CLOB and a field to extract the vaule of
*	
*	Useful for parsing through a previously known XML structure (like a SOAP response) and getting a value
*	Could be refactored into obtaining more values and returning a record type
*
**/
create or replace function function parse_xml (pc_clob 	in clob,
											   pv_field	in varchar2)
return varchar2
is
	lc_msg          clob;
    lx_msg          xmltype;
	lx_res          xmltype;
	ln_num_result   number := 0;
	lv_value		varchar2(256);
begin
	
	lc_msg := replace(pc_clob, '&#65533;', '');

	lx_msg := xmltype(lc_msg);
	
	-- extracts the value even if it belongs in an array
	select	count(*)
	into 	ln_num_result
	from 	table(xmlsequence(extract(lx_msg,
									'/soapenv:Envelope/env:Body/Response/ns1:path/ns1:to/ns1:target/ns2:'||pv_field,
									'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
									 xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
									 xmlns="http://xmlns/test/something"
									 xmlns:ns1="http://xmlns/ns/one"
									 xmlns:ns2="http://xmlns/ns/two"')));
									 
	if ln_num_result > 0
	then
		for rec in 1 .. ln_num_result
		loop
			-- extract field that has the value
			select	extract(lx_msg,
						   '/soapenv:Envelope/env:Body/Response/ns1:path/ns1:to/ns1:target['||rec||']',
						   'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
							xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
							xmlns="http://xmlns/test/something"
							xmlns:ns1="http://xmlns/ns/one"')
			into 	lx_res
			from 	dual;
			
			-- extract values
			select 	extractvalue(lx_res,
								'/ns1:target/ns2:'||pv_field,
								'xmlns:ns1="http://xmlns/ns/one"
								 xmlns:ns2="http://xmlns/ns/two"')
			into 	lv_value
			from 	dual;
		end loop;
	else
		lv_value := null;
	end if;
	
	return lv_value;
	
end parse_xml;