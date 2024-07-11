<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.Interconsulta"%>
<%@ page import="issi.expediente.InterconsultaDiagnostico"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="InterMgr" scope="page" class="issi.expediente.InterconsultaMgr" />
<jsp:useBean id="iInter" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
InterMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject intCon = new CommonDataObject();

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String desc = request.getParameter("desc");
String usuarioCreacion = request.getParameter("usuario_creacion");
String userName = (String) session.getAttribute("_userName");
String estado = request.getParameter("estado");

if (estado == null) estado = "";
if (fg == null) fg = "I";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view") || modeSec.equalsIgnoreCase("edit")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (usuarioCreacion == null) usuarioCreacion = "";

int rowCount = 0;
String sql2 = "";

String change = request.getParameter("change");
String cod_interconsulta = request.getParameter("cod_interconsulta");
String nombreMedico = request.getParameter("nombreMedico");
String codMedico = request.getParameter("codMedico");
String especialidad = request.getParameter("cod_especialidad");

int interLastLineNo =0;
String filter ="", filter2 ="";
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (request.getParameter("interLastLineNo") != null) interLastLineNo = Integer.parseInt(request.getParameter("interLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
sql2="select distinct e.codigo, e.medico, e.cod_especialidad, decode(AM.APELLIDO_DE_CASADA,null, AM.PRIMER_APELLIDO||' '||AM.SEGUNDO_APELLIDO, AM.APELLIDO_DE_CASADA)||' '|| AM.PRIMER_NOMBRE||' '||AM.SEGUNDO_NOMBRE as nombre_medico, nvl(esp.descripcion,' ') as descripcionEsp, to_char(e.fecha,'dd/mm/yyyy')||' '||to_char(e.hora,'hh12:mi am') fecha, nvl(am.reg_medico, am.codigo) registro_medico, decode(e.status,'A', 'ACTIVO', 'I', 'INVALIDO') as status_dsp, e.usuario_creacion from  tbl_sal_diagnostico_inter_esp di, tbl_adm_medico AM, tbl_adm_especialidad_medica esp, tbl_sal_interconsultor_espec e Where e.pac_id="+pacId+" and e.secuencia="+noAdmision+"and e.medico=AM.codigo and esp.codigo(+)=e.cod_especialidad  and di.cod_interconsulta =   e.codigo and di.pac_id=e.pac_id and di.secuencia= e.secuencia  ORDER BY e.codigo desc";
al2 = SQLMgr.getDataList(sql2);
		if((al2.size() == 0 && change == null) ||(cod_interconsulta == null || cod_interconsulta.trim().equals("")))
		{
						iInter.clear();
						cod_interconsulta = "00";
						change="3";
						if (!viewMode) modeSec = "add";
		}

	/*System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::");
	System.out.println("CIC WITH GET ="+cod_interconsulta);
	System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::");*/

if(!cod_interconsulta.equals("00"))
{
		if(cod_interconsulta == null || cod_interconsulta.trim().equals(""))
		{
				filter = " and a.codigo=(select nvl(max(codigo),0) as codigo from TBL_SAL_INTERCONSULTOR_ESPEC where pac_id="+pacId+" and secuencia="+noAdmision+")";
		}
		else
		 filter = " and a.codigo="+cod_interconsulta;

		sql="select AM.primer_nombre||decode(AM.segundo_nombre,'','',' '||AM.segundo_nombre)||' '||AM.primer_apellido|| decode(AM.segundo_apellido, null,'',' '||AM.segundo_apellido)||decode(AM.sexo,'F', decode(AM.apellido_de_casada,'','',' '||AM.apellido_de_casada)) as nombremedico, esp.descripcion as descripcion, a.medico as medico, a.codigo as codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.observacion as observacion, nvl(a.cod_especialidad,' ') as codespecialidad, a.comentario as comentario, a.usuario_creacion as usuariocreacion, to_char(a.FECHA_CREACION,'dd/mm/yyyy hh12:mi:ss am') as fechacreacion, a.usuario_modificacion as usuariomodificacion, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi:ss am') as fechamodificacion , to_char(a.HORA,'hh12:mi:ss am') as hora, decode(a.status,'A', 'ACTIVO', 'I', 'INVALIDO') as status_dsp from TBL_SAL_INTERCONSULTOR_ESPEC a, tbl_adm_medico AM, tbl_adm_especialidad_medica esp Where a.pac_id(+)="+pacId+" and a.secuencia="+noAdmision+" "+filter+" and a.medico=AM.codigo(+) and esp.codigo(+)=a.cod_especialidad and (a.pac_id, a.secuencia) in (select sd.pac_id, sd.secuencia from tbl_sal_diagnostico_inter_esp sd) order by a.codigo asc";

		intCon = SQLMgr.getData(sql);
		if (intCon == null) intCon = new CommonDataObject();
		cod_interconsulta = intCon.getColValue("codigo","0");

		if (!viewMode) modeSec = "edit";
	 filter2 = " and cod_interconsulta="+cod_interconsulta;
			if(change == null )
			{
			iInter.clear();
			sql="select COD_INTERCONSULTA CODINTERCONSULTA, DIAGNOSTICO, nvl(e.OBSERVACION,' ') as OBSERVACION, CODIGO from  TBL_SAL_DIAGNOSTICO_INTER_ESP e where pac_id="+pacId+"and secuencia="+noAdmision+" "+filter2+" order by codigo asc";

			//System.out.println("SQLDET::*********************************************************************************** "+sql);
			al = sbb.getBeanList(ConMgr.getConnection(), sql, InterconsultaDiagnostico.class);

			interLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
						if (i < 10) key = "00" + i;
						else if (i < 100) key = "0" + i;
						else key = "" + i;
						try
						{
							iInter.put(key, al.get(i-1));
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
			}//for
			if(al.size()==0)
			{
										InterconsultaDiagnostico interDiag = new InterconsultaDiagnostico();
										interDiag.setCodigo("0");
										interDiag.setCodInterconsulta("00");
										interLastLineNo++;
										if (interLastLineNo < 10) key = "00" + interLastLineNo;
										else if (interLastLineNo < 100) key = "0" + interLastLineNo;
										else key = "" + interLastLineNo;
										try
										{
											iInter.put(key, interDiag);
										}
										catch(Exception e)
										{
											System.err.println(e.getMessage());
										}
			}
	}//change

}else if(cod_interconsulta.equals("00") || intCon==null)
{
						intCon = new CommonDataObject();
						intCon.addColValue("codigo", "0");
						if(change.equals("1"))
						{
							intCon.addColValue("nombreMedico", nombreMedico);
							intCon.addColValue("codMedico", codMedico);
							intCon.addColValue("especialidad", especialidad);
						}
						intCon.addColValue("fecha", cDateTime.substring(0,10));
						intCon.addColValue("hora", cDateTime.substring(11));
						intCon.addColValue("usuarioCreacion", UserDet.getUserName());
						intCon.addColValue("fechaCreacion", cDateTime);
						intCon.addColValue("usuarioModificacion", UserDet.getUserName());
						intCon.addColValue("fechaModificacion", cDateTime);
						
						if(change.equals("2") || change.equals("3"))
						{
										iInter.clear();
										InterconsultaDiagnostico interDiag = new InterconsultaDiagnostico();
										interDiag.setCodigo("0");
										interDiag.setCodInterconsulta("00");
										interLastLineNo++;
										if (interLastLineNo < 10) key = "00" + interLastLineNo;
										else if (interLastLineNo < 100) key = "0" + interLastLineNo;
										else key = "" + interLastLineNo;
										try
										{
											iInter.put(key, interDiag);
										}
										catch(Exception e)
										{
											System.err.println(e.getMessage());
										}
						}
						if (!viewMode) modeSec = "add";
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
document.title = 'INTERCONSULTORES - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function add(){var cod_esp =eval('document.form0.cod_especialidad').value;var codMedico = eval('document.form0.cod_medico').value;var nm = eval('document.form0.nombreMedico').value;window.location = '../expediente3.0/exp_interconsulta.jsp?change=2&mode=<%=mode%>&estado=<%=estado%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cod_interconsulta=00&nombreMedico='+nm+'&codMedico='+codMedico+'&cod_especialidad='+cod_esp;}
function medicoList(){abrir_ventana1('../common/search_medico.jsp?fp=exp_interconsulta_medico');}
function view(){abrir_ventana1('../expediente3.0/list_interconsulta.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
function setInterconsulta(k){
	var nm=eval('document.form0.nombreMedico').value;
	var code = eval('document.form0.codigo_inter'+k).value;
	var usuarioCreacion = eval('document.form0.usuario_creacion'+k).value;
	document.getElementById("codigo_interconsulta").value=code;
	window.location = '../expediente3.0/exp_interconsulta.jsp?modeSec=edit&estado=<%=estado%>&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cod_interconsulta='+code+'&usuario_creacion='+usuarioCreacion;
}
function doAction(){getMedico();checkViewMode();}

function getMedico(){var medico=eval('document.form0.cod_medico').value;var especMed = '';var medDesc ='';if(medico!=undefined && medico !=''){medDesc=getDBData('<%=request.getContextPath()%>','b.especialidad,primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_de_casada,null,\'\',\' \'||apellido_de_casada))','tbl_adm_medico a,tbl_adm_medico_especialidad b','a.codigo = b.medico(+) and b.secuencia(+) = 1 and  a.codigo=\''+medico+'\'','');var index = medDesc.indexOf('|'); if(index > 0)especMed = medDesc.substring(0,index);eval('document.form0.nombre_medico').value=medDesc.substring(index+1);eval('document.form0.cod_especialidad').value=especMed;}
}
function printExp(){var _IC_ID = document.getElementById("codigo_interconsulta").value;if(_IC_ID != 0 || _IC_ID != '0' ){var ICID = '&IC_ID='+_IC_ID;}else{var ICID = '';}	abrir_ventana("../expediente3.0/print_exp_seccion_50.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>"+ICID);}
function printExpAll(){abrir_ventana("../expediente3.0/print_exp_seccion_50_all.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>");}

function verHistorial() {
  $("#hist_container").toggle();
}
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
	<div class="row">
		<div class="table-responsive" data-pattern="priority-columns">
			<div class="headerform">
				 <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
				 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
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
				 <%=fb.hidden("nombreMedico",intCon.getColValue("nombreMedico"))%>
				 <%=fb.hidden("interSize",""+iInter.size())%>
				 <%=fb.hidden("interLastLineNo",""+interLastLineNo)%>
				 <%=fb.hidden("codigo_interconsulta",cod_interconsulta)%>
				 <%=fb.hidden("usuario_creac",intCon.getColValue("usuarioCreacion"))%>
				 <%=fb.hidden("fecha_creac",intCon.getColValue("fechaCreacion"))%>
				 <%=fb.hidden("usuario_modific",intCon.getColValue("usuarioModificacion"))%>
				 <%=fb.hidden("fecha_modific",intCon.getColValue("fechaModificacion"))%>
				 <%=fb.hidden("inter_codigo",intCon.getColValue("codigo"))%>
				 <%=fb.hidden("obser_inter",intCon.getColValue("observacion"))%>
				 <%=fb.hidden("cod_especialidad",intCon.getColValue("especialidad"))%>
				 <%=fb.hidden("comentario",intCon.getColValue("comentario"))%>
				 <%=fb.hidden("desc",desc)%>
				 <%=fb.hidden("usuario_creacion",usuarioCreacion)%>
				 <%=fb.hidden("estado", estado)%>
				 
				<table cellspacing="0" class="table pull-right table-striped table-custom-2">
					<tr>
						<td class="controls form-inline">
							<button type="button" name="agregar" id="agregar" class="btn btn-inverse btn-sm" onclick="javascript:add()"><i class="fa fa-plus fa-lg"></i> Agregar Interconsulta</button>
							
							<button type="button" class="btn btn-inverse btn-sm" onclick="javascript:view()"><i class="fa fa-eye fa-lg"></i> Ver Interconsulta M&eacute;dica</button>
							 
							 <% if (!cod_interconsulta.equals("") && !cod_interconsulta.equals("00")&& !cod_interconsulta.equals("0")){%>
								<%=fb.button("_imprimir","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print",null,"onClick=\"javascript:printExp()\"")%>
							 <%}%>
							 
							 <%if(al2.size() > 0){%>
								<%=fb.button("_imprimir","Imprimir Todo",false,false,"btn btn-inverse btn-sm|fa fa-print",null,"onClick=\"javascript:printExpAll()\"")%>
							 
								<button type="button" class="btn btn-inverse btn-sm" onClick="verHistorial()">
									<i class="fa fa-eye fa-printico"></i> <b>Historial</b>
								</button>
							<%}%>
						</td>
					</tr>
				</table>
				
				<div class="table-wrapper" id="hist_container" style="display:none">
					<table cellspacing="0" class="table table-small-font table-bordered table-striped">
						<thead>
							<tr class="bg-headtabla2">
								<td><cellbytelabel id="5">C&oacute;digo</cellbytelabel></td>
								<td><cellbytelabel id="5">Fecha</cellbytelabel></td>
								<td><cellbytelabel id="6">Especialidad</cellbytelabel></td>
								<td><cellbytelabel id="7">Nombre m&eacute;dico</cellbytelabel></td>
								<td></td>
							</tr>
						</thead>
						<tbody>
						<%for (int i=1; i<=al2.size(); i++){
							cdo = (CommonDataObject) al2.get(i-1);
						%>
						<%=fb.hidden("codigo_inter"+i,cdo.getColValue("CODIGO"))%>
						<%=fb.hidden("especialidad"+i,cdo.getColValue("cod_especialidad"))%>
						<%=fb.hidden("medico"+i,cdo.getColValue("medico"))%>
						<%=fb.hidden("nombre_medico"+i,cdo.getColValue("nombre_medico"))%>
						<%=fb.hidden("registro_medico"+i,cdo.getColValue("registro_medico"))%>
						<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
						<tr class="pointer" onClick="javascript:setInterconsulta(<%=i%>)">
							<td><%=cdo.getColValue("CODIGO")%></td>
							<td><%=cdo.getColValue("fecha")%></td>
							<td><%=cdo.getColValue("descripcionEsp")%></td>
							<td>[<%=cdo.getColValue("registro_medico")%>] <%=cdo.getColValue("nombre_medico")%></td>
							<td><span style="font-weight:bold"><%=cdo.getColValue("status_dsp")%></span></td>
						</tr>
						<%}%>
						<tbody>
					</table>
				</div>
			</div> 
			
			<table cellspacing="0" class="table table-small-font table-bordered">
			
			<tr>
			<td colspan="4" class="text-danger">
				<b>*** Para consultar a la vez tanto las Evoluciones como Interconsultas registradas en su paciente debe revisar el formulario de Evoluci&oacute;n Cl&iacute;nica</b>
			</td>
			</tr>

				<tr>
					<td><cellbytelabel id="8">Registro m&eacute;dico</cellbytelabel></td>
					<td colspan="3" class="controls form-inline">
					<%=fb.textBox("cod_medico",intCon.getColValue("medico"),true,false,((intCon.getColValue("medico") != null && !intCon.getColValue("medico"," ").trim().equals("")) ||viewMode),10,"form-control input-sm",null,"onChange=\"javascript:getMedico()\"")%>
					<%=fb.textBox("nombre_medico",intCon.getColValue("nombreMedico"),true,viewMode,true,60, "form-control input-sm", null, null)%>
					<%=fb.button("medico","...",true,((intCon.getColValue("medico") != null && !intCon.getColValue("medico"," ").trim().equals("")) ||viewMode),"btn btn-primary btn-sm",null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%>
					
					<span style="font-weight:bold; float:right"><%=intCon.getColValue("status_dsp"," ")%></span>
					</td>
				</tr>
							
				<tr class="TextRow01">
					<td width="15%"> <cellbytelabel id="9">Fecha</cellbytelabel></td>
					<td width="35%" class="controls form-inline">
						<%//=fb.textBox("fecha",intCon.getFecha(),false,false,true,10, "form-control input-sm", null, null)%>
						
						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="fecha" />
							<jsp:param name="valueOfTBox1" value="<%=intCon.getColValue("fecha")%>" />
							<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
						</jsp:include>
					</td>
					<td width="15%"><cellbytelabel id="10">Hora</cellbytelabel></td>
					<td width="35%" class="controls form-inline">
						<%//=fb.textBox("hora",intCon.getHora(),false,false,true,10, "form-control input-sm", null, null)%>
						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="hora" />
							<jsp:param name="valueOfTBox1" value="<%=intCon.getColValue("hora")%>" />
							<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
							<jsp:param name="format" value="hh12:mi:ss am" />
						</jsp:include>
					</td>
				</tr>
					
				<tr>
					<td colspan="4" class="controls form-inline">
						<table width="100%" class="table table-sm table-striped table-bordered">
							<tbody>
								<tr class="bg-headtabla">
									<td width="95%"><cellbytelabel id="11">Notas de la Interconsulta</cellbytelabel></td>
									<td width="5%" align="center"><%=fb.submit("agregar","+",true,viewMode,"btn btn-primary btn-xs",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Notas")%></td>
								</tr>
								<%
									al = CmnMgr.reverseRecords(iInter);
									for (int i=1; i<=iInter.size(); i++){
										key = al.get(i-1).toString();
										InterconsultaDiagnostico intDiag = (InterconsultaDiagnostico) iInter.get(key);
								%>
										<%=fb.hidden("codigo"+i,intDiag.getCodigo())%>
										<%=fb.hidden("cod_interconsulta"+i,intDiag.getCodInterconsulta())%>
										<%=fb.hidden("key"+i,key)%>
										<%=fb.hidden("remove"+i,"")%>
										<%=fb.hidden("diagnostico"+i,intDiag.getDiagnostico())%>
										<tr>
											<td>
												<%=fb.textarea("observacion"+i,intDiag.getObservacion(),false,false,viewMode,79,3,2000,"form-control input-sm","width:100%","")%>
											</td>
											<td align="center">
												<%=fb.submit("rem"+i,"x",false,viewMode,"btn btn-danger btn-sm",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%>
											</td>
										</tr>
								<%}
									fb.appendJsValidation("if(error>0)doAction();");
								%>
							</tbody>
						</table>
					</td>
				</tr>
					
			</table>
			
			<div class="footerform">
				<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
					<tr>
						<td>
							<%=fb.hidden("saveOption", "O")%>
							<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm|fa fa-floppy-o fa-lg",null,"")%>
							<!--<button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button>-->
							<%if(!usuarioCreacion.trim().equals("") && usuarioCreacion.equalsIgnoreCase(userName) && intCon.getColValue("status_dsp"," ").trim().equalsIgnoreCase("ACTIVO") ){%>
								<%//=fb.button("inactivar1","Inactivar",true,estado.equalsIgnoreCase("F"),"btn btn-sm btn-danger",null,"onClick='doSubmit(this.form, this.value)'")%>
								
								<%=fb.submit("inactivar1","Inactivar",false,estado.equalsIgnoreCase("F"),"btn btn-danger btn-sm",null,"","Inactivar")%>
							<%}%>
							
							<authtype type="50">
							<%if(intCon.getColValue("status_dsp"," ").trim().equalsIgnoreCase("ACTIVO") ){%>
								<%//=fb.button("inactivar2","Inactivar",true,estado.equalsIgnoreCase("F"),"btn btn-sm btn-warning",null,"onClick='doSubmit(this.form, this.value)'")%>
								<%=fb.submit("inactivar2","Inactivar",false,estado.equalsIgnoreCase("F"),"btn btn-warning btn-sm",null,"","Inactivar")%>
							<%}%>
							</authtype>
						</td>
					</tr>
				</table>   
			</div>
			<%=fb.formEnd(true)%>
			
		</div>
	</div>
</body>
</html>
<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";
	String errorCode = "";
	String errorMsg = "";
	cod_interconsulta=request.getParameter("codigo_interconsulta");
		
	if (baction.equalsIgnoreCase("Inactivar")) {
		cdo = new CommonDataObject();
		cdo.setTableName("TBL_SAL_INTERCONSULTOR_ESPEC");
		cdo.setWhereClause("pac_id = "+pacId+" and secuencia = "+noAdmision+" and codigo = "+request.getParameter("inter_codigo"));

		cdo.addColValue("status", "I");
		cdo.addColValue("fecha_modificacion", cDateTime);
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"baction=Inactivar");
		SQLMgr.update(cdo);
		ConMgr.clearAppCtx(null);
		
		 errorCode = SQLMgr.getErrCode();
		 errorMsg = SQLMgr.getErrMsg();
	} else {

		Interconsulta interc = new Interconsulta();
		interc.setNombreMedico(request.getParameter("nombreMedico"));
		interc.setCodPaciente(request.getParameter("codPac"));
		interc.setSecuencia(request.getParameter("noAdmision"));
		interc.setFecNacimiento(request.getParameter("dob"));
		interc.setPacId(request.getParameter("pacId"));
		interc.setCodigo(request.getParameter("inter_codigo"));
		interc.setMedico(request.getParameter("cod_medico"));
		interc.setFecha(request.getParameter("fecha"));
		interc.setObservacion(request.getParameter("obser_inter"));
		interc.setCodEspecialidad(request.getParameter("cod_especialidad"));
		interc.setComentario(request.getParameter("comentario"));
		interc.setHora(request.getParameter("hora"));
		
		if (modeSec.equalsIgnoreCase("add")){
			interc.setUsuarioCreacion(request.getParameter("usuario_creac"));
			interc.setFechaCreacion(request.getParameter("fecha_creac"));
		} else {
			interc.setUsuarioModificacion((String) session.getAttribute("_userName"));
			interc.setFechaModificacion(cDateTime);
		}

		int size = 0;
		if (request.getParameter("interSize") != null)
		size = Integer.parseInt(request.getParameter("interSize"));
		al.clear();
		for (int i=1; i<=size; i++)
		{
				InterconsultaDiagnostico interDiag = new InterconsultaDiagnostico();
				interDiag.setSecuencia(request.getParameter("noAdmision"));
				interDiag.setCodPaciente(request.getParameter("codPac"));
				interDiag.setFecNacimiento(request.getParameter("dob"));
				interDiag.setPacId(request.getParameter("pacId"));
				interDiag.setCodInterconsulta(request.getParameter("cod_interconsulta"+i));
				interDiag.setDiagnostico(request.getParameter("diagnostico"+i));
				interDiag.setObservacion(request.getParameter("observacion"+i));
				interDiag.setCodigo(request.getParameter("codigo"+i));
				key=request.getParameter("key"+i);

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = key;
			else
			{
				try
				{
					al.add(interDiag);
					iInter.put(key,interDiag);
					interc.addInterconsultaDiagnostico(interDiag);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//End else
		}//end For
	
		if(!itemRemoved.equals(""))
		{
			iInter.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&interLastLineNo="+interLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&cod_interconsulta="+request.getParameter("codigo_interconsulta")+"&nombreMedico="+request.getParameter("nombre_medico")+"&codMedico="+request.getParameter("cod_medico")+"&cod_especialidad="+request.getParameter("cod_especialidad")+"&desc="+desc+"&estado="+estado+"&usuario_creacion="+usuarioCreacion);
		return;
		}

		if(baction.equals("+"))//Agregar
		{

			InterconsultaDiagnostico interDiag = new InterconsultaDiagnostico();
			interDiag.setCodInterconsulta(request.getParameter("codigo_interconsulta"));
			interDiag.setCodigo("0");
			interLastLineNo++;
			if (interLastLineNo < 10) key = "00" + interLastLineNo;
			else if (interLastLineNo < 100) key = "0" + interLastLineNo;
			else key = "" + interLastLineNo;
			try
			{
				iInter.put(key,interDiag);
				 //System.out.println("iInter.size() == "+iInter.size());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&interLastLineNo="+interLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&cod_interconsulta="+request.getParameter("codigo_interconsulta")+"&nombreMedico="+request.getParameter("nombre_medico")+"&codMedico="+request.getParameter("cod_medico")+"&cod_especialidad="+request.getParameter("cod_especialidad")+"&desc="+desc+"&estado="+estado+"&usuario_creacion="+usuarioCreacion);
			return;
		}

		if (baction.equalsIgnoreCase("Guardar")) {
			 ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			 if (modeSec.equalsIgnoreCase("add")){
				 InterMgr.add(interc,"I");
				 cod_interconsulta = InterMgr.getPkColValue("codigo");
			 } else if (modeSec.equalsIgnoreCase("edit")){
				InterMgr.update(interc,"I");
		     }
			 ConMgr.clearAppCtx(null);
			 
			 errorCode = InterMgr.getErrCode();
			 errorMsg = InterMgr.getErrMsg();
		}
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (errorCode.equals("1"))
{
%>
	alert('<%=errorMsg%>');
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cod_interconsulta=<%=cod_interconsulta%>&codMedico=<%=codMedico%>&nombreMedico=<%=nombreMedico%>&desc=<%=desc%>&estado=<%=estado%>&usuario_creacion=<%=usuarioCreacion%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>