<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htPac" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPac" scope="session" class="java.util.Vector" />
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
String change = request.getParameter("change");
String key = "";
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
int lineNo = 0;

boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null) htPac.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	<%
	if(type!=null && type.equals("1")){
	%>
	abrir_ventana1('../common/search_paciente.jsp?fp=merge&mode=<%=mode%>&pac_id=<%=pacId%>');

	<%
	}
	%>
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function _doSubmit(valor){
	document.form1.action.value = valor;
	document.form1.clearHT.value = 'N';
	if(parent.doSubmit()) doSubmit();
}

function doSubmit(){
	document.form1.pacId.value = parent.document.paciente.pacId.value;

	document.form1.submit();

}

function chkCeroRegisters(){
	var size = document.form1.keySize.value;
	if(size>0) return true;
	else{
		if(document.form1.action.value!='Guardar') return true;
		else {
			alert('Seleccione al menos una Unidad!');
			document.form1.action.value = '';
			return false;
		}
	}
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
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>

<%=fb.hidden("pacId",""+pacId)%>

<table width="100%" align="center">
  <tr>
    <td><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <%
				int colspan = 7;
				%>
        <tr class="TextPanel">
          <td colspan="<%=colspan-2%>">Detalle</td>
          <td colspan="2" align="right"><%=fb.button("addPaciente","Agregar Pacientes",false,viewMode, "", "", "onClick=\"javascript: _doSubmit(this.value);\"")%></td>
        </tr>
        <tr class="TextHeader">
          <td align="center">Pac. Id</td>
          <td align="center">Nombre</td>
          <td align="center">Identificaci&oacute;n</td>
		  <td align="center">Fecha Nac.</td>
          <td align="center">Sexo</td>
          <td align="center">Edad</td>
          <td width="3%" align="center">Eliminar?</td>
        </tr>
        <%
				key = "";
				if (htPac.size() != 0) al = CmnMgr.reverseRecords(htPac);
				for (int i=0; i<htPac.size(); i++){
					key = al.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) htPac.get(key);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
        <%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
        <%=fb.hidden("nombre_paciente"+i,cdo.getColValue("nombre_paciente"))%>
		<%=fb.hidden("edad"+i,cdo.getColValue("edad"))%>
        <%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
        <%=fb.hidden("id_paciente"+i,cdo.getColValue("id_paciente"))%>
        <%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
		<%=fb.hidden("is_saved"+i,cdo.getColValue("is_saved"))%>
		<%=fb.hidden("f_nac"+i,cdo.getColValue("f_nac"))%>
        <tr class="<%=color%>" >
          <td align="center"><%=cdo.getColValue("pac_id")%> </td>
          <td align="left"><%=cdo.getColValue("nombre_paciente")%> </td>
          <td align="center"><%=cdo.getColValue("id_paciente")%> </td>
          <td align="center"><%=cdo.getColValue("f_nac")%> </td>
          <td align="center"><%=cdo.getColValue("sexo")%> </td>
          <td align="center"><%=cdo.getColValue("edad")%> </td>
          <td width="3%" align="center">
		  <%if(cdo.getColValue("is_saved").equals("S")){%>
		  <%=fb.checkbox("chk"+i,""+i,false, false, "", "", "")%>
		  <%} else {%>
		  <%=fb.submit("del"+i,"X",false,viewMode, "text10", "", "onClick=\"javascript: _doSubmit(this.value);\"")%>
		  <%}%>
		  </td>
        </tr>
        <%
		}
		%>
        <%=fb.hidden("keySize",""+htPac.size())%>
        <tr class="TextRow02">
          <td colspan="<%=colspan%>" align="right">
          Opciones de Guardar:
					<%//=fb.radio("saveOption","N",false,false,false)%><!--Crear Otro-->
					<%=fb.radio("saveOption","O",false,false,false)%>Mantener Abierto
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar
					<%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript: _doSubmit(this.value);\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
          </td>
        </tr>
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
	String clearHT = request.getParameter("clearHT");
	String uAdmDel = "";
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	htPac.clear();
	vPac.clear();
	al = new ArrayList();
	CommonDataObject cdoE = new CommonDataObject();
	for(int i=0;i<keySize;i++){
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("pac_id",request.getParameter("pac_id"+i));
		cdo.addColValue("nombre_paciente",request.getParameter("nombre_paciente"+i));
		cdo.addColValue("sexo",request.getParameter("sexo"+i));
		cdo.addColValue("edad",request.getParameter("edad"+i));
		cdo.addColValue("fecha_nacimiento",request.getParameter("fecha_nacimiento"+i));
		cdo.addColValue("id_paciente",request.getParameter("id_paciente"+i));
		cdo.addColValue("is_saved",request.getParameter("is_saved"+i));
		cdo.addColValue("f_nac",request.getParameter("f_nac"+i));
		if(request.getParameter("action")!=null && request.getParameter("action").equalsIgnoreCase("Guardar")){
			cdoE = new CommonDataObject();
			cdoE.setTableName("tbl_adm_paciente");
			if(request.getParameter("is_saved"+i)!=null && request.getParameter("is_saved"+i).equals("S") && request.getParameter("chk"+i)!=null){
			cdoE.addColValue("exp_id","pac_id");
			cdoE.addColValue("pac_unico","S");
			} else {
			cdoE.addColValue("exp_id",request.getParameter("pacId"));
			cdoE.addColValue("pac_unico","N");
			}
			cdoE.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdoE.setWhereClause("pac_id="+request.getParameter("pac_id"+i));
		}

		if ((i+1) < 10) key = "00"+(i+1);
		else if ((i+1) < 100) key = "0"+(i+1);
		else key = ""+(i+1);

		if(request.getParameter("del"+i)==null){
			try {
				htPac.put(key, cdo);
				vPac.add(cdo.getColValue("pac_id"));
				al.add(cdoE);
			} catch (Exception e) {
				System.out.println("Unable to addget item "+key);
			}
		} else {
			uAdmDel = "1";
		}
	}

	if(!uAdmDel.equals("") || clearHT.equals("S")){
		response.sendRedirect("../admision/merge_paciente_det.jsp?mode="+mode+"&pacId="+pacId+"&change=1");
		return;
	}


	if(request.getParameter("action")!=null && request.getParameter("action").equalsIgnoreCase("Agregar Pacientes")){
		response.sendRedirect("../admision/merge_paciente_det.jsp?mode="+mode+"&type=1&change=1&pacId="+pacId);
		return;
	}

	if (mode.equalsIgnoreCase("add")&& request.getParameter("action")!=null && request.getParameter("action").equals("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.updateList(al);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (SQLMgr.getErrCode().equals("1")){%>
			parent.document.paciente.errCode.value = <%=SQLMgr.getErrCode()%>;
			parent.document.paciente.errMsg.value = '<%=SQLMgr.getErrMsg()%>';
			parent.document.paciente.pacId.value = '<%=pacId%>';
			parent.document.paciente.saveOption.value = '<%=saveOption%>';
			parent.document.paciente.submit();
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

