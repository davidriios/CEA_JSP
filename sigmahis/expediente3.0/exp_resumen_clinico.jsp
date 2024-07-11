<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
Resumen clinico
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();

ArrayList alDiagEg = new ArrayList();
ArrayList alProced = new ArrayList();
ArrayList alOmMed  = new ArrayList();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds")==null?"-1":request.getParameter("cds");
String desc = request.getParameter("desc")==null?"":request.getParameter("desc");
String tab = request.getParameter("tab")==null?"0":request.getParameter("tab");
String from = request.getParameter("from") == null ? "": request.getParameter("from");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{

	alDiagEg = SQLMgr.getDataList("select a.diagnostico, a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fecha_modificacion, a.orden_diag, case when a.icd10 is not null then (select nvl(x.nombre_esp,x.nombre_eng) from tbl_cds_diagnostico_icd10map x where x.codigo_icd09=a.diagnostico and x.codigo_icd10=a.icd10) else coalesce(b.observacion,b.nombre) end as diagnosticoDesc, nvl(a.icd10,' ') as icd10 from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and tipo = 'S' order by a.orden_diag");

  	alProced = SQLMgr.getDataList("select codigo, to_char(fecha_registro,'dd/mm/yyyy') as fecha_registro, procedimiento_desc  from tbl_sal_datos_cirugia where pac_id="+pacId+" and secuencia="+noAdmision+"  order by fecha_registro desc ");
  	if (alProced.size()==0) alProced = SQLMgr.getDataList("select codigo_eval codigo, to_char(fecha,'dd/mm/yyyy') as fecha_registro, procedimiento procedimiento_desc  from tbl_sal_eval_preanestesica where pac_id="+pacId+" and admision="+noAdmision+"  order by fecha desc ");
  	 
  
	sql = "select CODIGO, resumen, USUARIO_CREAC, to_char(FECHA_CREAC,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREAC, USUARIO_MODIF, to_char(FECHA_MODIF,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF, cita, medicacion, indicacion, dieta, u.name as MEDICO_TRATANTE from TBL_SAL_RESUMEN_CLINICO r, tbl_sec_users u where pac_id="+pacId+" and admision="+noAdmision+" and r.usuario_creac = u.user_name";
	cdo = SQLMgr.getData(sql);

	alOmMed = SQLMgr.getDataList("select A.ORDEN_MED, a.nombre as medicamento, a.dosis, a.frecuencia from tbl_sal_detalle_orden_med a where a.pac_id = "+pacId+" and a.secuencia = "+noAdmision+" and a.tipo_orden = 2 order by a.fecha_orden desc, a.codigo desc");

	if (cdo == null)
	{
		if (!viewMode) mode = "add";
		cdo = new CommonDataObject();

		cdo.addColValue("CODIGO","1");
		cdo.addColValue("USUARIO_CREAC",UserDet.getUserName());
		cdo.addColValue("FECHA_CREAC",cDateTime);
		cdo.addColValue("USUARIO_MODIF",UserDet.getUserName());
		cdo.addColValue("FECHA_MODIF",cDateTime);
		cdo.addColValue("MEDICO_TRATANTE",UserDet.getName());
	}
	else if (!viewMode) mode = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE - RESUMEN CLINICO - '+document.title;
<%if(from.equals("salida_pop")){%>var noNewHeight = true;<%}%>

function doAction()
{
	<%if(!from.equals("salida_pop") ){%><%}%>
}
function imprimirResumenClinico()
{
	var fecha = eval('document.form0.fecha_creac').value;

	<%=from.equals("")?"":"parent."%>showPopWin('<%=request.getContextPath()%>/common/email_to_printer.jsp?fg=RESUMEN&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fechaProt='+fecha,winWidth*.65,winHeight*.45,null,null,''); 
	
}
function verificar()
{
alert("Tiene que llenar todos los campos y guardar para que se envien los cambios");
 
}

function addDiagSal()
{
 abrir_ventana("../expediente/exp_diagnostico_salida.jsp?seccion=88&mode=&cds=&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&defaultAction=&desc=DIAGNOSTICOS DE SALIDA&pacInfo=n");
}

function printResumen(){
	abrir_ventana('<%=request.getContextPath()%>/expediente/print_resumen_clinico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>'); 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="RESUMEN CLINICO"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" >
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("tab","0")%>
			<%=fb.hidden("seccion",seccion)%>
			<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
			<%=fb.hidden("dob","")%>
			<%=fb.hidden("codPac","")%>
			<%=fb.hidden("pacId",pacId)%>
			<%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("usuario_creac",cdo.getColValue("USUARIO_CREAC"))%>
			<%=fb.hidden("fecha_creac",cdo.getColValue("FECHA_CREAC"))%>
			<%=fb.hidden("usuario_modific",cdo.getColValue("USUARIO_MODIF"))%>
			<%=fb.hidden("fecha_modific",cdo.getColValue("FECHA_MODIF")) %>
			<%=fb.hidden("codigo",cdo.getColValue("CODIGO"))%>
            <%=fb.hidden("from",from)%>
			
			<tr class="TextRow01">
				<td></td>
				<td align="right">
                <a href="javascript:printResumen();" class="Link00Bold">[ Imprimir ]</a>
                &nbsp;<a href="javascript:imprimirResumenClinico();" class="Link00Bold">[ Email to printer ]</a></td>
			</tr>
			
			<tr class="TextHeader">
				<td width="70%" >DIAGNOSTICOS AL EGRESO</td>
				<td width="30%" align="center"><a href="javascript:addDiagSal();" class="Link03" title="Agregar Diagn&oacute;stico de Salida">Agregar Diagn&oacute;stico de Salida</a></td>
			</tr>
				
			
			
			<tr>
				<td colspan="2">
				   <table width="100%" cellpadding="1" cellspacing="1">
					<% if ( alDiagEg.size() > 0 ){ %>
					   <tr class="TextRow01">
						  <td colspan="2">
							<table width="100%" cellpadding="1" cellspacing="1" >
								<tr align="center" class="TextHeader01">
									<td align="center" width="6%">ICD9</td>
									<td align="center" width="8%">ICD10</td>
									<td width="79%">Diagn&oacute;stico</td>
									<td align="center" width="7%">Prioridad</td>
								</tr>

								<%  CommonDataObject cdoDiagEg = new CommonDataObject();
									for (int d = 0; d<alDiagEg.size(); d++){
									cdoDiagEg = (CommonDataObject)alDiagEg.get(d);
								%>
								<tr>
									<td><%=cdoDiagEg.getColValue("diagnostico")%></td>
									<td><%=cdoDiagEg.getColValue("icd10")%></td>
									<td><%=cdoDiagEg.getColValue("diagnosticodesc")%></td>
									<td><%=cdoDiagEg.getColValue("orden_diag")%></td>
								</tr>
								<%}%>

							</table>
						  </td>
						</tr>
					<%} else {%>
				  		<tr align="center" class="TextRow01">
					        <td colspan="2">NO HAY DIAGNOSTICO DE EGRESO DOCUMENTADO, POR FAVOR RECUERDE IR A DIAGNOSTICOS DE SALIDA!!</td>
						</tr>
				  <%}%>
				  </table>
				</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="2">CIRUGIAS / PROCEDIMIENTOS</td>
			</tr>
			<tr>
				<td colspan="2" id="sec1" style="display:inblock;">
				   <table width="100%" cellpadding="1" cellspacing="1">
					<% if ( alProced.size() > 0 ){ %>
					   <tr class="TextRow01">
						  <td colspan="2">
							 <table width="100%" cellpadding="1" cellspacing="1" >
								<tr align="center" class="TextHeader01">
									<td width="100%">Procedimiento realizado</td>
								</tr>

							<%  CommonDataObject cdoProced = new CommonDataObject();
								 for (int d = 0; d<alProced.size(); d++){
											cdoProced = (CommonDataObject)alProced.get(d);
							 %>
							<tr>
								<td><%=cdoProced.getColValue("procedimiento_desc")%></td>
							</tr>
							<%} %>
						   </table>
					      </td>
						</tr>
				  <%} else {%>
				  	<tr align="center" class="TextRow01">
					    <td colspan="2">NO PROCEDIMIENTOS DOCUMENTADOS!</td>
			        </tr>
				  <% } %>
				  </table>
				</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="2">&nbsp;</td>
			</tr>
			<!-- OM MEDICAMENTOS -->
			<tr class="TextHeader">
				<td colspan="2">MEDICAMENTOS ORDENADOS</td>
			</tr>

			<tr>
				<td colspan="2">

				   <table width="100%" cellpadding="1" cellspacing="1">
					<% if ( alOmMed.size() > 0 ){ %>
					   <tr class="TextRow01">
						  <td colspan="2">
							 <table width="100%" cellpadding="1" cellspacing="1" >
								<tr align="center" class="TextHeader01">
									<td width="50%">Medicamento</td>
									<td width="14%">Dosis</td>
									<td width="36%">Frecuencia</td>
								</tr>

								 <% CommonDataObject cdoMed = new CommonDataObject();
									 for (int m = 0; m<alOmMed.size(); m++){
												cdoMed = (CommonDataObject)alOmMed.get(m);
								 %>
							  <tr>
									<td><%=cdoMed.getColValue("medicamento")%></td>
									<td><%=cdoMed.getColValue("dosis")%></td>
									<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=cdoMed.getColValue("frecuencia")%></td>
							  </tr>
								<%}%>
							</table>
						  </td>
					   </tr>
						<%} else {%>
				  		<tr align="center" class="TextRow01">
					        <td colspan="2">NO OM MEDICAMENTOS DOCUMENTADAS!</td>
			            </tr>
				  <% } %>
				  </table>
				 </td>
			</tr> <!-- OM MEDICAMENTOS -->

			<tr class="TextRow01">
				<td colspan="2">&nbsp;</td>
			</tr>


			<tr class="TextHeader">
				<td colspan="2">RESUMEN DE EVOLUCION DURANTE HOSPITALIZACION</td>
			</tr>

			<tr class="TextRow01">
				<td colspan="2">R E S U M E N &nbsp;&nbsp;&nbsp;&nbsp;  C L I N I C O &nbsp;<%=fb.textarea("resumen",cdo.getColValue("resumen"),true,false,viewMode,60,8,2000,"","width:100%","")%>
				</td>
			</tr>

		<tr>
			<td colspan="2">
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2">INDICACIONES AL PACIENTE A SU SALIDA</td>
				</tr>
	
				<tr class="TextRow01">
					<td width="20%">Dieta</td>
					<td width="80%"><%=fb.textarea("dieta",cdo.getColValue("dieta"),true,false,viewMode,60,2,2000,"","width:100%","")%></td>
				</tr>
	
				<tr class="TextRow01">
					<td width="20%">Otras Indicaciones <br>(Laboratorios, Terapias, etc)</td>
					<td width="80%"><%=fb.textarea("indicacion",cdo.getColValue("indicacion"),true,false,viewMode,60,3,2000,"","width:100%","")%></td>
				</tr>
                <%if(from.trim().equalsIgnoreCase("")){%>
				<tr class="TextRow01">
					<td width="20%">Medicamentos a tomar en casa <br>(DOSIS / FRECUENCIA / DIAS)</td>
					<td width="80%"><%=fb.textarea("medicacion",cdo.getColValue("medicacion"),true,false,viewMode,60,4,2000,"","width:100%","")%></td>
				</tr>
                <%}else{%>
                
                <tr class="TextRow01">
					<td colspan="2">
                    <iframe name="iMedRec" id="iMedRec" src="../expediente/exp_medicamentos_recetas.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&desc=<%=desc%>&seccion=<%=seccion%>&mode=<%=mode%>&merged_with_res_cli=Y" width="100%" height="200px" scrolling="yes"></iframe>
                    
                    <%=fb.hidden("medicacion", cdo.getColValue("medicacion"))%>
                    </td>
				</tr>
                <%}%>
	
				<tr class="TextRow01">
					<td width="20%">Cita de Control</td>
					<td width="80%"><%=fb.textarea("cita",cdo.getColValue("cita"),true,false,viewMode,60,2,2000,"","width:100%","")%></td>
				</tr>
	
				<tr class="TextRow01">
					<td width="20%">M&eacute;dico Tratante</td>
					<td width="80%"><%=cdo.getColValue("MEDICO_TRATANTE")%></td>
				</tr>
			</table>
			</td>
		</tr>

			
			
			<tr>
				<td colspan="2">
					<jsp:include page="../common/bitacora.jsp?audCollapsed=n" flush="true">
						<jsp:param name="audTable" value="tbl_sal_resumen_clinico"></jsp:param>
						<jsp:param name="audFilter" value="<%="admision="+noAdmision+" and pac_id="+pacId%>"></jsp:param>
					</jsp:include>
				</td>
			</tr>

			<tr class="TextRow02" align="right">
				<td colspan="2">
                <%if(!from.equalsIgnoreCase("salida_pop")){%>
					Opciones de Guardar:
					<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
					<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
					<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
					<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
                    <%}else{%>
                        <%=fb.submit("save","Siguiente",true,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value); parent.openNextAccordionPanel('"+fb.getFormName()+"')\"")%>
                        <%=fb.hidden("saveOption","O")%>
                    <%}%>
				</td>
			</tr>
			<%fb.appendJsValidation("if(error>0)doAction();");%>
			<%=fb.formEnd(true)%>
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
	String baction = request.getParameter("baction");

	cdo = new CommonDataObject();

	cdo.setTableName("tbl_sal_resumen_clinico");
	cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision="+request.getParameter("noAdmision"));

	cdo.addColValue("resumen",request.getParameter("resumen"));
	cdo.addColValue("cita",request.getParameter("cita"));
	cdo.addColValue("dieta",request.getParameter("dieta"));
	cdo.addColValue("medicacion",request.getParameter("medicacion"));
	cdo.addColValue("indicacion",request.getParameter("indicacion"));
	cdo.addColValue("USUARIO_CREAC",request.getParameter("usuario_creac"));
	cdo.addColValue("FECHA_CREAC",request.getParameter("fecha_creac"));
	cdo.addColValue("USUARIO_MODIF",request.getParameter("usuario_modific"));
	cdo.addColValue("FECHA_MODIF",request.getParameter("fecha_modific"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("PAC_ID",request.getParameter("pacId"));
		cdo.addColValue("ADMISION",request.getParameter("noAdmision"));
		cdo.addColValue("CODIGO",request.getParameter("codigo"));

		SQLMgr.insert(cdo);
	}
	else
	{
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision="+request.getParameter("noAdmision"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	<%if(from.equals("")){%>alert('<%=SQLMgr.getErrMsg()%>');<%}%>
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
<%
	}
	else
	{
%>
<%
	}

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
	parent.doRedirect(0);
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

