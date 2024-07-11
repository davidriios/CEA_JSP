<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
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
<jsp:useBean id="iNotasCtas" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vNotasCtas" scope="session" class="java.util.Vector"/>
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
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (mode == null) mode = "add";

//convenio_cobertura_centro, convenio_exclusion_centro
String tab = request.getParameter("tab");
String index = request.getParameter("index");

if (id == null) id = "";
if (tab == null) tab = "";
if (index == null || index.equals("null")) index = "";

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
	String descripcion = "",cta1="",cta2="",cta3="",cta4="",cta5="",cta6="";
	 if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
	appendFilter += "and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }
  if (request.getParameter("cta1") != null && !request.getParameter("cta1").trim().equals(""))
  {
	appendFilter += "and a.cta1 like '%"+request.getParameter("cta1").toUpperCase()+"%'";
    cta1 = request.getParameter("cta1");
  }
  if (request.getParameter("cta2") != null && !request.getParameter("cta2").trim().equals(""))
  {
	appendFilter += "and a.cta2 like '%"+request.getParameter("cta2").toUpperCase()+"%'";
    cta2 = request.getParameter("cta2");
  }
  if (request.getParameter("cta3") != null && !request.getParameter("cta3").trim().equals(""))
  {
	appendFilter += "and a.cta3 like '%"+request.getParameter("cta3").toUpperCase()+"%'";
    cta3 = request.getParameter("cta3");
  }
  if (request.getParameter("cta4") != null && !request.getParameter("cta4").trim().equals(""))
  {
	appendFilter += "and a.cta4 like '%"+request.getParameter("cta4").toUpperCase()+"%'";
    cta4 = request.getParameter("cta4");
  }
  if (request.getParameter("cta5") != null && !request.getParameter("cta5").trim().equals(""))
  {
	appendFilter += "and a.cta5 like '%"+request.getParameter("cta5").toUpperCase()+"%'";
    cta5 = request.getParameter("cta5");
  }
  if (request.getParameter("cta6") != null && !request.getParameter("cta6").trim().equals(""))
  {
	appendFilter += "and a.cta6 like '%"+request.getParameter("cta6").toUpperCase()+"%'";
    cta6 = request.getParameter("cta6");
  }


	if (fp.equalsIgnoreCase("orden_pago") || fp.equalsIgnoreCase("fact_prov") || fp.equalsIgnoreCase("reporte") || fp.equalsIgnoreCase("fact_prov") || fp.equalsIgnoreCase("tipo_nota_cr_db")||fp.equalsIgnoreCase("ajuste_cxp"))
	{
	if (request.getParameter("cta6") != null){
  sql = "select a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6 as cta, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.descripcion, a.compania from tbl_con_catalogo_gral a where a.status ='A' and a.recibe_mov ='S' and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6";
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
		}
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
%>	//alert('deepak'+<%=index%>);
		window.opener.document.form1.cg_1_cta1<%=index%>.value = eval('document.result.cta1_'+k).value;
		window.opener.document.form1.cg_1_cta2<%=index%>.value = eval('document.result.cta2_'+k).value;
		window.opener.document.form1.cg_1_cta3<%=index%>.value = eval('document.result.cta3_'+k).value;
		window.opener.document.form1.cg_1_cta4<%=index%>.value = eval('document.result.cta4_'+k).value;
		window.opener.document.form1.cg_1_cta5<%=index%>.value = eval('document.result.cta5_'+k).value;
		window.opener.document.form1.cg_1_cta6<%=index%>.value = eval('document.result.cta6_'+k).value;
		window.opener.document.form1.cuenta_desc<%=index%>.value = eval('document.result.descripcion'+k).value;
		//window.opener.replicaAll();
		//window.close();
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("index",index)%>
		<tr class="TextFilter">
			<td width="40%"><cellbytelabel>Cuenta</cellbytelabel>:
                     	<%=fb.textBox("cta1",cta1,false,false,false,3,3)%>
                        <%=fb.textBox("cta2",cta2,false,false,false,3,3)%>
                        <%=fb.textBox("cta3",cta3,false,false,false,3,3)%>
                        <%=fb.textBox("cta4",cta4,false,false,false,3,3)%>
                        <%=fb.textBox("cta5",cta5,false,false,false,3,3)%>
                        <%=fb.textBox("cta6",cta6,false,false,false,3,3)%>
			</td>
			<td width="60%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
						<%=fb.textBox("descripcion",descripcion,false,false,false,40)%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("cta1",cta1)%>
<%=fb.hidden("cta2",cta2)%>
<%=fb.hidden("cta3",cta3)%>
<%=fb.hidden("cta4",cta4)%>
<%=fb.hidden("cta5",cta5)%>
<%=fb.hidden("cta6",cta6)%>
<%=fb.hidden("descripcion",descripcion)%>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
      	<%if(!fp.equalsIgnoreCase("tipo_nota_cr_db") && !fp.equalsIgnoreCase("orden_pago")){%>
				<%=fb.submit("saveNcontT","Agregar y Continuar",true,al.size()==0)%>
				<%=fb.submit("save","Agregar",true,al.size()==0)%>
        <%}else{%>
        <%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
	<% } %>
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
		<tr class="TextHeader" align="center">
			<td width="5%"><cellbytelabel>Cta 1</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta 2</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta 3</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta 4</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta 5</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cta 6</cellbytelabel></td>
			<td width="65%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="5%"><%if(fp.equalsIgnoreCase("reporte")){%>
			<%//=fb.checkbox("checkAll","",false,false,"","","onClick=\"javascript:chkAll();\"")%>
			<%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todas las Cuentas!")%>
      <%}%></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String ctas = cdo.getColValue("cta1")+"_"+cdo.getColValue("cta2")+"_"+cdo.getColValue("cta3")+"_"+cdo.getColValue("cta4")+"_"+cdo.getColValue("cta5")+"_"+cdo.getColValue("cta6");
%>
		<%=fb.hidden("cta1_"+i,cdo.getColValue("cta1"))%>
		<%=fb.hidden("cta2_"+i,cdo.getColValue("cta2"))%>
		<%=fb.hidden("cta3_"+i,cdo.getColValue("cta3"))%>
		<%=fb.hidden("cta4_"+i,cdo.getColValue("cta4"))%>
		<%=fb.hidden("cta5_"+i,cdo.getColValue("cta5"))%>
		<%=fb.hidden("cta6_"+i,cdo.getColValue("cta6"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("cuenta"+i,cdo.getColValue("cta"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" <%=((fp.equals("orden_pago") && !index.equals("")) || fp.equalsIgnoreCase("tipo_nota_cr_db")?"onClick=\"javascript:setValues("+i+");\"  style=\"cursor:pointer\"":"")%>>
			<td><%=cdo.getColValue("cta1")%></td>
			<td><%=cdo.getColValue("cta2")%></td>
			<td><%=cdo.getColValue("cta3")%></td>
			<td><%=cdo.getColValue("cta4")%></td>
			<td><%=cdo.getColValue("cta5")%></td>
			<td><%=cdo.getColValue("cta6")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center">
			<%if(index.equals("") && !fp.equalsIgnoreCase("tipo_nota_cr_db")){%>
			<%=(((fp.equalsIgnoreCase("orden_pago") || fp.equalsIgnoreCase("reporte")) && vCtas.contains(ctas))||(fp.equalsIgnoreCase("ajuste_cxp")&& vNotasCtas.contains(ctas)))?"Elegido":fb.checkbox("check"+i,""+i,false,false,"","","")%>
      <%}%>
      </td>
		</tr>
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
				<%=fb.submit("saveNcontB","Agregar y Continuar",true,al.size()==0)%>
				<%=fb.submit("save","Agregar",true,al.size()==0)%>
				<%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
	if (fp.equalsIgnoreCase("orden_pago") || fp.equalsIgnoreCase("fact_prov"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				if (fp.equalsIgnoreCase("fact_prov")) cdo.addColValue("renglon","0");
				cdo.addColValue("cg_1_cta1",request.getParameter("cta1_"+i));
				cdo.addColValue("cg_1_cta2",request.getParameter("cta2_"+i));
				cdo.addColValue("cg_1_cta3",request.getParameter("cta3_"+i));
				cdo.addColValue("cg_1_cta4",request.getParameter("cta4_"+i));
				cdo.addColValue("cg_1_cta5",request.getParameter("cta5_"+i));
				cdo.addColValue("cg_1_cta6",request.getParameter("cta6_"+i));
				cdo.addColValue("descripcion_cuenta",request.getParameter("descripcion"+i));
				if(fp.equalsIgnoreCase("fact_prov"))cdo.addColValue("descCta",request.getParameter("cuenta"+i)+" - "+request.getParameter("descripcion"+i));
				line++;

				String key = "";
				if (line < 10) key = "00"+line;
				else if (line < 100) key = "0"+line;
				else key = ""+line;
				cdo.addColValue("key",key);

				try
				{
					htCtas.put(key,cdo);
					String ctas = cdo.getColValue("cg_cta1")+"_"+cdo.getColValue("cg_cta2")+"_"+cdo.getColValue("cg_cta3")+"_"+cdo.getColValue("cg_cta4")+"_"+cdo.getColValue("cg_cta5")+"_"+cdo.getColValue("cg_cta6");
					vCtas.add(ctas);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	} else if (fp.equalsIgnoreCase("reporte"))
	{
		for (int i=0; i<size; i++)
		{
			System.out.println(" check == "+request.getParameter("check"+i));
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
	else if (fp.equalsIgnoreCase("ajuste_cxp"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("renglon","0");
				cdo.addColValue("cg_1_cta1",request.getParameter("cta1_"+i));
				cdo.addColValue("cg_1_cta2",request.getParameter("cta2_"+i));
				cdo.addColValue("cg_1_cta3",request.getParameter("cta3_"+i));
				cdo.addColValue("cg_1_cta4",request.getParameter("cta4_"+i));
				cdo.addColValue("cg_1_cta5",request.getParameter("cta5_"+i));
				cdo.addColValue("cg_1_cta6",request.getParameter("cta6_"+i));
				cdo.addColValue("descripcion_cuenta",request.getParameter("descripcion"+i));

				cdo.setKey(iNotasCtas.size()+1);
				cdo.setAction("I");

				try
				{
					iNotasCtas.put(cdo.getKey(),cdo);
					String ctas = cdo.getColValue("cg_cta1")+"_"+cdo.getColValue("cg_cta2")+"_"+cdo.getColValue("cg_cta3")+"_"+cdo.getColValue("cg_cta4")+"_"+cdo.getColValue("cg_cta5")+"_"+cdo.getColValue("cg_cta6");
					vNotasCtas.add(ctas);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	} else if (fp.equalsIgnoreCase("reporte"))

	System.out.println("..........................."+request.getParameter("saveNcontT")+" "+request.getParameter("saveNcontB"));
	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&tab="+tab+"&index="+index+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&cta1="+request.getParameter("cta1")+"&cta2="+request.getParameter("cta2")+"&cta3="+request.getParameter("cta3")+"&cta4="+request.getParameter("cta4")+"&cta5="+request.getParameter("cta5")+"&cta6="+request.getParameter("cta6")+"&descripcion="+request.getParameter("descripcion"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&tab="+tab+"&index="+index+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&cta1="+request.getParameter("cta1")+"&cta2="+request.getParameter("cta2")+"&cta3="+request.getParameter("cta3")+"&cta4="+request.getParameter("cta4")+"&cta5="+request.getParameter("cta5")+"&cta6="+request.getParameter("cta6")+"&descripcion="+request.getParameter("descripcion"));
		return;
	}
	else if (request.getParameter("saveNcontT") != null || request.getParameter("saveNcontB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&tab="+tab+"&index="+index+"&nextVal="+request.getParameter("nextVal")+"&previousVal="+request.getParameter("previousVal")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&cta1="+request.getParameter("cta1")+"&cta2="+request.getParameter("cta2")+"&cta3="+request.getParameter("cta3")+"&cta4="+request.getParameter("cta4")+"&cta5="+request.getParameter("cta5")+"&cta6="+request.getParameter("cta6")+"&descripcion="+request.getParameter("descripcion"));
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("orden_pago"))
	{
%>
	window.opener.location = '../cxp/orden_pago_det.jsp?change=1&mode=<%=mode%>';
<%
	} else 	if (fp.equalsIgnoreCase("fact_prov"))
	{
%>
	window.opener.location = '../cxp/fact_prov_det.jsp?change=1&mode=<%=mode%>';
<%
	} else 	if (fp.equalsIgnoreCase("reporte"))
	{
%>
	window.opener.location = '../contabilidad/detalle_rep_det.jsp?change=1&mode=<%=mode%>';
<%
	}
	else 	if (fp.equalsIgnoreCase("ajuste_cxp"))
	{
%>
	window.opener.location = '../cxp/nota_ajuste_det.jsp?change=1&mode=<%=mode%>&id=<%=id%>';
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