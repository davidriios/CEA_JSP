<%@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="ACMMgr" scope="page" class="issi.contabilidad.AccountMapMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htCtas" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCtas" scope="session" class="java.util.Vector" />
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
ACMMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String repCode=request.getParameter("repCode");
String grupoCode=request.getParameter("grupoCode");
int lineNo = 0;

boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null) htCtas.clear();
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
	abrir_ventana1('../common/check_cuentas_rep.jsp?fp=reporte&mode=<%=mode%>');

	<%
	}
	%>
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function _doSubmit(valor){
	document.reporte.action.value = valor;
	document.reporte.clearHT.value = 'N';
	doSubmit();
}

function doSubmit(){
	document.reporte.repCode.value = parent.document.reporte.repCode.value;
	document.reporte.grupoCode.value = parent.document.reporte.grupoCode.value;

	if (document.reporte.action.value == 'Guardar'){
		if (!reporteValidation()){
			reporteBlockButtons(false);
			return false;
		} else document.reporte.submit();
	} else {
		if(document.reporte.action.value != 'Guardar'){
			parent.reporteBlockButtons(false);
			reporteBlockButtons(false);
		}	
		document.reporte.submit();
	}
	
}

function chkCeroRegisters(){
	var size = document.reporte.keySize.value;
	if(size>0) return true;
	else{
		if(document.reporte.action.value!='Guardar') return true;
		else {
			alert('Seleccione al menos una Cuenta!');
			document.reporte.action.value = '';
			return false;
		}
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("reporte",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%> 
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("baction","")%> 
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("clearHT","")%> 
<%=fb.hidden("action","")%> 
<%=fb.hidden("repCode",repCode)%> 
<%=fb.hidden("grupoCode",grupoCode)%> 
<table width="100%" align="center">
  <tr>
    <td><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <tr class="TextPanel">
          <td colspan="4" align="right"><%=fb.button("addCuentas","Agregar Cuentas",false,viewMode, "", "", "onClick=\"javascript: _doSubmit(this.value);\"")%></td>
        </tr>
        <tr class="TextHeader">
          <td width="15%" align="center">Secuencia</td>
          <td width="20%" align="center">&nbsp;</td>
          <td width="62%" align="center">Cuenta</td>
          <td width="3%" align="center">&nbsp;</td>
        </tr>
        <%
				key = "";
				if (htCtas.size() != 0) al = CmnMgr.reverseRecords(htCtas);
				for (int i=0; i<htCtas.size(); i++){
					key = al.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) htCtas.get(key);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
        <%=fb.hidden("secuen"+i,cdo.getColValue("secuen"))%>
        <%=fb.hidden("cod_rep"+i,cdo.getColValue("cod_rep"))%>
        <%=fb.hidden("cod_grupo"+i,cdo.getColValue("cod_grupo"))%>
				<%=fb.hidden("cta1_"+i,cdo.getColValue("cta1"))%>
        <%=fb.hidden("cta2_"+i,cdo.getColValue("cta2"))%>
        <%=fb.hidden("cta3_"+i,cdo.getColValue("cta3"))%>
        <%=fb.hidden("cta4_"+i,cdo.getColValue("cta4"))%>
        <%=fb.hidden("cta5_"+i,cdo.getColValue("cta5"))%>
        <%=fb.hidden("cta6_"+i,cdo.getColValue("cta6"))%>
        <%=fb.hidden("cuenta"+i,cdo.getColValue("cuenta"))%>
        <%=fb.hidden("descripcion_cuenta"+i,cdo.getColValue("descripcion_cuenta"))%>
        <tr class="<%=color%>" >
          <td align="center">
					<%=fb.textBox("secuen"+i,cdo.getColValue("secuen"),false,false,true,5,"text10",null,"onFocus=\"this.select();\"")%></td>
          <td><%=cdo.getColValue("cuenta")%></td>
          <td><%=cdo.getColValue("cta1")+"."+cdo.getColValue("cta2")+"."+cdo.getColValue("cta3")+"."+cdo.getColValue("cta4")+"."+cdo.getColValue("cta5")+"."+cdo.getColValue("cta6")+" - "+cdo.getColValue("descripcion_cuenta")%></td>
          <td width="3%" align="center"><%=fb.submit("del"+i,"X",false,false, "text10", "", "onClick=\"javascript: _doSubmit(this.value);\"")%></td>
        </tr>
        <%
				}
				%>
        <%=fb.hidden("keySize",""+htCtas.size())%> 
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

	htCtas.clear();
	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("secuen",request.getParameter("secuen"+i));
		cdo.addColValue("cta1",request.getParameter("cta1_"+i));
		cdo.addColValue("cta2",request.getParameter("cta2_"+i));
		cdo.addColValue("cta3",request.getParameter("cta3_"+i));
		cdo.addColValue("cta4",request.getParameter("cta4_"+i));
		cdo.addColValue("cta5",request.getParameter("cta5_"+i));
		cdo.addColValue("cta6",request.getParameter("cta6_"+i));
		cdo.addColValue("cuenta",request.getParameter("cuenta"+i));
		cdo.addColValue("descripcion_cuenta",request.getParameter("descripcion_cuenta"+i));

		cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
		cdo.addColValue("cod_rep", request.getParameter("repCode"));
		cdo.addColValue("cod_grupo", request.getParameter("grupoCode"));
		cdo.addColValue("cia_cta", (String) session.getAttribute("_companyId"));

		
		if ((i+1) < 10) key = "00"+(i+1);
		else if ((i+1) < 100) key = "0"+(i+1);
		else key = ""+(i+1);

		if(request.getParameter("del"+i)==null){
			try {
				htCtas.put(key, cdo);
				String ctas = cdo.getColValue("cta1")+"_"+cdo.getColValue("cta2")+"_"+cdo.getColValue("cta3")+"_"+cdo.getColValue("cta4")+"_"+cdo.getColValue("cta5")+"_"+cdo.getColValue("cta6");
				vCtas.add(ctas);
				al.add(cdo);
			} catch (Exception e) {
				System.out.println("Unable to addget item "+key);
			}
		} else {
			uAdmDel = "1";
		}
	}

	if(!uAdmDel.equals("") || clearHT.equals("S")){
		response.sendRedirect("../contabilidad/detalle_rep_det.jsp?mode="+mode+"&repCode="+repCode+"&grupoCode="+grupoCode+"&change=1&type=2&fg="+fg+"&fp="+fp);
		return;
	}


	if(request.getParameter("action")!=null && request.getParameter("action").equalsIgnoreCase("Agregar Cuentas")){
		response.sendRedirect("../contabilidad/detalle_rep_det.jsp?mode="+mode+"&repCode="+repCode+"&grupoCode="+grupoCode+"&change=1&type=1&fg="+fg);
		return;
	}

	if (mode.equalsIgnoreCase("add")&& request.getParameter("action")!=null && request.getParameter("action").equals("Guardar")){
		ACMMgr.addDetReporte(al);
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (ACMMgr.getErrCode().equals("1")){%>
			parent.document.reporte.errCode.value = <%=ACMMgr.getErrCode()%>;
			parent.document.reporte.errMsg.value = '<%=ACMMgr.getErrMsg()%>';
			parent.document.reporte.submit();
	<%} else throw new Exception(ACMMgr.getErrMsg());%>
		
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

