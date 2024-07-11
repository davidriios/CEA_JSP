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
<jsp:useBean id="iCPTMapping" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCPTMapping" scope="session" class="java.util.Vector"/>
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
int cptLastLineNoMapping = 0;
String key = "";
if (request.getParameter("cptLastLineNoMapping") != null) cptLastLineNoMapping = Integer.parseInt(request.getParameter("cptLastLineNoMapping"));
String cCompany = (String)session.getAttribute("_companyId");

if (mode == null) mode = "add";
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(change == null)
	{
		iCPTMapping.clear();
		vCPTMapping.clear();

		sql = "select id, cpt as codigo, (select coalesce(a.observacion,a.descripcion) FROM tbl_cds_procedimiento a where a.codigo = cpt and rownum = 1 ) as descCPT from tbl_map_axa_revenue_cpt where id = "+revenueId+" order by cpt ";

		al = SQLMgr.getDataList(sql);

		//System.out.println(":::::::::::::::::::::::: AL GET = "+al.size());
		cptLastLineNoMapping = al.size();
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
				iCPTMapping.put(cdoD.getKey(), cdoD);
				vCPTMapping.addElement(cdoD.getColValue("codigo"));
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
	showCPTList();
<%
	}
%>
}
function showCPTList(){
	abrir_ventana("../common/check_procedimiento.jsp?fp=MAPPING_CPT&cds=<%=cds%>&cptLastLineNoMapping=<%=cptLastLineNoMapping%>&revenueId=<%=revenueId%>&parentMode=<%=parentMode%>");
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
	<%=fb.hidden("cptLastLineNoMapping",""+cptLastLineNoMapping)%>
	<%=fb.hidden("iCPTSize",""+iCPTMapping.size())%>
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
		<td colspan="3">PROCEDIMIENTOS</td>
	</tr>
	<tr>
		<td>
			<div id="_cMain" class="Container">
			<div id="_cContent" class="ContainerContent">
			<table width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextHeader">
				<td width="20%">&nbsp;&nbsp;C&oacute;digo</td>
				<td width="75%">Descripci&oacute;n</td>
				<td align="center" width="5%"><%=fb.submit("addCPT","+",true,false,null,null,"onClick=javascript:setBAction('"+fb.getFormName()+"',this.value)","Agregar CPT")%></td>
			</tr>
			<%
			al = CmnMgr.reverseRecords(iCPTMapping);
			for (int i=0; i<iCPTMapping.size(); i++)
			{
				key = al.get(i).toString();
				CommonDataObject cdoD = (CommonDataObject) iCPTMapping.get(key);
			%>
			<%=fb.hidden("key"+i,cdoD.getKey())%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("action"+i,cdoD.getAction())%>
			<%=fb.hidden("codigo"+i,cdoD.getColValue("codigo"))%>
			<%=fb.hidden("descCPT"+i,cdoD.getColValue("descCPT"))%>

			<tr class="TextRow01">
				<td>&nbsp;&nbsp;<%=cdoD.getColValue("codigo")%></td>
				<td><%=cdoD.getColValue("descCPT")%></td>
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
	if (request.getParameter("iCPTSize") != null) size = Integer.parseInt(request.getParameter("iCPTSize"));
	String itemRemoved = "", lastRemCode = "";

	cdo = new CommonDataObject();
	cdo.setTableName("tbl_map_axa_revenue");
	cdo.addColValue("code",request.getParameter("revenuecode"));
	cdo.addColValue("company",cCompany);

	if (request.getParameter("patient_type") != null && !request.getParameter("patient_type").trim().equals("")) cdo.addColValue("adm_type",request.getParameter("patient_type"));
	else cdo.addColValue("adm_type","-");
	if (request.getParameter("cds") != null && !request.getParameter("cds").trim().equals("")) cdo.addColValue("cds",request.getParameter("cds"));
	else cdo.addColValue("cds","-99999");
	if (request.getParameter("ts_code") != null && !request.getParameter("ts_code").trim().equals("")) cdo.addColValue("ts",request.getParameter("ts_code"));
	else cdo.addColValue("ts","-");
	cdo.addColValue("description",request.getParameter("description"));
	cdo.addColValue("comments",request.getParameter("comments"));
	cdo.addColValue("status",request.getParameter("status"));
	cdo.addColValue("prioridad",request.getParameter("prioridad"));
	Map.setCdo(cdo);
	
	System.out.println(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 1 = "+revenueId);

	if (parentMode!=null && parentMode.trim().equalsIgnoreCase("edit")) {
		cdo.setWhereClause(" id = "+request.getParameter("revenueId") );
		cdo.setAction("U");
	} else {
		CommonDataObject cdoId = SQLMgr.getData("SELECT nvl(max(id),0)+1 as revenueId FROM tbl_map_axa_revenue");
		revenueId = cdoId.getColValue("revenueId");
		cdo.setAction("I");
		cdo.addColValue("id",revenueId);
		
		System.out.println(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ???? = "+revenueId);
	}
	System.out.println(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 2 = "+revenueId);

	al.clear();
	iCPTMapping.clear();
	vCPTMapping.clear();

	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo2 = new CommonDataObject();

		cdo2.setTableName("tbl_map_axa_revenue_cpt");
		cdo2.setWhereClause("id="+revenueId+" and cpt = '"+request.getParameter("codigo"+i)+"'");

		if (i < 10) key = "00" + i;
		else if (i < 100) key = "0" + i;
		else key = "" + i;

		cdo2.addColValue("id",revenueId);
		cdo2.addColValue("cpt",request.getParameter("codigo"+i));
		cdo2.addColValue("codigo",request.getParameter("codigo"+i));
		cdo2.addColValue("descCPT",request.getParameter("descCPT"+i));
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
				sbCols.append("3,3,null");
				sbCols.append(",'@xxid=");
				sbCols.append(revenueId);
				sbCols.append("~@xxcpt=");
				sbCols.append(request.getParameter("codigo"+i));
				sbCols.append("',null)");
				SQLMgr.execute(sbCols.toString()); 
			}
		}

		if (!cdo2.getAction().equalsIgnoreCase("X") && !cdo2.getAction().equalsIgnoreCase("D")) {
			try
			{
				iCPTMapping.put(cdo2.getKey(),cdo2);
				vCPTMapping.addElement(request.getParameter("codigo"+i));
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
		vCPTMapping.remove(lastRemCode);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&tab=1&mode="+mode+"&id="+id+"&cptLastLineNoMapping="+cptLastLineNoMapping+"&cds="+cds+"&revenueId="+revenueId+"&parentMode="+parentMode);
		return;
	}

	if (baction != null && baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&type=1&tab=1&mode="+mode+"&id="+id+"&cptLastLineNoMapping="+cptLastLineNoMapping+"&cds="+cds+"&revenueId="+revenueId+"&parentMode="+parentMode);
		return;
	}

	if (al.size() == 0)
	{
		CommonDataObject cdo2 = new CommonDataObject();

		cdo2.setTableName("tbl_map_axa_revenue_cpt");
		cdo2.setWhereClause("id=-1");

		al.add(cdo2);
	}
	Map.setAlCpt(al);

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
	parent.window.doSubmitArt(<%=revenueId%>);
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