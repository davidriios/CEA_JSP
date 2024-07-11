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
String contrato = request.getParameter("contrato");
String tipo = request.getParameter("tipo");

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql.append("select id, to_char(fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, getPagadoHasta(id) pagado_hasta, cuota_mensual, (select nombre_paciente from vw_pm_cliente c where c.codigo = a.id_cliente) responsable from tbl_pm_solicitud_contrato a where id = ");
	sbSql.append(contrato);
	cdo = SQLMgr.getData(sbSql.toString());
	
	sbSql = new StringBuffer();
	sbSql.append("select decode(tipo_cambio, 1, 'INICIAR CONTRATO', 2, 'CERRAR CONTRATO', 3, 'CANCELAR CERRAR CONTRATO', 4, 'CUOTA EXTRA NORMAL', 5, 'CUOTA EXTRA PENALIZACION', 6, 'ADENDA CAMBIA FECHA INICIO', 7, 'ADENDA OTROS') tipo_cambio_desc, id, id_contrato, usuario_modificacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, tipo_cambio, observacion, to_char(fecha_inicio, 'dd/mm/yyyy') fecha_inicio, to_char(fecha_fin, 'dd/mm/yyyy') fecha_fin, estado, cuota_mensual, status, id_ref, decode(estado, 'A', 'ACTIVO', 'F', 'FINALIZADO') estado_desc from tbl_pm_aud_contrato where id_contrato = ");
	sbSql.append(contrato);
	if(tipo.equals("CE")){sbSql.append(" and tipo_cambio in (4, 5)");
	} else if(tipo.equals("AD")){sbSql.append(" and tipo_cambio in (6, 7)");
	} else if(tipo.equals("ME")){sbSql.append(" and tipo_cambio in (1, 2, 3)");
	} 
	sbSql.append(" order by tipo_cambio, fecha_modificacion");

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
											<td colspan="6" align="center">
											MODIFICACIONES AL CONTRATO
											</td>
										</tr>
										<tr class="">
											<td colspan="6" align="center">
											CONTRATO:<%=cdo.getColValue("id")%>
											&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;RESPONSABLE:
											<%=cdo.getColValue("responsable")%>
											&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;FECHA INICIO:
											<%=cdo.getColValue("fecha_ini_plan")%>
											</td>
										</tr>
										<tr class="TextPanel02" align="center">
											<td>TIPO MODIFICACION</td>
											<td>FECHA MODIFICACION</td>
											<td>USUARIO MODIFICACION</td>
											<td>FECHA INICIO PLAN</td>
											<td>ESTADO CONTRATO</td>
											<td>MONTO CONTRATO</td>
										</tr>
										<%
										String tipo_cambio = "";
										for(int i=0;i<al.size();i++){
											CommonDataObject cd = (CommonDataObject) al.get(i);
											String color = "TextRow02";
											if (i % 2 == 0) color = "TextRow01";
											if(!tipo_cambio.equals(cd.getColValue("tipo_cambio_desc"))){
											%>
										<tr class="TextPanel01" align="center">
											<td colspan="6"><%=cd.getColValue("tipo_cambio_desc")%></td>
										</tr>
											<%	
											}
										%>
										<%
										String href = "";
										if(tipo.equals("CE")) href = "../planmedico/pm_cuota_extra_config.jsp?mode=view&id="+cd.getColValue("id_ref");
										else if(tipo.equals("AD")) href = "../planmedico/reg_solicitud.jsp?mode=view&fp=adenda&id="+cd.getColValue("id_ref");
										%>
										<tr class="<%=color%>" align="center">
											<td style="cursor:pointer" onDblClick="javascript:abrir_ventana('<%=href%>');"><%=cd.getColValue("tipo_cambio_desc")%></td>
											<td><%=cd.getColValue("fecha_modificacion")%></td>
											<td><%=cd.getColValue("usuario_modificacion")%></td>
											<td><%=cd.getColValue("fecha_inicio")%></td>
											<td><%=cd.getColValue("estado_desc")%></td>
											<td><%=cd.getColValue("cuota_mensual")%></td>
										</tr>
										<%
										tipo_cambio=cd.getColValue("tipo_cambio_desc");
										}%>
										<tr class="TableTopBorder">
											<td colspan="6" align="center"><%=fb.button("add","Cerrar",false,false,"text10","","onClick=\"javascript:parent.hidePopWin(false);\"")%></td>
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
