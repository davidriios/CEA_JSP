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

ArrayList al = new ArrayList();
ArrayList alTot = new ArrayList();
ArrayList alDesc = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

String sql = "";
String sqlT = "";
 
String id = request.getParameter("id"); 
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String compania =  (String) session.getAttribute("_companyId");	
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes"); 
String codes = request.getParameter("codes"); 

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql= "select all to_char(a.fecha_de_entrada,'dd/mm/yyyy') entrada, nvl(a.valor_inicial,0)as valor_inicial , nvl(m.monto_depre,0)as valor_deprem, to_char(a.final_garantia,'dd/mm/yy') final, a.secuencia, nvl(m.valor_activo_act,0)  valor_actual, d.descripcion, ue.codigo, ue.descripcion unidad, a.observacion, e.descripcion desr, m.depre_acum_act from tbl_con_temporal_depreciacion m, tbl_con_activos a, tbl_con_detalle_otro d, tbl_sec_unidad_ejec ue, tbl_con_especificacion e where a.secuencia = m.activo_sec and a.compania = m.compania and a.compania ="+(String) session.getAttribute("_companyId")+" and a.cuentah_detalle = d.codigo_detalle and a.compania = d.cod_compania and a.compania = ue.compania and a.ue_codigo = ue.codigo and m.cod_ano = "+anio+" and m.cod_mes = "+mes+" and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec and e.compania = a.compania and e.cta_control||e.codigo_espec = '"+codes+"' order by a.fecha_de_entrada, a.secuencia";
	al = SQLMgr.getDataList(sql);
	
	//sqlT= "select sum(nvl(a.valor_inicial,0)) tot_inicial, sum(nvl(m.monto_depre,0)) tot_deprem, sum(nvl(m.depre_acum_act,0)) tot_actual from tbl_con_temporal_depreciacion m, tbl_con_activos a, tbl_con_detalle_otro d, tbl_sec_unidad_ejec ue, tbl_con_especificacion e where a.secuencia = m.activo_sec and a.compania = m.compania and a.compania ="+(String) session.getAttribute("_companyId")+" and a.cuentah_detalle = d.codigo_detalle and a.compania = d.cod_compania and a.compania = ue.compania and a.ue_codigo = ue.codigo and m.cod_ano = "+anio+" and m.cod_mes = "+mes+" and e.cta_control = a.cuentah_activo and e.codigo_espec = a.cuentah_espec  and e.cta_control||e.codigo_espec = '"+codes+"' and e.compania = a.compania";
//	alTot = SQLMgr.getData(sql);


	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Depreciación Mensual - '+document.title;


function winClose()
{
parent.SelectSlide('drs<%=id%>','list','clear')
parent.hidePopWin(true);
}


function printList(anio,mes,codes)
{
	abrir_ventana('../activos/print_list_depreciacion_acum.jsp?anio='+anio+'&mes='+mes+'&codes='+codes);
}
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
<%=fb.hidden("codes",codes)%>
<table width="100%" cellpadding="1" cellspacing="1">
 
  <tr>
    <td align="right" colspan="8">&nbsp;
        <%
//if (SecMgr.checkAccess(session.getId(),"0"))
//{
%>
        <a href="javascript:printList('<%=anio%>','<%=mes%>','<%=codes%>')" class="Link00">[ Imprimir Depreciación ]</a>
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
    <td colspan="6" align="center">ACTIVOS POR CUENTA CONTABLE</td>
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
	    <td align="left" colspan="8"> TIPO CUENTA:&nbsp; <%=cdo.getColValue("desr")%> </td>
  </tr>
	 <tr class="TextRow01">
	    <td align="left" colspan="8"> UNIDAD:&nbsp; [ <%=cdo.getColValue("codigo")%> ] <%=cdo.getColValue("unidad")%> </td>
  </tr>
		 
		 
	<tr align="center" class="TextHeader">
    <td width="10%">Sec</td>
    <td width="20%">Descripción</td>
    <td width="20%">Observación</td>
    <td width="10%">Entrada</td>
    <td width="10%">Valor Inicial</td>
    <td width="10%">Valor Deprec.</td>
    <td width="10%">Fecha Final</td>
		<td width="10%">Depr. Acumulada</td>
  </tr>
	<% } %>	 
		 
	<tr class="<%=color%>">	
    <td align="center"> <%=cdo.getColValue("secuencia")%> </td>
		<td align="left"> <%=cdo.getColValue("observacion")%> </td>
		<td align="left"> <%=cdo.getColValue("descripcion")%> </td>
		<td align="center"> <%=cdo.getColValue("entrada")%> </td>
		<td align="right"><%=CmnMgr.getFormattedDecimal("999,999,990.00",cdo.getColValue("valor_inicial"))%> </td>
		<td align="right"><%=CmnMgr.getFormattedDecimal("999,999,990.00",cdo.getColValue("valor_deprem"))%> </td>
		<td align="center"> <%=cdo.getColValue("final")%> </td>
		<td align="right"><%=CmnMgr.getFormattedDecimal("999,999,990.00",cdo.getColValue("depre_acum_act"))%> </td>
  </tr>
 
 <%
 totIni   += Double.parseDouble(cdo.getColValue("valor_inicial"));
		totDepre += Double.parseDouble(cdo.getColValue("valor_deprem"));
		totAct   += Double.parseDouble(cdo.getColValue("depre_acum_act"));
}
%>
				
	<%
				{
					String color1 = "TextRow03";
				%>
		
	<tr class="<%=color1%>">	
    <td colspan="4" align="right">&nbsp; Total &nbsp;&nbsp; </td>
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
