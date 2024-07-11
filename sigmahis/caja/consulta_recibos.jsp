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
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
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
String compania = request.getParameter("compania");
String tipoCliente = request.getParameter("tipoCliente");
if(anio==null) anio = "";
if(codigo==null) codigo = "";
if(compania==null) compania = (String) session.getAttribute("_companyId");
if(tipoCliente==null) tipoCliente = "";

int lineNo = 0;
boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
	if(!codigo.trim().equals("")){
	
	
	
 sql="select decode(a.tipo_cliente,'P',b.nombre_paciente,'E',e.nombre,'S/N') nombreCliente ,a.pago_total, a.descripcion, to_char (a.fecha, 'dd/mm/yyyy') as fecha, a.tipo_cliente, a.codigo, a.anio, a.recibo, a.caja, nvl(a.nombre, ' ') nombre, b.pac_id, c.codigo as codcaja, c.descripcion as nomcaja, nvl(a.nombre_adicional, ' ') nombre_adicional,e.codigo codEmpresa from tbl_cja_transaccion_pago a, vw_adm_paciente b,tbl_adm_empresa e, tbl_cja_cajas c where a.compania = "+compania+" and a.codigo = "+codigo+" and a.anio = "+anio+" and b.pac_id(+) = a.pac_id and a.codigo_empresa = e.codigo(+) and c.codigo = a.caja and a.rec_status <> 'I'";
      
        cdo = SQLMgr.getData(sql);
				
				
		sql="select a.anio, (select codigo from tbl_cja_recibos where ctp_codigo = a.codigo and ctp_anio = a.anio and compania = a.compania) codigo_recibo, a.codigo, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.descripcion, (select max(num_cheque) from tbl_cja_trans_forma_pagos where tran_codigo = a.codigo and tran_anio = a.anio and compania = a.compania) num_cheque, b.monto, b.secuencia_pago,b.tipo_transaccion from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.compania = b.compania and a.anio = b.tran_anio and a.codigo = b.codigo_transaccion and a.rec_status <> 'I' and b.compania = "+compania+ " and a.codigo = "+codigo+" and a.anio ="+anio;
		al = SQLMgr.getDataList(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<table width="100%" align="center" id="_tblMain">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%> 
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("baction","")%> 
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("anio",anio)%> 
<%=fb.hidden("clearHT","")%> 
<%=fb.hidden("action","")%> 
<%=fb.hidden("codigo","")%> 

      <tr class="TextRow02">
        <td colspan="4">&nbsp;</td>
      </tr>     
      <tr class="TextRow01" >
        <td width="15%"><cellbytelabel>Recibo:</cellbytelabel></td>
        <td width="35%"><%=fb.textBox("recibo",cdo.getColValue("recibo"),true,(mode.equals("edit")||viewMode),false,20,12,null,null,"onBlur=\"javascript:checkCode(this)\"")%>
        </td>
        <td width="15%"><cellbytelabel>C&oacute;digo:</cellbytelabel></td>
        <td width="35%"><%=fb.textBox("codigo",codigo,false,false,true,15)%></td>          
      </tr>             
      <tr class="TextRow01" >

<!-- ============================================================================================================= -->
<% if(tipoCliente.equals("E")){ %>
        <td><cellbytelabel>Empresa:</cellbytelabel></td>
        <td colspan="3">
        <%=fb.textBox("codEmpresa",""+cdo.getColValue("codEmpresa"), true, false, true, 3, "Text10", "", "")%> 
        <%=fb.textBox("empresaNombre",""+cdo.getColValue("nombreCliente"), true, false, true, 55, "Text10", "", "")%> 
        </td>
<% } else if(tipoCliente.equals("P")){ %>
        <td><cellbytelabel>Paciente:</cellbytelabel></td>
        <td colspan="3">
        <%=fb.textBox("codPaciente",""+cdo.getColValue("pac_id"), true, false, true, 3, "Text10", "", "")%> 
        <%=fb.textBox("pacienteNombre",""+cdo.getColValue("nombreCliente"), true, false, true, 55, "Text10", "", "")%>       
        </td>
<% } %>
</tr>  
<!-- ============================================================================================================= -->
			<tr class="TextRow02" >
        <td><cellbytelabel>Fecha:</cellbytelabel></td>
        <td colspan="3"><%=fb.textBox("fecha",""+cdo.getColValue("fecha"),false,false,true,15)%></td>
      </tr>
      <tr class="TextRow01" >
        <td><cellbytelabel>Cajas:</cellbytelabel></td>
        <td colspan="3">
		<%  StringBuffer sbSql = new StringBuffer();
			sbSql.append(" and codigo in (");
				if(session.getAttribute("_codCaja")!=null)
					sbSql.append(session.getAttribute("_codCaja"));
				else sbSql.append("-1");
			sbSql.append(") ");
		%>	 
        <%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_cja_cajas where compania = "+(String) session.getAttribute("_companyId")+" and codigo="+cdo.getColValue("codCaja")+" order by descripcion asc","codCaja",cdo.getColValue("codCaja"),false,viewMode,0,null,null,"onChange=\"javascript:setTurno();\"")%>
        </td>
      </tr>
      <tr class="TextRow01" >
        <td><cellbytelabel>Cantidad:</cellbytelabel></td>
        <td colspan="3">
        <%=fb.decBox("cantidad",""+cdo.getColValue("pago_total"), true, viewMode,false,15,"Text10","","onKeyUp=\" calcSaldo(); \" ")%>
        </td>
      </tr>
      <tr class="TextRow01">
        <td><cellbytelabel>Concepto:</cellbytelabel></td>
        <td><%=fb.textBox("concepto",""+cdo.getColValue("descripcion"),true,viewMode,false,70)%></td>
        <td colspan="2">
				<% if(tipoCliente.equals("D")||tipoCliente.equals("P")){%>
       <cellbytelabel> Nombre Adicional:</cellbytelabel><%=fb.textBox("nombre_adicional",""+cdo.getColValue("nombre_adicional"),false,viewMode,false,50)%><%}%>
        </td>
      </tr>                 
  <tr>
    <td colspan="4"><table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextPanel">
          <td colspan="6"><cellbytelabel>Pagos:</cellbytelabel></td>
        </tr>
        <tr class="">
          <td colspan="6">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
                <table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextHeader">
          <td width="15%" align="center"><cellbytelabel>Recibo</cellbytelabel></td>
          <td width="15%" align="center"><cellbytelabel>No. Trans</cellbytelabel></td>
          <td width="15%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
          <td width="20%" align="center"><cellbytelabel>Tipo Transaccion</cellbytelabel></td>
          <td width="15%" align="center"><cellbytelabel>No. Cheque</cellbytelabel></td>
          <td width="15%" align="center"><cellbytelabel>Pagado</cellbytelabel></td>
          <td width="5%"  align="center">&nbsp;</td>
        </tr>
        <%
				key = "";
				double monto_total = 0.00;
				for (int i=0; i<al.size(); i++){
					CommonDataObject cdo2 = (CommonDataObject) al.get(i);
					monto_total += Double.parseDouble(cdo2.getColValue("monto"));
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
		<%=fb.hidden("anio"+i,cdo2.getColValue("anio"))%>
        <%=fb.hidden("codigo"+i,cdo2.getColValue("codigo"))%>
        <%=fb.hidden("secuencia_pago"+i,cdo2.getColValue("secuencia_pago"))%>
        <%=fb.hidden("monto"+i,cdo2.getColValue("monto"))%> 
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center"><%=cdo2.getColValue("codigo_recibo")%></td>
          <td align="center"><%=cdo2.getColValue("codigo")%></td>
          <td align="center"><%=cdo2.getColValue("fecha")%></td>
          <td align="center"><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cja_tipo_transaccion order by descripcion asc","tipo",cdo.getColValue("tipo_transaccion"),false,viewMode,0,null,null,"")%></td>
          <td align="center"><%=cdo2.getColValue("num_cheque")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo2.getColValue("monto"))%>&nbsp;&nbsp; </td>
          <td align="center"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "onClick=\"javascript:setDetValues()\"")%></td>
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
        </div><!---->
        </td>
        </tr>
         
       <%=fb.hidden("keySize",""+al.size())%> 
	  </td>
  </tr>
</table>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
%>

