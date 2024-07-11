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
<jsp:useBean id="InterMgr" scope="page" class="issi.expediente.InterconsultaMgr" />
<jsp:useBean id="iInter" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
InterMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
Interconsulta intCon = new Interconsulta(); 

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
boolean viewMode = false;
int rowCount = 0;
String sql = "";
String sql2 = "";


String change = request.getParameter("change");
String mode = request.getParameter("mode"); 
String seccion = request.getParameter("seccion");
String pac_id = request.getParameter("pac_id");
String secuencia = request.getParameter("secuencia");
String fec_nacimiento = request.getParameter("fec_nacimiento");
String cod_pac = request.getParameter("cod_pac");
String cod_interconsulta = request.getParameter("cod_interconsulta");
String nombreMedico = request.getParameter("nombreMedico");
String codMedico = request.getParameter("codMedico");
String especialidad = request.getParameter("cod_especialidad");



int interLastLineNo =0; 
String filter ="", filter2 ="";
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode != null && mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La sección no es válida. Por favor intente nuevamente!");
if (pac_id == null || secuencia == null || fec_nacimiento == null || cod_pac == null) throw new Exception("La admisión no es válida. Por favor intente nuevamente!");

if (request.getParameter("interLastLineNo") != null) interLastLineNo = Integer.parseInt(request.getParameter("interLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{ 

sql2="select PRIMER_NOMBRE||' '||SEGUNDO_NOMBRE||' '||PRIMER_APELLIDO||' '||SEGUNDO_APELLIDO as nombre, num_empleado as numempleado, emp_id as empid from tbl_pla_empleado where compania="+(String) session.getAttribute("_companyId")+" and ubic_seccion = "+seccion;
al2 = SQLMgr.getDataList(sql2);



System.out.println("al2. size "+al2.size());
System.out.println("cod interconsulta en el get "+cod_interconsulta);

filter="and a.codigo= "+cod_interconsulta;
filter2="and cod_interconsulta= "+cod_interconsulta;

if (change == null)
{			

	if( cod_interconsulta == null || cod_interconsulta.equals("0"))
	{ 
			
			
			rowCount = CmnMgr.getCount("SELECT count(*) FROM TBL_SAL_INTERCONSULTOR_ESPEC WHERE pac_id(+) = "+pac_id +" and secuencia ="+secuencia);
			System.out.println("rowCount "+rowCount);



			if(rowCount > 0 )
			{		
					
					if(mode.equalsIgnoreCase("edit"))
					{
						cdo = SQLMgr.getData("select nvl(max(codigo),0) as codigo from TBL_SAL_INTERCONSULTOR_ESPEC where pac_id ="+pac_id +" and secuencia ="+secuencia);
					}
			 		if(mode.equalsIgnoreCase("add")||mode.equalsIgnoreCase("view")||mode==null)
					{  
								cdo = SQLMgr.getData("select nvl(min(codigo),0) as codigo from TBL_SAL_INTERCONSULTOR_ESPEC where pac_id ="+pac_id +" and secuencia ="+secuencia);
							if (!viewMode) mode="edit";
					}
					if(cdo!=null)
					{
							cod_interconsulta= cdo.getColValue("codigo");
							filter="and a.codigo= "+cod_interconsulta;
							filter2="and cod_interconsulta= "+cod_interconsulta;
														
							if (!viewMode) mode="edit";		
							
					}//cdo !=null
					
			}//	
			else if(rowCount == 0 )
			{			
						iInter.clear();
						cod_interconsulta = "00";
					  intCon = new Interconsulta();	
						intCon.setCodigo("0");
						intCon.setNombreMedico("");
						intCon.setMedico("");
						intCon.setFecha(cDateTime.substring(0,10));
						intCon.setHora(cDateTime.substring(11));				  
													
						InterconsultaDiagnostico interDiag = new InterconsultaDiagnostico();
						interDiag.setCodigo("0");
						interDiag.setCodInterconsulta("0");
						interDiag.setObservacion("");
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
						if (!viewMode) mode = "add";
						
					System.out.println("fecha"+intCon.getFecha());
					System.out.println("hora"+intCon.getHora());
					System.out.println("codigo"+interDiag.getCodigo());	
		
			
			}
						
	}	
	/*else
	{
	filter="and a.codigo= "+cod_interconsulta;
	filter2="and cod_interconsulta= "+cod_interconsulta;
	}	*/
	
	
if(cod_interconsulta != null && !cod_interconsulta.equals("00") && !cod_interconsulta.equals("0"))
{
System.out.println("en el if 00 ");

filter="and a.codigo= "+cod_interconsulta;
filter2="and cod_interconsulta= "+cod_interconsulta;

sql="select AM.primer_nombre||decode(AM.segundo_nombre,'','',' '||AM.segundo_nombre)||' '||AM.primer_apellido||decode(AM.segundo_apellido,null,'',' '||AM.segundo_apellido)||decode(AM.sexo,'F',decode(AM.apellido_de_casada,'','',' '||AM.apellido_de_casada)) as  nombremedico, esp.descripcion as descripcion , a.medico as medico , a.codigo as codigo , to_char(a.fecha,'dd/mm/yyyy')as fecha, a.observacion as observacion, a.cod_especialidad as codespecialidad  , a.comentario as comentario, a.usuario_creacion as usuariocreacion, to_char(a.FECHA_CREACION,'dd/mm/yyyy')as fechacreacion, a.usuario_modificacion as usuariomodificacion, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy')as fechamodificacion , to_char(a.HORA,'hh12:mi:ss am')as hora  from TBL_SAL_INTERCONSULTOR_ESPEC a, tbl_adm_medico AM,tbl_adm_especialidad_medica esp Where a.pac_id(+) ="+pac_id+" and a.secuencia = "+secuencia+filter+" and a.medico=AM.codigo(+) and esp.codigo = a.cod_especialidad and (a.pac_id, a.secuencia) in (select sd.pac_id, sd.secuencia  from tbl_sal_diagnostico_inter_esp sd where sd.observacion is not null )  order by a.codigo asc";

 intCon = (Interconsulta) sbb.getSingleRowBean(ConMgr.getConnection(), sql, Interconsulta.class);
 iInter.clear();
		  sql="select COD_INTERCONSULTA CODINTERCONSULTA, DIAGNOSTICO, OBSERVACION,CODIGO from  TBL_SAL_DIAGNOSTICO_INTER_ESP  where  pac_id="+pac_id+"and secuencia = "+secuencia+ filter2 +" order by codigo asc";
    	
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
 	}
}//change

else 
{
		if (!viewMode) mode="edit";	
		if(change.equals("1"))	
		{
				sql="select AM.primer_nombre||decode(AM.segundo_nombre,'','',' '||AM.segundo_nombre)||' '||AM.primer_apellido||decode(AM.segundo_apellido,null,'',' '||AM.segundo_apellido)||decode(AM.sexo,'F',decode(AM.apellido_de_casada,'','',' '||AM.apellido_de_casada)) as  nombremedico, esp.descripcion as descripcion , a.medico as medico , a.codigo as codigo , to_char(a.fecha,'dd/mm/yyyy')as fecha, a.observacion as observacion, a.cod_especialidad as codespecialidad  , a.comentario as comentario, a.usuario_creacion as usuariocreacion, to_char(a.FECHA_CREACION,'dd/mm/yyyy')as fechacreacion, a.usuario_modificacion as usuariomodificacion, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy')as fechamodificacion , to_char(a.HORA,'hh12:mi:ss am')as hora  from TBL_SAL_INTERCONSULTOR_ESPEC a, tbl_adm_medico AM,tbl_adm_especialidad_medica esp Where a.pac_id(+) ="+pac_id+" and a.secuencia = "+secuencia+filter+" and a.medico=AM.codigo(+) and esp.codigo = a.cod_especialidad and (a.pac_id, a.secuencia) in (select sd.pac_id, sd.secuencia  from tbl_sal_diagnostico_inter_esp sd where sd.observacion is not null )  order by a.codigo asc";

 intCon = (Interconsulta) sbb.getSingleRowBean(ConMgr.getConnection(), sql, Interconsulta.class);
				//intCon.setNombreMedico(nombreMedico);
				//intCon.setMedico(codMedico);
		}
		if(change.equals("2"))	//new interconsulta
		{				System.out.println("en change = 2");
		
				    iInter.clear();
						intCon = new Interconsulta();	
						intCon.setCodigo("0");
						intCon.setNombreMedico(nombreMedico);
						intCon.setMedico(codMedico);
						intCon.setCodEspecialidad(especialidad);
						intCon.setFecha(cDateTime.substring(0,10));
						intCon.setHora(cDateTime.substring(11));
						intCon.setUsuarioCreacion(UserDet.getUserName());
						intCon.setFechaCreacion(cDateTime.substring(0,10));
						intCon.setUsuarioModificacion(UserDet.getUserName());
						intCon.setFechaModificacion(cDateTime.substring(0,10));
					  
											
						InterconsultaDiagnostico interDiag = new InterconsultaDiagnostico();
						interDiag.setCodigo("0");
						interDiag.setCodInterconsulta("0");
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
		if (!viewMode) mode = "add";
		}
		
}

	if(cod_interconsulta.equals("00"))
	{					//iInter.clear();
						System.out.println("cod_interconsulta en if 00 ");
						intCon.setCodigo("0");
						intCon.setNombreMedico(nombreMedico);
						intCon.setMedico(codMedico);
						intCon.setFecha(cDateTime.substring(0,10));
						intCon.setHora(cDateTime.substring(11));
					  if (!viewMode) mode = "add";
	}
	
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Recursos Humanos - '+document.title;

function add()
{ 
var cod_esp =eval('document.form0.cod_especialidad').value;
var codMedico=eval('document.form0.cod_medico').value;
var nm=eval('document.form0.nombreMedico').value;
window.location = '../expediente/exp_interconsulta.jsp?change=2&mode=<%=mode%>&seccion=<%=seccion%>&pac_id=<%=pac_id%>&secuencia=<%=secuencia%>&fec_nacimiento=<%=fec_nacimiento%>&cod_pac=<%=cod_pac%>&cod_interconsulta=000&nombreMedico='+nm+'&codMedico='+codMedico+'&cod_especialidad='+cod_esp;
}
function cargoList()
{
	abrir_ventana1('../common/search_cargo.jsp?fp=accion_cargo');
}
function setInterconsulta(k)
{
var nm=eval('document.form0.nombreMedico').value;
var code = eval('document.form0.codigo_inter'+k).value;
window.location = '../expediente/exp_interconsulta.jsp?mode=<%=mode%>&seccion=<%=seccion%>&pac_id=<%=pac_id%>&secuencia=<%=secuencia%>&fec_nacimiento=<%=fec_nacimiento%>&cod_pac=<%=cod_pac%>&cod_interconsulta='+code;
}
function doAction()
{
	//showHide(0);
	setHeight();
}
function setHeight()
{
	newHeight();
	parent.setHeight('secciones',document.body.scrollHeight);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="ACCIONES"></jsp:param>
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
					 <%=fb.hidden("mode",mode)%> 
				   <%=fb.hidden("seccion",seccion)%>
					 <%=fb.hidden("nombreMedico",intCon.getNombreMedico())%>
					 <%=fb.hidden("secuencia",secuencia)%>
					 <%=fb.hidden("cod_pac",cod_pac)%>
					 <%=fb.hidden("fec_nacimiento",fec_nacimiento)%>
					 <%=fb.hidden("pac_id",pac_id)%>
					 <%=fb.hidden("baction","")%>
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
																	 
				<tr>
					<td  colspan="4" onClick="javascript:showHide(0);setHeight()" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Listado de Empleados y sus Acciones </td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>					</td>
				</tr>
				<tr id="panel0"><!-- style="display:''"-->
					<td colspan="4">
					 <table align="center" width="100%" cellpadding="1" cellspacing="1">
	 	<tr class="TextHeader" align="center"> 
						
							<td width="20%">C&oacute;digo</td>
							<td width="40%">Nombre</td>
							<td width="40%">Acci&oacute;n</td>
	</tr>
<%System.out.println("antes del for");

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
			
		    <td><%=cdo.getColValue("numempleado")%></td>
				<td><%=cdo.getColValue("nombre")%></td>
				<td><a href="javascript:move()" class="Link00">[ Agregar Acciones ]</a></td>
		</tr>
<%
System.out.println("despues del for");
}
%>		
				</table>				</td>
				</tr>
						
						<tr class="TextRow01">
								<td>Cargo Nuevo </td>
								<td colspan="3"><%=fb.intBox("codigo",cdo.getColValue("codigo"),false,false,true,10)%><%=fb.textBox("denominacion",cdo.getColValue("denominacion"),false,false,true,25)%><%=fb.button("cargo","...",true,viewMode,null,null,"onClick=\"javascript:cargoList()\"","seleccionar cargo")%></td>
						</tr>	
						<tr class="TextRow01">
						<td width="15%"> Salario Nuevo </td>
						<td width="35%"><%=fb.textBox("salario","",false,false,false,10,10)%></td>
					  <td width="15%">Gasto de Rep. Nuevo </td>
						<td width="35%"> <%=fb.textBox("gasto","",false,false,false,10,10)%></td>	
						</tr>	
						
							<tr class="TextRow01">
						<td width="15%"> Fecha Efectiva </td>
						<td width="35%"><%=fb.textBox("fecha",intCon.getFecha(),false,viewMode,true,10)%></td>
					  <td width="15%">Horario Nuevo </td>
						<td width="35%"><%=fb.textBox("codigo1",intCon.getMedico(),true,viewMode,false,5)%><%=fb.textBox("nombre_horario",intCon.getNombreMedico(),false,viewMode,true,15)%><%=fb.button("horario","...",true,viewMode,null,null,"onClick=\"javascript:medicoList()\"","seleccionar horario")%>  </td>
			  </tr>
								
									<tr class="TextRow01">
						<td width="15%"> Desde </td>
						<td width="35%"><%=fb.textBox("desde",intCon.getFecha(),false,viewMode,true,10)%></td>
					  <td width="15%">Hasta </td>
						<td width="35%"> <%=fb.textBox("hasta",intCon.getFecha(),false,viewMode,true,10)%></td>	
						</tr>	
						
						<tr class="TextRow01">
								<td colspan="4">
								<table width="100%" cellpadding="1" cellspacing="1">
	 	<tr class="TextHeader"> 
						
							<td width="95%">Registro de Acciones</td>
								<td width="5%" align="center"><%=fb.submit("agregar","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Notas")%></td>
	</tr>
						<%
						System.out.println("antes del segundo for");
						al = CmnMgr.reverseRecords(iInter);	
							for (int i=1; i<=iInter.size(); i++)
							{
								key = al.get(i-1).toString();	
								InterconsultaDiagnostico intDiag = (InterconsultaDiagnostico) iInter.get(key);			
								//cdo = (CommonDataObject) iInter.get(key);
								String color = "TextRow01";
									if (i % 2 == 0) color = "TextRow02";
							
						%>
								<%=fb.hidden("codigo"+i,intDiag.getCodigo())%>
								<%=fb.hidden("cod_interconsulta"+i,intDiag.getCodInterconsulta())%>			
								<%=fb.hidden("key"+i,key)%> 
								<%=fb.hidden("remove"+i,"")%>
								<%=fb.hidden("diagnostico"+i,intDiag.getDiagnostico())%>
								
								
									
						<tr class="<%=color%>">
								<td><%=fb.textarea("observacion"+i,intDiag.getObservacion(),false,false,viewMode,80,7,2000,"","width:100%","")%></td> 		
				<td align="center"><%=fb.submit("rem"+i,"X",false,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
						</tr>	
						
	<%	
	}
	fb.appendJsValidation("if(error>0)doAction();");

	%> 
								</table>								</td>	
						</tr>	
						<tr class="TextRow02" align="right">
								<td colspan="4">
									Opciones de Guardar: 
							<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro--> 
							<%=fb.radio("saveOption","O",false,viewMode,false)%>Mantener Abierto 
							<%=fb.radio("saveOption","C",true,viewMode,false)%>Cerrar 
							<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
							<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>								</td>
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
		nombreMedico=request.getParameter("nombre_medico");
		codMedico=request.getParameter("cod_medico");
		
		System.out.println("codigo interconsulta en el post -----"+request.getParameter("codigo_interconsulta"));
		System.out.println("mode el post -----"+request.getParameter("mode")+" mode "+mode);
		Interconsulta interc = new Interconsulta();
		interc.setNombreMedico(request.getParameter("nombreMedico"));
		interc.setCodPaciente(request.getParameter("cod_pac"));
		interc.setSecuencia(request.getParameter("secuencia")); 
		interc.setFecNacimiento(request.getParameter("fec_nacimiento")); 
		interc.setPacId(request.getParameter("pac_id"));
		interc.setUsuarioCreacion(request.getParameter("usuario_creac"));
		interc.setFechaCreacion(request.getParameter("fecha_creac"));
		interc.setUsuarioModificacion(request.getParameter("usuario_modific"));
		interc.setFechaModificacion(request.getParameter("fecha_modific"));
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
					
				interDiag.setSecuencia(request.getParameter("secuencia"));
				interDiag.setCodPaciente(request.getParameter("cod_pac"));
				interDiag.setFecNacimiento(request.getParameter("fec_nacimiento")); 
				interDiag.setPacId(request.getParameter("pac_id"));
				
				interDiag.setCodInterconsulta(request.getParameter("cod_interconsulta"+i));
				interDiag.setDiagnostico(request.getParameter("diagnostico"+i));
				interDiag.setObservacion(request.getParameter("observacion"+i));
				interDiag.setCodigo(request.getParameter("codigo"+i));
					/*	
				cdo = new CommonDataObject();
				cdo.setTableName("TBL_SAL_DIAGNOSTICO_INTER_ESP"); 
							
				cdo.addColValue("SECUENCIA",request.getParameter("secuencia"));
				cdo.addColValue("COD_PACIENTE",request.getParameter("cod_pac"));
				cdo.addColValue("FEC_NACIMIENTO",request.getParameter("fec_nacimiento"));
				cdo.addColValue("PAC_ID",request.getParameter("pac_id"));
				
				cdo.addColValue("COD_INTERCONSULTA",request.getParameter("cod_interconsulta"+i));
				cdo.addColValue("DIAGNOSTICO",request.getParameter("diagnostico"+i));
				cdo.addColValue("OBSERVACION",request.getParameter("observacion"+i));
					
				cdo.addColValue("CODIGO",request.getParameter("codigo"+i));
				
				cdo.addColValue("key",request.getParameter("key"+i));*/
				key=request.getParameter("key"+i);
		
	if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				itemRemoved = key;  
			else
			{
			  try
				{ 
					al.add(interDiag);
					iInter.put(key,interDiag);
					interc.addInterconsultaDiagnostico (interDiag);
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
			
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=4&mode="+mode+"&interLastLineNo="+interLastLineNo+"&fec_nacimiento="+request.getParameter("fec_nacimiento")+"&secuencia="+request.getParameter("secuencia")+"&cod_pac="+request.getParameter("cod_pac")+"&pac_id="+request.getParameter("pac_id")+"&seccion="+request.getParameter("seccion")+"&cod_interconsulta="+request.getParameter("codigo_interconsulta")+"&nombreMedico="+request.getParameter("nombre_medico")+"&codMedico="+request.getParameter("cod_medico")+"&cod_especialidad="+request.getParameter("cod_especialidad"));
			
			return;
		}

	if(baction.equals("+"))//Agregar
		{
			//intCon.setNombreMedico(request.getParameter("nombre_medico"));
      //intCon.setMedico(request.getParameter("cod_medico"));
			InterconsultaDiagnostico interDiag = new InterconsultaDiagnostico();
			//cdo = new CommonDataObject();
			interDiag.setCodInterconsulta(request.getParameter("codigo_interconsulta"));
			interDiag.setCodigo("0");
			//cdo.addColValue("codigo","0");
			//cdo.addColValue("COD_INTERCONSULTA",request.getParameter("codigo_interconsulta"));	
			System.out.println("codigo interconsulta+++++++"+request.getParameter("codigo_interconsulta"));					
			interLastLineNo++;
			if (interLastLineNo < 10) key = "00" + interLastLineNo;
			else if (interLastLineNo < 100) key = "0" + interLastLineNo;
			else key = "" + interLastLineNo;
			//cdo.addColValue("key",key);

			try
			{
				iInter.put(key,interDiag);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change="+change+"&mode="+mode+"&interLastLineNo="+interLastLineNo+"&fec_nacimiento="+request.getParameter("fec_nacimiento")+"&secuencia="+request.getParameter("secuencia")+"&cod_pac="+request.getParameter("cod_pac")+"&pac_id="+request.getParameter("pac_id")+"&seccion="+request.getParameter("seccion")+"&cod_interconsulta="+request.getParameter("codigo_interconsulta")+"&nombreMedico="+request.getParameter("nombre_medico")+"&codMedico="+request.getParameter("cod_medico")+"&cod_especialidad="+request.getParameter("cod_especialidad"));
			return;
		}
	
	if (baction.equalsIgnoreCase("Guardar"))
	{	
		
	
	if (mode.equalsIgnoreCase("add"))
	 {
	 		cod_interconsulta="0";
			change = "";
	 		InterMgr.add(interc);
	 } 
	 else if (mode.equalsIgnoreCase("edit"))
	 {
	 	 InterMgr.update(interc);
	 }
		


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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&mode=edit&pac_id=<%=pac_id%>&secuencia=<%=secuencia%>&fec_nacimiento=<%=fec_nacimiento%>&cod_pac=<%=cod_pac%>&cod_interconsulta=<%=cod_interconsulta%>&codMedico=<%=codMedico%>&nombreMedico=<%=nombreMedico%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

		
	

