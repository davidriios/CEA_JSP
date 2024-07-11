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
<jsp:useBean id="OP" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="OrdPago" scope="session" class="issi.cxp.OrdenPago" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="opDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="opDetKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fact" scope="session" class="java.util.Hashtable" />
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
OrdPagoMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "", key = "";
String mode = request.getParameter("mode");
String documento = request.getParameter("documento");
String change = request.getParameter("change");
String pac_id = request.getParameter("pac_id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String appendFilter ="";
boolean viewMode = false;

String fecha = request.getParameter("fecha");
if(fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");

if(fg==null) fg = "mat_paciente";
if(fp==null) fp = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	//cdo = SQLMgr.getData("select nombre from tbl_sec_compania where codigo = " + (String) session.getAttribute("_companyId"));
	OP = new CommonDataObject();
	OrdPago = new OrdenPago();
	if (mode.equalsIgnoreCase("add")){
		documento = "0";
		OP.addColValue("fecha", fecha);
		OP.addColValue("documento", documento);
		opDet.clear();
		opDetKey.clear();
		fact.clear();
	} else {
		if (documento == null) throw new Exception("Requisición no es válida. Por favor intente nuevamente!");

		if (change==null){
			opDet.clear();
			opDetKey.clear();
			fact.clear();
			/*
			encabezado
			*/
			sql="select a.documento, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.beneficiario, a.unidad_adm1, to_char(a.monto,'999,999,999.00') monto, a.estado1, decode(a.estado1, 'P', 'Pendiente', 'A', 'Aprobada', 'T', 'Autorizada', 'R', 'Procesada', 'N', 'Anulada', 'X', 'Rechazada') estado1_desc, a.observacion, a.motivo_rechazado, a.clasificacion, b.descripcion unidad_descripcion, c.nombre nom_beneficiario, nvl(c.ruc, ' ') ruc, nvl(to_char(c.digito_verificador), ' ') dv from tbl_cxp_orden_unidad a, tbl_sec_unidad_ejec b, tbl_con_pagos_otros c where a.compania = b.compania and a.unidad_adm1 = b.codigo and a.compania = c.compania and a.beneficiario = c.codigo and a.compania = "+(String) session.getAttribute("_companyId") + " and a.documento = "+documento+" and trunc(a.fecha) = to_date('"+fecha+"', 'dd/mm/yyyy')";
			OP = SQLMgr.getData(sql);

			sql="select a.unidad_adm, a.monto, a.observacion2, a.usuario_creacion, b.descripcion nombre_unidad from tbl_cxp_orden_unidad_det a, tbl_sec_unidad_ejec b where a.compania = b.compania and a.unidad_adm = b.codigo and a.compania = "+(String) session.getAttribute("_companyId") + " and a.documento = "+documento+" and trunc(a.fecha) = to_date('"+fecha+"', 'dd/mm/yyyy')";
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
					opDet.put(key, cdoDet);
					opDetKey.put(cdoDet.getColValue("unidad_adm"), key);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	}
	session.setAttribute("OP",OP);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Cuentas x Pagar- '+document.title;

function doAction(){
}

function doSubmit(){
	return true;
}

function selOtros(){
	abrir_ventana1('../common/search_pago_otro.jsp?fp=orden_pago');
}

function addFacturas(){
	var fecha = document.orden_pago.fecha.value;
	var documento = document.orden_pago.documento.value;
	<%if(mode.equals("add")){%>
	abrir_ventana1('../cxp/ingreso_facturas.jsp?fp=sol_orden_pago');
	<%} else if(mode.equals("edit")){%>
	abrir_ventana1('../cxp/ingreso_facturas.jsp?fp=sol_orden_pago&fecha='+fecha+'&documento='+documento+'&compania=<%=(String) session.getAttribute("_companyId")%>');
	<%}%>
}
function printSol(){
    var fecha = document.orden_pago.fecha.value;
	var doc = document.orden_pago.documento.value;
   abrir_ventana('../cxp/print_sol_orden_pago.jsp?mode=edit&doc='+doc+'&fecha='+fecha);
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
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
						<%
						fb = new FormBean("orden_pago","","post");
						%>
              <%=fb.formStart(true)%> 
							<%=fb.hidden("mode",mode)%> 
							<%//=fb.hidden("documento",documento)%> 
							<%=fb.hidden("errCode","")%> 
							<%=fb.hidden("errMsg","")%> 
              <%=fb.hidden("saveOption","")%> 
							<%=fb.hidden("clearHT","")%> 
							<%=fb.hidden("action","")%> 
              <%=fb.hidden("fg",fg)%> 
              <tr class="TextPanel">
                <td colspan="5"><cellbytelabel>Orden de Pago</cellbytelabel></td>
                <td align="right">
				<%=fb.button("btnPnt","Imprimir",false, (viewMode||mode.trim().equals("add")),"","","onClick=\"javascript:printSol()\"")%>
				</td>
              </tr>
              <tr class="TextPanel">
                <td align="right"><cellbytelabel>Compan&ntilde;&iacute;a</cellbytelabel></td>
                <td colspan="5"><%=cdo.getColValue("nombre")%></td>
              </tr>
              <tr class="TextRow01" >
                <td align="right"><cellbytelabel>Orden No</cellbytelabel>.</td>
                <td><%=fb.textBox("documento",OP.getColValue("documento"),true,false,true,10,"text10",null,"")%> </td>
                <td align="right"><cellbytelabel>Tipo de Orden</cellbytelabel></td>
                <td><%=fb.select("tipo_orden","O=Otros", OP.getColValue("tipo_orden"),false, false, 0,"text10",null,"")%> </td>
                <td align="right"><cellbytelabel>Fecha</cellbytelabel></td>
                <td><%=fb.textBox("fecha",OP.getColValue("fecha"),true,false,true,12,"text10",null,"")%> </td>
              </tr>
              <tr class="TextRow01">
                <td align="right"><cellbytelabel>Unidad Solicitante</cellbytelabel></td>
                <td>
								<%=fb.select(ConMgr.getConnection(),"select u.unidad_adm, u.unidad_adm||'-'||e.descripcion from tbl_cxp_usuario_x_unidad u, tbl_sec_unidad_ejec e where u.compania = "+(String) session.getAttribute("_companyId") + " and u.usuario = '"+(String) session.getAttribute("_userName")+"' and u.orden_pago in (1, 3) and (e.compania = u.compania and e.codigo = u.unidad_adm) order by e.descripcion","unidad_adm1",OP.getColValue("unidad_adm1"),false,false,0, "text10", "", "")%>
                &nbsp;&nbsp;
                </td>
                <td align="right"><cellbytelabel>Estado</cellbytelabel></td>
                <td><%=fb.select("estado1","P=Pendiente", OP.getColValue("estado1"), false, false,0,"text10",null,"")%> </td>
                <td align="right">Clasificaci&oacute;n</td>
                <td>
								<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||'-'||descripcion from tbl_cxp_orden_clasificacion where estado = 'A' order by descripcion","clasificacion",OP.getColValue("clasificacion"),false,false,0, "text10", "", "")%>
                &nbsp;&nbsp;
                </td>
              </tr>
              <tr class="TextRow01" >
                <td align="right"><cellbytelabel>A Favor de</cellbytelabel></td>
                <td colspan="3">
								<%=fb.textBox("beneficiario",OP.getColValue("beneficiario"),true,false,true,20,"text10",null,"")%>
								<%=fb.textBox("nom_beneficiario",OP.getColValue("nom_beneficiario"),true,false,true,80,"text10",null,"")%>
                <%=fb.button("buscar","...",false, viewMode,"","","onClick=\"javascript:selOtros()\"")%> 
                </td>
                <td align="right" colspan="2">
                <%=fb.hidden("tipo_persona", OP.getColValue("tipo_persona"))%>
                <cellbytelabel>R.U.C</cellbytelabel>.&nbsp;<%=fb.textBox("ruc",OP.getColValue("ruc"),false,false,true,30,"text10",null,"")%>&nbsp;
								<cellbytelabel>D.V</cellbytelabel>.<%=fb.textBox("dv",OP.getColValue("dv"),false,false,true,10,"text10",null,"")%>&nbsp;
                <cellbytelabel>Monto</cellbytelabel>
                <%=fb.decBox("monto",OP.getColValue("monto"),true,false,false,10, 8.2,"text10",null,"onFocus=\"this.select();\"","Monto",false,"")%>
								</td>
              </tr>
              <tr class="TextRow01" >
                <td colspan="2">
                <cellbytelabel>En Concepto de</cellbytelabel>:<br>
                <%=fb.textarea("observacion",OP.getColValue("observacion"),true,false,viewMode,45,5,"text10",null,"")%> 
                </td>
                <td colspan="3">
                <%if(mode.equals("edit")){%>
                <font class="RedTextBold">
                <cellbytelabel>Motivo de Correci&oacute;n</cellbytelabel>:</font><br>
                <%=fb.textarea("motivo_rechazado",OP.getColValue("motivo_rechazado"),true,false,viewMode,45,5,"text10",null,"")%> 
                <%}%>
                </td>
                <td align="center"><%=fb.button("add_facturas","Ingreso de Facturas",false, viewMode,"","","onClick=\"javascript:addFacturas()\"")%> </td>
              </tr>
              <tr>
                <td colspan="6"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../cxp/reg_orden_pago_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&documento=<%=documento%>"></iframe></td>
              </tr>
            </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
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

	documento = request.getParameter("documento");
	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
	session.removeAttribute("OP");
	session.removeAttribute("opDet");
	session.removeAttribute("opDetKey");
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	window.opener.location = '<%=request.getContextPath()%>/cxp/sol_orden_pago_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&tr=<%=tr%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&documento=<%=documento%>&fecha=<%=fecha%>';
	///reg_sol_mat_pacientes.jsp?mode=view&id=1&anio=2009&tr=PAC_S
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
