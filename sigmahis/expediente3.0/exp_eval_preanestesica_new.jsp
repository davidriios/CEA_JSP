<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.expediente.EvalPreAnestesica" %>
<%@ page import="issi.expediente.RespuestaEvalPreAnestesica" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="ROMgr" scope="page" class="issi.expediente.EvalPreAnestesicaMgr" />
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject rev = new CommonDataObject();

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

String code = request.getParameter("code");

if (fecha == null) fecha = cDate.substring(0,10);
if (hora == null)  hora = cDate.substring(11);
if (code == null)  code = "0";

if (request.getMethod().equalsIgnoreCase("GET")) {

	sql="select c.codigo_eval as codEval, to_char(c.fecha,'dd/mm/yyyy') as fecha, to_char(c.fecha,'hh12:mi am') as hora, c.cod_anestesiologo as codAnestesiologo, nvl(c.nombre_anestesiologo, (SELECT a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre) ||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada)) FROM TBL_ADM_MEDICO a WHERE a.codigo = c.cod_anestesiologo)) as nombre_anestesiologo, c.procedimiento as procedimiento, c.cirujano as cirujano from tbl_sal_eval_preanestesica c where c.pac_id="+pacId+" and c.admision="+noAdmision+" order by c.fecha desc";
	al2 = SQLMgr.getDataList(sql);
	
	if(!code.trim().equals("0")) {
		sql=" select c.codigo_eval as codEval, to_char(c.fecha,'dd/mm/yyyy hh12:mi am') as fecha, c.usuario_creacion as usuarioCreacion, to_char(c.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, c.cod_anestesiologo as codAnestesiologo, (SELECT a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre) ||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada)) FROM TBL_ADM_MEDICO a WHERE a.codigo = c.cod_anestesiologo) nombre_anestesiologo, c.procedimiento, c.cirujano, nvl((SELECT a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre) ||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada)) FROM TBL_ADM_MEDICO a WHERE a.codigo = c.cirujano),c.cirujano) as nombre_cirujano, nvl((select decode(observacion , null , descripcion,observacion) as descripcion FROM tbl_cds_procedimiento where codigo = c.procedimiento), c.procedimiento) as nombre_procedimiento from tbl_sal_eval_preanestesica c where c.pac_id="+pacId+" and c.admision="+noAdmision+" and c.codigo_eval= "+code+" order by 2 desc";

		rev = SQLMgr.getData(sql);
	} 
	else if(code.trim().equals("0") || rev == null) {
		rev = new CommonDataObject();
		rev.addColValue("fecha", cDate);
		rev.addColValue("codEval", code);
		rev.addColValue("fechaCreacion", cDateTime);
		
		if (UserDet.getRefType().equalsIgnoreCase("M")){			
			rev.addColValue("codAnestesiologo", UserDet.getRefCode());
			rev.addColValue("nombre_anestesiologo", UserDet.getName());
		}		
		rev.addColValue("usuarioCreacion", (String) session.getAttribute("_userName"));
		if(!viewMode) modeSec = "add";		
	}

	sql = "select a.id as pregunta, a.descripcion as descripcion, a.evaluable as evaluable, a.comentable as comentable, b.cod_respuesta as codRespuesta, b.codigo_eval as codEvaluacion, nvl(b.respuesta,'N') as respuesta, to_char(b.fecha_eval,'dd/mm/yyyy hh12:mi am') as fechaEvaluacion, b.observacion as observacion, a.orden from tbl_sal_parametro a, tbl_sal_resp_ev_preanestesica b where a.id = b.pregunta(+) and a.status = 'A' and a.tipo = 'EPA' and b.pac_id(+)="+pacId+" and b.secuencia(+)="+noAdmision+" and to_date(to_char(b.fecha_eval(+),'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') = to_date('"+fecha+" "+hora+"','dd/mm/yyyy hh12:mi am') order by a.orden asc  ";
	
	al = sbb.getBeanList(ConMgr.getConnection(),sql,RespuestaEvalPreAnestesica.class);		
  
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
document.title = 'Revisión PreAnestésica - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){checkViewMode();}
function isChecked(k,trueFalse){}
function setEvaluacion(k){
	var fecha = eval('document.form0.fecha'+k).value;
	var hora = eval('document.form0.hora'+k).value;
	var codEval = eval('document.form0.cod_eval'+k).value;
	var modeSec = (fecha=='<%=cDateTime.substring(0,10)%>')?'edit':'view';
	
	window.location= '../expediente3.0/exp_eval_preanestesica_new.jsp?modeSec='+modeSec+'&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha+'&hora='+hora+'&code='+codEval+'&desc=<%=desc%>';
}
function add(fecha,hora){window.location= '../expediente3.0/exp_eval_preanestesica_new.jsp?seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha+'&hora='+hora+'&desc=<%=desc%>';}
function getAnestesiologo(){abrir_ventana1('../common/search_medico.jsp?fp=EPA');}
function imprimirExp(all){
	if(!all) abrir_ventana1('../expediente3.0/print_eval_preanestesica.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&code=<%=code%>');
	else abrir_ventana1('../expediente3.0/print_eval_preanestesica.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&code=');
}

function verHistorial() {
  $("#hist_container").toggle();
}

function procedimientoList(){
	abrir_ventana1('../expediente/listado_procedimiento.jsp?fp=eval_preanestesia');
}

function showMedicoList(option){
	if (option == 1) abrir_ventana1('../common/search_medico.jsp?fp=EPA&fg=CIR');
	else if (option == 2) abrir_ventana1('../common/search_medico.jsp?fp=EPA&fg=anestesiologo');
}
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">

<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("codEval", rev.getColValue("codEval"))%>  
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("usuarioCreacion", rev.getColValue("usuarioCreacion"))%>
<%=fb.hidden("fechaCreacion", rev.getColValue("fechaCreacion"))%>					
<%=fb.hidden("desc",desc)%>
	<div class="headerform">

		<table cellspacing="0" class="table pull-right table-striped table-custom-2">
			<tr>
				<td class="controls form-inline">
					<%if(!mode.trim().equals("view")){%>
					<%=fb.button("btnAdd","Agregar Evaluación",true,false,"btn btn-inverse btn-sm|fa fa-plus fa-printico",null,"onclick=\"add('"+cDate.substring(0,10)+"','"+cDate.substring(11)+"')\"")%>

					 <%} if(al2.size()>0 ){%> 
					<%=fb.button("btnPrintAll","Imprimir Todo",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimirExp(1)\"")%>
					 <%}if(!code.trim().equals("0")){%>
					<%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimirExp()\"")%>
					 <%}%>
					 
					 <%if(al2.size() > 0){%>
					<%=fb.button("btnHistory","Historial",false,false,"btn btn-inverse btn-sm|fa fa-eye fa-printico",null,"onClick=\"javascript:verHistorial()\"")%>
					 <%}%>
				</td>
			</tr>
		</table> 

		<div class="table-wrapper" id="hist_container" style="display:none">  
			<table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<thead>                   
					<tr><th colspan="3" class="bg-headtabla"><cellbytelabel>Listado de Evaluaciones</cellbytelabel></th></tr>                    
					<tr class="bg-headtabla2">
						<th><cellbytelabel>Fecha</cellbytelabel></th>
						<th><cellbytelabel>Hora</cellbytelabel></th>
						<th><cellbytelabel>Anestesi&oacute;logo</cellbytelabel></th>
					</tr>
				</thead> 
				<tbody>
				<%for (int i=1; i<=al2.size(); i++){
					CommonDataObject cdo1 = (CommonDataObject) al2.get(i-1);
				%>	
		   
					<%=fb.hidden("fecha"+i,cdo1.getColValue("fecha"))%>
					<%=fb.hidden("hora"+i,cdo1.getColValue("hora"))%>
					<%=fb.hidden("cod_eval"+i,cdo1.getColValue("codEval"))%>
					<tr onClick="javascript:setEvaluacion(<%=i%>)" style="text-decoration:none; cursor:pointer">
						<td><%=cdo1.getColValue("fecha")%></td>
						<td><%=cdo1.getColValue("hora")%></td>	
						<td><%=cdo1.getColValue("nombre_anestesiologo")%></td>	
					</tr>
				<%}%>
				</tbody>
			</table>
		</div>           
	</div> 

	<table cellspacing="0" class="table table-small-font table-bordered table-striped"> 

		<tr>
			<td colspan="2" class="controls form-inline"><cellbytelabel id="5">Fecha</cellbytelabel>:&nbsp;
				<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=rev.getColValue("fecha").substring(0,10)%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include>
			</td>
			<td class="controls form-inline">
				<cellbytelabel id="6">Hora</cellbytelabel>  &nbsp;&nbsp;&nbsp;&nbsp;						
				<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="hora" />
				<jsp:param name="valueOfTBox1" value="<%=rev.getColValue("fecha").substring(11)%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include>
			</td>
		</tr>
		
		<tr class="TextRow01">
			<td colspan="3" class="controls form-inline">
				<cellbytelabel id="7">M&eacute;dico Cirujano</cellbytelabel>:
				<%=fb.hidden("cirujano", rev.getColValue("cirujano"))%>
				<%=fb.textBox("nombre_cirujano", rev.getColValue("nombre_cirujano"),true,false,true,100,"form-control input-sm","","")%>
				<%=fb.button("btn_cirujano","...",true,viewMode,"btn btn-sm btn-inverse",null,"onClick=\"javascript:showMedicoList(1)\"","Seleccionar Cirujano")%>
			</td>
		</tr>
		
		<tr class="TextRow01">
			<td colspan="3" class="controls form-inline">
				<cellbytelabel id="7">Anestesi&oacute;logo</cellbytelabel>:&nbsp;&nbsp;&nbsp;&nbsp;
				<%=fb.hidden("codAnestesiologo", rev.getColValue("codAnestesiologo"))%>
				<%=fb.textBox("nombre_anestesiologo", rev.getColValue("nombre_anestesiologo"),true,false,true,100,"form-control input-sm","","")%>
				<%=fb.button("btn_anestesiologo","...",true,viewMode,"btn btn-sm btn-inverse",null,"onClick=\"javascript:showMedicoList(2)\"","Seleccionar Anestesiologo")%>
			</td>
		</tr>

		<tr>
			<td colspan="3" class="controls form-inline">
				<cellbytelabel id="7">Procedimiento</cellbytelabel>:&nbsp;&nbsp;&nbsp;
				<%=fb.hidden("procedimiento", rev.getColValue("procedimiento"))%>
				<%=fb.textBox("nombre_procedimiento", rev.getColValue("nombre_procedimiento"),true,false,true,100,"form-control input-sm","","")%>
				<%=fb.button("btn_procedimiento","...",true,viewMode,"btn btn-sm btn-inverse",null,"onClick=\"javascript:procedimientoList()\"","Seleccionar Procedimiento")%>
			</td> 			
		</tr> 
		
		<tr class="bg-headtabla2" align="center">	
			<td width="45%"><cellbytelabel id="10">Antecedentes</cellbytelabel></td>  
			<td width="10%"><cellbytelabel id="11">S&iacute;</cellbytelabel>&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel id="12">No</cellbytelabel></td>
			<td width="40%"><cellbytelabel id="13">Observaci&oacute;n</cellbytelabel></td>
		</tr>
		
		<%for (int i=0; i<al.size(); i++){
			RespuestaEvalPreAnestesica rresp = (RespuestaEvalPreAnestesica) al.get(i);
		%>
			<%=fb.hidden("codigo"+i,rresp.getCodRespuesta())%>	  						
			<%=fb.hidden("codEval"+i,rresp.getCodEvaluacion())%>	  						
			<%=fb.hidden("pregunta"+i,rresp.getPregunta())%>
			<%=fb.hidden("evaluable"+i,rresp.getEvaluable())%>	
			
			<tr>
				<td><%=rresp.getDescripcion()%></td>
				
				<td align="center">
				  <% if (rresp.getEvaluable().trim().equals("S")) {%>
					<%=fb.radio("respuesta"+i,"S",((rresp.getRespuesta()!=null && rresp.getRespuesta().equalsIgnoreCase("S"))?true:false),viewMode,false)%>S&iacute;&nbsp;&nbsp;&nbsp;          
					<%=fb.radio("respuesta"+i,"N",((rresp.getRespuesta()!=null && rresp.getRespuesta().equalsIgnoreCase("N"))?true:false),viewMode,false)%>No
				  <%}%>
				</td>					
		 
				<td>
					<%=(rresp.getComentable().trim().equals("S"))?fb.textarea("observacion"+i,rresp.getObservacion(),false,false,viewMode,22,0,2000,"form-control input-sm","width='100%'",null):""%>
				</td>
			</tr>
					
		<%}%>

	</table>

	<div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
			<tr>
				<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null)%>
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
		EvalPreAnestesica revi = new EvalPreAnestesica();
	 //TBL_SAL_EVAL_PREANESTESICA

	 revi.setCodPaciente(request.getParameter("codPac"));
 	 revi.setCodEval(request.getParameter("codEval"));
	 //revi.setFecNacimiento(request.getParameter("dob"));
	 revi.setPacId(request.getParameter("pacId"));
	 revi.setSecuencia(request.getParameter("noAdmision"));
	 revi.setFecha(request.getParameter("fecha")+" "+request.getParameter("hora"));
	 revi.setProcedimiento(request.getParameter("procedimiento"));	
 	 revi.setCirujano(request.getParameter("cirujano"));	
	 revi.setCodAnestesiologo(request.getParameter("codAnestesiologo"));	
	 revi.setNombreAnestesiologo(request.getParameter("nombre_anestesiologo"));	
	 revi.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
	 revi.setFechaCreacion(request.getParameter("fechaCreacion"));
	 
	if (modeSec.equalsIgnoreCase("edit")){
		revi.setUsuarioModif((String) session.getAttribute("_userName"));    
		revi.setFechaModif(cDateTime); 
	}

	for (int i=0; i<size; i++)
	{				
		/*if((request.getParameter("evaluable"+i).trim().equals("S") && request.getParameter("respuesta"+i)!= null) 
  		|| (request.getParameter("evaluable"+i).trim().equals("S") && request.getParameter("respuesta"+i)== null  
		&& !request.getParameter("observacion"+i).trim().equals(""))
		|| (request.getParameter("evaluable"+i).trim().equals("N") && !request.getParameter("observacion"+i).trim().equals("")))
		*/
			{
				RespuestaEvalPreAnestesica resp = new RespuestaEvalPreAnestesica();
				//System.out.println("respuesta = "+request.getParameter("respuesta"+i));
            //TBL_SAL_RESP_EV_PREANESTESICA

			resp.setCodPaciente(request.getParameter("codPac"));						
            resp.setCodRespuesta(request.getParameter("codRespuesta"));
			resp.setCodEvaluacion(request.getParameter("codEval"));
			resp.setPacId(request.getParameter("pacId"));
			resp.setSecuencia(request.getParameter("noAdmision"));
			resp.setFechaEval(request.getParameter("fecha")+" "+request.getParameter("hora"));
			resp.setPregunta(request.getParameter("pregunta"+i));
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
					code =	ROMgr.getPkColValue("codEval");
				}
				else if (modeSec.equalsIgnoreCase("edit"))
				{						
						ROMgr.update(revi);
						code = request.getParameter("codEval");  						
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha=<%=fecha%>&hora=<%=hora%>&code=<%=code%>&desc=<%=desc%>'; 
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
