/**
*	function that receives a Base64 encoded CLOB and returns a decoded BLOB
*	useful for PDF files or encoded data returned from a webservice 
**/
create or replace function decode_base64 (pc_clob in clob) 
return blob 
is
    lb_blob             blob;
    lb_result           blob;
    li_offset           integer;
    li_buffer_size      binary_integer := 48;
    lv_buffer_varchar	varchar2(48);
    lr_buffer_raw       raw(48);
begin
	if pc_clob is null 
	then
		return null;
    end if;

    dbms_lob.createtemporary(lb_blob, true);

    li_offset := 1;

    for i in 1 .. ceil(dbms_lob.getlength(pc_clob) / li_buffer_size) 
	loop
		dbms_lob.read(pc_clob, li_buffer_size, li_offset, lv_buffer_varchar);
		lr_buffer_raw := utl_raw.cast_to_raw(lv_buffer_varchar);
		lr_buffer_raw := utl_encode.base64_decode(lr_buffer_raw);
		dbms_lob.writeappend(lb_blob, utl_raw.length(lr_buffer_raw), lr_buffer_raw);
		li_offset := li_offset + li_buffer_size;
    end loop;

    lb_result := lb_blob;
    dbms_lob.freetemporary(lb_blob);

    return lb_result;

end decode_base64;

 
 