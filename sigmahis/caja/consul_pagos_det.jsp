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
String facA = request.getParameter("factA");

if(anio==null) anio = "";
if(codigo==null) codigo = "";
if(facA==null) facA = "";

int lineNo = 0;

boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(!codigo.equals("")){
		sql="select a.anio, (select codigo from tbl_cja_recibos where ctp_codigo = a.codigo and ctp_anio = a.anio and compania = a.compania) codigo_recibo, a.codigo, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.descripcion, (select max(num_cheque) from tbl_cja_trans_forma_pagos where tran_codigo = a.codigo and tran_anio = a.anio and compania = a.compania) num_cheque, b.monto, b.secuencia_pago from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.compania = b.compania and a.anio = b.tran_anio and a.codigo = b.codigo_transaccion and b.compania = "+(String) session.getAttribute("_companyId") + " and b.fac_codigo = '"+codigo+"'  and a.rec_status <> 'I'";
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
	if(document.form1.rb){
		setDetValues();
	}
	newHeight();
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}
 

function chkRB(i){
	checkRadioButton(document.form1.rb, i);
	setDetValues();
}

function setDetValues(){
	var index = 	getRadioButtonValue(document.form1.rb);
	var anio = eval('document.form1.anio'+index).value;
	var codigo = eval('document.form1.codigo'+index).value;
	var secuencia_pago = eval('document.form1.secuencia_pago'+index).value;
	if(anio!='' && codigo !='' && secuencia_pago != ''){
		window.frames['itemFrame'].location = '../caja/consul_pagos_x_aseg_det_dist.jsp?anio='+anio+'&codigo='+codigo+'&secuencia_pago='+secuencia_pago;
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
          <td colspan="6"><cellbytelabel>Pagos:</cellbytelabel></td>
        </tr>
        <tr class="">
          <td colspan="6">
		<div id="list_opMain" width="100%" style="overflow:scroll;position:static;height:140">
		<div id="list_op" width="100%" style="overflow;position:relative">
                <table align="center" width="99%" cellpadding="0" cellspacing="1">
        <tr class="TextHeader">
          <td width="10%" align="center"><cellbytelabel>Recibo</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>No. Trans</cellbytelabel></td>
          <td width="15%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
          <td width="38%" align="center"><cellbytelabel>Concepto</cellbytelabel></td>
          <td width="15%" align="center"><cellbytelabel>No. Cheque</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>Pagado</cellbytelabel></td>
          <td width="2%"  align="center">&nbsp;</td>
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
				<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
        <%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
        <%=fb.hidden("secuencia_pago"+i,cdo.getColValue("secuencia_pago"))%>
        <%=fb.hidden("monto"+i,cdo.getColValue("monto"))%> 
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
          <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=cdo.getColValue("codigo_recibo")%></td>
          <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=cdo.getColValue("codigo")%></td>
          <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=cdo.getColValue("fecha")%></td>
          <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=cdo.getColValue("descripcion")%></td>
          <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=cdo.getColValue("num_cheque")%></td>
          <td align="right" onClick="javascript:chkRB(<%=i%>);"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%>&nbsp;&nbsp; </td>
          <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "onClick=\"javascript:setDetValues()\"")%></td>
        </tr>
        <%
				}
				%>
        <tr class="TextRow01" >
          <td colspan="5" align="right"><cellbytelabel>&nbsp;Monto Total</cellbytelabel></td>
          <td align="right"><%=fb.decBox("monto_total",CmnMgr.getFormattedDecimal(monto_total),true,false,viewMode,10, 8.2,"text10",null,"onFocus=\"this.select();\"","Cantidad",false,"")%>&nbsp;&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        </table>
        </div>
        </div>
        </td>
        </tr>
         <%if(!facA.trim().equals("O")){%>
		 <tr>
          <td colspan="6"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../caja/consul_pagos_x_aseg_det_dist.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>"></iframe><!----></td>
        </tr><%}%>
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

