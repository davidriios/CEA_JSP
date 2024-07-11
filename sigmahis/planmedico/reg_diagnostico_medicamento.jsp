<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="SOL" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SolMgr" scope="page" class="issi.planmedico.SolicitudMgr"/>
<jsp:useBean id="Sol" scope="session" class="issi.planmedico.Solicitud"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="htCltD" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="fact" scope="session" class="java.util.Hashtable"/>
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
SolMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alPar = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String id = request.getParameter("id_solicitud");
String anio = request.getParameter("anio");
int lineNo = 0;
if(fp==null)fp="plan_medico";
boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{

	newHeight();
}

function calc(){}

function getPlan(size,ind){}

function doSubmit(valor){
	document.form1.action.value = valor;
	document.form1.submit();
}

function chkCeroRegisters(){
	return true;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>
<%=fb.hidden("id_cliente", "")%>
<%=fb.hidden("id_solicitud",id)%>

<table width="100%" align="center">
	<tr>
		<td><table align="center" width="99%" cellpadding="0" cellspacing="1">
				<%
				int colspan = 8;
				%>
				<%
				key = "";
				if (htCltD.size() != 0) al = CmnMgr.reverseRecords(htCltD);
				for (int i=0; i<htCltD.size(); i++){
					key = al.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) htCltD.get(key);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("id_cliente"+i,cdo.getColValue("id_cliente"))%>
				<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
				<%=fb.hidden("id_solicitud"+i,cdo.getColValue("id_solicitud"))%>
						<tr class="TextHeader01">
							<td colspan="2"><%=cdo.getColValue("client_name")%></td>
						</tr>
						<tr class="<%=color%>">
							<td>Diagnostico</td>
							<td><%=fb.textarea("diagnostico"+i,cdo.getColValue("diagnostico"),false,false,viewMode,100,2, 200)%></td>
						</tr>
						<tr class="<%=color%>">
							<td>Medicamento</td>
							<td><%=fb.textarea("medicamento"+i,cdo.getColValue("medicamento"),false,false,viewMode,100,2, 200)%></td>
						</tr>

				<%
				}
				%>
						<tr class="TextRow02">
							<td colspan="6" align="right">
							<cellbytelabel>Opciones de Guardar</cellbytelabel>:
								<%=fb.radio("saveOption","O",false,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
								<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
							<%=fb.button("save","Guardar",true,false,"","","onClick=\"javascript:doSubmit(this.value);\"")%>
							<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
							</td>
						</tr>

				<%=fb.hidden("keySize",""+htCltD.size())%>
			</table></td>
	</tr>
</table>
<%
fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{

	String companyId = (String) session.getAttribute("_companyId");
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	
	htCltD.clear();
	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		CommonDataObject cd = new CommonDataObject();
		cd.setTableName("tbl_pm_sol_contrato_det");
		cd.setAction("U");
		if(request.getParameter("diagnostico"+i)!=null &&  !request.getParameter("diagnostico"+i).equals("")) cd.addColValue("diagnostico", request.getParameter("diagnostico"+i));	
		else cd.addColValue("diagnostico", "");	
		if(request.getParameter("medicamento"+i)!=null &&  !request.getParameter("medicamento"+i).equals("")) cd.addColValue("medicamento", request.getParameter("medicamento"+i));	
		else cd.addColValue("medicamento", "");	
		cd.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cd.setWhereClause("id_solicitud = "+request.getParameter("id_solicitud"+i)+" and id = "+request.getParameter("id"+i)+" and id_cliente = "+request.getParameter("id_cliente"+i));
		al.add(cd);
	}
	
	SQLMgr.saveList(al, true);


%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if (SQLMgr.getErrCode().equals("1")){%>
			parent.document.form2.errCode.value = <%=SQLMgr.getErrCode()%>;
			parent.document.form2.errMsg.value = '<%=SQLMgr.getErrMsg()%>';
			parent.document.form2.id.value = '<%=id%>';
			parent.document.form2.saveOption.value = '<%=saveOption%>';
			parent.document.form2.submit();
	<%} else throw new Exception(SQLMgr.getErrMsg());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>