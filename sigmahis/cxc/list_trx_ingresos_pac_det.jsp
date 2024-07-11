<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" /> 
<%
/*
=========================================================================
=========================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbFilterFF = new StringBuffer();
String fg = request.getParameter("fg");
String saldoIni = request.getParameter("saldoIni");
String paciente = request.getParameter("paciente");

if (fg == null) fg = "PAC";
if (saldoIni == null) saldoIni = "0";
if (paciente == null) paciente = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	String codigo = request.getParameter("codigo");
	String nombre = request.getParameter("nombre");
 	String fecha_ini = request.getParameter("fecha_ini");
	String fecha_fin = request.getParameter("fecha_fin");
	if (codigo == null) codigo = "";
 	if (fecha_ini == null) fecha_ini = "";
	if (fecha_fin == null) fecha_fin = "";    
	if(!fecha_ini.trim().equals("")){sbFilter.append(" and fecha >= to_date('"); sbFilter.append(fecha_ini); sbFilter.append("','dd/mm/yyyy')"); }
	if(!fecha_fin.trim().equals("")){sbFilter.append(" and fecha <= to_date('"); sbFilter.append(fecha_fin); sbFilter.append("','dd/mm/yyyy')");}
	if (!codigo.trim().equals("")) { sbFilter.append(" and x.pac_id="); sbFilter.append(codigo);}
	if(fg.trim().equals("EMP")){ sbFilter.append(" and nvl(x.aseguradora,0) <> 0 ");}
	
	sbSql.append(" select 0 as saldo_ini, sum(cargos) as cargos,sum(factura_pac) as factura_pac,sum(factura_emp)as factura_emp,sum(desc_pac) as desc_pac,sum(desc_emp) as desc_emp,sum(paquete) as paquete,sum(ajuste_pac) as ajuste_pac,sum(ajuste_emp) as ajuste_emp ,(sum(cargos) +decode(get_sec_comp_param(x.compania,'CXC_APLICAR_PAQUETE_CS'),'S',sum(paquete),0)) - (sum(desc_pac) + sum(desc_emp)) - (sum(ajuste_pac) +sum(ajuste_emp)) as saldo ");
	if(fg.trim().equals("EMP"))sbSql.append(",x.aseguradora as codigo,(select (select nombre from tbl_adm_empresa where codigo = x.aseguradora) from dual) as nombre ");
	else sbSql.append(",pac_id as codigo,(select (select nombre_paciente from vw_adm_paciente where pac_id =x.pac_id) from dual) as nombre ");
	sbSql.append(" from vw_cxc_mov_adm x where compania =");
	sbSql.append(session.getAttribute("_companyId")); 	
 	sbSql.append(sbFilter);
 	
	if(fg.trim().equals("EMP")){sbSql.append(" group by pac_id ,x.compania,x.aseguradora");sbSql.append(" order by aseguradora");}
	else if(fg.trim().equals("PAC")){sbSql.append(" group by pac_id ,x.compania");/*sbSql.append(" order by aseguradora");*/}
         
 	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
 
 	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";
	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);
	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;
	if (rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Saldos - '+document.title;
var forceList = true;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
 
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
  <tr>
	<td class="TextRow01"><%=paciente%>&nbsp;&nbsp;&nbsp;&nbsp;SALDO INICIAL &nbsp;&nbsp;<%=saldoIni%>
    </td>
  </tr>
  <tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
 		<tr class="TextHeader" align="center"> 
			<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="20%"><cellbytelabel>Nombre</cellbytelabel></td> 
			<td width="7%"><cellbytelabel>S. Anterior</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Cargos/Dev. </cellbytelabel></td>
			<td width="7%"><cellbytelabel>Facturas Pac.</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Facturas Emp.</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Desc Pac.</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Desc Emp.</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Ajuste Pac.</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Ajuste Emp.</cellbytelabel></td> 
			<td width="7%">&nbsp;<cellbytelabel><!--Saldo--></cellbytelabel></td> 
			<td width="7%"><cellbytelabel>Paquete</cellbytelabel></td>
			<td width="2%">&nbsp;</td> 
		</tr>
<%
double saldoTotal =0.00,saldo=0.00,saldoAnt=0.00,facturas_pac=0.00,facturas_emp=0.00,desc_pac=0.00,desc_emp=0.00,saldoFin=0.00,ajuste_pac=0.00,ajuste_emp=0.00,cargos=0.00,paquete=0.00;

for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	saldoAnt += Double.parseDouble(cdo.getColValue("saldo_ini"));
	cargos += Double.parseDouble(cdo.getColValue("cargos"));	
	facturas_pac += Double.parseDouble(cdo.getColValue("factura_pac"));	
	facturas_emp += Double.parseDouble(cdo.getColValue("factura_emp"));
	desc_pac += Double.parseDouble(cdo.getColValue("desc_pac"));	
	desc_emp += Double.parseDouble(cdo.getColValue("desc_emp"));
	ajuste_pac += Double.parseDouble(cdo.getColValue("ajuste_pac"));
	ajuste_emp = Double.parseDouble(cdo.getColValue("ajuste_emp"));
	paquete += Double.parseDouble(cdo.getColValue("paquete"));
	saldoFin += Double.parseDouble(cdo.getColValue("saldo"));
	saldo  = Double.parseDouble(cdo.getColValue("saldo"));
	saldoTotal += Double.parseDouble(cdo.getColValue("saldo_ini"))+ Double.parseDouble(cdo.getColValue("saldo"));

%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
 			<td align="center"><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("nombre")%></td> 
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_ini"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cargos"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("factura_pac"))%></td>
			<td align="right"><a href="javascript:view('<%=cdo.getColValue("pac_id")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("factura_emp"))%></a></td>			
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("desc_pac"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("desc_emp"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_pac"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_emp"))%></td>
			<td align="right"><!--
			  <%if(saldo<0){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
				<%=CmnMgr.getFormattedDecimal(saldo)%>
			  <%if(saldo<0){%>&nbsp;&nbsp;</label></label><%}%>-->
			</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("paquete"))%></td> 
			<td align="center">&nbsp;</td> 
 		</tr>
<%
}
%>
	<tr class="TextHeader02" align="center">
			<td colspan="2" align="right">TOTALES PAGINA</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(saldoAnt)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cargos)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(facturas_pac)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(facturas_emp)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(desc_pac)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(desc_emp)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(ajuste_pac)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(ajuste_emp)%></td>
			<td align="right"><%//=CmnMgr.getFormattedDecimal(saldoFin)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(paquete)%></td>
			<td>&nbsp;</td> 
		</tr>

		 <%=fb.formEnd(true)%>
   </table>
 </div>
</div>
 <!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>

</table>
</body>
</html>
<%
}
%>