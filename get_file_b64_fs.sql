/**
*	function that receives a table (that holds BLOB content) ID and a filename
*	returns the file with the same filename from an existing path/folder in the ALL_DIRECTORIES table
*
*	the returned file is encoded in a Base64 CLOB without line breaks
*	useful for sending a file in a directory through an HTTP POST
**/
create or replace function get_file_b64_fs (pv_id in varchar2,
                                            pv_filename in varchar2)
return clob
is

    f_lob       			bfile;
    b_lob       			blob;
    c_lob       			clob;
    li_isopen   			integer;
    lv_home_dir 			varchar2(100);
    l_step                  pls_integer := 22500; 
    l_converted             varchar2(32767);
    l_buffer_size_approx	pls_integer := 1048576;
    l_buffer				clob;
    io_clob					clob;
begin

    lv_home_dir := '/path/to/file/' || pv_filename;

    -- "For the successful completion of DBMS_LOB subprograms, you must provide an input locator that represents a LOB that already exists in the database tablespaces or external file system"
    update table_with_content
    set content_col = empty_blob()
    where id = pv_id
    returning content_col into b_lob;

    f_lob := bfilename('USER_DIR', lv_home_dir);
    dbms_lob.fileopen(f_lob, dbms_lob.file_readonly);
    dbms_lob.loadfromfile(b_lob, f_lob, dbms_lob.getlength(f_lob));

    dbms_lob.createtemporary(l_buffer, true, dbms_lob.call);
    dbms_lob.createtemporary(io_clob, true, dbms_lob.call);

    for i in 0 .. trunc((dbms_lob.getlength(f_lob) - 1 )/l_step) 
    loop
        l_converted := utl_raw.cast_to_varchar2(utl_encode.base64_encode(dbms_lob.substr(f_lob, l_step, i * l_step + 1)));
        dbms_lob.writeappend(l_buffer, length(l_converted), l_converted);

        if dbms_lob.getlength(l_buffer) >= l_buffer_size_approx 
        then
            dbms_lob.append(io_clob, l_buffer);
            dbms_lob.trim(l_buffer, 0);
        end if;
    end loop;

    c_lob := io_clob || l_buffer;

    dbms_lob.fileclose(f_lob);

    dbms_lob.freetemporary(l_buffer);

    return replace(replace(c_lob, CHR(10)), CHR(13));
exception
    when others
    then
        li_isopen := dbms_lob.isopen(f_lob);

        if li_isopen = 1
        then
            dbms_lob.fileclose(f_lob);
        end if;

        return sqlerrm||chr(10)||dbms_utility.format_error_backtrace;
end get_file_b64_fs;