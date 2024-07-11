<%@ page import="issi.admin.UserDetail"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<%
String serveTo=request.getParameter("serveTo")==null?"":request.getParameter("serveTo");
String pacId=request.getParameter("pacId")==null?"":request.getParameter("pacId");
String noAdmision=request.getParameter("noAdmision")==null?"":request.getParameter("noAdmision");
String section=request.getParameter("section")==null?"":request.getParameter("section");
String paso=request.getParameter("paso")==null?"":request.getParameter("paso");
String flujo=request.getParameter("flujo")==null?"":request.getParameter("flujo");
String compania=request.getParameter("compania")==null?"":request.getParameter("compania");
String fechaDesde=request.getParameter("fechaDesde")==null?"":request.getParameter("fechaDesde");
String fechaHasta=request.getParameter("fechaHasta")==null?"":request.getParameter("fechaHasta");
String tipo=request.getParameter("tipo")==null?"":request.getParameter("tipo");
String documento=request.getParameter("documento")==null?"":request.getParameter("documento");
String filePath=request.getParameter("filePath")==null?"":request.getParameter("filePath");
StringBuffer sbSql=new StringBuffer();

if(serveTo.trim().equals("FLUJO_ATENCION")){
SQLMgr.setConnection(ConMgr);
CommonDataObject param=new CommonDataObject();

sbSql.append("call sp_sal_check_data (?,?,?,?,?,?,?,?,?,?,?)");

param.setSql(sbSql.toString());
param.addInStringStmtParam(1,pacId);
param.addInStringStmtParam(2,noAdmision);
param.addInStringStmtParam(3,section);
param.addInStringStmtParam(4,paso);
param.addInStringStmtParam(5,flujo);
param.addInStringStmtParam(6,compania);
param.addInStringStmtParam(7,fechaDesde);
param.addInStringStmtParam(8,fechaHasta);
param.addOutStringStmtParam(9);//MSG
param.addOutStringStmtParam(10);//PASO ANTERIOR
param.addOutStringStmtParam(11);//CONTINUE?

param = SQLMgr.executeCallable(param);

String res = "";
for (int i=0; i<param.getStmtParams().size(); i++) {
	CommonDataObject.StatementParam pp = param.getStmtParam(i);
	if (pp.getType().contains("o")) {
	   res +=pp.getData().toString();
	   if (i < param.getStmtParams().size()) res += "@@";
	}
}
out.print(res);}
else if(serveTo.trim().equals("APP_ENV")){ String _env = ""; try { _env = java.util.ResourceBundle.getBundle("issi").getString("app.access"); } catch (Exception ex) {_env ="I";} out.print(_env);}
else if (serveTo.trim().equals("ESTADO_ACTUAL_PAC")){
  SQLMgr.setConnection(ConMgr);
  sbSql.append("select seccion_tabla, seccion_columnas, seccion_where_clause, ultimos_n_registros, ultimos_x_registros from tbl_sal_secciones_resumen where seccion_tabla is not null and tipo = '");
  sbSql.append(tipo);
  sbSql.append("' and seccion_id = ");
  sbSql.append(section);
  sbSql.append(" and documento_id = ");
  sbSql.append(documento);
  CommonDataObject cdo=new CommonDataObject();
  cdo = SQLMgr.getData(sbSql.toString());
  String dateField = "",_where=(cdo.getColValue("seccion_where_clause")).replaceAll("@@PACID",pacId).replaceAll("@@ADMISION",noAdmision);
  String[] limit={};
  sbSql=new StringBuffer();
  sbSql.append("select ");
  sbSql.append((cdo.getColValue("seccion_columnas", " ")).replaceAll("@@PACID",pacId).replaceAll("@@ADMISION",noAdmision));
  sbSql.append(" from ");
  sbSql.append(cdo.getColValue("seccion_tabla"));
  sbSql.append(" where ");
  
  if ((cdo.getColValue("seccion_where_clause")).contains("DATE_FIELD")){
	dateField = _where.substring( _where.lastIndexOf("-")+1,_where.length() );
	_where = _where.replaceAll("@@DATE_FIELD-"+dateField," ORDER BY "+dateField+" DESC ");
  }
 
  sbSql.append(_where);

  java.util.ArrayList al = SQLMgr.getDataList(sbSql.toString());
  String res = "";
  for (int i=0;i<al.size();i++){
	cdo = (CommonDataObject) al.get(i);
	res += cdo.getColValue("col_val")+((i+1)<al.size()?"<br />":"");
  }
  out.print(res); 
}else if (serveTo.trim().equalsIgnoreCase("SCANNED_DOC") || serveTo.trim().equalsIgnoreCase("INF_CISTO")){
   CmnMgr.setConnection(ConMgr);
   if (CmnMgr.deleteFilesOnDisk(filePath)) out.print("DELETED");
   else out.print("FAILED");
}
else if(serveTo.trim().equals("EXP_NO_COPY_PASTE")){
	
	UserDetail UserDet = new UserDetail();
	if (session.getAttribute("UserDet") != null) UserDet = (UserDetail) session.getAttribute("UserDet");
	
	String noCopyPaste = "N", version = "1"; try { noCopyPaste = java.util.ResourceBundle.getBundle("issi").getString("expediente.no_copy_paste"); } catch (Exception ex) {}
	try { version = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception ex) {} out.print(noCopyPaste+"@"+version+"@"+UserDet.getUserProfile());
}
%>