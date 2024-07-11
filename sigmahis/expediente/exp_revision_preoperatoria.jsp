<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.expediente.RevisionPreOperatoria" %>
<%@ page import="issi.expediente.RespuestaRevision" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="ROMgr" scope="page" class="issi.expediente.RevisionOperatoriaMgr" />
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
ROMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
RevisionPreOperatoria rev = new RevisionPreOperatoria();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fecha = request.getParameter("fecha");
String hora = request.getParameter("hora");
String desc = request.getParameter("desc");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");

if (fecha == null) fecha = cDate.substring(0,10);
if (hora == null)  hora = cDate.substring(11);

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

sql="select to_char(fecha,'dd/mm/yyyy') as fecha,to_char(fecha,'hh12:mi am') as hora, observacion, cirugia, medico_cirujano as cirujano  from tbl_sal_revision_preoperatoria where pac_id="+pacId+" and secuencia="+noAdmision +" order by fecha desc";

al2 = SQLMgr.getDataList(sql);

sql="select to_char(fecha,'dd/mm/yyyy hh12:mi am') as fecha, observacion, emp_provincia as empProvincia, emp_sigla as empSigla, emp_tomo as empTomo, emp_asiento as empAsiento, emp_compania as empCompania, usuario_creacion as usuarioCreacion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, emp_id as empId, cirugia as cirugia, medico_cirujano as cirujano from tbl_sal_revision_preoperatoria where pac_id="+pacId+" and secuencia="+noAdmision+" and to_date(to_char(fecha,'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') = to_date('"+fecha+" "+hora+"','dd/mm/yyyy hh12:mi am')";
System.out.println("SQL:\n"+sql);
rev = (RevisionPreOperatoria) sbb.getSingleRowBean(ConMgr.getConnection(), sql, RevisionPreOperatoria.class);
if(rev == null)
{
		rev = new RevisionPreOperatoria();
		rev.setFechaCreacion(cDateTime);
		rev.setUsuarioCreacion((String) session.getAttribute("_userName"));
		rev.setFecha(cDate);
		rev.setObservacion("");
		if (!viewMode) modeSec = "add";

}
else if (!viewMode) modeSec = "edit";
	sql = "SELECT a.codigo AS pregunta, a.descripcion as descripcion, nvl(b.respuesta,'N') as respuesta, to_char(b.fecha_revision,'dd/mm/yyyy hh12:mi am') as fechaRevision, b.observacion as observacion from TBL_SAL_PREGUNTA a, TBL_SAL_RESPUESTA b where a.codigo=b.pregunta(+) and b.pac_id(+)="+pacId+" and b.secuencia(+)="+noAdmision+" and to_date(to_char(b.fecha_revision(+),'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') = to_date('"+fecha+" "+hora+"','dd/mm/yyyy hh12:mi am') ";
	
	if (!viewMode) 
	  {//para agregar evaluación mostrar sólo preguntas con estado Activo.
	  sql +=" and a.estado in ('A') ORDER BY a.orden ASC ";  
	  }
	  else   
	  {//en consulta mostrar preguntas Activas y las Inactivas que hallan sido llenadas (anteriormente).
	  sql +=" and a.estado in ('A') union SELECT a.codigo AS pregunta, a.descripcion as descripcion, nvl(b.respuesta,'N') as respuesta, to_char(b.fecha_revision,'dd/mm/yyyy hh12:mi am') as fechaRevision, b.observacion as observacion from TBL_SAL_PREGUNTA a, TBL_SAL_RESPUESTA b where a.codigo=b.pregunta and b.pac_id="+pacId+" and b.secuencia="+noAdmision+" and a.estado = 'I' and to_date(to_char(b.fecha_revision,'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') = to_date('"+fecha+" "+hora+"','dd/mm/yyyy hh12:mi am')   ORDER BY 1 ASC ";  
	  }
		al = sbb.getBeanList(ConMgr.getConnection(),sql,RespuestaRevision.class);
		

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Revisión Preoperatoria - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){newHeight();checkViewMode();}
function isChecked(k,trueFalse){}
function imprimir(){var fecha = document.form0.fecha.value;fecha +=' '+document.form0.hora.value;abrir_ventana1('../expediente/print_revision_preoperatoria.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fecha='+fecha+'&mode=<%=modeSec%>');}
function setEvaluacion(k){var fecha = eval('document.listado.fecha'+k).value ;var hora = eval('document.listado.hora'+k).value ;window.location= '../expediente/exp_revision_preoperatoria.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha+'&hora='+hora;}
function add(fecha,hora){window.location= '../expediente/exp_revision_preoperatoria.jsp?seccion=<%=seccion%>&desc=<%=desc%>modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha+'&hora='+hora;}
function medicoList(){abrir_ventana1('../common/search_medico.jsp?fp=exp_verif_cuidad_pre_oper');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr class="TextRow01">
					<td>
					<div id="proc" width="100%" class="exp h100">
					<div id="proced" width="98%" class="child">

						<table width="100%" cellpadding="1" cellspacing="0">
						<%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
						<tr class="TextRow02">
							<td colspan="2">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel></td>
							<td align="right"><%if(!mode.trim().equals("view")){%><a href="javascript:add('<%=cDate.substring(0,10)%>','<%=cDate.substring(11)%>')" class="Link00">[ <cellbytelabel id="2">Agregar Evaluaci&oacute;n</cellbytelabel> ]</a><%}%></td>
						</tr>
						<tr class="TextHeader">
							<td width="20%"><cellbytelabel id="3">Fecha</cellbytelabel></td>
							<td width="20%"><cellbytelabel id="4">Hora</cellbytelabel></td>
							<td width="60" colspan="2"><cellbytelabel id="5">Observaci&oacute;n</cellbytelabel></td>
						</tr>
<%


for (int i=1; i<=al2.size(); i++)
{
	CommonDataObject cdo1 = (CommonDataObject) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("fecha"+i,cdo1.getColValue("fecha"))%>
		<%=fb.hidden("hora"+i,cdo1.getColValue("hora"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEvaluacion(<%=i%>)" style="text-decoration:none; cursor:pointer">
				<td><%=cdo1.getColValue("fecha")%></td>
				<td><%=cdo1.getColValue("hora")%></td>
				<td colspan="2"><%=cdo1.getColValue("observacion")%></td>
		</tr>
<%}%>
			<%=fb.formEnd(true)%>
			</table>
		</div>
		</div>
					</td>
				</tr>

	
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("modeSec",modeSec)%>
				<%=fb.hidden("seccion",seccion)%>
				<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
				<%=fb.hidden("dob","")%>
				<%=fb.hidden("codPac","")%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("size",""+al.size())%>
				<%=fb.hidden("usuarioCreacion",rev.getUsuarioCreacion())%>
				<%=fb.hidden("fechaCreacion",rev.getFechaCreacion())%>
				<%=fb.hidden("empProvincia",rev.getEmpProvincia())%>
				<%=fb.hidden("empSigla",rev.getEmpSigla())%>
				<%=fb.hidden("empTomo",rev.getEmpTomo())%>
				<%=fb.hidden("empAsiento",rev.getEmpAsiento())%>
				<%=fb.hidden("empCompania",rev.getEmpCompania())%>
				<%=fb.hidden("empId",rev.getEmpId())%>	
                <%=fb.hidden("desc",desc)%>			
		<tr class="TextRow02">
					<td colspan="4" align="right"><a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="6">Imprimir</cellbytelabel> ]</a></td>
				</tr>
				<tr>
					<td colspan="4">
						<table width="100%" border="0" cellpadding="0" cellspacing="0" class="TextRow01">
									<tr>
										<td width="44%" ><cellbytelabel id="3">Fecha</cellbytelabel>:&nbsp;
										<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="nameOfTBox1" value="fecha" />
										<jsp:param name="valueOfTBox1" value="<%=rev.getFecha().substring(0,10)%>" />
										<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
										</jsp:include>
										</td>
										<td width="50%">
										<cellbytelabel id="4">Hora</cellbytelabel>  &nbsp;&nbsp;&nbsp;&nbsp;						
										<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1"/>
										<jsp:param name="format" value="hh12:mi am"/>
										<jsp:param name="nameOfTBox1" value="hora" />
										<jsp:param name="valueOfTBox1" value="<%=rev.getFecha().substring(11)%>" />
										<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
										</jsp:include>
										</td>
									</tr>
								
								<tr class="TextRow01">
								  <td colspan="2">&nbsp;</td>								 
								</tr>	
									
								<tr class="TextRow01">
								  <td width="10%"><cellbytelabel id="7">Cirug&iacute;a</cellbytelabel></td>
								 <td width="90%"><%=fb.textBox("cirugia",rev.getCirugia(),true,false,viewMode,55,20)%></td>
								</tr>
								<tr class="TextRow01">
								  <td width="10%"><cellbytelabel id="8">M&eacute;dico Cirujano</cellbytelabel></td>
								 <td width="85%"><%=fb.textBox("cirujano",rev.getCirujano(),true,false,viewMode,55)%></td>
                                 <td width="5%"><%=fb.button("medico","...",true,viewMode,null,null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%></td>
								</tr>
									
									<tr>
										<td><cellbytelabel id="9">Observaciones Generales</cellbytelabel>&nbsp;</td>
										<td><%=fb.textarea("observ",rev.getObservacion(),false,false,viewMode,22,2,2000,null,"width='100%'",null)%></td>
									</tr>
								</table></td>
							</tr>
							<tr align="center" class="TextHeader">
								<td width="55%"><cellbytelabel id="10">Factores</cellbytelabel></td>
								<td width="5%"><cellbytelabel id="11">S&iacute;</cellbytelabel></td>
								<td width="5%"><cellbytelabel id="12">No</cellbytelabel></td>
								<td width="35%"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel></td>
							</tr>
<%
for (int i=0; i<al.size(); i++)
{
		RespuestaRevision rresp = (RespuestaRevision) al.get(i);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
	%>
							<%=fb.hidden("codigo"+i,rresp.getPregunta())%>
							<tr class="<%=color%>">
								<td><%=rresp.getDescripcion()%></td>
								<td align="center"><%=fb.radio("respuesta"+i,"S",rresp.getRespuesta().trim().equals("S"),viewMode,false,null,null,"")%></td>
								<td align="center"><%=fb.radio("respuesta"+i,"N",rresp.getRespuesta().trim().equals("N"),viewMode,false,null,null,"")%></td>
								<td><%=fb.textarea("observacion"+i,rresp.getObservacion(),false,false,viewMode,22,2,2000,null,"width='100%'",null)%></td>
							</tr>
<%
}
%>

				<tr class="TextRow02">
					<td colspan="4" align="right">
				<cellbytelabel id="14">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="15">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="16">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
					</td>
				</tr>
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
	fecha = request.getParameter("fecha");
	hora  = request.getParameter("hora");
	int size= 0;
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));
		al.clear();
		RevisionPreOperatoria revi = new RevisionPreOperatoria();
	 //tbl_sal_revision_preoperatoria

	 revi.setCodPaciente(request.getParameter("codPac"));
	 revi.setFecNacimiento(request.getParameter("dob"));
	 revi.setPacId(request.getParameter("pacId"));
	 revi.setSecuencia(request.getParameter("noAdmision"));
	 revi.setFecha(request.getParameter("fecha")+" "+request.getParameter("hora"));
	 revi.setObservacion(request.getParameter("observ"));
	 revi.setEmpProvincia(request.getParameter("empProvincia"));
	 revi.setEmpSigla(request.getParameter("empSigla"));
	 revi.setEmpTomo(request.getParameter("empTomo"));
	 revi.setEmpAsiento(request.getParameter("empAsiento"));
	 revi.setEmpCompania(request.getParameter("empCompania"));
	 revi.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
	 revi.setFechaCreacion(request.getParameter("fechaCreacion"));
	 revi.setUsuarioModif((String) session.getAttribute("_userName"));
	 revi.setFechaModif(cDateTime);
	 revi.setEmpId(request.getParameter("empId"));
	 revi.setCirugia(request.getParameter("cirugia"));
	 revi.setCirujano(request.getParameter("cirujano"));

	
	for (int i=0; i<size; i++)
	{
				
				
				if(request.getParameter("respuesta"+i) != null && (request.getParameter("respuesta"+i).trim().equals("S") || (  request.getParameter("observacion"+i) != null && !request.getParameter("observacion"+i).trim().equals(""))))
				{
						RespuestaRevision resp = new RespuestaRevision();//System.out.println("respuesta = "+request.getParameter("respuesta"+i));

						resp.setCodPaciente(request.getParameter("codPac"));
						resp.setFecNacimiento(request.getParameter("dob"));
						resp.setPacId(request.getParameter("pacId"));
						resp.setSecuencia(request.getParameter("noAdmision"));
						resp.setFechaRevision(request.getParameter("fecha")+" "+request.getParameter("hora"));
						resp.setPregunta(request.getParameter("codigo"+i));
						resp.setRespuesta(request.getParameter("respuesta"+i));
						resp.setObservacion(request.getParameter("observacion"+i));
						al.add(resp);
						revi.addDetalle(resp);
				}
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
						ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				if (modeSec.equalsIgnoreCase("add"))
				{
						ROMgr.add(revi);
				}
				else if (modeSec.equalsIgnoreCase("edit"))
				{
						ROMgr.update(revi);
				}
						ConMgr.clearAppCtx(null);
		}



%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ROMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ROMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';  
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
} else throw new Exception(ROMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha=<%=fecha%>&hora=<%=hora%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
