<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.Comprobante"%>
<%@ page import="issi.contabilidad.CompDetails"%>
<%@ page import="issi.presupuesto.AjusteDetail"%> 
<%@ page import="issi.presupuesto.CompDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCta" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCta" scope="session" class="java.util.Vector" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();

int rowCount = 0;
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String tipoAjuste = request.getParameter("tipoAjuste");
int p_anio = 0;
int lastLineNo = 0;
String anioRef = request.getParameter("anioRef");
String numDocRef = request.getParameter("numDocRef");
String tipoComRef = request.getParameter("tipoComRef");
StringBuffer sbSql = new StringBuffer();
if(fp==null) fp = "";
if(fg==null) fg = "";
if(request.getParameter("p_anio")!=null) p_anio = Integer.parseInt(request.getParameter("p_anio"));
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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
	
	String cta1="",cta2="",cta3="",descripcion="", mes="",tipoInv="",unidad="",anio="";
	if (request.getParameter("cta1") != null && !request.getParameter("cta1").equals(""))
	{
		appendFilter += " and c.cta1 = "+request.getParameter("cta1");
		cta1 = request.getParameter("cta1");
	}
	if (request.getParameter("cta2") != null && !request.getParameter("cta2").equals(""))
	{
		appendFilter += " and c.cta2 = "+request.getParameter("cta2");
		cta2 = request.getParameter("cta2");
	}
	if (request.getParameter("cta3") != null && !request.getParameter("cta3").equals(""))
	{
		appendFilter += " and c.cta3 = "+request.getParameter("cta3");
		cta3 = request.getParameter("cta3");
	}
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").equals(""))
	{
		appendFilter += " and upper(c.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		descripcion = request.getParameter("descripcion");
	}
	
	if (request.getParameter("anioIm") != null && !request.getParameter("anioIm").trim().equals(""))
	{
		appendFilter += " and c.anio = "+request.getParameter("anioIm");
    	anio = request.getParameter("anioIm");
	} 
	if (request.getParameter("unidad") != null && !request.getParameter("unidad").trim().equals("") ){
		appendFilter += " and c.codigo_ue = "+request.getParameter("unidad");
    	unidad = request.getParameter("unidad");
	} 
	
	if (request.getParameter("tipoInv") != null && !request.getParameter("tipoInv").trim().equals("") ){
		appendFilter += " and c.tipo_inv = "+request.getParameter("tipoInv");
    	tipoInv = request.getParameter("tipoInv");
	}	
	if(fp.trim().equals("PRESPO")){if(!UserDet.getUserProfile().contains("0") && tipoAjuste.trim().equals("2")){
		appendFilter +=" and codigo in(";
			if(session.getAttribute("_ua")!=null) appendFilter += CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua")); 
			else appendFilter +="-1";
			appendFilter +=")";
	}}
	

	if(fp.trim().equals("PRESPO")){ sql="select cm.anio, cm.cta1||'-'||cm.cta2||'-'||cm.cta3||'-'||cm.cta4||'-'||cm.cta5||'-'||cm.cta6 numCuenta,initcap(c.descripcion)  descripcion,       nvl(cm.compania_origen,cm.compania)  companiaOrigen,cm.cta1 cta1 ,cm.cta2 cta2 ,cm.cta3 cta3 ,cm.cta4 cta4 ,cm.cta5 cta5 ,cm.cta6 cta6 ,cm.compania compania,  cm.mes mes,    (nvl(cm.traslado,0) + nvl(cm.asignacion,0) + nvl(cm.redistribuciones,0) - nvl(cm.consumido,0)) dspAsignacion from tbl_con_cuenta_mensual cm , tbl_con_catalogo_gral c where (c.cta1 =  cm.cta1 and c.cta2 =  cm.cta2 and c.cta3 =  cm.cta3 and c.cta4 =  cm.cta4 and c.cta5 =  cm.cta5 and c.cta6 =  cm.cta6 and c.compania =  nvl(cm.compania_origen,cm.compania)) and cm.anio in (select ano from tbl_con_estado_meses where estatus = 'ACT' and cod_cia = "+(String) session.getAttribute("_companyId")+") and cm.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by  cm.unidad,cm.mes,c.cta1, c.cta2, c.cta3,c.cta4,c.cta5,c.cta6 ";}
	else if(fp.trim().equals("PRESPI") )
	{
	sql="select c.anio anio , c.tipo_inv tipoInv , c.compania , c.codigo_ue codigoUe , c.consec ,c.mes,c.estado, (nvl(c.traslado,0) + nvl(c.aprobado,0) + nvl(c.redistribuciones,0) - nvl(c.ejecutado,0)) dspAsignacion, c.descripcion,(select descripcion from tbl_con_tipo_inversion  where tipo_inv=c.tipo_inv and compania = c.compania )descTipoInv,(select descripcion from tbl_sec_unidad_ejec where codigo = c.codigo_ue and compania = c.compania)descUnidad from tbl_con_inversion_mensual c where c.estado in ('ACT','INA') and c.compania ="+(String) session.getAttribute("_companyId")+appendFilter+" order by c.anio,c.tipo_inv , c.compania , c.codigo_ue, c.consec , c.mes ";
	}
	else if(fp.trim().equals("CF") )
	{
	sql="select c.anio anio, c.tipo_inv tipoInv, c.compania, c.codigo_ue codigoUe,c.consec,c.mes, nvl(c.aprobado,0)aprobado,nvl(c.ejecutado,0) ejecutado , nvl(c.aprobado,0) - nvl(c.ejecutado,0) dspAsignacion , c.descripcion,(select descripcion from tbl_con_tipo_inversion  where tipo_inv=c.tipo_inv and compania = c.compania )descTipoInv,(select descripcion from tbl_sec_unidad_ejec where codigo = c.codigo_ue and compania = c.compania)descUnidad from tbl_con_inversion_mensual c /*where estado = 'ACT'*/ order by c.anio , c.tipo_inv,c.compania,c.codigo_ue, c.consec , c.mes";
	}
	else if(fp.trim().equals("AC") )
	{
	sql="select comp.anio||' '||comp.tipo_inv||' '||comp.compania||' '||comp.codigo_ue||' '||comp.consec cuenta ,comp.anio anio ,comp.tipo_inv tipoInv ,comp.compania ,comp.codigo_ue codigoUe,comp.consec ,comp.mes ,comp.anio_cfi||' '||comp.tipo_com||' '||comp.num_doc documento ,comp.anio_cfi anioCfi ,comp.tipo_com tipoCom ,comp.num_doc numDoc ,comp.monto_de_ajuste montoAjuste ,(nvl(comp.monto_original,0) + nvl(monto_de_ajuste,0)) dspAsignacion,(select descripcion from tbl_con_tipo_inversion  where tipo_inv=comp.tipo_inv and compania = comp.compania )descTipoInv,(select descripcion from tbl_sec_unidad_ejec where codigo = comp.codigo_ue and compania = comp.compania)descUnidad ,'' descripcion from tbl_con_compromiso_inversion comp where comp.anio = "+anioRef+" and comp.tipo_com = "+tipoComRef+" and comp.num_doc = "+numDocRef+" and nvl(comp.monto_original,0) > nvl(monto_de_ajuste,0) * -1 order by comp.anio ,comp.tipo_inv ,comp.compania ,comp.codigo_ue ,comp.consec ,comp.mes ,comp.anio_cfi ,comp.tipo_com ,comp.num_doc";
	}
	
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

  if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";
  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";

  int nVal, pVal;
  int preVal=Integer.parseInt(previousVal);
  int nxtVal=Integer.parseInt(nextVal);
  if (nxtVal<=rowCount) nVal=nxtVal;
  else nVal=rowCount;
  if(rowCount==0) pVal=0;
  else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Contabilidad - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - SELECCION DE CUENTAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("p_anio",""+p_anio)%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("tipoAjuste",""+tipoAjuste)%>
<%=fb.hidden("anioRef",""+anioRef)%>
<%=fb.hidden("numDocRef",""+numDocRef)%>
<%=fb.hidden("tipoComRef",""+tipoComRef)%>

<%if(fp.trim().equals("PRESPO")){%>
			<td width="20%">
				<cellbytelabel>Cta 1</cellbytelabel>
				<%=fb.intBox("cta1",cta1,false,false,false,15)%>
			</td>
			<td width="20%">
				<cellbytelabel>Cta 2</cellbytelabel>
				<%=fb.intBox("cta2",cta2,false,false,false,15)%>
			</td>
			<td width="20%">
				<cellbytelabel>Cta 3</cellbytelabel>
				<%=fb.intBox("cta3",cta3,false,false,false,15)%>
			</td>
			
			<td width="40%">
				<cellbytelabel>Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("descripcion","",false,false,false,20)%>
				<%=fb.submit("go","Ir")%>
			</td><%}else if(fp.trim().equals("PRESPI")){%><td width="20%">
				<cellbytelabel>A&ntilde;o</cellbytelabel>
				<%=fb.intBox("anioIm",anio,false,false,false,10)%>
			</td>
			<td width="40%">Tipo De Inversón<%=fb.select(ConMgr.getConnection(), "select a.tipo_inv, a.descripcion||' - '||a.compania||' - '||(select nombre from tbl_sec_compania where codigo =a.compania) from tbl_con_tipo_inversion a where a.compania = "+(String) session.getAttribute("_companyId")+" order by a.descripcion", "tipoInv",tipoInv,false,false, 0,"S")%>
			</td>
			<td width="40%"><%
			  sbSql = new StringBuffer();
if(!UserDet.getUserProfile().contains("0")){
	if(session.getAttribute("_ua")!=null){
	sbSql.append(" and b.codigo in (");
	sbSql.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_ua")));
	sbSql.append(")");}
	else sbSql.append(" and b.codigo in (-1)");
}%> 

				<cellbytelabel>Unidad</cellbytelabel> <%=fb.select(ConMgr.getConnection(), "select b.codigo unidad, b.codigo||' - '||b.descripcion, b.descripcion x from tbl_sec_unidad_ejec b where b.compania = " + (String) session.getAttribute("_companyId")+sbSql.toString()+"  order by b.descripcion, b.codigo", "unidad",unidad, false, false, 0, "", "", "", "Unidad Administrativa", "")%>

				<%=fb.submit("go","Ir")%>
			</td>
			<%}%>
<%=fb.formEnd()%>
		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("results",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("p_anio",""+p_anio)%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("cta1",cta1)%>
<%=fb.hidden("cta2",cta2)%>
<%=fb.hidden("cta3",cta3)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("tipoAjuste",""+tipoAjuste)%>
<%=fb.hidden("anioRef",""+anioRef)%>
<%=fb.hidden("numDocRef",""+numDocRef)%>
<%=fb.hidden("tipoComRef",""+tipoComRef)%>


<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
</table>	

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder" colspan="2">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<%if(fp.trim().equals("PRESPO")){%>
		<tr class="TextHeader" align="center">
			<%if(fp.trim().equals("PRESPO")){%><td width="5%">Mes</td><%}%>
			<td width="5%"><cellbytelabel>Cta1</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta2</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta3</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta4</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta5</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta6</cellbytelabel></td>
			<td width="60%"><cellbytelabel>Descrpci&oacute;n</cellbytelabel></td>
			<td width="10%">&nbsp;</td>
		</tr>
		<%}else if(fp.trim().equals("PRESPI") || fp.trim().equals("CF")|| fp.trim().equals("AC")){%>
		<tr class="TextHeader" align="center">
			<td width="5%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Compa&ntilde;ia</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Tipo Inv</cellbytelabel>.</td>
			<td width="5%"><cellbytelabel>Mes</cellbytelabel></td>
			<td width="5%"><cellbytelabel>consec</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Asignaci&oacute;n</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Unidad</cellbytelabel></td>
			<td width="60%"><cellbytelabel>Descrpci&oacute;n</cellbytelabel></td>
			<td width="10%">&nbsp;</td>
		</tr>
		<%}%>
		
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String key ="";
	 key =cdo.getColValue("cta1")+"-"+cdo.getColValue("cta2")+"-"+cdo.getColValue("cta3")+"-"+cdo.getColValue("cta4")+"-"+cdo.getColValue("cta5")+"-"+cdo.getColValue("cta6");
	if(fp.trim().equals("PRESPO")||fp.trim().equals("PRESPI")){ key =cdo.getColValue("compania")+"-"+cdo.getColValue("anio")+"-"+cdo.getColValue("mes")+"-"+cdo.getColValue("cta1")+"-"+cdo.getColValue("cta2")+"-"+cdo.getColValue("cta3")+"-"+cdo.getColValue("cta4")+"-"+cdo.getColValue("cta5")+"-"+cdo.getColValue("cta6");}
	else if(fp.trim().equals("PRESPI")) key =cdo.getColValue("compania")+"-"+cdo.getColValue("anio")+"-"+cdo.getColValue("mes")+"-"+cdo.getColValue("codigoUe")+"-"+cdo.getColValue("consec");
	else if(fp.trim().equals("CF")) key =cdo.getColValue("tipoInv")+"-"+cdo.getColValue("anio")+"-"+cdo.getColValue("consec")+"-"+cdo.getColValue("codigoUe")+"-"+cdo.getColValue("compania")+"-"+cdo.getColValue("mes");

%>
<%=fb.hidden("cta1"+i,cdo.getColValue("cta1"))%>
<%=fb.hidden("cta2"+i,cdo.getColValue("cta2"))%>
<%=fb.hidden("cta3"+i,cdo.getColValue("cta3"))%>
<%=fb.hidden("cta4"+i,cdo.getColValue("cta4"))%>
<%=fb.hidden("cta5"+i,cdo.getColValue("cta5"))%>
<%=fb.hidden("cta6"+i,cdo.getColValue("cta6"))%>
<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
<%=fb.hidden("recibe_mov"+i,cdo.getColValue("recibe_mov"))%>
<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
<%=fb.hidden("mes"+i,cdo.getColValue("mes"))%>
<%=fb.hidden("dspAsignacion"+i,cdo.getColValue("dspAsignacion"))%>
<%=fb.hidden("companiaOrigen"+i,cdo.getColValue("companiaOrigen"))%>
<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
<%=fb.hidden("numCuenta"+i,cdo.getColValue("numCuenta"))%>
<%=fb.hidden("tipoInv"+i,cdo.getColValue("tipoInv"))%>
<%=fb.hidden("consec"+i,cdo.getColValue("consec"))%>
<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
<%=fb.hidden("codigoUe"+i,cdo.getColValue("codigoUe"))%>
<%=fb.hidden("descUnidad"+i,cdo.getColValue("descUnidad"))%>
<%=fb.hidden("descTipoInv"+i,cdo.getColValue("descTipoInv"))%>

	<%if(fp.trim().equals("PRESPO")){%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
			<%if(fp.trim().equals("PRESPO")){%><td><%=fb.select("mesDesde"+i,"01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",cdo.getColValue("mes"),false,true,0,null,null,null,"","")%></td><%}%>
			<td><%=cdo.getColValue("cta1")%></td>
			<td><%=cdo.getColValue("cta2")%></td>
			<td><%=cdo.getColValue("cta3")%></td>
			<td><%=cdo.getColValue("cta4")%></td>
			<td><%=cdo.getColValue("cta5")%></td>
			<td><%=cdo.getColValue("cta6")%></td>
			<td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td><%if(fp.trim().equals("PRESPO")||fp.trim().equals("PRESPI")){%><%=(vCta.contains(key))?"Elegido":fb.checkbox("check"+i,key,false,false)%> <%}else{%><%=fb.checkbox("check"+i,key,false,false)%><%=(vCta.contains(key))?"Elegido":""%><%}%></td>
		</tr>
			
		
		<%}else if(fp.trim().equals("PRESPI") ||fp.trim().equals("CF")||fp.trim().equals("AC")){%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
			<td><%=cdo.getColValue("anio")%></td>
			<td><%=cdo.getColValue("compania")%></td>
			<td><%=cdo.getColValue("descTipoInv")%></td>
			<td><%=fb.select("mes"+i,"01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",cdo.getColValue("mes"),false,true,0,null,null,null,"","")%></td>
			<td><%=cdo.getColValue("consec")%></td>
			<td><%=cdo.getColValue("dspAsignacion")%></td>
			<td><%=cdo.getColValue("descUnidad")%></td>
			<td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td><%=(vCta.contains(key))?"Elegido":fb.checkbox("check"+i,key,false,false)%></td>
		</tr>
		
		<%}%>
	
<%
}

if (al.size()==0)
{
%>
		<tr>
			<td align="center" colspan="8"><cellbytelabel>No registros encontrados</cellbytelabel>.</td>
		</tr>
<%
}
%>		
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd()%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	
	
	if(fp.trim().equals("PRESPO")||fp.trim().equals("PRESPI")){
	
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			AjusteDetail ajCta = new AjusteDetail();

			ajCta.setAnio(request.getParameter("anio"+i));
			ajCta.setMes(request.getParameter("mes"+i));
			ajCta.setCta1(request.getParameter("cta1"+i));
			ajCta.setCta2(request.getParameter("cta2"+i));
			ajCta.setCta3(request.getParameter("cta3"+i));
			ajCta.setCta4(request.getParameter("cta4"+i));
			ajCta.setCta5(request.getParameter("cta5"+i));
			ajCta.setCta6(request.getParameter("cta6"+i));
			ajCta.setDescCuenta(request.getParameter("descripcion"+i));
			ajCta.setCompaniaOrigen(request.getParameter("companiaOrigen"+i));
			ajCta.setCompania(request.getParameter("compania"+i));
			ajCta.setDspAsignacion(request.getParameter("dspAsignacion"+i));
			ajCta.setNumCuenta(request.getParameter("numCuenta"+i));
			
			ajCta.setConsec(request.getParameter("consec"+i));
			ajCta.setCodigoUe(request.getParameter("codigoUe"+i));
			
			ajCta.setTipoInv(request.getParameter("tipoInv"+i));
			ajCta.setDescUnidad(request.getParameter("descUnidad"+i));
			ajCta.setAnioIm(request.getParameter("anio"+i));
			
			ajCta.setMontoOrigen("0");
			lastLineNo++;

			String key = "";
			if (lastLineNo < 10) key = "00"+lastLineNo;
			else if (lastLineNo < 100) key = "0"+lastLineNo;
			else key = ""+lastLineNo;
			ajCta.setKey(key);
	
			try
			{
				iCta.put(ajCta.getKey(), ajCta);
				if(fp.trim().equals("PRESPO"))vCta.add(ajCta.getCompania()+"-"+ajCta.getAnio()+"-"+ajCta.getMes()+"-"+ajCta.getCta1()+"-"+ajCta.getCta2()+"-"+ajCta.getCta3()+"-"+ajCta.getCta4()+"-"+ajCta.getCta5()+"-"+ajCta.getCta6());
				else vCta.add(ajCta.getCompania()+"-"+ajCta.getAnio()+"-"+ajCta.getMes()+"-"+ajCta.getCodigoUe()+"-"+ajCta.getConsec());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	   }//for
	}
	else if(fp.trim().equals("CF")||fp.trim().equals("AC")){
	
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			CompDetail ajCta = new CompDetail();

			ajCta.setAnio(request.getParameter("anio"+i));
			ajCta.setMes(request.getParameter("mes"+i));
			ajCta.setCompania(request.getParameter("compania"+i));
			ajCta.setSaldo(request.getParameter("dspAsignacion"+i));
		
			ajCta.setConsec(request.getParameter("consec"+i));
			ajCta.setCodigoUe(request.getParameter("codigoUe"+i));
			
			ajCta.setTipoInv(request.getParameter("tipoInv"+i));
			//ajCta.setDescTipoInv(request.getParameter("descTipoInv"+i));
			ajCta.setDescUnidad(request.getParameter("descUnidad"+i));
			ajCta.setDescripcion(request.getParameter("descripcion"+i));
			
			ajCta.setDescripcion(request.getParameter("descripcion"+i));
			
			lastLineNo++;
			if(fg.trim().equals("CF"))
			{
				ajCta.setMontoOriginal("0");
				ajCta.setMontoAjuste("0");
				ajCta.setUsuarioMod((String) session.getAttribute("_userName"));
				ajCta.setFechaMod(cDateTime);
			}
			else 
			{
				ajCta.setMontoOriginal(request.getParameter("dspAsignacion"+i));
				ajCta.setMontoAjuste("0");
				ajCta.setAnioRef(request.getParameter("anioRef"));
				ajCta.setNumDocRef(request.getParameter("numDocRef"));
				ajCta.setTipoComRef(request.getParameter("tipoComRef"));
				
			}

			String key = "";
			if (lastLineNo < 10) key = "00"+lastLineNo;
			else if (lastLineNo < 100) key = "0"+lastLineNo;
			else key = ""+lastLineNo;
			ajCta.setKey(key);
	
			try
			{
				iCta.put(ajCta.getKey(), ajCta);
				if(fp.trim().equals("CF"))vCta.add(ajCta.getTipoInv()+"-"+ajCta.getAnio()+"-"+ajCta.getConsec()+"-"+ajCta.getCodigoUe()+"-"+ajCta.getCompania()+"-"+ajCta.getMes());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	   }//for
	}
	
	

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&fg="+fg+"&fp="+fp+"&p_anio="+p_anio+"&lastLineNo="+lastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&cta1="+request.getParameter("cta1")+"&cta2="+request.getParameter("cta2")+"&cta3="+request.getParameter("cta3")+"&descripcion="+request.getParameter("descripcion")+"&tipoAjuste="+request.getParameter("tipoAjuste")+"&anioRef="+request.getParameter("anioRef")+"&numDocRef="+request.getParameter("numDocRef")+"&tipoComRef="+request.getParameter("tipoComRef"));
		
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&fg="+fg+"&fp="+fp+"&p_anio="+p_anio+"&lastLineNo="+lastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&cta1="+request.getParameter("cta1")+"&cta2="+request.getParameter("cta2")+"&cta3="+request.getParameter("cta3")+"&descripcion="+request.getParameter("descripcion")+"&tipoAjuste="+request.getParameter("tipoAjuste")+"&anioRef="+request.getParameter("anioRef")+"&numDocRef="+request.getParameter("numDocRef")+"&tipoComRef="+request.getParameter("tipoComRef"));
		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("comp_diario")||fp.equalsIgnoreCase("EC")||fp.equalsIgnoreCase("RE"))
	{
%>
	window.opener.location = '../contabilidad/reg_comp_diario_det.jsp?change=1&mode=<%=mode%>&fg=<%=fg%>&lastLineNo=<%=lastLineNo%>';
<%
	}else if (fp.equalsIgnoreCase("PRESPO")||fp.equalsIgnoreCase("PRESPI"))
	{
%>
	window.opener.location = '../presupuesto/reg_ajuste_presupuesto_det.jsp?change=1&mode=<%=mode%>&fg=<%=fg%>&lastLineNo=<%=lastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("CF")||fp.equalsIgnoreCase("AC"))
	{
%>
	window.opener.location = '../presupuesto/reg_compromisos_pres_det.jsp?change=1&mode=<%=mode%>&fg=<%=fg%>&lastLineNo=<%=lastLineNo%>';
<%
	}

%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
	
}//POST
%>
