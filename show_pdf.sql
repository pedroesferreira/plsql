/**
*	procedure that receives a table ID
*	when called by URL, presents the Base64 CLOB content on the screen
*	
*	uses the "decode_base64" function
*	useful for showing saved PDF files on screen
**/
create or replace procedure show_pdf (pv_id in varchar2)
is
    lb_lob 		blob;
    ln_amt 		number default 30;
    ln_off 		number default 1;
    lr_raw 		raw(4096);
    lc_base64	clob;
begin

	select	pdf_content_base64
	into   	lc_base64
	from   	table_with_pdf
	where  	id = pv_id;

	lb_lob := decode_base64(lc_base64);

	owa_util.mime_header('application/pdf');
	htp.p('Content-Disposition: attachment; filename="file' || pv_id || '.pdf"');
	owa_util.http_header_close;   

	begin
		loop
			dbms_lob.read(lb_lob, ln_amt, ln_off, lr_raw);
			-- it is vital to use htp.PRN to avoid spurious line feeds getting added to the document
			htp.prn(utl_raw.cast_to_varchar2(lr_raw));
			ln_off := ln_off + ln_amt;
			ln_amt := 4096;
		end loop;
	exception
		when no_data_found 
		then
			null;
	end;
end show_pdf;
 