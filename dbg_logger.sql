/**
*	Table and procedure used for logging purposes
*	
*	Procedure can be used as "dbg_logger('99', 'description', 'value');"
*	and then accessed as "select * from dbg_log where code = 99 order by ts desc;"
*
**/

create table dbg_log (ts        timestamp(6),  
					  code      varchar2(100), 
                      text      varchar2(200), 
                      val_clob	clob);
/

create or replace procedure dbg_logger (pv_code in varchar2,
                                        pv_text in varchar2,
                                        pv_val_clob in clob default null)
is 
    pragma autonomous_transaction;
begin
    insert into dbg_log (ts, code, text, val_clob)
    values (current_timestamp, pv_code, pv_text, pv_val_clob);

    commit;
end dbg_logger;