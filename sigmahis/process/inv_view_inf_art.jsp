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
CommonDataObject cdo = new CommonDataObject();

String key = "";
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String codigo = request.getParameter("codigo");
String almacen = request.getParameter("almacen");

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql.append("select cod_articulo, descripcion, cod_barra from tbl_inv_articulo where cod_articulo = ");
	sbSql.append(codigo);
	cdo = SQLMgr.getData(sbSql.toString());
	
	sbSql = new StringBuffer();
	sbSql.append("select to_char(fecha_vence, 'dd/mm/yyyy') fecha_vence, fecha_vence fecha, decode(no_lote, '-','', no_lote) no_lote, decode(no_serie, 'NA','', no_serie) no_serie, cantidad, (select descripcion from tbl_inv_almacen a where l.cod_almacen = a.codigo_almacen and a.compania = l.compania) almacen_desc, cod_almacen from tbl_inv_art_lote l where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and cod_articulo = ");
	sbSql.append(codigo);
	sbSql.append(" and exists (select null from tbl_inv_articulo a where a.compania = l.compania and a.cod_articulo = l.cod_articulo and nvl(a.mostrar_fecha_vence, 'N') = 'S')");
	if(almacen!=null && !almacen.equals("") && !almacen.equals("null")){
		sbSql.append(" and cod_almacen = ");
		sbSql.append(almacen);
	}
	sbSql.append(" order by cod_almacen, fecha");

	System.out.println("sql det = "+sbSql.toString());
	al = SQLMgr.getDataList(sbSql.toString());
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Contabilidad - '+document.title;

function doSubmit(value){document.form1.baction.value = value;}
function doAction(){}

function ejecutarJob(job){
if(job==1)
showPopWin('../process/pm_run_job_fact.jsp?fp=CIERRE',winWidth*.75,winHeight*.65,null,null,'');
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
							<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
							<%=fb.formStart(true)%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
							<%=fb.hidden("baction","")%>
							<%=fb.hidden("clearHT","")%>
							<tr>
								<td>
									<table width="100%" cellpadding="1" cellspacing="0">
										<tr class="TextPanel">
											<td colspan="4" align="center">
											LOTES Y FECHAS DE VENCIMIENTO
											</td>
										</tr>
										<tr class="">
											<td colspan="4" align="center">
											CODIGO:<%=cdo.getColValue("cod_articulo")%>
											&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;DESCRIPCION:
											<%=cdo.getColValue("descripcion")%>
											&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;COD. BARRA:
											<%=cdo.getColValue("cod_barra")%>
											</td>
										</tr>
										<tr class="TextPanel02" align="center">
											<td>NO. LOTE</td>
											<td>FECHA VENCIMIENTO</td>
											<td>NO. SERIE</td>
											<td>CANTIDAD</td>
										</tr>
										<%
										String wh = "";
										for(int i=0;i<al.size();i++){
											CommonDataObject cd = (CommonDataObject) al.get(i);
											String color = "TextRow02";
											if (i % 2 == 0) color = "TextRow01";
											if(!wh.equals(cd.getColValue("cod_almacen"))){
											%>
										<tr class="TextPanel01" align="center">
											<td colspan="4"><%=cd.getColValue("almacen_desc")%></td>
										</tr>
											<%	
											}
										%>
										<tr class="<%=color%>" align="center">
											<td><%=cd.getColValue("no_lote")%></td>
											<td><%=cd.getColValue("fecha_vence")%></td>
											<td><%=cd.getColValue("no_serie")%></td>
											<td><%=cd.getColValue("cantidad")%></td>
										</tr>
										<%
										wh=cd.getColValue("cod_almacen");
										}%>
										<tr class="TableTopBorder">
											<td colspan="4" align="center"><%=fb.button("add","Cerrar",false,false,"text10","","onClick=\"javascript:parent.hidePopWin(false);\"")%></td>
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
%>
