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
String anio = request.getParameter("anio");
String codigo = request.getParameter("codigo");
String secuencia_pago = request.getParameter("secuencia_pago");

if(anio==null) anio = "";
if(codigo==null) codigo = "";
if(secuencia_pago==null) secuencia_pago = "";

int lineNo = 0;

boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(!anio.equals("") && !codigo.equals("") && !secuencia_pago.equals("")){
		sql="select a.secuencia, decode(a.tipo, 'H', a.med_codigo, 'E', a.empre_codigo, 'C', a.centro_servicio) codigo, decode(a.tipo, 'H', (select primer_apellido||' '||segundo_apellido||' '||apellido_de_casada ||' '||primer_nombre||' '||segundo_nombre from tbl_adm_medico where codigo = a.med_codigo), 'E', (select nombre from tbl_adm_empresa where codigo = a.empre_codigo), 'C', decode(a.centro_servicio, null, 'CO-PAGO', (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio)),null,'CO-PAGO') descripcion, a.monto, decode(a.pagado, 'S', 'Liquidado', 'N', 'No Liquidado') pagado, decode(a.distribucion, 'A', 'Automatica', 'M', 'Manual') distribucion from tbl_cja_distribuir_pago a where a.compania = "+(String) session.getAttribute("_companyId") + " and a.tran_anio = "+anio+" and a.codigo_transaccion = "+codigo+" and a.secuencia_pago = " + secuencia_pago+"  ";
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
	abrir_ventana1('../common/check_unidad_adm.jsp?fp=orden_pago&mode=<%=mode%>&anio=<%=anio%>');

	<%
	}
	%>
	newHeight();//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function _doSubmit(valor){
	document.form1.action.value = valor;
	document.form1.clearHT.value = 'N';
	if(parent.doSubmit()) doSubmit();
}

function doSubmit(){
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

<%=fb.hidden("codigo","")%> 

<table width="100%" align="center">
  <tr>
    <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextPanel">
          <td colspan="6"><cellbytelabel>Distribuci&oacute;n Pago:</cellbytelabel></td>
        </tr>
        <tr class="TextHeader">
          <td width="10%" align="center"><cellbytelabel>Secuencia</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
          <td width="40%" align="center"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
          <td width="15%" align="center"><cellbytelabel>Pagado</cellbytelabel></td>
          <td width="15%" align="center"><cellbytelabel>Distrubuci&oacute;n</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
        </tr>
        <%
				key = "";
				double monto_total = 0.00;
				for (int i=0; i<al.size(); i++){
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					monto_total += Double.parseDouble(cdo.getColValue("monto"));

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
        <%=fb.hidden("monto"+i,cdo.getColValue("monto"))%> 
        <tr class="<%=color%>" >
          <td align="center"><%=cdo.getColValue("secuencia")%></td>
          <td align="center"><%=cdo.getColValue("codigo")%></td>
          <td align="center"><%=cdo.getColValue("descripcion")%></td>
          <td align="center"><%=cdo.getColValue("pagado")%></td>
          <td align="center"><%=cdo.getColValue("distribucion")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%>&nbsp;&nbsp; </td>
        </tr>
        <%
				}
				%>
        <tr class="TextRow01" >
          <td colspan="5" align="right"><cellbytelabel>&nbsp;Monto Total</cellbytelabel></td>
          <td align="right"><%=fb.decBox("monto_total",CmnMgr.getFormattedDecimal(monto_total),true,false,viewMode,10, 8.2,"text10",null,"","",false,"")%>&nbsp;&nbsp;</td>
        </tr>
        <%=fb.hidden("keySize",""+al.size())%> 
      </table></td>
  </tr>
</table>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
%>

