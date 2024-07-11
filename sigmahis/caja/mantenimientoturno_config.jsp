<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.caja.Turnos"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="TrMgr" scope="page" class="issi.caja.TurnosMgr"/>
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
TrMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alCaja = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String ip = request.getRemoteAddr();
CommonDataObject cdoCaj = new CommonDataObject();
CommonDataObject cdoC = new CommonDataObject();
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
int iconHeight = 20;
int iconWidth = 20;

String touch = request.getParameter("touch") == null ? "" : request.getParameter("touch");
String useKeypad = request.getParameter("useKeypad") == null ? "" : request.getParameter("useKeypad");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (viewMode) alCaja = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_cja_cajas where compania = "+session.getAttribute("_companyId")+" order by descripcion",CommonDataObject.class);
	else{
	sbSql = new StringBuffer();
	sbSql.append("select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_cja_cajas where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and codigo in (");
				if(session.getAttribute("_codCaja")!=null)
					sbSql.append(session.getAttribute("_codCaja"));
				else sbSql.append("-1");
			sbSql.append(") ");
	sbSql.append("  order by descripcion ");
	alCaja = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
	}
	if (alCaja.size() == 0) throw new Exception("Sr. Usuario: esta PC no tiene asignado un número de caja!");

	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("id","0");
		cdo.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		cdo.addColValue("horaIni",CmnMgr.getCurrentDate("hh12:mi:ss am"));
		cdo.addColValue("horaFin","");

		sbSql = new StringBuffer();
		sbSql.append("select cod_cajera, nombre, usuario from tbl_cja_cajera where usuario = '");
		sbSql.append(session.getAttribute("_userName"));
		sbSql.append("' and compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		cdoCaj = SQLMgr.getData(sbSql.toString());
        
		if (cdoCaj == null) throw new Exception("Usuario, usted no esta registrado como cajero!. Por favor intente nuevamente!");
		cdo.addColValue("cajeraCode",cdoCaj.getColValue("cod_cajera"));
		cdo.addColValue("cajera",cdoCaj.getColValue("nombre"));
	}
	else
	{
		if (id == null) throw new Exception("El Código de Mantenimiento de Turno no es válido. Por favor intente nuevamente!");
		sbSql = new StringBuffer();
		sbSql.append("select a.compania, a.codigo as id, a.cja_cajera_cod_cajera as cajeraCode, b.nombre as cajera, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.monto_inicial as montoIni, to_char(a.hora_inicio,'hh12:mi:ss am') as horaIni, to_char(a.hora_final,'hh12:mi:ss am') as horaFin, a.observacion, c.cod_caja as caja, c.estatus, d.descripcion, f.nombre from tbl_cja_turnos a, tbl_cja_cajera b, tbl_cja_turnos_x_cajas c, tbl_cja_cajas d, tbl_sec_compania f where a.cja_cajera_cod_cajera = b.cod_cajera and a.compania = b.compania and a.compania = c.compania(+) and a.codigo = c.cod_turno(+) and c.cod_caja=d.codigo /*and d.estado = 'A'*/ and a.codigo = ");
		sbSql.append(id);
		sbSql.append(" and a.compania = f.codigo and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		cdo = SQLMgr.getData(sbSql.toString());
		System.out.println(" cajeraCode ====== "+cdo.getColValue("cajeraCode"));
		System.out.println(" cajera ====== "+cdo.getColValue("cajera"));
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Mantenimiento de Turno - "+document.title;
function addCajera(){abrir_ventana1('../caja/mantenimientoturno_cajeros_list.jsp?id=1&cia=<%=session.getAttribute("_companyId")%>&user=<%=session.getAttribute("_userName")%>');}
function doAction(){<% if (mode.equalsIgnoreCase("add")) { %>chkCaja();<% } %>}
function chkCaja(){var cod_caja=document.form1.caja.value;var estado=getDBData('<%=request.getContextPath()%>','estatus','tbl_cja_turnos_x_cajas','compania = <%=(String) session.getAttribute("_companyId")%> and cod_caja = '+cod_caja+' and estatus = \'A\'');if(estado=='A'){alert('Sr(a). Usuario, Esta caja ya está Activa!');form1BlockButtons(true);}else{form1BlockButtons(false);chkCajero();}}
function chkCajero(){var cod_caja=document.form1.caja.value;var cod_cajero=document.form1.cajeraCode.value;var estado=getDBData('<%=request.getContextPath()%>','tc.estatus','tbl_cja_cajera c, tbl_cja_turnos t, tbl_cja_turnos_x_cajas tc','t.cja_cajera_cod_cajera = c.cod_cajera and t.compania = c.compania and tc.cod_turno = t.codigo and tc.compania = t.compania and t.compania = <%=(String) session.getAttribute("_companyId")%> and t.cja_cajera_cod_cajera = \''+cod_cajero+'\' and tc.estatus = \'A\' and tc.cod_caja = '+cod_caja);if(estado=='A'){alert('Sr(a). Usuario, Usted ya está asignado a una caja, Verifique!');form1BlockButtons(true);document.form1.caja.disabled=true;}else form1BlockButtons(false);}

function corteZ(){
showPopWin('../common/run_process.jsp?fp=mantenimiento_turno&actType=3&docType=DGI'+'&docNo=X',winWidth*.75,winHeight*.65,null,null,'');
}

function comments(){
  var cajaTxt = $("#caja option:selected").text();
  if (!cajaTxt) cajaTxt = $("#_cajaDsp option:selected").text();
  showPopWin('../admin/seguimientos_list.jsp?ref_type=CAJA_TURNO&ref_id=<%=id%>&caja_text='+cajaTxt+'&useKeypad=<%=useKeypad%>&touch=<%=touch%>',winWidth*.80,winHeight*.45,null,null,'');
}
</script>

<% if(touch.trim().equalsIgnoreCase("Y")){%>
<link rel="stylesheet" href="../css/styles_touch.css" type="text/css"/>
<%if(useKeypad.trim().equalsIgnoreCase("Y")){%>
<link href="../js/jquery.keypad.css" rel="stylesheet">
<style>#inlineKeypad { width: 10em; }
input[type=radio] {
    display:none; 
    margin:10px;
}
</style>
<script src="../js/jquery.plugin.js"></script>
<script src="../js/jquery.keypad.js"></script>

<script>
$(document).ready(function(){
  <%if(useKeypad.trim().equalsIgnoreCase("Y")){%>
       var opts ={
        keypadOnly: false, 
        layout: [
        '1234567890-', 
        'qwertyuiop' + $.keypad.CLOSE, 
        'asdfghjkl' + $.keypad.CLEAR, 
        'zxcvbnm' + 
        $.keypad.SPACE_BAR + $.keypad.BACK]
     };
      $('#observacion').keypad(opts);
      
      $(document).on('keyup',function(evt) {
        if (evt.keyCode == 27) {
           $('#observacion').keypad("hide");
        }
      });
  <%}%>
});
</script>

<%}%>
<%}%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">

<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="<%=touch.trim().equalsIgnoreCase("Y")?"7":"0"%>" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("compania",(String) session.getAttribute("_companyId"))%>
			<%=fb.hidden("cod_supervisor_abre","")%>
            <%=fb.hidden("useKeypad",useKeypad)%>
                <%=fb.hidden("touch",touch)%>

			<tr class="TextRow02">
				<td colspan="4" align="right"><authtype type='50'>
				<%if(mode.equals("view") && cdo.getColValue("estatus").equals("A")){%>
				<a href="javascript:corteZ()"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder"  src="../images/printer_z.gif">Corte Z</a>
				<%}%>
				</authtype>
                &nbsp;
                <authtype type='51'>
                <a href="javascript:comments()" class="Link00Bold">Comentarios</a>
                </authtype>
                </td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4"><cellbytelabel>Mantenimiento de Turno</cellbytelabel> </td>
			</tr>
			<tr class="TextRow01">
				<td width="12%"><cellbytelabel>Caja</cellbytelabel></td>
				<td width="55%">

				<%=fb.select("caja",alCaja,cdo.getColValue("caja"),false,viewMode,0,null,null,"onChange=\"javascript:chkCaja();\"")%>
				<%//=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_cja_cajas where compania = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by descripcion asc","caja",cdo.getColValue("caja"),false,viewMode,0,null,null,"onChange=\"javascript:chkCaja();\"")%></td>
				<td width="12%"><cellbytelabel>Fecha</cellbytelabel></td>
				<td width="21%"><%=fb.textBox("fecha",cdo.getColValue("fecha"),false,false,false,12,12)%></td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Cajero</cellbytelabel></td>
				<td>
				<%=fb.textBox("cajeraCode",cdo.getColValue("cajeraCode"),true,false,true,5)%>
				<%=fb.textBox("cajera",cdo.getColValue("cajera"),true,false,true,55)%>
				</td>
				<td><cellbytelabel>Hora Inicio</cellbytelabel></td>
				<td><%=fb.textBox("horaIni",cdo.getColValue("horaIni"),false,false,true,12,12)%>
				</td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Monto Inicial</cellbytelabel></td>
				<td><%=fb.decBox("montoIni",cdo.getColValue("montoIni"),false,false,true,12)%></td>
				<td><cellbytelabel>Hora Final</cellbytelabel></td>
				<td><%=fb.decBox("horaFin",cdo.getColValue("horaFin"),false,false,true,12)%></td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
				<td colspan="3">
				<%=fb.hidden("user",id)%>
				<%=fb.textBox("observacion",cdo.getColValue("observacion"),false,false,viewMode,66)%></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right">
                <%if(touch.equals("")){%>
                <%=fb.button("save","Guardar",true,viewMode, null, null, "onClick=\"javascript:showPopWin('../caja/iniciar_caja.jsp?fp=abrir_caja&cod_caja='+document.form1.caja.value+'&compania_caja="+(String) session.getAttribute("_companyId")+"&useKeypad="+useKeypad+"&touch="+touch+"',winWidth*.60,_contentHeight*.80,null,null,'');\"")%>
                <%}else{%>
                  <%=fb.button("save","Guardar",true,viewMode, null, null, "onClick=\"javascript:showPopWin('../caja/iniciar_caja.jsp?fp=abrir_caja&cod_caja='+document.form1.caja.value+'&compania_caja="+(String) session.getAttribute("_companyId")+"&useKeypad="+useKeypad+"&touch="+touch+"',winWidth*.70,winHeight*.85,null,null,'');\"")%>
                <%}%>

				<%//=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>
			<tr>
				<td colspan="4">&nbsp;</td>
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
	mode = request.getParameter("mode");

	Turnos tr= new Turnos();
	tr.setCodCajera(request.getParameter("cajeraCode"));
	tr.setFecha(request.getParameter("fecha"));
	tr.setMontoInicial(request.getParameter("montoIni"));
	tr.setHoraInicio(request.getParameter("horaIni"));
	//tr.setHoraFinal(request.getParameter("horaFin"));
	tr.setObservacion(request.getParameter("observacion"));
	tr.setUserModificacion((String) session.getAttribute("_userName"));
	tr.setFechaModif(CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am"));
	tr.setCodCaja(request.getParameter("caja"));
	tr.setCompania(request.getParameter("compania"));
	tr.setCodigo(request.getParameter("id"));
	if(request.getParameter("cod_supervisor_abre")!=null && !request.getParameter("cod_supervisor_abre").equals("")) tr.setOther1(request.getParameter("cod_supervisor_abre"));
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&id="+id);
	if (mode.equalsIgnoreCase("add")) {
		tr.setUserCreacion((String) session.getAttribute("_userName"));
		tr.setFechaCreacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am"));
		TrMgr.add(tr);
	} else {
		cdo.setWhereClause("compania="+request.getParameter("compania")+" and codigo="+request.getParameter("id"));
		TrMgr.update(tr);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (TrMgr.getErrCode().equals("1"))
{
%>
	alert('<%=TrMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/mantenimientoturno_list.jsp"))
	{
%>  <%if(!touch.trim().equalsIgnoreCase("Y")){%>
	    window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/mantenimientoturno_list.jsp")%>';
    <%}else{%>
      parent.window.location.reload(true);
    <%}%>
<%
	}
	else
	{
%>
	<%if(!touch.trim().equalsIgnoreCase("Y")){%>
    window.opener.location = '<%=request.getContextPath()%>/caja/mantenimientoturno_list.jsp';
    <%}else{%>
      parent.window.location.reload(true);
    <%}%>
<%
	}
%>
	window.close();
<%
} else throw new Exception(TrMgr.getErrMsg());
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