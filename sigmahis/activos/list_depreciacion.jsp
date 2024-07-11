<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
SecMgr.setConnection(ConMgr);

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

/*===============================================================================
fg = t=obtener datos de tbl_con_temporal_depreciacion
		 d=obtener datos de tbl_con_deprec_mensual
================================================================================*/

ArrayList al = new ArrayList();
ArrayList alTot = new ArrayList();
ArrayList alDesc = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

String sql = "";
String sqlT = "";

String anio = request.getParameter("anio");
String id = request.getParameter("id");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String compania =  (String) session.getAttribute("_companyId");
String userName = UserDet.getUserName();
String mes = request.getParameter("mes");
String unidad = request.getParameter("unidad");
String fg = request.getParameter("fg");

if(fg == null) fg ="t";   // temporal

if (request.getMethod().equalsIgnoreCase("GET"))
{

	if (fg.trim().equals("t"))
	{
			sql= "select nvl(a.gasto1,getCtaGastDepre(a.compania,'C1',a.ue_codigo,a.cod_flia))cta1, nvl(a.gasto2,getCtaGastDepre(a.compania,'C2',a.ue_codigo,a.cod_flia))cta2, nvl(a.gasto3,getCtaGastDepre(a.compania,'C3',a.ue_codigo,a.cod_flia))cta3,nvl(a.gasto4,getCtaGastDepre(a.compania,'C4',a.ue_codigo,a.cod_flia))cta4, nvl(a.gasto5,getCtaGastDepre(a.compania,'C5',a.ue_codigo,a.cod_flia))cta5,nvl(a.gasto6,getCtaGastDepre(a.compania,'C6',a.ue_codigo,a.cod_flia))cta6, a.ue_codigo, u.DESCRIPCION, d.cod_ano, d.cod_mes, to_char(a.fecha_de_entrada,'dd/mm/yy') entrada, a.valor_inicial, d.monto_depre, to_char(a.final_garantia,'dd/mm/yy') final, a.secuencia, d.valor_activo_act actual, o.descripcion otro, a.observacion from tbl_con_temporal_depreciacion d, tbl_con_activos a, tbl_con_especificacion e, tbl_sec_unidad_ejec u, tbl_con_detalle_otro o where a.SECUENCIA = d.activo_sec and a.compania = d.compania and u.codigo = a.ue_codigo and u.compania = a.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and a.cuentah_detalle = o.codigo_detalle and a.compania = o.cod_compania and d.cod_ano = "+anio+" and d.cod_mes = "+mes+" and a.ue_codigo = "+unidad+" order by  a.fecha_de_entrada";
			al = SQLMgr.getDataList(sql);
  } else {
			sql= "select nvl(a.gasto1,getCtaGastDepre(a.compania,'C1',a.ue_codigo,a.cod_flia))cta1, nvl(a.gasto2,getCtaGastDepre(a.compania,'C2',a.ue_codigo,a.cod_flia))cta2, nvl(a.gasto3,getCtaGastDepre(a.compania,'C3',a.ue_codigo,a.cod_flia))cta3,nvl(a.gasto4,getCtaGastDepre(a.compania,'C4',a.ue_codigo,a.cod_flia))cta4, nvl(a.gasto5,getCtaGastDepre(a.compania,'C5',a.ue_codigo,a.cod_flia))cta5,nvl(a.gasto6,getCtaGastDepre(a.compania,'C6',a.ue_codigo,a.cod_flia))cta6, a.ue_codigo, u.DESCRIPCION, d.cd_ano  cod_ano, d.cd_mes cod_mes, to_char(a.fecha_de_entrada,'dd/mm/yy') entrada, a.valor_inicial, d.monto_depre, to_char(a.final_garantia,'dd/mm/yy') final, a.secuencia, d.valor_activo_act actual, o.descripcion otro, a.observacion from tbl_con_deprec_mensual d, tbl_con_activos a, tbl_con_especificacion e, tbl_sec_unidad_ejec u, tbl_con_detalle_otro o where a.SECUENCIA = d.activo_sec and a.compania = d.compania and u.codigo = a.ue_codigo and u.compania = a.compania and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and a.compania= "+(String) session.getAttribute("_companyId")+" and a.cuentah_detalle = o.codigo_detalle and a.compania = o.cod_compania and d.cd_ano = "+anio+" and d.cd_mes = "+mes+" and a.ue_codigo = "+unidad+" order by  a.fecha_de_entrada";
			al = SQLMgr.getDataList(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Depreciación Mensual - '+document.title;
function printList(anio,mes,unidad,fg){abrir_ventana('../activos/print_list_depreciacion.jsp?anio='+anio+'&mes='+mes+'&unidad='+unidad+'&fg='+fg);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="ACTIVO FIJO "></jsp:param>
  <jsp:param name="displayCompany" value="y"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode","")%>
<%=fb.hidden("seccion","")%>
<%=fb.hidden("size","")%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("unidad",unidad)%>
<table width="100%" cellpadding="1" cellspacing="1">

  <tr>
    <td align="right" colspan="8">&nbsp;
        <%
//if (SecMgr.checkAccess(session.getId(),"0"))
//{
%>
        <a href="javascript:printList('<%=anio%>','<%=mes%>','<%=unidad%>','<%=fg%>')" class="Link00">[ Imprimir Activo ]</a>
        <%
//}
%>    </td>
  </tr>
	<tr align="center" class="TextHeader">
    <td colspan="1">&nbsp;</td>
    <td colspan="6" align="center">DEPARTAMENTO DE CONTABILIDAD</td>
    <td colspan="1">&nbsp;</td>
  </tr>
<tr align="center" class="TextHeader">
     <td colspan="1">&nbsp;</td>
    <td colspan="6" align="center">ACTIVOS POR UNIDAD ADMINISTRATIVA</td>
    <td colspan="2">&nbsp;</td>
  </tr>

	<tr class="TextHeader">
    <td colspan="2" align="left">Usuario:&nbsp;<%=userName%></td>
    <td colspan="3" align="center">&nbsp;</td>
    <td colspan="3" align="left">Fecha:&nbsp;<%=cDateTime%></td>
  </tr>



 <%
 
 double 	totIni = 0.00;
					double 	totDepre = 0.00;
					double 	totAct   = 0.00;
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

%>
<% if(i==0) {%>

  <tr class="TextRow01">
	    <td align="left" colspan="8"> Unidad Administradtiva:&nbsp; <%=cdo.getColValue("descripcion")%> </td>
  </tr>


	<tr align="center" class="TextHeader">
    <td width="10%">Sec</td>
    <td width="20%">Descripción</td>
    <td width="20%">Observación</td>
    <td width="10%">Entrada</td>
    <td width="10%">Valor Inicial</td>
    <td width="10%">Valor Deprec.</td>
    <td width="10%">Fecha Final</td>
		<td width="10%">Valor Actual</td>
  </tr>
	<% } %>

	<tr class="<%=color%>">
    <td align="center"> <%=cdo.getColValue("secuencia")%> </td>
		 <td align="left"> <%=cdo.getColValue("otro")%> </td>
		  <td align="left"> <%=cdo.getColValue("observacion")%> </td>
			 <td align="center"> <%=cdo.getColValue("entrada")%> </td>
			  <td align="right"><%=CmnMgr.getFormattedDecimal("999,999,990.00",cdo.getColValue("valor_inicial"))%> </td>
				 <td align="right"><%=CmnMgr.getFormattedDecimal("999,999,990.00",cdo.getColValue("monto_depre"))%> </td>
				  <td align="center"> <%=cdo.getColValue("final")%> </td>
					 <td align="right"><%=CmnMgr.getFormattedDecimal("999,999,990.00",cdo.getColValue("actual"))%> </td>

  </tr>

 <%
 		totIni   += Double.parseDouble(cdo.getColValue("valor_inicial"));
		totDepre += Double.parseDouble(cdo.getColValue("monto_depre"));
		totAct   += Double.parseDouble(cdo.getColValue("actual"));
}
%>

	<%
				{
				String color1 = "TextRow03";
					
				
				%>

	<tr class="<%=color1%>">
    <td colspan="4" align="right"> &nbsp; Total &nbsp;&nbsp; </td>
		<td align="right"><%=CmnMgr.getFormattedDecimal("999,999,990.00",totIni)%> </td>
				 <td align="right"><%=CmnMgr.getFormattedDecimal("999,999,990.00",totDepre)%> </td>
				 <td align="center">&nbsp;  </td>
				 <td align="right"><%=CmnMgr.getFormattedDecimal("999,999,990.00",totAct)%> </td>

  </tr>
	<%
	}
	%>



</table>
<%=fb.formEnd(true)%>

</body>
</html>
<%
}//GET
%>
