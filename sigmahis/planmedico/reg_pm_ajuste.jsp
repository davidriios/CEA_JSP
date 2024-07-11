<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.planmedico.Solicitud"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="SOL" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SolMgr" scope="page" class="issi.planmedico.SolicitudMgr" />
<jsp:useBean id="Sol" scope="session" class="issi.planmedico.Solicitud" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htClt" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htCltD" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vClt" scope="session" class="java.util.Vector" />

<%
/**
==========================================================================================
FORMA SOL_0001 Orden de pago
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
SolMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alAM = new ArrayList();
StringBuffer sbSql = new StringBuffer();
CommonDataObject cdo = new CommonDataObject();
String key = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String anio = request.getParameter("anio");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String appendFilter ="";
boolean viewMode = false;
String tab = request.getParameter("tab");
if (tab == null) tab = "0";
String tabFunctions = "'1=tabFunctions(1)'";
String fecha = request.getParameter("fecha");
if(fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if(anio == null) anio = CmnMgr.getCurrentDate("yyyy");
if(fg==null) fg = "";
if(fp==null) fp = "plan_medico";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	SOL = new CommonDataObject();
	Sol = new Solicitud();
	sbSql = new StringBuffer();
			sbSql.append("select get_sec_comp_param(-1, 'PORC_IMP_FACT_PLAN_MEDICO') itbm from dual");
			System.out.println("query...................."+sbSql.toString());
			cdo = SQLMgr.getData(sbSql.toString());

	if (mode.equalsIgnoreCase("add")){

		id = "0";
		SOL.addColValue("fecha_ini_plan", "");
		SOL.addColValue("id", id);
		SOL.addColValue("estado", "P");
		SOL.addColValue("id_cliente", "0");
		htClt.clear();
		vClt.clear();
		session.removeAttribute("Sol");
		System.out.println("..............................id="+id);
		if(fp.equals("adenda") && request.getParameter("id")!=null && !request.getParameter("id").equals("")){
			id = request.getParameter("id");
			/*
			encabezado
			*/
			sbSql = new StringBuffer();
			sbSql.append("");
			System.out.println("query...................."+sbSql.toString());
			SOL = SQLMgr.getData(sbSql.toString());

			sbSql = new StringBuffer();
			sbSql.append("");
			al = SQLMgr.getDataList(sbSql.toString());
			sbSql = new StringBuffer();
			/*
			detalle
			*/
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				cdoDet.setKey(i);
				try {
					htClt.put(cdoDet.getKey(),cdoDet);
					String ctas = cdoDet.getColValue("id_cliente");
					vClt.add(ctas);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	} else {
		if (id == null) throw new Exception("Númeor de Ajuste no es válido. Por favor intente nuevamente!");

		if (change==null){

		htClt.clear();
		vClt.clear();
			/*
			encabezado
			*/
			sbSql = new StringBuffer();
			sbSql.append("select a.id, a.compania, a.anio, a.mes, a.tipo_aju, a.tipo_ben, a.id_solicitud, a.id_referencia, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_aprobacion, 'dd/mm/yyyy') fecha_aprobacion, a.usuario_aprobacion, a.estado, a.observacion, (case when a.tipo_ben = 1 then (select v.nombre_paciente from vw_pm_cliente v where to_char(v.codigo) = a.id_referencia) else ''  end) referencia_desc, decode(a.tipo_ben, 1, 'CxC Afiliado', 2, 'CxP Medico', 3, 'CxP Empresa Reclamos') tipo_ben_desc, decode(a.tipo_aju, 1, 'Descuento a Factura', 2, 'Anular Pago', 3, 'Nota de Credito', 4, 'Nota de Credito CxP', 5, 'Nota de Debito', 0, 'NC Anular Factura') tipo_aju_desc from tbl_pm_ajuste a");
			sbSql.append(" where compania = ");
			sbSql.append((String) session.getAttribute("_companyId"));
			sbSql.append(" and a.id = ");
			sbSql.append(id);
			SOL = SQLMgr.getData(sbSql.toString());
			sbSql = new StringBuffer();
			sbSql.append("select a.tipo_trx, a.id, a.compania, a.secuencia, a.estado, a.id_ref, a.anio, a.mes, a.monto, a.debito, a.credito, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, (case when b.tipo_aju in (1, 3) then b.id_solicitud||'_'||a.anio||'_'||a.mes when b.tipo_aju = 2 then b.id_solicitud||'_'||a.tipo_trx||'_'||a.id_ref else '' end) key, to_char(to_date(a.mes, 'mm'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') mes_desc, a.descripcion, decode(a.tipo_trx, 'M', 'PAGO MANUAL', 'ACH', 'ACH', 'TC', 'TARJETA DE CREDITO', tipo_trx) tipo_trx_desc, nvl(a.subtotal, 0) subtotal, nvl(a.impuesto, 0) impuesto from tbl_pm_ajuste_det a, tbl_pm_ajuste b where a.compania = ");
			sbSql.append((String) session.getAttribute("_companyId"));
			sbSql.append(" and a.id = ");
			sbSql.append(id);
			sbSql.append(" and a.compania = b.compania and a.id = b.id");
			System.out.println("sbSql="+sbSql.toString());
			al = SQLMgr.getDataList(sbSql.toString());
			sbSql = new StringBuffer();
			/*
			detalle
			*/
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				cdoDet.setKey(i);
				try {
					htClt.put(cdoDet.getKey(),cdoDet);
					htCltD.put(cdoDet.getKey(),cdoDet);
					String ctas = cdoDet.getColValue("key");
					vClt.add(ctas);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	}
	session.setAttribute("SOL",SOL);
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Plan Médico - Ajuste'+document.title;

function doAction(){
}

function doSubmit(valor){
	window.frames['itemFrame'].doSubmit(valor);
}
function chkDetail(valor){
	
	window.frames['itemFrame'].location='../planmedico/reg_pm_ajuste_det.jsp?mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&tipo_aju='+valor;
}
function addCliente(){
	var cuota = document.ajuste.cuota.value;
	var afiliados = '';
	if(document.ajuste.afiliados) afiliados = document.ajuste.afiliados.value;
	abrir_ventana('../planmedico/pm_sel_cliente.jsp?fp=plan_medico&fg=responsable&cuota='+cuota+'&afiliados='+afiliados);
}

function addSolicitud(){
	abrir_ventana('../planmedico/pm_sel_solicitud.jsp?fg=<%=fg%>&fp=ajustes');
}



function tabFunctions(tab){
	var iFrameName = '';
	if(tab==1) iFrameName='iFrameTarjeta';
	window.frames[iFrameName].doAction();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<table align="center" width="99%" cellpadding="0" cellspacing="1">
        <tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
						<%
						fb = new FormBean("ajuste","","post");
						%>
              <%=fb.formStart(true)%>
							<%=fb.hidden("tab","0")%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
							<%=fb.hidden("clearHT","")%>
							<%=fb.hidden("action","")%>
              <%=fb.hidden("fg",fg)%>
              <%=fb.hidden("fp",fp)%>
              <%=fb.hidden("id",id)%>
              <%=fb.hidden("itbm",cdo.getColValue("itbm"))%>
              <tr class="TextPanel">
                <td colspan="6">Notas de Ajuste <%=(fg.equals("cxc")?"CXC":"CXP")%></td>
              </tr>
              <tr class="TextRow01">
                <td><cellbytelabel>Contrato</cellbytelabel></td>
								<td>
								<%=fb.textBox("id_solicitud",SOL.getColValue("id_solicitud"),true,false,true,10,"Text10",null,null)%>
								<%=fb.button("btnsolicitud","Contrato",true,viewMode,null,null,"onClick=\"javascript:addSolicitud()\"")%>
								</td>
                <td>Tipo:
								</td>
								<td>
								<%if(mode.equals("add")){%>
								<%=fb.select("tipo_ben",(fg.equals("cxc")?"1=CxC Afiliado":"2=CxP Medico,3=CxP Empresa Reclamos"),SOL.getColValue("tipo_ben"),true,false,viewMode,0,"","","")%>
								<%} else {%>
								<%=fb.hidden("tipo_ben",SOL.getColValue("tipo_ben"))%>
								<%=fb.textBox("tipo_ben_desc",SOL.getColValue("tipo_ben_desc"),false,false,true,25,"Text10",null,null)%>
								<%}%>
								</td>
								<td><cellbytelabel>Tipo Ajuste</cellbytelabel>:</td>
								<td>
								<%if(mode.equals("add")){%>
								<%=fb.select("tipo_aju",(fg.equals("cxc")?"1=Descuento a Factura,2=Anular Pago,3=N/C-Ajuste a Factura,5=Nota de Debito, 0=NC Anular Factura":"4=Nota de Credito CxP"),SOL.getColValue("tipo_ajuste"),true,false,viewMode,0,"","","onChange='javascript:chkDetail(this.value);'","","S")%>
								<%} else {%>
								<%=fb.hidden("tipo_aju",SOL.getColValue("tipo_aju"))%>
								<%=fb.textBox("tipo_aju_desc",SOL.getColValue("tipo_aju_desc"),false,false,true,30,"Text10",null,null)%>
								<%}%>
								</td>
              </tr>
							<%=fb.hidden("id_referencia",SOL.getColValue("id_referencia"))%>
              <tr class="TextRow01">
                <td colspan="1">Referencia:</td>
                <td colspan="2"><%=fb.textBox("referencia_desc",SOL.getColValue("referencia_desc"),false,false,true,100,"Text10",null,null)%></td>
                <td colspan="1">Observaci&oacute;n:</td>
                <td colspan="2"><%=fb.textarea("observacion",SOL.getColValue("observacion"),false,false,viewMode,60,2, 200)%></td>
              </tr>
              <tr>
                <td colspan="6"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="99" scrolling="no" src="../planmedico/reg_pm_ajuste_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&id=<%=id%>&tipo_aju=<%=SOL.getColValue("tipo_aju")%>"></iframe></td>
              </tr>
							<tr class="TextRow02">
								<td colspan="6" align="right">
								<cellbytelabel>Opciones de Guardar</cellbytelabel>:
								<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro</cellbytelabel>
								<%=fb.radio("saveOption","O",false,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
								<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
								<%=fb.button("save","Guardar",true,((fp.equals("adenda") && SOL.getColValue("estado").equals("A") && mode.equals("edit")) || (!fp.equals("adenda") && SOL.getColValue("estado").equals("A") && mode.equals("edit")) || SOL.getColValue("estado").equals("I") || mode.equals("view")),"","","onClick=\"javascript:doSubmit(this.value);\"")%>
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
								</td>
							</tr>
							<!--
							-->
            </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	System.out.println("saveOption............................="+saveOption);
	id = request.getParameter("id");
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
	window.opener.location = '<%=request.getContextPath()%>/planmedico/pm_ajustes_list.jsp';
<%
session.removeAttribute("Sol");
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
