<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="htCtas" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCtas" scope="session" class="java.util.Vector"/>
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

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String nivel = request.getParameter("nivel");
if(nivel==null) nivel = "";

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (mode == null) mode = "add";

//convenio_cobertura_centro, convenio_exclusion_centro
String tab = request.getParameter("tab");
String index = request.getParameter("index");

if (id == null) id = "";
if (tab == null) tab = "";
if (index == null || index.equals("null")) index = "";
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

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

	String code = request.getParameter("code");
	String name = request.getParameter("name");
	String sbTable="";
	if (code == null) code = "";
	if (name == null) name = "";
	if (!code.trim().equals("")) appendFilter += " and a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6 like '%"+request.getParameter("code").toUpperCase()+"%'";
	if (!name.trim().equals("")) appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("name").toUpperCase()+"%'";

	if (fp.equalsIgnoreCase("reporte")||fp.equalsIgnoreCase("und"))
	{
		if (!nivel.trim().equals("") && !nivel.equals("T")) appendFilter += "and a.nivel <= "+nivel;
	if (fp.equalsIgnoreCase("und")){appendFilter +=" and a.status ='A'  and cp.codigo_prin in ('4','5','6') and cc.codigo_clase  = a.tipo_cuenta and cp.codigo_prin = cc.codigo_prin";sbTable +=",tbl_con_cla_ctas cc, tbl_con_ctas_prin cp";}
	sql = "select a.num_cuenta as cta, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.descripcion, a.compania from vw_con_catalogo_gral a"+sbTable+" where a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6 ";





		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	}

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
document.title = 'Cuentas Contables - '+document.title;
function setValues(k)
{
<%
if (fp.equalsIgnoreCase("orden_pago"))
{
%>
		window.opener.document.form1.cg_1_cta1<%=index%>.value = eval('document.result.cta1_'+k).value;
		window.opener.document.form1.cg_1_cta2<%=index%>.value = eval('document.result.cta2_'+k).value;
		window.opener.document.form1.cg_1_cta3<%=index%>.value = eval('document.result.cta3_'+k).value;
		window.opener.document.form1.cg_1_cta4<%=index%>.value = eval('document.result.cta4_'+k).value;
		window.opener.document.form1.cg_1_cta5<%=index%>.value = eval('document.result.cta5_'+k).value;
		window.opener.document.form1.cg_1_cta6<%=index%>.value = eval('document.result.cta6_'+k).value;
		window.opener.document.form1.cuenta_desc<%=index%>.value = eval('document.result.descripcion'+k).value;
<%
} else if (fp.equalsIgnoreCase("tipo_nota_cr_db"))
{
%>
		window.opener.document.form1.cta1.value = eval('document.result.cta1_'+k).value;
		window.opener.document.form1.cta2.value = eval('document.result.cta2_'+k).value;
		window.opener.document.form1.cta3.value = eval('document.result.cta3_'+k).value;
		window.opener.document.form1.cta4.value = eval('document.result.cta4_'+k).value;
		window.opener.document.form1.cta5.value = eval('document.result.cta5_'+k).value;
		window.opener.document.form1.cta6.value = eval('document.result.cta6_'+k).value;
		window.opener.document.form1.desc_cta.value = eval('document.result.descripcion'+k).value;
<%
}
%>
		window.close();
}

function chkAll(){
	var size = <%=al.size()%>;
	if(document.result.checkAll.checked){for(i=0;i<size;i++){eval('document.result.check'+i).checked=true;}
	} else {for(i=0;i<size;i++){eval('document.result.check'+i).checked=false;}}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CUENTAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("index",index)%>
		<tr class="TextFilter">
			<td width="40%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.textBox("code","",false,false,false,30)%>
			</td>
			<td width="40%">
				<cellbytelabel>Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("name","",false,false,false,40)%>
			</td>
			<td width="20%">
			<cellbytelabel>Hasta Nivel</cellbytelabel>:
			<%=fb.select("nivel","T=Todos,1=1,2=2,3=3,4=4,5=5,6=6",nivel,false,false,0,"Text10",null,"")%>
			<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("result",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextVal",""+nxtVal)%>
<%=fb.hidden("previousVal",""+preVal)%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("index",index)%>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%if(!fp.equalsIgnoreCase("tipo_nota_cr_db")){%>
				<%=fb.submit("saveNcont","Agregar y Continuar",true,false)%>
				<%=fb.submit("save","Agregar",true,false)%>
				<%}%>
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
<table width="99%" cellpadding="0" cellspacing="0" align="center">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<%if(fp.equals("reporte")||fp.equals("und")){%>
		<tr class="TextHeader" align="center">
			<td width="25%"><cellbytelabel>Cuenta</cellbytelabel></td>
			<td width="65%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="5%"><%if(fp.equalsIgnoreCase("reporte")||fp.equalsIgnoreCase("und")){%>
			<%=fb.checkbox("checkAll","",false,false,"","","onClick=\"javascript:chkAll();\"")%>
			<%}%></td>
		</tr>
		<%} else {%>
		<tr class="TextHeader" align="center">
			<td width="5%"><cellbytelabel>Cta 1</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta 2</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta 3</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta 4</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta 5</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta 6</cellbytelabel></td>
			<td width="65%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="5%">&nbsp;</td>
		</tr>
		<%}%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String ctas = cdo.getColValue("cta1")+"_"+cdo.getColValue("cta2")+"_"+cdo.getColValue("cta3")+"_"+cdo.getColValue("cta4")+"_"+cdo.getColValue("cta5")+"_"+cdo.getColValue("cta6");
	if(fp.equalsIgnoreCase("und")){ ctas = cdo.getColValue("cta1")+"-"+cdo.getColValue("cta2")+"-"+cdo.getColValue("cta3")+"-"+cdo.getColValue("cta4")+"-"+cdo.getColValue("cta5")+"-"+cdo.getColValue("cta6");}
%>
		<%=fb.hidden("cta1_"+i,cdo.getColValue("cta1"))%>
		<%=fb.hidden("cta2_"+i,cdo.getColValue("cta2"))%>
		<%=fb.hidden("cta3_"+i,cdo.getColValue("cta3"))%>
		<%=fb.hidden("cta4_"+i,cdo.getColValue("cta4"))%>
		<%=fb.hidden("cta5_"+i,cdo.getColValue("cta5"))%>
		<%=fb.hidden("cta6_"+i,cdo.getColValue("cta6"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("cta"+i,cdo.getColValue("cta"))%>
		<%if(fp.equals("reporte")||fp.equalsIgnoreCase("und")){%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td>&nbsp;&nbsp;&nbsp;<b><%=cdo.getColValue("cta")%></b></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center">
			<%=(vCtas.contains(ctas))?"Elegido":fb.checkbox("check"+i,""+i,false,false,"","","")%>
			</td>
		</tr>
		<%}%>
<%}%>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.submit("saveNcont","Agregar y Continuar",true,false)%>
				<%=fb.submit("save","Agregar",true,false)%>
				<%//=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
	int line = htCtas.size();
	if (fp.equalsIgnoreCase("reporte"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("secuen","0");
				cdo.addColValue("cta1",request.getParameter("cta1_"+i));
				cdo.addColValue("cta2",request.getParameter("cta2_"+i));
				cdo.addColValue("cta3",request.getParameter("cta3_"+i));
				cdo.addColValue("cta4",request.getParameter("cta4_"+i));
				cdo.addColValue("cta5",request.getParameter("cta5_"+i));
				cdo.addColValue("cta6",request.getParameter("cta6_"+i));
				cdo.addColValue("cuenta",request.getParameter("cta"+i));
				cdo.addColValue("descripcion_cuenta",request.getParameter("descripcion"+i));
				line++;

				String key = "";
				if (line < 10) key = "00"+line;
				else if (line < 100) key = "0"+line;
				else key = ""+line;
				cdo.addColValue("key",key);

				try
				{
					htCtas.put(key,cdo);
					String ctas = cdo.getColValue("cta1")+"_"+cdo.getColValue("cta2")+"_"+cdo.getColValue("cta3")+"_"+cdo.getColValue("cta4")+"_"+cdo.getColValue("cta5")+"_"+cdo.getColValue("cta6");
					vCtas.add(ctas);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//procedimiento
	else if (fp.equalsIgnoreCase("und"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("id","0");
				cdo.addColValue("cta1",request.getParameter("cta1_"+i));
				cdo.addColValue("cta2",request.getParameter("cta2_"+i));
				cdo.addColValue("cta3",request.getParameter("cta3_"+i));
				cdo.addColValue("cta4",request.getParameter("cta4_"+i));
				cdo.addColValue("cta5",request.getParameter("cta5_"+i));
				cdo.addColValue("cta6",request.getParameter("cta6_"+i));
				cdo.addColValue("cuenta",request.getParameter("cta"+i));
				cdo.addColValue("desc_cuenta",request.getParameter("descripcion"+i));
				cdo.addColValue("fecha_creacion",cDateTime);
				cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
				line++;

				String ctas = cdo.getColValue("cta1")+"-"+cdo.getColValue("cta2")+"-"+cdo.getColValue("cta3")+"-"+cdo.getColValue("cta4")+"-"+cdo.getColValue("cta5")+"-"+cdo.getColValue("cta6");
				cdo.addColValue("cuenta",ctas);

				String key = "";
				if (line < 10) key = "00"+line;
				else if (line < 100) key = "0"+line;
				else key = ""+line;
				cdo.addColValue("key",key);

				try
				{
					htCtas.put(key,cdo);
					vCtas.add(ctas);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//procedimiento
	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&fp="+fp+"&mode="+mode+"&id="+id+"&tab="+tab+"&index="+index+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&fp="+fp+"&mode="+mode+"&id="+id+"&tab="+tab+"&index="+index+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if (request.getParameter("saveNcont") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&fp="+fp+"&mode="+mode+"&id="+id+"&tab="+tab+"&index="+index+"&nextVal="+request.getParameter("nextVal")+"&previousVal="+request.getParameter("previousVal")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("reporte"))
	{
%>
	window.opener.location = '../contabilidad/detalle_rep_det.jsp?change=1&mode=<%=mode%>';
<%
	}else if (fp.equalsIgnoreCase("und"))
	{
%>
	window.opener.location = '../rhplanilla/unidadesadm_config.jsp?fp=<%=fg%>&change=1&tab=2&mode=<%=mode%>&id=<%=id%>';

<%
	}

%>
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>