<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="FPMgr" scope="page" class="issi.admin.FileMgr"/>
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoHeader = new CommonDataObject();
CommonDataObject cdoSep = new CommonDataObject();

String docPath = ResourceBundle.getBundle("path").getString("docs").replace(ResourceBundle.getBundle("path").getString("root"),"");
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer xtraFilter = new StringBuffer();
StringBuffer sbSep = new StringBuffer();
String fp = request.getParameter("fp");
String docType = request.getParameter("docType");
String anio =request.getParameter("anio");
String mes = request.getParameter("mes");
String fileName = request.getParameter("fileName"); 
String cargar = request.getParameter("cargar");
String procesar = request.getParameter("procesar");
String separador = "";   
String compania=(String) session.getAttribute("_companyId");
if (fp == null) fp = "";
if (docType == null) docType = "";
if (mes == null) mes = "";
if (anio == null) anio = ""; 
if (fileName == null) fileName = ""; 
if (cargar == null) cargar = ""; 
if (procesar == null) procesar = ""; 
if (fp.trim().equals("")) throw new Exception("El Origen no es válido. Por favor consulte con su Administrador!"); 

    sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'ADMIN_FILE_SEP'),'P') as fileSep from dual");
	//cdoSep = SQLMgr.getData(sbSql.toString());
	sbSql = new StringBuffer();
	
	/*if (cdoSep == null) {	
		cdoSep = new CommonDataObject();
		cdoSep.addColValue("fileSep","P");		
	}
	separador = cdoSep.getColValue("fileSep");
	*/
String docDesc = "";
if (docType.equalsIgnoreCase("FILEPLA"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.asientos");//.replace(ResourceBundle.getBundle("path").getString("root"),""); 
	cdo.addColValue("fileSep","|");	 
	cdo.addColValue("table","tbl_pla_pago_empleado_ext"); 
	cdo.addColValue("archivo",docPath+"/"+fileName);
	cdo.addColValue("checkReg","S");
	cdo.addColValue("checkRegWhere"," where compania="+compania+" and nombre_archivo='"+fileName+"'");
	cdo.addColValue("columns","id,compania,anio,mes,fecha_creacion,fecha_modificacion, usuario_creacion,usuario_modificacion,estado,nombre_archivo,num_empleado,unidad_ext,nombre_empleado,sal_bruto,extra,bonificacion, comision, otros_ing,otros_ing3, vacacion, decimo,participacion, liquidacion, licencia,sub_total, gasto_rep, no_gravable,adelanto, seg_social, seg_educativo,imp_renta,otras_ded,sal_neto");
	cdo.addColValue("values","(select nvl(max(id),0)+1 from tbl_pla_pago_empleado_ext),"+compania+","+anio+","+mes+",sysdate,sysdate,'"+(String) session.getAttribute("_userName")+"','"+(String) session.getAttribute("_userName")+"','C','"+fileName+"'");
    System.out.println(" error === "+FPMgr.getErrCode());
	if(cargar.trim().equals("S"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath()); 		
		FPMgr.loadFile(cdo);
		ConMgr.clearAppCtx(null);
		if(!FPMgr.getErrCode().equals("1")){procesar="N"; throw new Exception(FPMgr.getErrMsg());}
		else procesar="S"; 
	}
	
	
	if (procesar.trim().equals("S"))
	{
		CommonDataObject param = new CommonDataObject();
		
		param.setSql("call sp_con_asiento_planilla_ext (?,?,?,?)");
		param.addInStringStmtParam(1,compania);
		param.addInStringStmtParam(2,anio);
		param.addInStringStmtParam(3,mes);
		param.addInStringStmtParam(4,IBIZEscapeChars.forSingleQuots(((String) session.getAttribute("_userName")).trim()));  	
		
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"docType="+docType+"&anio="+anio+"&mes="+mes);
		param = SQLMgr.executeCallable(param);
		ConMgr.clearAppCtx(null);
		if (!SQLMgr.getErrCode().equals("1")) throw new Exception (SQLMgr.getErrException());
		
	}
	
	docDesc="PARA GENERAR ASIENTO DE PLANILLA";
} 

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Cargar Archivo - '+document.title;
function showReporte()
{
	var anio=document.formDetalle.anio.value;
	var mes=document.formDetalle.mes.value; 
	if(anio != null && anio !='')abrir_ventana('../contabilidad/print_list_comprobante_mensual.jsp?fp=listComp&anio='+anio+'&mes='+mes+'&tipo=&fg=PLA&docType=PLAEXT&regType=')
	
}

 </script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("docType",docType)%> 
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("fileName",fileName)%> 

		<tr class="TextHeader" align="center">
			<td><cellbytelabel>ARCHIVO CARGADO</cellbytelabel> <%=docDesc%></td>
		</tr>
			
<%if (docType.equalsIgnoreCase("FILEPLA")&&procesar.trim().equals("S")){%>		
		<tr class="TextRow01">
			<td align="center"><cellbytelabel><a href="javascript:showReporte();" class="Link00">REPORTE PRELIMINAR</a></cellbytelabel></td>
		</tr>
<%}%>
		<tr class="TextHeader" align="center">
			<td align="center">
				<%=fb.button("cancel","Cerrar",false,false,"Text10",null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
			</td>
		</tr>
<%=fb.formEnd()%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
%>