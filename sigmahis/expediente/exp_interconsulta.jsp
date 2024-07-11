<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.Interconsulta"%>
<%@ page import="issi.expediente.InterconsultaDiagnostico"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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
Interconsulta intCon = new Interconsulta();

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


if (fg == null) fg = "I";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

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
sql2="select distinct e.codigo, e.medico, e.cod_especialidad, decode(AM.APELLIDO_DE_CASADA,null, AM.PRIMER_APELLIDO||' '||AM.SEGUNDO_APELLIDO, AM.APELLIDO_DE_CASADA)||' '|| AM.PRIMER_NOMBRE||' '||AM.SEGUNDO_NOMBRE as nombre_medico, nvl(esp.descripcion,' ') as descripcionEsp from  tbl_sal_diagnostico_inter_esp di, tbl_adm_medico AM, tbl_adm_especialidad_medica esp, tbl_sal_interconsultor_espec e Where e.pac_id="+pacId+" and e.secuencia="+noAdmision+"and e.medico=AM.codigo and esp.codigo(+)=e.cod_especialidad  and di.cod_interconsulta =   e.codigo and di.pac_id=e.pac_id and di.secuencia= e.secuencia  ORDER BY e.codigo desc";
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

		sql="select AM.primer_nombre||decode(AM.segundo_nombre,'','',' '||AM.segundo_nombre)||' '||AM.primer_apellido|| decode(AM.segundo_apellido, null,'',' '||AM.segundo_apellido)||decode(AM.sexo,'F', decode(AM.apellido_de_casada,'','',' '||AM.apellido_de_casada)) as nombremedico, esp.descripcion as descripcion, a.medico as medico, a.codigo as codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.observacion as observacion, nvl(a.cod_especialidad,' ') as codespecialidad, a.comentario as comentario, a.usuario_creacion as usuariocreacion, to_char(a.FECHA_CREACION,'dd/mm/yyyy hh12:mi:ss am') as fechacreacion, a.usuario_modificacion as usuariomodificacion, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi:ss am') as fechamodificacion , to_char(a.HORA,'hh12:mi:ss am') as hora from TBL_SAL_INTERCONSULTOR_ESPEC a, tbl_adm_medico AM, tbl_adm_especialidad_medica esp Where a.pac_id(+)="+pacId+" and a.secuencia="+noAdmision+" "+filter+" and a.medico=AM.codigo(+) and esp.codigo(+)=a.cod_especialidad and (a.pac_id, a.secuencia) in (select sd.pac_id, sd.secuencia from tbl_sal_diagnostico_inter_esp sd) order by a.codigo asc";

//System.out.println("SQL::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "+sql);
	 intCon = (Interconsulta) sbb.getSingleRowBean(ConMgr.getConnection(), sql, Interconsulta.class);
	 cod_interconsulta = intCon.getCodigo();

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
						intCon = new Interconsulta();
						intCon.setCodigo("0");
						if(change.equals("1"))
						{
							intCon.setNombreMedico(nombreMedico);
							intCon.setMedico(codMedico);
							intCon.setCodEspecialidad(especialidad);
						}
						intCon.setFecha(cDateTime.substring(0,10));
						intCon.setHora(cDateTime.substring(11));
						intCon.setUsuarioCreacion(UserDet.getUserName());
						intCon.setFechaCreacion(cDateTime);
						intCon.setUsuarioModificacion(UserDet.getUserName());
						intCon.setFechaModificacion(cDateTime);
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
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'INTERCONSULTORES - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function add(){var cod_esp =eval('document.form0.cod_especialidad').value;var codMedico = eval('document.form0.cod_medico').value;var nm = eval('document.form0.nombreMedico').value;window.location = '../expediente/exp_interconsulta.jsp?change=2&mode=<%=mode%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cod_interconsulta=00&nombreMedico='+nm+'&codMedico='+codMedico+'&cod_especialidad='+cod_esp;}
function medicoList(){abrir_ventana1('../common/search_medico.jsp?fp=exp_interconsulta_medico');}
function view(){abrir_ventana1('../expediente/list_interconsulta.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');}
function setInterconsulta(k){var nm=eval('document.form0.nombreMedico').value;var code = eval('document.form0.codigo_inter'+k).value;document.getElementById("codigo_interconsulta").value=code;window.location = '../expediente/exp_interconsulta.jsp?modeSec=edit&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cod_interconsulta='+code;}
function doAction(){setHeight();getMedico();checkViewMode();}
function setHeight(){newHeight();}
function getMedico(){var medico=eval('document.form0.cod_medico').value;var especMed = '';var medDesc ='';if(medico!=undefined && medico !=''){medDesc=getDBData('<%=request.getContextPath()%>','b.especialidad,primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_de_casada,null,\'\',\' \'||apellido_de_casada))','tbl_adm_medico a,tbl_adm_medico_especialidad b','a.codigo = b.medico(+) and b.secuencia(+) = 1 and  a.codigo=\''+medico+'\'','');var index = medDesc.indexOf('|'); if(index > 0)especMed = medDesc.substring(0,index);eval('document.form0.nombre_medico').value=medDesc.substring(index+1);eval('document.form0.cod_especialidad').value=especMed;}
}
function printExp(){var _IC_ID = document.getElementById("codigo_interconsulta").value;if(_IC_ID != 0 || _IC_ID != '0' ){var ICID = '&IC_ID='+_IC_ID;}else{var ICID = '';}	abrir_ventana("../expediente/print_exp_seccion_50.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>"+ICID);}
function printExpAll(){abrir_ventana("../expediente/print_exp_seccion_50_all.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>");}
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
	<tr>
		<td>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1" >
					 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
					 <%=fb.hidden("nombreMedico",intCon.getNombreMedico())%>
					 <%=fb.hidden("interSize",""+iInter.size())%>
					 <%=fb.hidden("interLastLineNo",""+interLastLineNo)%>
					 <%=fb.hidden("codigo_interconsulta",cod_interconsulta)%>
					 <%=fb.hidden("usuario_creac",intCon.getUsuarioCreacion())%>
					 <%=fb.hidden("fecha_creac",intCon.getFechaCreacion())%>
					 <%=fb.hidden("usuario_modific",intCon.getUsuarioModificacion())%>
					 <%=fb.hidden("fecha_modific",intCon.getFechaModificacion())%>
					 <%=fb.hidden("inter_codigo",intCon.getCodigo())%>
					 <%=fb.hidden("obser_inter",intCon.getObservacion())%>
					 <%=fb.hidden("cod_especialidad",intCon.getCodEspecialidad())%>
					 <%=fb.hidden("comentario",intCon.getComentario())%>
                      <%=fb.hidden("desc",desc)%>
				<tr class="TextRow01">
				<td colspan="4" align="right"> 
                 <a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Agregar Interconsulta</cellbytelabel> ]</a>&nbsp;&nbsp;
				 <!--<a href="javascript:view()" class="Link00">[ Ver Interconsulta Medica]</a>-->
                 
                 <% if (cod_interconsulta == null || cod_interconsulta.equals("00") || cod_interconsulta.equals("0") || cod_interconsulta.equals("")){%>
                     <a href="javascript:printExpAll();" class="Link00">[<cellbytelabel id="2">Imprimir Todo</cellbytelabel>]</a>
                  <%}else{%>
                      <a href="javascript:printExp();" class="Link00">[<cellbytelabel id="3">Imprimir</cellbytelabel>]</a>
                 <%}%>
                 </td>
				</tr>
				<tr>
					<td  colspan="4">
					<div id="listado" width="100%" class="exp h100">
					<div id="detListado" width="98%" class="child">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td colspan="3">&nbsp;<cellbytelabel id="4">Listado de Interconsultas</cellbytelabel></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="20%"><cellbytelabel id="5">C&oacute;digo</cellbytelabel></td>
							<td width="40%"><cellbytelabel id="6">Especialidad</cellbytelabel></td>
							<td width="40%"><cellbytelabel id="7">Nombre m&eacute;dico</cellbytelabel></td>
						</tr>
<%
for (int i=1; i<=al2.size(); i++)
{
	cdo = (CommonDataObject) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo_inter"+i,cdo.getColValue("CODIGO"))%>
		<%=fb.hidden("especialidad"+i,cdo.getColValue("cod_especialidad"))%>
		<%=fb.hidden("medico"+i,cdo.getColValue("medico"))%>
		<%=fb.hidden("nombre_medico"+i,cdo.getColValue("nombre_medico"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setInterconsulta(<%=i%>)" style="text-decoration:none; cursor:pointer">
				<td><%=cdo.getColValue("CODIGO")%></td>
				<td><%=cdo.getColValue("descripcionEsp")%></td>
				<td><%=cdo.getColValue("nombre_medico")%></td>
		</tr>
<%
}
%>
						</table>
					</div>
					</div>
					</td>
				</tr>
				
						<tr class="TextRow01">
								<td><cellbytelabel id="8">Registro m&eacute;dico</cellbytelabel></td>
								<td colspan="3">
								<%=fb.textBox("cod_medico",intCon.getMedico(),true,false,((intCon.getMedico() != null && !intCon.getMedico().trim().equals("")) ||viewMode),10,null,null,"onChange=\"javascript:getMedico()\"")%>
								<%=fb.textBox("nombre_medico",intCon.getNombreMedico(),true,viewMode,true,60)%>
								<%=fb.button("medico","...",true,((intCon.getMedico() != null && !intCon.getMedico().trim().equals("")) ||viewMode),null,null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%>
								</td>
						</tr>
						<tr class="TextRow01">
						<td width="15%"> <cellbytelabel id="9">fecha</cellbytelabel></td>
						<td width="35%"><%=fb.textBox("fecha",intCon.getFecha(),false,false,viewMode,10)%></td>
						<td width="15%"><cellbytelabel id="10">Hora</cellbytelabel></td>
						<td width="35%"> <%=fb.textBox("hora",intCon.getHora(),false,false,viewMode,10)%></td>
						</tr>
						<tr class="TextRow01">
								<td colspan="4">
								<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader">

							<td width="95%"><cellbytelabel id="11">Notas de la Interconsulta</cellbytelabel></td>
								<td width="5%" align="center"><%=fb.submit("agregar","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Notas")%></td>
	</tr>
						<%
						al = CmnMgr.reverseRecords(iInter);
							for (int i=1; i<=iInter.size(); i++)
							{
								key = al.get(i-1).toString();
								InterconsultaDiagnostico intDiag = (InterconsultaDiagnostico) iInter.get(key);
								String color = "TextRow01";
									if (i % 2 == 0) color = "TextRow02";
						%>
								<%=fb.hidden("codigo"+i,intDiag.getCodigo())%>
								<%=fb.hidden("cod_interconsulta"+i,intDiag.getCodInterconsulta())%>
								<%=fb.hidden("key"+i,key)%>
								<%=fb.hidden("remove"+i,"")%>
								<%=fb.hidden("diagnostico"+i,intDiag.getDiagnostico())%>
						<tr class="<%=color%>">
								<td><%=fb.textarea("observacion"+i,intDiag.getObservacion(),false,false,viewMode,79,4,2000,"","","")%></td> <!--(!intDiag.getCodigo().trim().equals("0") || viewMode)-->
				<td align="center"><%=fb.submit("rem"+i,"X",false,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
						</tr>
    <%
	  }
	fb.appendJsValidation("if(error>0)doAction();");
	%>
								</table>
								</td>
						</tr>
						<tr class="TextRow02" align="right">
								<td colspan="4">
				<cellbytelabel id="12">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="12">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="13">Cerrar</cellbytelabel>
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
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";
		cod_interconsulta=request.getParameter("codigo_interconsulta");

		Interconsulta interc = new Interconsulta();
		interc.setNombreMedico(request.getParameter("nombreMedico"));
		interc.setCodPaciente(request.getParameter("codPac"));
		interc.setSecuencia(request.getParameter("noAdmision"));
		interc.setFecNacimiento(request.getParameter("dob"));
		interc.setPacId(request.getParameter("pacId"));
		interc.setUsuarioCreacion(request.getParameter("usuario_creac"));
		interc.setFechaCreacion(request.getParameter("fecha_creac"));
		interc.setUsuarioModificacion((String) session.getAttribute("_userName"));
		interc.setFechaModificacion(cDateTime);
		interc.setCodigo(request.getParameter("inter_codigo"));
		interc.setMedico(request.getParameter("cod_medico"));
		interc.setFecha(request.getParameter("fecha"));
		interc.setObservacion(request.getParameter("obser_inter"));
		interc.setCodEspecialidad(request.getParameter("cod_especialidad"));
		interc.setComentario(request.getParameter("comentario"));
		interc.setHora(request.getParameter("hora"));

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
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&interLastLineNo="+interLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&cod_interconsulta="+request.getParameter("codigo_interconsulta")+"&nombreMedico="+request.getParameter("nombre_medico")+"&codMedico="+request.getParameter("cod_medico")+"&cod_especialidad="+request.getParameter("cod_especialidad"));
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
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&interLastLineNo="+interLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&cod_interconsulta="+request.getParameter("codigo_interconsulta")+"&nombreMedico="+request.getParameter("nombre_medico")+"&codMedico="+request.getParameter("cod_medico")+"&cod_especialidad="+request.getParameter("cod_especialidad"));
			return;
		}

	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	 if (modeSec.equalsIgnoreCase("add"))
	 {

				 InterMgr.add(interc,"I");
				 cod_interconsulta = InterMgr.getPkColValue("codigo");
	 }
	 else if (modeSec.equalsIgnoreCase("edit"))
	 {
				 InterMgr.update(interc,"I");
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
if (InterMgr.getErrCode().equals("1"))
{
%>
	alert('<%=InterMgr.getErrMsg()%>');
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cod_interconsulta=<%=cod_interconsulta%>&codMedico=<%=codMedico%>&nombreMedico=<%=nombreMedico%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>