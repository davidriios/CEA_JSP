<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
sct0200_rrhh				RECURSOS HUMANOS\TRANSACCIONES\Aprobar/Rechazar Sol. Vacaciones
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String itbm = "0";
if(session.getAttribute("_taxPercent")==null || session.getAttribute("_taxPercent").toString().trim().equals("")) itbm = "0";
else itbm = (String) session.getAttribute("_taxPercent");
CommonDataObject cdo = new CommonDataObject();
String codCaja = "";
boolean allowTransaction=true;
if(request.getParameter("codCaja")!=null && !request.getParameter("codCaja").equals("")) codCaja=request.getParameter("codCaja");
else {
	if(session.getAttribute("_codCaja")== null){
		allowTransaction=false;
		//throw new Exception("Sr. Usuario: esta PC no tiene asignado un número de caja!");
	} else codCaja = (String) session.getAttribute("_codCaja");
}
String key = "";
StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");

if(fg==null) fg = "anio";

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql.append("select coalesce(a.anio, to_number(to_char(sysdate, 'yyyy'))) anio, COALESCE(a.anio, 0) ult_anio, coalesce((select max(mes) from tbl_adm_alquiler_trx where compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(" and anio = a.anio), to_number(to_char(sysdate, 'mm'))) mes, COALESCE((select max(mes) from tbl_adm_alquiler_trx where compania = 1 and anio = a.anio), 0) ult_mes from (select max(anio) anio from tbl_adm_alquiler_trx where compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(" and estado = 'A') a");
	cdo = SQLMgr.getData(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
function doSubmit(){
	if($("#anio").val()=='') alert('Introduzca Año');
	else if($("#mes").val()=='') alert('Introduzca Mes');
	else {
		let existe = getDBData('<%=request.getContextPath()%>','distinct \'S\'','tbl_adm_alquiler_trx','compania = <%=(String) session.getAttribute("_companyId")%> and anio = '+$("#anio").val()+' and mes = '+$("#mes").val()+' and estado = \'A\'')||'N';
		if(existe=='S') alert('Ya existen las facturas para el periodo seleccionado!');
		else document.form0.submit();
	}
}
function doAction(){setCajaDetail();}
function chkCaja(){
	var caja=document.form0.caja.value;
	if(caja!='') caja = parseInt(caja);
	if(document.form0.caja.length>1) window.location = '<%=request.getContextPath()%>/process/pos_gen_fac_alquiler.jsp?codCaja='+caja;	
}
function setCajaDetail(){var caja=document.form0.caja.value;if(caja==undefined||caja==null||caja.trim()==''){CBMSG.warning('Usted no tiene Caja seleccionada!');if(document.form0.save)document.form0.save.disabled=true;return false;}else {setTurno(caja);/*setPrntDGI(caja)*/}}
/*function setPrntDGI(caja){
	var print_dgi='S';
	if(caja!=undefined&&caja!=null&&caja.trim()!='')print_dgi=getDBData('<%=request.getContextPath()%>','print_dgi','tbl_cja_cajas','compania = <%=(String) session.getAttribute("_companyId")%> and codigo = '+caja)||'S';
	document.form0.print_DGI.value = print_dgi;
}*/
function setTurno(caja){
	var turno=null;
	if(caja!=undefined&&caja!=null&&caja.trim()!='')turno=getDBData('<%=request.getContextPath()%>','a.cod_turno','tbl_cja_turnos_x_cajas a, tbl_cja_cajas b','a.compania = b.compania and a.cod_caja = b.codigo and a.compania = <%=(String) session.getAttribute("_companyId")%> and a.cod_caja = '+caja+' and a.estatus = \'A\'<%=(UserDet.getUserProfile().contains("0"))?"":" and b.ip = \\\'"+request.getRemoteAddr()+"\\\'"%>');

	if(turno==undefined||turno==null||turno.trim()==''){
		document.form0.turno.value='';
		CBMSG.warning('Usted o la Caja seleccionada no tiene un turno definido!');
		if(document.form0.save)document.form0.save.disabled=true;
		//window.frames['detalle'].formDetalleBlockButtons(true);
		return false;
	}else{
		document.form0.turno.value=turno;
	}
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="5" cellspacing="0">
				<tr>
					<td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
				<tr>
					<td>
						<table align="center" width="100%" cellpadding="0" cellspacing="1">
							<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
							<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
							<%=fb.formStart(true)%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
							<%=fb.hidden("baction","")%>
							<%=fb.hidden("turno","")%>
							<%=fb.hidden("itbm",itbm)%>
							<tr>
								<td>
									<table width="100%" cellpadding="1" cellspacing="0">
										<tr class="TextPanel">
											<td colspan="2">
											Generar Facturas de Alquiler
											</td>
										</tr>
										<tr class="TextPanel">
											<td colspan="2">
											&Uacute;ltimo A&ntilde;o: <%=cdo.getColValue("ult_anio")%>
											&nbsp;&nbsp;&nbsp;
											&Uacute;ltimo Mes:<%=fb.select("ult_mes","1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9 = Septiembre, 10 = Octubre, 11 = Noviembre, 12 = Diciembre",cdo.getColValue("ult_mes"),false,false,false,0,"Text12","","","","S")%>
											</td>
										</tr>

										<tr class="textRow02">
											<td coslpan="2" align="left">Caja:
											<%
											StringBuffer sbSql =  new StringBuffer();
											if (UserDet.getUserProfile().contains("0")) {
												sbSql.append("select codigo id, trim(to_char(codigo,'009'))||' - '||descripcion as descripcion from tbl_cja_cajas where compania = ");
												sbSql.append((String) session.getAttribute("_companyId"));
												sbSql.append(" and estado = 'A' order by descripcion");
											} else {
												sbSql.append("select codigo id, trim(to_char(codigo,'009'))||' - '||descripcion as descripcion from tbl_cja_cajas where compania = ");
												sbSql.append((String) session.getAttribute("_companyId"));
												sbSql.append(" and codigo in (");
												sbSql.append((String) session.getAttribute("_codCaja"));
												sbSql.append(") and ip = '");
												sbSql.append(request.getRemoteAddr());
												sbSql.append("' and estado = 'A' and codigo in (select b.cod_caja from tbl_cja_turnos a, tbl_cja_turnos_x_cajas b, tbl_cja_cajera c where a.compania = b.compania and a.codigo = b.cod_turno and a.cja_cajera_cod_cajera = c.cod_cajera and a.compania = c.compania and c.usuario = '");
												sbSql.append(UserDet.getUserName());
												sbSql.append("' and b.estatus = 'A') order by descripcion");
											}
											%>
											<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"caja",codCaja, false, false, 0, "", "", "onChange='javascript:chkCaja();'", "", "S")%>
											</td>
										</tr>
										<tr class="textRow02">
											<td width="65%">
											A&ntilde;o:
											<%=fb.textBox("anio",cdo.getColValue("anio"),false,false,false,5,"Text12",null,null)%>
											Mes <%=fb.select("mes","1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9 = Septiembre, 10 = Octubre, 11 = Noviembre, 12 = Diciembre",cdo.getColValue("mes"),false,false,false,0,"Text12","","")%>
											</td>
											<td>
											<authtype type='51'>
											<%=fb.button("save","Ejecutar",false,false,"text10","","onClick=\"javascript:doSubmit();\"")%>
											</authtype>
											</td>
										</tr>
										</table>
								</td>
							</tr>
							<%=fb.formEnd(true)%>
						<!-- ================================   F O R M   E N D   H E R E   ================================ -->
						</table>
					</td>
				</tr>
			</table>
		</td>
</tr>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table></td>
	</tr>
			</table>
		</td>
	</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	sql.append("call sp_adm_add_alquiler_trx(");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(", ");
	sql.append(request.getParameter("anio"));
	sql.append(", ");
	sql.append(request.getParameter("mes"));
	sql.append(", ");
	sql.append(request.getParameter("caja"));
	sql.append(", ");
	sql.append(request.getParameter("turno"));
	sql.append(", ");
	sql.append(request.getParameter("itbm"));
	sql.append(", '");
	sql.append((String) session.getAttribute("_userName"));
	sql.append("')");
  
	SQLMgr.execute(sql.toString());

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1")){
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
<%
} else throw new Exception(SQLMgr.getErrException());
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
