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
<jsp:useBean id="iIP" scope="session" class="java.util.Hashtable"/>
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

ArrayList al= new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
int lastLineNo = 0;

if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		iIP.clear();
		id = "0";
	}//add
	else
	{
		if (id == null) throw new Exception("La Variable Ambiente no es válida. Por favor intente nuevamente!");

		sql = "select id, name, description, status from tbl_sec_regvar where id="+id;
		cdo = SQLMgr.getData(sql);

		if (change == null)
		{
			iIP.clear();

			sql = "select z.*, lpad(rownum,4,'0') as key from (select get_filled_value(replace(ip,'.',':'),':','0',4), ip, regvar_id, regvar_value, status, nvl(description,' ') as description from tbl_sec_ip_regvar where regvar_id="+id+" order by 1) z";
			al  = SQLMgr.getDataList(sql);
			lastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject ip = (CommonDataObject) al.get(i-1);

				try
				{
					iIP.put(ip.getColValue("key"), ip);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//for
		}//change null
	}//edit
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title='Variables Ambiente - '+document.title;
function doAction(){if(document.form1.ip<%=iIP.size()%>.value=='')document.form1.ip<%=iIP.size()%>.focus();}
function save(opt,idx){
	if(opt==null||opt==undefined)opt=0;
	var ip=(opt==0)?document.form1.ip.value:eval('document.form1.ip'+idx).value;
	var regvarValue=(opt==0)?document.form1.regvar_value.value:eval('document.form1.regvar_value'+idx).value;
	var description=(opt==0)?document.form1.description.value:eval('document.form1.description'+idx).value;
	var status=(opt==0)?document.form1.status.value:eval('document.form1.status'+idx).value;
	var ipKey=(opt==0)?ip:eval('document.form1.ipKey'+idx).value;
	if((opt==0||opt==1)&&(ip.trim()==''||regvarValue.trim()=='')){
		alert("Por favor ingresar el IP y Valor!");
		if(ip.trim()=='')(opt==0)?document.form1.ip.focus():eval('document.form1.ip'+idx).focus();
		else if(regvarValue.trim()=='')(opt==0)?document.form1.regvar_value.focus():eval('document.form1.regvar_value'+idx).focus();
	}else{
		var skip=false;
		if(opt==0){
			skip=hasDBData("<%=request.getContextPath()%>","tbl_sec_ip_regvar","regvar_id = <%=id%> and ip = '"+replaceAll(ipKey,"'","''")+"'");
			if(skip){
				alert("El IP ya se encuentra registrado para la variable!");
				document.form1.ip.focus();
			}
		}
		if(!skip){
			if(  (opt==0&&executeDB("<%=request.getContextPath()%>","insert into tbl_sec_ip_regvar (ip, regvar_id, regvar_value, status, description) values ('"+replaceAll(ip,"'","''")+"', <%=id%>, '"+replaceAll(regvarValue,"'","''")+"', '"+status+"', '"+replaceAll(description,"'","''")+"')"))
				 ||(opt==1&&executeDB("<%=request.getContextPath()%>","update tbl_sec_ip_regvar set ip='"+ip+"', regvar_value='"+replaceAll(regvarValue,"'","''")+"', status='"+status+"', description='"+replaceAll(description,"'","''")+"' where regvar_id = <%=id%> and ip = '"+replaceAll(ipKey,"'","''")+"'"))
				 ||(opt==-1&&executeDB("<%=request.getContextPath()%>","delete from tbl_sec_ip_regvar where regvar_id = <%=id%> and ip = '"+replaceAll(ipKey,"'","''")+"'")) ){
				alert("Actualizado Satisfactoriamente!");
				if(opt==0)window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=1&id=<%=id%>';
				else if(opt==-1)$("#_idx"+idx).css("display","none");
			}else{
				alert("Encontramos un problema al intentar guardar el valor para la variable!");
			}
		}
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="VARIABLE AMBIENTE"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder" width="100%">

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

		<table width="100%" cellpadding="1" cellspacing="1" align="center">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>

		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("name",cdo.getColValue("name"),true,false,false,30,50)%></td>
			<td width="15%" align="right"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("description",cdo.getColValue("description"),true,false,false,50,200)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Estado</cellbytelabel></td>
			<td><%=fb.select("status","A=Activo,I=Inactivo",cdo.getColValue("status"))%></td>
			<td align="right">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</table>

<!-- TAB0 DIV END HERE-->
</div>



<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

		<table width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("size",""+iIP.size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%fb.appendJsValidation("if(document.form1.baction.value!='Guardar')return true;");%>
		<tr class="TextRow02">
			<td colspan="5">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="5"><cellbytelabel>Nombre</cellbytelabel>: <%=cdo.getColValue("name")%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="25%"><cellbytelabel>IP</cellbytelabel></td>
			<td width="25%"><cellbytelabel>Valor</cellbytelabel></td>
			<td width="35%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="5%"><%//=fb.submit("addIP","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Máquina")%></td>
		</tr>
		<tr class="TextHeader">
			<td align="center"><%=fb.textBox("ip","",true,false,false,40,40)%></td>
			<td align="center"><%=fb.textBox("regvar_value","",true,false,false,30,200)%></td>
			<td align="center"><%=fb.textBox("description","",false,false,false,50,100)%></td>
			<td align="center"><%=fb.select("status","A=Activo,I=Inactivo","")%></td>
			<td align="center"><a onclick="javascript:save();" class="hint hint--left" data-hint="Agregar"><img src="../images/save.png"></a></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iIP);
for (int i=1; i<=iIP.size(); i++)
{
	CommonDataObject ip = (CommonDataObject) iIP.get(al.get(i - 1).toString());
	String color = "TextRow01";
%>
		<%=fb.hidden("key"+i,ip.getColValue("key"))%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("ipKey"+i,ip.getColValue("ip"))%>
		<%=fb.hidden("ipVal"+i,ip.getColValue("regvar_value"))%>
		<tr id="_idx<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'BackgroundGray')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=fb.textBox("ip"+i,ip.getColValue("ip"),true,false,false,40,40)%></td>
			<td align="center"><%=fb.textBox("regvar_value"+i,ip.getColValue("regvar_value"),true,false,false,30,200)%></td>
			<td align="center"><%=fb.textBox("description"+i,ip.getColValue("description"),false,false,false,50,100)%></td>
			<td align="center"><%=fb.select("status"+i,"A=Activo,I=Inactivo",ip.getColValue("status"))%></td>
			<td align="center">
				<a onclick="javascript:save(1,<%=i%>);" class="hint hint--left" data-hint="Actualizar"><img src="../images/refresh.png" width="20" height="20"></a>
				<a onclick="javascript:save(-1,<%=i%>);" class="hint hint--left" data-hint="Remover"><img src="../images/icon-cross.png" width="20" height="20"></a>
				<%//=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%>
			</td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td colspan="5" align="right">
				<!--<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N")%>Crear Otro -->
				<!--<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>-->
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</table>

<!-- TAB1 DIV END HERE-->
</div>

<!-- MAIN DIV END HERE -->
</div>

	</td>
</tr>
</table>
<script type="text/javascript">
<%
String tabLabel = "'Variable Ambiente'";
if (mode.equalsIgnoreCase("edit")) tabLabel += ",'Valores x Máquina'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	if (tab.equals("0"))//Variable Ambiente
	{
		cdo = new CommonDataObject();

		cdo.setTableName("tbl_sec_regvar");
		cdo.addColValue("name",request.getParameter("name"));
		cdo.addColValue("description",request.getParameter("description"));
		cdo.addColValue("status",request.getParameter("status"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add"))
		{
			cdo.setAutoIncCol("id");
			cdo.addPkColValue("id","");
			SQLMgr.insert(cdo);
			SQLMgr.getPkColValue("id");
		}
		else
		{
			cdo.setWhereClause("id="+id);

			SQLMgr.update(cdo);
		}
		ConMgr.clearAppCtx(null);
	}//tab 0
	else if (tab.equals("1"))//Valor x Máquina
	{
		int size = 0;
		if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_ip_regvar");
			cdo.setWhereClause("regvar_id="+id+"");
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("ip",request.getParameter("ip"+i));
			cdo.addColValue("regvar_id",id);
			cdo.addColValue("regvar_value",request.getParameter("regvar_value"+i));
			cdo.addColValue("description",request.getParameter("description"+i));
			cdo.addColValue("status",request.getParameter("status"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = cdo.getColValue("key");
			else
			{
				try
				{
					iIP.put(cdo.getColValue("key"),cdo);
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}//for

		if (!itemRemoved.equals(""))
		{
			iIP.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&lastLineNo="+lastLineNo);
			return;
		}

		if (baction.equalsIgnoreCase("+"))
		{
			String key = "";
			cdo = new CommonDataObject();

			lastLineNo++;
			if (lastLineNo < 10) key = "000" + lastLineNo;
			else if (lastLineNo < 100) key = "00" + lastLineNo;
			else if (lastLineNo < 1000) key = "0" + lastLineNo;
			else key = "" + lastLineNo;

			cdo.addColValue("key",key);
			try
			{
				iIP.put(key,cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&lastLineNo="+lastLineNo);
			return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				cdo = new CommonDataObject();

				cdo.setTableName("tbl_sec_ip_regvar");
				cdo.setWhereClause("regvar_id="+id+"");

				al.add(cdo);
			}

			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&id="+id);
			SQLMgr.insertList(al);
			ConMgr.clearAppCtx(null);
		}
	}//tab 1
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (tab.equals("0"))
	{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/list_regvar.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/list_regvar.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/list_regvar.jsp';
<%
		}
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>