<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/* Check whether the user is logged in or not what access rights he has----------------------------
0         ACCESO TODO SISTEMA
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
SQLMgr.setConnection(ConMgr);
CmnMgr.setConnection(ConMgr);

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

String creatorId = UserDet.getUserEmpId();

String mode=request.getParameter("mode");
String change=request.getParameter("change");
String type=request.getParameter("type");
String compId=(String) session.getAttribute("_companyId");
String id = request.getParameter("id");
String fg = request.getParameter("fg");
String title = "";
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();

if(mode==null) mode="add";
if(fg==null) fg="";
if (change == null) change = "0";
if (type == null) type = "0";

String key = "";

if(request.getMethod().equalsIgnoreCase("GET")){

	if(mode.equalsIgnoreCase("add")) {
			title = "REGISTRAR";
			id = "";
			cdo.addColValue("id", "");
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
	} else {
			title = "MODIFICAR";
			sbSql.append("select id, descripcion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_creacion, estado, observacion,cta1,cta2,cta3,cta4,cta5,cta6,(select descripcion from tbl_con_catalogo_gral where cta1=a.cta1 and cta2=a.cta2 and cta3=a.cta3 and cta4=a.cta4 and cta5=a.cta5 and cta6=a.cta6 and compania=a.compania) descCuenta, nvl(limite_subsidio, 0) limite_subsidio from tbl_cxc_tipo_otro_cliente a where id = ");
			sbSql.append(id);
			sbSql.append(" and compania=");
			sbSql.append((String) session.getAttribute("_companyId"));

			if (id == null) throw new Exception("El Parametro no es válido. Por favor intente nuevamente!");
			cdo = SQLMgr.getData(sbSql.toString());
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
null;
}

function doSubmit(valor){
    document.form1.baction.value = valor;
    if(form1Validation()) document.form1.submit();

}
function selCuenta(){abrir_ventana1('../common/search_catalogo_gral.jsp?fp=clientePos');}
</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
    <jsp:param name="title" value=""></jsp:param>
</jsp:include>
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode", mode)%>
<%=fb.hidden("id", cdo.getColValue("id"))%>
<%=fb.hidden("usuario_creacion", cdo.getColValue("usuario_creacion"))%>
<%=fb.hidden("change", change)%>
<%=fb.hidden("baction", "")%>
<%=fb.hidden("fg", fg)%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td align="right">C&oacute;digo:</td>
				<td><%=fb.textBox("codigo", cdo.getColValue("id"), true, false, false, 30, 30, "text12", "", "", "", false, "", "")%></td>
				<td align="right">Descripci&oacute;n:</td>
				<td><%=fb.textBox("descripcion", cdo.getColValue("descripcion"), false, false, false, 50, 100, "text12", "", "", "", false, "", "")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Comentario:</td>
				<td><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,50,3,2000,null,"","")%></td>
				<td align="right">Estado:</td>
				<td><%=fb.select("estado", "A=Activo,I=Inactivo", cdo.getColValue("estado"), false, false, 0, "text12", "", "", "", "", "", "", "")%></td>
			</tr>
			<tr class="TextRow01">
					<td><cellbytelabel>Cuenta Contable(CXC)</cellbytelabel></td>
					<td colspan="3"><%=fb.textBox("cta1",cdo.getColValue("cta1"),false,false,true,3)%>
								<%=fb.textBox("cta2",cdo.getColValue("cta2"),false,false,true,3)%>
								<%=fb.textBox("cta3",cdo.getColValue("cta3"),false,false,true,3)%>
								<%=fb.textBox("cta4",cdo.getColValue("cta4"),false,false,true,3)%>
								<%=fb.textBox("cta5",cdo.getColValue("cta5"),false,false,true,3)%>
								<%=fb.textBox("cta6",cdo.getColValue("cta6"),false,false,true,3)%>&nbsp;
								<%=fb.textBox("descCuenta",cdo.getColValue("descCuenta"),false,false,true,51)%>&nbsp;
								<%=fb.button("btnCta","...",true,false,null,null,"onClick=\"javascript:selCuenta();\"")%>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								Cr&eacute;dito Empresa Diario:
								<%=fb.decBox("limite_subsidio",cdo.getColValue("limite_subsidio"),false,false,false,5,5.2,null,null,"")%>
								</td>

		</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right">
				Opciones de Guardar: 
				<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro 
				<%=fb.radio("saveOption","O",false,false,false)%>Mantener Abierto 
				<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
				<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
			</tr>
		</table>
		</td>
	</tr>
</table>
<%=fb.formEnd(true)%>
<%
%>
</body>
</html>
<%
} else if(request.getMethod().equalsIgnoreCase("post")) {
	String baction = request.getParameter("baction");
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	cdo = new CommonDataObject();
  cdo.setTableName("tbl_cxc_tipo_otro_cliente");  
	if(request.getParameter("id")!=null) cdo.addColValue("id", request.getParameter("id"));
	if(request.getParameter("codigo")!=null) cdo.addColValue("codigo", request.getParameter("codigo"));
	if(request.getParameter("descripcion")!=null) cdo.addColValue("descripcion", request.getParameter("descripcion"));
	if(request.getParameter("observacion")!=null) cdo.addColValue("observacion", request.getParameter("observacion"));
	if(request.getParameter("estado")!=null) cdo.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("limite_subsidio")!=null) cdo.addColValue("limite_subsidio", request.getParameter("limite_subsidio"));
	else cdo.addColValue("limite_subsidio", "0");
	String returnId = "";
	
	cdo.addColValue("cta1", request.getParameter("cta1"));
	cdo.addColValue("cta2", request.getParameter("cta2"));
	cdo.addColValue("cta3", request.getParameter("cta3"));
	cdo.addColValue("cta4", request.getParameter("cta4"));
	cdo.addColValue("cta5", request.getParameter("cta5"));
	cdo.addColValue("cta6", request.getParameter("cta6"));
	
	if (request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("Guardar")) {
		if (mode.equalsIgnoreCase("add")){
			cdo.setAutoIncCol("id");
			cdo.addPkColValue("id","");
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			SQLMgr.insert(cdo);
			returnId = SQLMgr.getPkColValue("id");
		} else {
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.setWhereClause("id="+cdo.getColValue("id")+" and compania="+(String) session.getAttribute("_companyId"));
			SQLMgr.update(cdo);
			returnId = cdo.getColValue("id");
		}
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<%
if(SQLMgr.getErrCode().equals("1")){
%>
    alert('<%=SQLMgr.getErrMsg()%>');
    window.opener.location = '<%=request.getContextPath()%>/pos/list_tipo_otros_clientes.jsp';
<%
    if (saveOption.equalsIgnoreCase("N")){
%>
    setTimeout('addMode()',500);
<%
    } else if (saveOption.equalsIgnoreCase("O")){
%>
    setTimeout('editMode()',500);
<%
    } else if (saveOption.equalsIgnoreCase("C")){
%>
    window.close();
<%
    }    
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
    window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add';
}

function editMode()
{
    window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=returnId%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//post
%>
