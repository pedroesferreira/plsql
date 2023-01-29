create or replace function get_soap_resp (pv_url in varchar2) 
return xmltype 
is
    lv_req       	varchar2(32767);
	lv_resp			varchar2(32767);
    http_req  		utl_http.req;
    http_resp 		utl_http.resp;
    lx_return_xml	xmltype;
begin
    lv_req := generate_req_xml();

    UTL_HTTP.SET_WALLET('file:' || '/path/to/wallet', 'wallet_password');
    http_req := utl_http.begin_request(pv_url, 'POST', 'HTTP/1.1');
  
    utl_http.set_header(http_req,
                        'Content-Type',
                        'text/xml; charset=utf-8');
    utl_http.set_header(http_req, 'Content-Type', 'text/xml');
    utl_http.set_header(http_req, 'Content-Length', length(lv_req));
    
    utl_http.write_text(http_req, convert(lv_req, 'US7ASCII'));
  
    http_resp := utl_http.get_response(http_req);
    utl_http.read_text(http_resp, lv_resp);
    utl_http.end_response(http_resp);
    
    lx_return_xml := xmltype.createxml(lv_resp);

    return lx_return_xml;
end get_soap_resp;