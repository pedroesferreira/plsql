/*
//load this java class into database

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.security.AccessControlException;
import java.sql.*;
import oracle.jdbc.*;

public class create_custom_dir {
  
	public static String create_user_dir(String path_, String username_) {
		String path = new String(path_+"/users/"+username_);
		File directory = new File(path);
	
		if (directory.exists()) {
			return "EXISTS";
		}
    
		if (directory.mkdirs()) {
			return "OK";
		} else {
			return "NO";
		}

	}

}
*/

create or replace function create_custom_user_dir (pv_path in varchar2, 
												   pv_username in varchar2) 
return varchar2 
is
LANGUAGE JAVA
NAME 'create_custom_dir.create_user_dir(java.lang.String, java.lang.String) return java.lang.String';


