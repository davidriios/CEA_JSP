<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="iICD" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vICD" scope="session" class="java.util.Vector"/>
<%
/*
==================================================================================
==================================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();
String change = request.getParameter("change");
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
ArrayList al = new ArrayList();

if (tab == null) tab = "0";
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET")) {

	if (mode.equalsIgnoreCase("add")) {

		iICD.clear();
		id = "0";
		cdo.addColValue("code","");

	} else {
	
		if (id == null) throw new Exception("El Diagnóstico no es válido. Por favor intente nuevamente!");

		sbSql.append("select a.codigo as code, a.categoria, a.nombre as name, a.observacion, a.comun, a.usuario_creacion, a.usuario_modificacion, a.fecha_creacion, a.fecha_modificacion, decode(a.enfermedad_notificable,null,' ',''||a.enfermedad_notificable) as codenot, a.icd_version from tbl_cds_diagnostico a where a.codigo = '");
		sbSql.append(id);
		sbSql.append("'");
		cdo = SQLMgr.getData(sbSql.toString());

		if (change == null) {

			iICD.clear();

			sbSql = new StringBuffer();
			sbSql.append("select codigo_icd10, nvl(sec,' ') as sec, nvl(table_type,' ') as table_type from tbl_cds_diagnostico_icd10map where codigo_icd09 = '");
			sbSql.append(id);
			sbSql.append("' order by codigo_icd10");
			al = SQLMgr.getDataList(sbSql.toString());

			for (int i=0; i<al.size(); i++) {
				CommonDataObject tcdo = (CommonDataObject) al.get(i);
				tcdo.setKey(i+1);
				tcdo.setAction("U");
				try {
					iICD.put(tcdo.getKey(),tcdo);
					vICD.add(tcdo.getColValue("codigo_icd10"));
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}

		}

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Diagnóstico - "+document.title;
function checkCode(obj)
{
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_cds_diagnostico','codigo=\''+obj.value+'\'','<%=cdo.getColValue("code")%>');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DIAGNÓSTICO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%fb.appendJsValidation("if(checkCode(document.form1.code))error++;");%>
		<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="2" align="left">&nbsp;<cellbytelabel id="1">Diagn&oacute;stico</cellbytelabel></td>
		</tr>	
		<tr class="TextRow01">
			<td>&nbsp;<cellbytelabel>Versi&oacute;n</cellbytelabel></td>
			<td><%=fb.select("icd_version","9,10",cdo.getColValue("icd_version"),true,false,false,0)%><% if (mode.equalsIgnoreCase("edit")) { %> <label class="RedTextBold">IMPORTANTE: Si cambia la versi&oacute;n de 9 a 10 y tiene equivalencia en ICD10, estas equivalencias ser&aacute;n removidas!</label><% } %></td>				
		</tr>
		<tr class="TextRow01">
			<td width="25%">&nbsp;<cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
			<td width="75%"><%=fb.textBox("code",cdo.getColValue("code"),true,mode.equals("edit"),false,45,null,null,"onBlur=\"javascript:checkCode(this)\"")%></td>				
		</tr>
		<tr class="TextRow01" >
			<td>&nbsp;<cellbytelabel id="4">Categor&iacute;a</cellbytelabel></td>
			<td><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, rango from tbl_cds_categoria_diag order by descripcion","categoria",cdo.getColValue("categoria"),true,false,false,0,null,null,null,null,"S")%></td>
		</tr>		
		<tr class="TextRow01" >
			<td>&nbsp;<cellbytelabel id="6">Nombre</cellbytelabel></td>
			<td><%=fb.textBox("name",cdo.getColValue("name"),true,false,false,60)%></td>
		</tr>
		<tr class="TextRow01" >
			<td>&nbsp;<cellbytelabel id="7">Observaciones</cellbytelabel></td>
			<td><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,46,4)%></td>
		</tr>
		<tr class="TextRow01" >
			<td>&nbsp;<cellbytelabel id="8">Com&uacute;n</cellbytelabel></td>
			<td><%=fb.select("comun","S=Si,N=No",cdo.getColValue("comun"))%></td>
		</tr>	
		<tr class="TextRow01">
			<td>&nbsp;<cellbytelabel id="9">Enfermedades Notificables</cellbytelabel></td>
			<td><%=fb.select(ConMgr.getConnection(),"select codigo, nombre from tbl_cds_enfermedad_notificable order by nombre","codenot",cdo.getColValue("codenot"),false,false,false,0,null,null,null,null," ")%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="2" align="right">
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("icdSize",""+iICD.size())%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextPanel">
			<td colspan="4">&nbsp;(<%=iICD.size()%>) <cellbytelabel>Equivalente en ICD10</cellbytelabel></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="5%">&nbsp;</td>
			<td width="35%"><cellbytelabel>ICD10</cellbytelabel></td>
			<td width="55%"><cellbytelabel>Clasificaci&oacute;n</cellbytelabel></td>
			<td width="5%"><%=fb.submit("addRow","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Nuevo")%></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iICD);
for (int i=0; i<iICD.size(); i++) {
	CommonDataObject tcdo = (CommonDataObject) iICD.get(al.get(i).toString());
	String style = (tcdo.getAction().equalsIgnoreCase("D"))?" style=\"display:none\"":"";
%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("action"+i,tcdo.getAction())%>
		<%=fb.hidden("key"+i,tcdo.getKey())%>
		<%=fb.hidden("table_type"+i,tcdo.getColValue("table_type"))%>
		<tr class="TextRow01" align="center" <%=style%>>
			<td><%=(tcdo.getAction().equalsIgnoreCase("I"))?"*":""%></td>
			<td><%=fb.textBox("codigo_icd10"+i,tcdo.getColValue("codigo_icd10"),true,false,!tcdo.getAction().equalsIgnoreCase("I"),20,20,"Text10",null,null)%></td>
			<td><%=fb.textBox("sec"+i,tcdo.getColValue("sec"),true,false,false,100,2000,"Text10",null,null)%></td>
			<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Registro")%></td>
		</tr>
<% } %>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<!--<%//=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>-->
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
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

<script type="text/javascript">
initTabs('dhtmlgoodies_tabView1',Array('Diagnóstico','Equivalente ICD10'),<%=tab%>,'100%','','','','',<%=(mode.equalsIgnoreCase("add") || (mode.equalsIgnoreCase("edit") && cdo.getColValue("icd_version").equals("10")))?"[1]":"''"%>);
</script>

	</td>
</tr>
</table>		

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {

	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	if (tab.equals("0")) {

		cdo = new CommonDataObject();
		cdo.setTableName("tbl_cds_diagnostico");   
		cdo.addColValue("categoria",request.getParameter("categoria")); 
		cdo.addColValue("nombre",request.getParameter("name")); 
		cdo.addColValue("observacion",request.getParameter("observacion")); 
		cdo.addColValue("comun",request.getParameter("comun"));
		cdo.addColValue("enfermedad_notificable",request.getParameter("codenot")); 
		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
		cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		cdo.addColValue("icd_version",request.getParameter("icd_version"));


		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode"+mode);
		if (mode.equalsIgnoreCase("add")) {

			cdo.addColValue("codigo",request.getParameter("code"));
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
			cdo.addColValue("fecha_creacion","sysdate");
			SQLMgr.insert(cdo);
			id = request.getParameter("code");

		} else {

			cdo.setWhereClause("codigo='"+id+"'");
			SQLMgr.update(cdo);

		}
		ConMgr.clearAppCtx(null);

	} else if (tab.equals("1")) {

		int size = 0;
		if (request.getParameter("icdSize") != null) size = Integer.parseInt(request.getParameter("icdSize"));
		String itemRemoved = "";

		al.clear();
		iICD.clear();
		for (int i=0; i<size; i++) {
			CommonDataObject tcdo = new CommonDataObject();
			tcdo.setKey(i);
			tcdo.setAction(request.getParameter("action"+i));
			tcdo.setTableName("tbl_cds_diagnostico_icd10map");
			tcdo.setWhereClause("codigo_icd10 = '"+request.getParameter("codigo_icd10"+i)+"' and codigo_icd09 = '"+id+"'");
			if (baction.equalsIgnoreCase("Guardar") && tcdo.getAction().equalsIgnoreCase("U")) {/*do not update pk values*/}
			else {

				tcdo.addColValue("codigo_icd10",request.getParameter("codigo_icd10"+i));
				tcdo.addColValue("codigo_icd09",id);

			}
			tcdo.addColValue("sec",request.getParameter("sec"+i));
			tcdo.addColValue("table_type",request.getParameter("table_type"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) {

				if (tcdo.getAction().equalsIgnoreCase("I")) {

					itemRemoved = request.getParameter("remove"+i);
					tcdo.setAction("X");//if it is not in DB then remove it

				} else {

					itemRemoved = request.getParameter("codigo_icd10"+i);
					tcdo.setAction("D");

				}

			}

			if (!tcdo.getAction().equalsIgnoreCase("X")) {

				try {
					iICD.put(tcdo.getKey(),tcdo);
					al.add(tcdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}

			}

		}


		if (!itemRemoved.equals("")) {

			vICD.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&id="+id);
			return;

		} else if (baction.equalsIgnoreCase("+")) {

			CommonDataObject tcdo = new CommonDataObject();
			tcdo.setKey(iICD.size());
			tcdo.setAction("I");
			tcdo.addColValue("codigo_icd10","");
			tcdo.addColValue("sec","");
			tcdo.addColValue("table_type","");
			try {
				iICD.put(tcdo.getKey(),tcdo);
			} catch(Exception e) {
				System.err.println(e.getMessage());
			}
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&id="+id);
			return;

		} else if (baction.equalsIgnoreCase("Guardar")) {

			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
			SQLMgr.saveList(al,true,false);
			ConMgr.clearAppCtx(null);	
		
		}

	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (tab.equals("0")) {
	
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/diagnostico_list.jsp")) {
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/diagnostico_list.jsp")%>';
<% } else { %>
	window.opener.location = '<%=request.getContextPath()%>/admision/diagnostico_list.jsp';
<%
		}
	}

	if (saveOption.equalsIgnoreCase("N")) {
%>
	setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>