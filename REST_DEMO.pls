create or replace function rest_demo (v_url  IN  VARCHAR2, v_method IN VARCHAR2 DEFAULT 'GET', v_text varchar2 default null) return clob AS 
  v_http_request UTL_HTTP.req;
  v_http_response UTL_HTTP.resp;
  v_pom varchar2(32767); 
  v_cred varchar2(200);
  v_res clob;
BEGIN
  v_cred:=substr(v_url,9,instr(v_url,':',9)-9);
  UTL_HTTP.set_wallet('file:/acfs01/wallet/'||v_cred);
  dbms_lob.createtemporary(v_res,true);
  v_http_request := utl_http.begin_request(v_url, v_method,' HTTP/1.1');
  UTL_HTTP.SET_AUTHENTICATION_FROM_WALLET(v_http_request, v_cred);
  utl_http.set_header(v_http_request, 'user-agent', 'mozilla/4.0');
  utl_http.set_header(v_http_request, 'content-type', 'application/json');
  if v_method in ('POST','PATCH') then
    utl_http.set_header(v_http_request, 'Content-Length', length(v_text));
    UTL_HTTP.WRITE_TEXT (v_http_request, v_text);
  end if;
  v_http_response := UTL_HTTP.get_response(v_http_request);
  BEGIN
    LOOP
      UTL_HTTP.read_text(v_http_response, v_pom, 32767);
      dbms_lob.append(v_res,to_clob(v_pom));
    END LOOP;
  EXCEPTION
    WHEN UTL_HTTP.end_of_body THEN
      UTL_HTTP.end_response(v_http_response);
      return v_res;
      dbms_lob.freetemporary(v_res);
  END;
END;