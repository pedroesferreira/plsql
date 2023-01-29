create or replace procedure encode_base64 (pb_blob in blob, 
										   pc_clob in out nocopy clob)
is
    li_step					pls_integer := 22500; 
    lv_converted			varchar2(32767);

    li_buffer_size_approx	pls_integer := 1048576;
    lc_buffer				clob;
begin
    dbms_lob.createtemporary(lc_buffer, true, dbms_lob.call);

    for i in 0 .. trunc((dbms_lob.getlength(pb_blob) - 1 )/li_step) 
    loop
        lv_converted := utl_raw.cast_to_varchar2(utl_encode.base64_encode(dbms_lob.substr(pb_blob, li_step, i * li_step + 1)));
        dbms_lob.writeappend(lc_buffer, length(lv_converted), lv_converted);

        if dbms_lob.getlength(lc_buffer) >= li_buffer_size_approx 
        then
            dbms_lob.append(pc_clob, lc_buffer);
            dbms_lob.trim(lc_buffer, 0);
        end if;
    end loop;

    pc_clob := pc_clob || lc_buffer;

    dbms_lob.freetemporary(lc_buffer);
end encode_base64;
 