<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htCtas" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCtas" scope="session" class="java.util.Vector" />
<%
/**
==========================================================================================
FORMA OP_0001 Orden de pago
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "", key = "";
String mode = request.getParameter("mode");
String id=request.getParameter("id");
String repCode=request.getParameter("repCode");
String grupoCode=request.getParameter("grupoCode");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String appendFilter ="";
boolean viewMode = false;

String fecha = request.getParameter("fecha");
if(fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if(fg==null) fg = "reporte";
if(fp==null) fp = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	cdo = SQLMgr.getData("select nombre from tbl_sec_compania where codigo = " + (String) session.getAttribute("_companyId"));
	if (mode.equalsIgnoreCase("add")){
		if (repCode == null) throw new Exception("El Reporte no es válido. Por favor intente nuevamente!");
		if (grupoCode == null) throw new Exception("El Grupo de Reporte no es válido. Por favor intente nuevamente!");
		sql = "SELECT c.codigo cod_rep, d.codigo cod_grupo, c.descripcion as reporte, d.descripcion as grupo FROM tbl_con_reporte c, tbl_con_grupos_rep d WHERE c.compania = "+(String) session.getAttribute("_companyId")+" and c.compania = d.compania and c.codigo = "+repCode+" and d.codigo = "+grupoCode;
		cdo = SQLMgr.getData(sql);
		htCtas.clear();
		vCtas.clear();
		if (change==null){
			/*
			encabezado
			*/

		sql = "SELECT a.secuen, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, b.descripcion as descripcion_cuenta, a.cia_cta, c.descripcion as reporte, d.descripcion as grupo, a.cod_rep, a.cod_grupo, a.cod_grupo_rel, a.cuenta FROM tbl_con_detalle_rep a, tbl_con_catalogo_gral b, tbl_con_reporte c, tbl_con_grupos_rep d WHERE a.cta1=b.cta1 and a.cta2=b.cta2 and a.cta3=b.cta3 and a.cta4=b.cta4 and a.cta5=b.cta5 and a.cta6=b.cta6 and a.cia_cta=b.compania and a.cod_rep=c.codigo and a.cod_grupo=d.codigo and a.cod_rep=d.cod_rep and a.compania=c.compania and a.compania=d.compania and a.cod_rep="+repCode+" and a.cod_grupo="+grupoCode+" and a.compania="+(String) session.getAttribute("_companyId");

			al = SQLMgr.getDataList(sql);
			/*
			detalle
			*/
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				if ((i+1) < 10) key = "00"+(i+1);
				else if ((i+1) < 100) key = "0"+(i+1);
				else key = ""+(i+1);

				try {
					htCtas.put(key, cdoDet);
					String ctas = cdo.getColValue("cta1")+"_"+cdo.getColValue("cta2")+"_"+cdo.getColValue("cta3")+"_"+cdo.getColValue("cta4")+"_"+cdo.getColValue("cta5")+"_"+cdo.getColValue("cta6");
					vCtas.add(ctas);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Cuentas del reporte- '+document.title;

function doAction(){
}

function doSubmit(valor){
	document.reporte.action.value = valor;
	document.reporte.clearHT.value = 'N';
	window.frames["itemFrame"]._doSubmit(valor);
}

function selOtros(){
	abrir_ventana1('../common/search_beneficiario.jsp?fp=reporte&flag_tipo=PR');
}

function selCuentaBancaria(){
	var cod_banco = document.reporte.cod_banco.value;
	if(cod_banco=='') alert('Seleccione Banco!');
	else abrir_ventana1('../common/search_cuenta_bancaria.jsp?fp=reporte&cod_banco='+cod_banco);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECHAZAR SOLICITUD DE MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td><table align="center" width="99%" cellpadding="0" cellspacing="1">
						<%
						fb = new FormBean("reporte","","post");
						%>
              <%=fb.formStart(true)%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
							<%=fb.hidden("clearHT","")%>
							<%=fb.hidden("action","")%>
              <%=fb.hidden("fg",fg)%>
              <%=fb.hidden("repCode",repCode)%>
              <%=fb.hidden("grupoCode",grupoCode)%>
              <tr class="TextPanel">
                <td colspan="4">REPORTE</td>
              </tr>
              <tr class="TextRow01" >
                <td align="right">Reporte:</td>
                <td><%=cdo.getColValue("cod_rep")%>-<%=cdo.getColValue("reporte")%></td>
                <td align="right">Grupo:</td>
                <td><%=cdo.getColValue("cod_grupo")%>-<%=cdo.getColValue("grupo")%> </td>
              </tr>
              <tr>
                <td colspan="4"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../contabilidad/detalle_rep_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>"></iframe></td>
              </tr>
            </table></td>
        </tr>
        <tr class="TextRow02">
          <td align="right">
          Opciones de Guardar:
					<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro
					<%=fb.radio("saveOption","O",false,false,false)%>Mantener Abierto
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar
					<%=fb.button("save","Guardar",true,false,"","","onClick=\"javascript: doSubmit(this.value);\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
          </td>
        </tr>
        <tr>
          <td>&nbsp;</td>
        </tr>
				<%fb.appendJsValidation("\n\tif (!chkFechaFact()) error++;\n");%>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close

	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function unload(){closeChild=false;}
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/detallereportes_list.jsp?repCode=<%=request.getParameter("repCode")%>&grupoCode=<%=request.getParameter("grupoCode")%>';
<%
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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&repCode=<%=request.getParameter("repCode")%>&grupoCode=<%=request.getParameter("grupoCode")%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&repCode=<%=request.getParameter("repCode")%>&grupoCode=<%=request.getParameter("grupoCode")%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
