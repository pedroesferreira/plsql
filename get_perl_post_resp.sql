/**
*	function that receives an URL to a Perl script and a Content-Type
*	example of an URL: https://url.com/path_to_perl/get_soap_resp_oracle_table.pl?table_id=321
*	returns a CLOB with the response from a HTTP POST made through a Perl script
*
*	uses Perl to get the Request Body saved on a table to make the POST and return the response
*	check "get_soap_resp_oracle_table.pl" for an example
**/
create or replace function get_perl_response (pv_url      in varchar2,
											  pv_ct_val   in varchar2 default null)
return clob
is
	lc_msg_resp         clob;
	
	lh_http_req         utl_http.req;
	lh_http_resp        utl_http.resp;
	lv_url              varchar2(2048) := ''; 
	lv_ct_val           varchar2(100);
	lv_text             varchar2(32767); 
	ln_ms_aux           number;
begin
	
	lh_http_req := utl_http.begin_request(url => pv_url);
	
	lv_ct_val := nvl(pv_ct_val, 'application/json');

	utl_http.set_header(r       => lh_http_req,
						name    => 'content-type',
						value   => lv_ct_val||'; charset=utf8');

	lh_http_resp := utl_http.get_response(r => lh_http_req, 
										  return_info_response  => false);
	
	dbms_lob.createtemporary(lc_msg_resp, false);
	
	begin
		loop
			utl_http.read_text(lh_http_resp, lv_text, 32767);
			dbms_lob.writeappend (lc_msg_resp, length(lv_text), lv_text);
		end loop;
	exception
		when utl_http.end_of_body 
		then
			utl_http.end_response(lh_http_resp);
	end;
	
	return lc_msg_resp;
	
end get_perl_response;