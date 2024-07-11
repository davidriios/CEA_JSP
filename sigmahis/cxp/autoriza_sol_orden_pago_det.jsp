<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="OP" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="OrdPago" scope="session" class="issi.cxp.OrdenPago" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="opDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="opDetKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fact" scope="session" class="java.util.Hashtable" />
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
OrdPagoMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String documento = request.getParameter("documento");
String fecha = request.getParameter("fecha");
if(documento==null) documento = "";
if(fecha==null) fecha = "";
int lineNo = 0;

boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(!documento.equals("") && !fecha.equals("")){
		sql="select a.unidad_adm, a.monto, a.observacion2, a.estado, decode(a.estado, 'A', 'APROBADO', 'P', 'PENDIENTE', 'N', 'ANULADA') estado_desc, a.usuario_creacion, b.descripcion nombre_unidad, a.usuario_aprobacion, to_char(a.fecha_aprobacion, 'dd/mm/yyyy hh:mi am') fecha_aprobacion from tbl_cxp_orden_unidad_det a, tbl_sec_unidad_ejec b where a.estado = 'A' and a.compania = b.compania and a.unidad_adm = b.codigo and a.compania = "+(String) session.getAttribute("_companyId") + " and a.documento = "+documento+" and trunc(a.fecha) = to_date('"+fecha+"', 'dd/mm/yyyy')";
		al = SQLMgr.getDataList(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{	
	<%
	if(type!=null && type.equals("1")){
	%>
	abrir_ventana1('../common/check_unidad_adm.jsp?fp=orden_pago&mode=<%=mode%>&documento=<%=documento%>');

	<%
	}
	%>
	verValues();
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function _doSubmit(valor){
	document.form1.action.value = valor;
	document.form1.clearHT.value = 'N';
	if(parent.doSubmit()) doSubmit();
}

function doSubmit(){
}

function verValues(){
	var size = document.form1.keySize.value;
	var monto = 0.00;
	for(i=0;i<size;i++){
		if(eval('document.form1.monto'+i).value>0){
		 monto += parseFloat(eval('document.form1.monto'+i).value);
		}
	}
	document.form1.monto_total.value = monto;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%> 
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("baction","")%> 
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("documento",documento)%> 
<%=fb.hidden("clearHT","")%> 
<%=fb.hidden("action","")%> 
<%=fb.hidden("documento","")%> 
<%=fb.hidden("tipo_orden","")%> 
<%=fb.hidden("fecha","")%> 
<%=fb.hidden("unidad_adm1","")%> 
<%=fb.hidden("estado1","")%> 
<%=fb.hidden("clasificacion","")%> 
<%=fb.hidden("beneficiario","")%> 
<%=fb.hidden("nom_beneficiario","")%> 
<%=fb.hidden("ruc","")%> 
<%=fb.hidden("dv","")%> 
<%=fb.hidden("monto","")%> 
<%=fb.hidden("observacion","")%> 

<table width="100%" align="center">
  <tr>
    <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextPanel">
          <td colspan="7"><cellbytelabel>Afecta el Gasto de</cellbytelabel>:</td>
        </tr>
        <tr class="TextHeader">
          <td width="30%" align="center" colspan="2"><cellbytelabel>Unidad Administrativa</cellbytelabel></td>
          <td width="30%" align="center"><cellbytelabel>Detalle</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
          <td width="20%" align="center" colspan="2"><cellbytelabel>Aprobaci&oacute;n</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
        </tr>
        <%
				key = "";
				for (int i=0; i<al.size(); i++){
					CommonDataObject cdo = (CommonDataObject) al.get(i);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
        <%=fb.hidden("unidad_adm_"+i,cdo.getColValue("unidad_adm"))%>
        <%=fb.hidden("nombre_unidad"+i,cdo.getColValue("nombre_unidad"))%>
        <tr class="<%=color%>" >
          <td><%=cdo.getColValue("unidad_adm")%></td>
          <td><%=cdo.getColValue("nombre_unidad")%></td>
          <td><%=cdo.getColValue("observacion2")%></td>
          <td align="center"><%=fb.decBox("monto"+i,cdo.getColValue("monto"),false,false,viewMode,10, 8.2,"text10",null,"onFocus=\"this.select();\"" + "onChange = \"javascript:verValues();\"","Cantidad",false,"")%></td>
          <td width="8%" align="center"><%=cdo.getColValue("usuario_aprobacion")%></td>
          <td width="12%" align="center"><%=cdo.getColValue("fecha_aprobacion")%></td>
          <td align="center"><%=cdo.getColValue("estado_desc")%> </td>
        </tr>
        <%
				}
				%>
        <tr class="TextRow01" >
          <td colspan="4" align="right">&nbsp;<cellbytelabel>Monto Total</cellbytelabel></td>
          <td align="center"><%=fb.decBox("monto_total","0",true,false,viewMode,10, 8.2,"text10",null,"onFocus=\"this.select();\"","Cantidad",false,"")%></td>
          <td width="3%" align="center">&nbsp;</td>
          <td align="center" colspan="2">&nbsp;</td>
        </tr>
        <%=fb.hidden("keySize",""+al.size())%> 
      </table></td>
  </tr>
</table>
<%
fb.appendJsValidation("\n\tif (!chkCeroValues()) error++;\n");
fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
%>

