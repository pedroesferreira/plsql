create or replace procedure write_file (pv_filename in varchar2,
										pb_blob in blob) 
is
	l_file			utl_file.file_type;
	ln_lob_size 	number;
	lr_chunk 		raw(32000);
	ln_pass_length	number := 32000;
	ln_position 	number := 1;
	ln_remaining 	number;
begin
	
	l_file := utl_file.fopen('USER_DIR', pv_filename, 'wb', 32000); --CREATE DIRECTORY USER_DIR AS '/path/to/dir';
	ln_lob_size := dbms_lob.getlength(pb_blob);  
	ln_remaining := ln_lob_size;

	while ln_position < ln_lob_size and ln_pass_length > 0 
	loop
		-- read and write chunk to file
		dbms_lob.read(pb_blob, ln_pass_length, ln_position, lr_chunk);
		utl_file.put_raw(l_file, lr_chunk);
		utl_file.fflush(l_file);
		  
		-- advance blob position
		ln_position := ln_position + ln_pass_length;
		  
		-- set chunk size if remaining is less than 32k
		ln_remaining := ln_remaining - ln_pass_length;
		
		if ln_pass_length < 32000 
		then
			ln_pass_length := ln_remaining;
		end if;
	end loop;

	utl_file.fclose(l_file);
  
end write_file;