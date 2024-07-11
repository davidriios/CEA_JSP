<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="iArtMapping" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vArtMapping" scope="session" class="java.util.Vector"/>
<jsp:useBean id="Map" scope="session" class="issi.admin.Mapping" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();
String sql="";
String fp = request.getParameter("fp");
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String change = request.getParameter("change");
String revenueId = request.getParameter("revenueId")==null?"0":request.getParameter("revenueId");
String parentMode = request.getParameter("parentMode")==null?"":request.getParameter("parentMode");
String cds = request.getParameter("cds")==null?"-1":request.getParameter("cds");
int artLastLineNoMapping = 0;
String key = "";
if (request.getParameter("artLastLineNoMapping") != null) artLastLineNoMapping = Integer.parseInt(request.getParameter("artLastLineNoMapping"));
String cCompany = (String)session.getAttribute("_companyId");

if (mode == null) mode = "add";
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(change == null)
	{
		iArtMapping.clear();
		vArtMapping.clear();

		sql = "select id, articulo as codigo, (select a.descripcion FROM tbl_inv_articulo a where a.compania = ca.compania and a.cod_articulo = ca.articulo) as descArt, articulo_axa from tbl_map_axa_revenue_art ca where id = "+revenueId+ " and compania= "+(String) session.getAttribute("_companyId")+" order by articulo ";

		al = SQLMgr.getDataList(sql);

		//System.out.println(":::::::::::::::::::::::: AL GET = "+al.size());
		artLastLineNoMapping = al.size();
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdoD = (CommonDataObject) al.get(i);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			cdoD.setKey(key);
			cdoD.setAction("U");

			try
			{
				iArtMapping.put(cdoD.getKey(), cdoD);
				vArtMapping.addElement(cdoD.getColValue("codigo"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script type="text/javascript">
var xHeight=0;
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function doAction()
{
xHeight=objHeight('_tblMain');resizeFrame();
<%
	if (request.getParameter("type") != null)
	{
%>
	showArtList();
<%
	}
%>
}
function showArtList(){
	abrir_ventana("../common/check_articulo.jsp?fp=MAPPING_CPT&cds=<%=cds%>&artLastLineNoMapping=<%=artLastLineNoMapping%>&revenueId=<%=revenueId%>&parentMode=<%=parentMode%>");
}

function doSubmit(){
 $("#form0").submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0" id="_tblMain">
	<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("id",id)%>
	<%=fb.hidden("cds",cds)%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("artLastLineNoMapping",""+artLastLineNoMapping)%>
	<%=fb.hidden("iArtSize",""+iArtMapping.size())%>
	<%=fb.hidden("revenueId",revenueId)%>
	<%=fb.hidden("status","")%>
	<%=fb.hidden("patient_type","")%>
	<%=fb.hidden("ts_code","")%>
	<%=fb.hidden("revenuecode","")%>
	<%=fb.hidden("description","")%>
	<%=fb.hidden("parentMode",parentMode)%>
	<%=fb.hidden("cUrl","")%>
	<%=fb.hidden("saveOption","")%>
	<%=fb.hidden("comments","")%>
	<%=fb.hidden("prioridad","")%>

	<tr class="TextHeader">
		<td colspan="3">ARTICULOS</td>
	</tr>
	<tr>
		<td>
			<div id="_cMain" class="Container">
			<div id="_cContent" class="ContainerContent">
			<table width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextHeader">
				<td width="20%">&nbsp;&nbsp;C&oacute;digo</td>
				<td width="55%">Descripci&oacute;n</td>
				<td width="25%">C&oacute;digo Axa</td>
				<td align="center" width="5%"><%=fb.submit("addArt","+",true,false,null,null,"onClick=javascript:setBAction('"+fb.getFormName()+"',this.value)","Agregar Articulos")%></td>
			</tr>
			<%
			al = CmnMgr.reverseRecords(iArtMapping);
			for (int i=0; i<iArtMapping.size(); i++)
			{
				key = al.get(i).toString();
				CommonDataObject cdoD = (CommonDataObject) iArtMapping.get(key);
			%>
			<%=fb.hidden("key"+i,cdoD.getKey())%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("action"+i,cdoD.getAction())%>
			<%=fb.hidden("codigo"+i,cdoD.getColValue("codigo"))%>
			<%=fb.hidden("descArt"+i,cdoD.getColValue("descArt"))%>

			<tr class="TextRow01">
				<td>&nbsp;&nbsp;<%=cdoD.getColValue("codigo")%></td>
				<td><%=cdoD.getColValue("descArt")%></td>
				<td><%=fb.textBox("articulo_axa"+i,cdoD.getColValue("articulo_axa"),true,false,false,20,100)%></td>
				<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=javascript:removeItem('"+fb.getFormName()+"',"+i+")")%></td>
			</tr>
<%
}
	fb.appendJsValidation("if(error>0)doAction();");
%>
						</table>
						</div>
						</div>
					</td>
				</tr>
<%=fb.formEnd(true)%>
</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption")==null||request.getParameter("saveOption").equals("")?"C":request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	parentMode = request.getParameter("parentMode");

	int size = 0;
	if (request.getParameter("iArtSize") != null) size = Integer.parseInt(request.getParameter("iArtSize"));
	String itemRemoved = "", lastRemCode = "";


	al.clear();
	iArtMapping.clear();
	vArtMapping.clear();

	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo2 = new CommonDataObject();

		cdo2.setTableName("tbl_map_axa_revenue_art");
		cdo2.setWhereClause("id="+revenueId+" and articulo = '"+request.getParameter("codigo"+i)+"'");

		if (i < 10) key = "00" + i;
		else if (i < 100) key = "0" + i;
		else key = "" + i;

		cdo2.addColValue("id",revenueId);
		cdo2.addColValue("articulo",request.getParameter("codigo"+i));
		cdo2.addColValue("codigo",request.getParameter("codigo"+i));
		cdo2.addColValue("articulo_axa",request.getParameter("articulo_axa"+i));
		cdo2.addColValue("descArt",request.getParameter("descArt"+i));
		cdo2.addColValue("compania", (String)session.getAttribute("_companyId"));
		cdo2.addColValue("key",request.getParameter("key"+i));
		cdo2.setKey(key);
		cdo2.setAction(request.getParameter("action"+i));

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){

			itemRemoved = cdo2.getKey();
			lastRemCode = request.getParameter("codigo"+i);
			if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");
			else cdo2.setAction("D");
			
			if (cdo2.getAction().equalsIgnoreCase("D")){
				StringBuffer sbCols = new StringBuffer();
				sbCols.append("call sp_par_do(");
				sbCols.append("4,3,null");
				sbCols.append(",'@xxid=");
				sbCols.append(revenueId);
				sbCols.append("~@xxarticulo=");
				sbCols.append(request.getParameter("codigo"+i));
				sbCols.append("',null)");
				SQLMgr.execute(sbCols.toString()); 
			}
		}

		if (!cdo2.getAction().equalsIgnoreCase("X") && !cdo2.getAction().equalsIgnoreCase("D")) {
			try
			{
				iArtMapping.put(cdo2.getKey(),cdo2);
				vArtMapping.addElement(request.getParameter("codigo"+i));
				al.add(cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}

	if (!itemRemoved.equals(""))
	{
		vArtMapping.remove(lastRemCode);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&tab=1&mode="+mode+"&id="+id+"&artLastLineNoMapping="+artLastLineNoMapping+"&cds="+cds+"&revenueId="+revenueId+"&parentMode="+parentMode);
		return;
	}

	if (baction != null && baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&type=1&tab=1&mode="+mode+"&id="+id+"&artLastLineNoMapping="+artLastLineNoMapping+"&cds="+cds+"&revenueId="+revenueId+"&parentMode="+parentMode);
		return;
	}

	if (al.size() == 0)
	{
		CommonDataObject cdo2 = new CommonDataObject();

		cdo2.setTableName("tbl_map_axa_revenue_art");
		cdo2.setWhereClause("id=-1");

		al.add(cdo2);
	}
	Map.setAlArt(al);

	/*
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.save(cdo,al,true,true,true,true);
	ConMgr.clearAppCtx(null);
	*/
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
//if (SQLMgr.getErrCode().equals("1")){
%>
	//alert('<%=SQLMgr.getErrMsg()%>');
	//parent.window.opener.document.location = "../admin/mapping_cpt_list.jsp?beginSearch=";
	//parent.window.document.location = "../admin/mapping_cpt.jsp?mode=edit&revenueId=<%=revenueId%>";
	parent.window.doSubmit(<%=revenueId%>);
<%
//} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>