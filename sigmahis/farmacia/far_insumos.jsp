<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();

String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String id = request.getParameter("id");
String noOrden ="";
String compania = (String) session.getAttribute("_companyId");
if (request.getParameter("noOrden") != null)noOrden =request.getParameter("noOrden");
String codigoOrdenMed = request.getParameter("codigo_orden_med") == null ? "" : request.getParameter("codigo_orden_med");
String mode = request.getParameter("mode") == null ? "" : request.getParameter("mode");
if (id == null) id = "";

if (request.getMethod().equalsIgnoreCase("GET")){
	
    StringBuffer sql = new StringBuffer();
	
    sql.append("select d.descripcion, decode(d.tipo_transaccion,'D', -1*d.cantidad, d.cantidad) cantidad , substr(fac.descripcion, instr(fac.descripcion,'-',1)+1) as cod_ord, to_char(d.fecha_hora_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha, decode(d.tipo_transaccion,'D','Devolución','Cargo') tipo_transaccion_desc, d.tipo_transaccion from tbl_fac_detalle_transaccion d, tbl_fac_transaccion fac  where d.ref_type = 'FARINSUMOS' and d.compania = fac.compania and d.fac_codigo = fac.codigo and d.fac_secuencia = fac.admi_secuencia and d.pac_id = fac.pac_id and d.tipo_transaccion = fac.tipo_transaccion and d.compania = ");
    sql.append(compania);
    sql.append(" and d.fac_secuencia = ");
    sql.append(noAdmision);
    sql.append(" and d.pac_id = ");
    sql.append(pacId);
    
    if (!mode.trim().equals("recibir") && !id.trim().equals("")) {
      sql.append(" and d.ref_id = '");
      sql.append(id);
	  sql.append("'");
    }
    
    if(!codigoOrdenMed.trim().equals("")){
	al = SQLMgr.getDataList("select aa.* from ("+sql.toString()+") aa where substr(aa.cod_ord, 0, instr(aa.cod_ord,'-',1)-1) = "+codigoOrdenMed+" order by aa.descripcion, aa.fecha");}

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
function doAction(){
  var o = document.getElementById("_insumos");
  var s = <%=al.size()%>;
  if (s) {
    o.style.display='inline';
    o.innerHTML = " ("+ s +")";
  }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<%@ include file="../common/header.jsp"%>
<table align="center" width="99%" cellpadding="1" cellspacing="1">
 	<tr>
		<td>

 <table width="100%" cellpadding="1" cellspacing="0">
    <!--<tr>
        <td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
    </tr>-->
     <tr>
        <td class="TableLeftBorder TableRightBorder">
            <table align="center" width="100%" cellpadding="0" cellspacing="1">
<%
String gItem = "";
for (int i=0; i<al.size(); i++){
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
    int cantidad = Integer.parseInt(cdo.getColValue("cantidad"));
    
    if (!gItem.equals(cdo.getColValue("descripcion"))){
    %>
       <tr class="TextHeader">
			<td colspan="3"><%=cdo.getColValue("descripcion")%></td>
		</tr>
        <tr class="TextHeader">
                <td width="70%">Fecha Creaci&oacute;on</td>
                <td width="10%" align="center">Cantidad</td>
                <td width="20%" align="center">Tipo Transacci&oacute;n</td>
            </tr>
    <%
    }

%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("fecha")%></td>
			<td align="center">
            <%if(cantidad < 1){%>
               <span class="RedTextBold"><%=cdo.getColValue("cantidad")%></span>
            <%}else{%> 
               <span><%=cdo.getColValue("cantidad")%></span>            
            <%}%>   
            </td>
			<td align="center"><%=cdo.getColValue("tipo_transaccion_desc")%></td>
		</tr>
<%
gItem = cdo.getColValue("descripcion");
}
%>
		</table>
	</div>
  </div>	
	</td>
</tr>
</table>
</body>
</html>
<%
}
%>