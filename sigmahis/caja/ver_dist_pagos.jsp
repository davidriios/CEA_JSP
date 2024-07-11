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
		sql="select a.secuencia, decode(a.tipo, 'H', 'MEDICO', 'E', 'EMPRESA', 'C', 'CARGO','M','PERDIEM','P','CO-PAGO',null,'CO-PAGO') tipo_desc, a.centro_servicio, decode(a.tipo, 'H', a.med_codigo, 'E', a.empre_codigo, 'C', a.centro_servicio) codigo, decode(a.tipo, 'H', (select primer_apellido||' '||segundo_apellido||' '||apellido_de_casada ||' '||primer_nombre||' '||segundo_nombre from tbl_adm_medico where codigo = a.med_codigo), 'E', (select nombre from tbl_adm_empresa where codigo = a.empre_codigo), 'C', nvl((select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio),a.desc_distribucion),null,'CO-PAGO','M','PERDIEM','P','CO-PAGO',null,'CO-PAGO') descripcion, a.monto, to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fecha, decode(a.pagado, 'S', 'PAGADO', 'N', 'POR PAGAR') pagado, a.num_cheque, decode(a.distribucion, 'A', 'Automatica', 'M', 'Manual') distribucion, a.tipo_cobertura,a.fac_codigo,a.usuario_creacion as usuario from tbl_cja_distribuir_pago a where a.compania = "+(String) session.getAttribute("_companyId") + " and a.tran_anio = "+anio+" and a.codigo_transaccion = "+codigo+" and a.secuencia_pago = " + secuencia_pago+"  and a.monto <> 0";
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
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function _doSubmit(valor){
	document.form1.action.value = valor;
	document.form1.clearHT.value = 'N';
	if(parent.doSubmit()) doSubmit();
}

function doSubmit(){
}

function corregir(secuencia, secuencia_pago, codigo,anio,factura){
showPopWin('../common/run_process.jsp?fp=corregir_dist&actType=50&docType=DIST&docId='+codigo+'&docNo='+secuencia_pago+'&anio='+anio+'&codigo='+secuencia+'&factura='+factura+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.20,null,null,'')
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
          <td colspan="10"><cellbytelabel>Distribuci&oacute;n Pago</cellbytelabel>:</td>
          <td align="center"><%=fb.button("cancel","Cerrar",true,false,"Text10",null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>
        <tr class="TextHeader">
          <td width="7%" align="center"><cellbytelabel>Secuencia</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Tipo</cellbytelabel></td>
          <td width="25%" align="center" colspan="2"><cellbytelabel>Distribuido A</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
          <td width="22%" align="center"><cellbytelabel>Fecha/Usuario</cellbytelabel></td>
          <td width="7%" align="center"><cellbytelabel>Pagado por CXP</cellbytelabel></td>
          <td width="7%" align="center"><cellbytelabel>Num</cellbytelabel>. <cellbytelabel>Cheque</cellbytelabel></td>
          <td width="7%" align="center"><cellbytelabel>Tipo de Dist</cellbytelabel>.</td>
          <td width="7%" align="center"><cellbytelabel>Tipo Cobert</cellbytelabel>.</td>
		  <td width="2%" align="center">&nbsp;</td>
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
          <td align="center"><%=cdo.getColValue("tipo_desc")%></td>
          <td align="center"><%=cdo.getColValue("codigo")%></td>
          <td align="center"><%=cdo.getColValue("descripcion")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%>&nbsp;&nbsp; </td>
          <td align="center"><%=cdo.getColValue("fecha")%>-<%=cdo.getColValue("usuario")%></td>
          <td align="center"><%=cdo.getColValue("pagado")%></td>
          <td align="center"><%=cdo.getColValue("num_cheque")%></td>
          <td align="center"><%=cdo.getColValue("distribucion")%></td>
          <td align="center"><%=cdo.getColValue("tipo_cobertura")%></td>
		  <td align="center"><%if (UserDet.getUserProfile().contains("0")){%><!-- <a href="javascript:corregir('<%=cdo.getColValue("secuencia")%>','<%=secuencia_pago%>','<%=codigo%>','<%=anio%>','<%=cdo.getColValue("fac_codigo")%>')"><img id="imgCorregir<%=i%>" height="20" width="20" class="ImageBorder" src="../images/actualizar.gif"></a>--><%}%>
	  </td>
        </tr>
        <%
				}
				%>
        <tr class="TextRow01" >
          <td colspan="4" align="right">&nbsp;<cellbytelabel>Monto Total</cellbytelabel></td>
          <td align="right"><%=fb.decBox("monto_total",CmnMgr.getFormattedDecimal(monto_total),true,false,viewMode,10, 8.2,"text10",null,"","",false,"")%>&nbsp;&nbsp;</td>
          <td colspan="7">&nbsp;</td>
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

