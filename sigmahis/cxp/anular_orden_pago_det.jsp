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
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String anio = request.getParameter("anio");
String cod_tipo_orden_pago = request.getParameter("cod_tipo_orden_pago");
String tipo_orden = request.getParameter("tipo_orden");
String odp = request.getParameter("odp");
String fecha_ini = request.getParameter("fecha_ini");
String fecha_fin = request.getParameter("fecha_fin");
String agrupa_hon = request.getParameter("agrupa_hon");
if(agrupa_hon==null) agrupa_hon = "";
String solicitadoPor = request.getParameter("solicitadoPor");

if(anio==null) anio = "";
if(cod_tipo_orden_pago==null) cod_tipo_orden_pago = "";
if(tipo_orden==null) tipo_orden = "";
if(odp==null) odp = "";
if(fecha_ini==null) fecha_ini = "";
if(fecha_fin==null) fecha_fin = "";
if(solicitadoPor==null) solicitadoPor = "";

int lineNo = 0;

boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
	String appendFilter = "";
	if(anio!=null && !anio.equals("")) appendFilter = "and a.anio = "+anio;
	if(cod_tipo_orden_pago!=null && !cod_tipo_orden_pago.equals("")) appendFilter += " and a.cod_tipo_orden_pago = "+cod_tipo_orden_pago;
	if(tipo_orden!=null && !tipo_orden.equals("")) appendFilter += (agrupa_hon.equals("Y")?" and decode(a.tipo_orden, 'S', 'H', 'M', 'H', a.tipo_orden)":" and a.tipo_orden ")+" = '"+ tipo_orden+"'";
	if(odp!=null && !odp.equals("")) appendFilter += " and a.num_orden_pago = "+odp;
	if(fecha_ini!=null && !fecha_ini.equals("")) appendFilter += " and trunc(a.fecha_solicitud) >= to_date('"+fecha_ini+"', 'dd/mm/yyyy')";
	if(fecha_fin!=null && !fecha_fin.equals("")) appendFilter += " and trunc(a.fecha_solicitud) <= to_date('"+fecha_fin+"', 'dd/mm/yyyy')";
	if(!solicitadoPor.trim().equals("")) appendFilter += " and a.solicitado_por = '"+solicitadoPor+"'";

     if(request.getParameter("tipo_orden")!=null){
		sql = "select a.cod_compania, a.anio, a.num_orden_pago, to_char(a.fecha_solicitud , 'dd/mm/yyyy') fecha_solicitud, a.estado, decode(a.estado, 'P', 'Pendiente', 'A', 'Aprobado') estado_desc, a.nom_beneficiario, a.num_id_beneficiario, a.cod_tipo_orden_pago, a.monto, a.tipo_orden, a.user_creacion from tbl_cxp_orden_de_pago a  where a.cod_compania = "+(String) session.getAttribute("_companyId")+" and estado <> 'N' and not exists (select 1 from tbl_con_cheque b where b.anio = a.anio and b.num_orden_pago = a.num_orden_pago and b.cod_compania_odp=a.cod_compania and b.estado_cheque <> 'A' ) "+appendFilter+" order by a.fecha_solicitud desc";
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
	newHeight();
}

function doSubmit(valor){
	document.form1.action.value = valor;
	document.form1.clearHT.value = 'N';
	document.form1.submit();
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
<%=fb.hidden("anio",anio)%> 
<%=fb.hidden("clearHT","")%> 
<%=fb.hidden("action","")%> 
<%=fb.hidden("tipo_orden","")%> 
<%=fb.hidden("cod_tipo_orden_pago","")%>
<%=fb.hidden("solicitadoPor",""+solicitadoPor)%> 
<table width="100%" align="center">
  <tr>
    <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextHeader02" >
          <td align="center" width="6%"><cellbytelabel>No</cellbytelabel>.</td>
          <td align="center" width="10%"><cellbytelabel>Fecha Solicitud</cellbytelabel></td>
          <td align="center" width="30%" colspan="2"><cellbytelabel>Beneficiario</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Monto</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Estado</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Usuario Crea</cellbytelabel></td>
          <td align="center" width="4%">&nbsp;</td>
        </tr>
        <%
				key = "";
				for (int i=0; i<al.size(); i++){
					CommonDataObject cdo = (CommonDataObject) al.get(i);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("num_orden_pago"+i,cdo.getColValue("num_orden_pago"))%>
        <%=fb.hidden("fecha_solicitud"+i,cdo.getColValue("fecha_solicitud"))%>
        <%=fb.hidden("monto"+i,cdo.getColValue("monto"))%>
        <%=fb.hidden("num_id_beneficiario"+i,cdo.getColValue("num_id_beneficiario"))%>
        <%=fb.hidden("nom_beneficiario"+i,cdo.getColValue("nom_beneficiario"))%>
        <%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
        <%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
        <%=fb.hidden("estado_ini"+i,cdo.getColValue("estado"))%>
        <%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center"><%=cdo.getColValue("num_orden_pago")%> </td>
          <td align="center"><%=cdo.getColValue("fecha_solicitud")%> </td>
          <td><%=cdo.getColValue("num_id_beneficiario")%></td>
          <td>&nbsp;<%=cdo.getColValue("nom_beneficiario")%> </td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
          <td align="center"><%=cdo.getColValue("estado_desc")%> </td>
          <td align="center"><%=cdo.getColValue("user_creacion")%></td>
          <td align="center"><%=fb.checkbox("check"+i,""+i,false,false,"","","")%></td>
        </tr>
        <%
				}
				%>
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
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int keySize = Integer.parseInt(request.getParameter("keySize"));

	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		if(request.getParameter("check"+i)!=null){
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("num_orden_pago", request.getParameter("num_orden_pago"+i));
			cdo.addColValue("anio", request.getParameter("anio"+i));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("cod_compania", (String) session.getAttribute("_companyId"));
			al.add(cdo);
		}
	}

	if (request.getParameter("action").equals("Anular Ordenes")){
		OrdPagoMgr.anulaOrdenPago(al);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if (OrdPagoMgr.getErrCode().equals("1")){%>
			parent.document.orden_pago.errCode.value = <%=OrdPagoMgr.getErrCode()%>;
			parent.document.orden_pago.errMsg.value = '<%=OrdPagoMgr.getErrMsg()%>';
			parent.document.orden_pago.saveOption.value = '<%=saveOption%>';
			parent.document.orden_pago.submit();
	<%} else throw new Exception(OrdPagoMgr.getErrMsg());%>
		
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

