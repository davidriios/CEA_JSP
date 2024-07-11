<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.expediente.EvalPreAnestesica" %>
<%@ page import="issi.expediente.RespuestaEvalPreAnestesica" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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

CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
EvalPreAnestesica rev = new EvalPreAnestesica();

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

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
sql="select a.codigo_eval as codEval, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.fecha,'hh12:mi am') as hora, a.cod_anestesiologo as codAnestesiologo, a.nombre_anestesiologo as nombreAnestesiologo, a.procedimiento as procedimiento, a.cirujano as cirujano from tbl_sal_eval_preanestesica a where pac_id="+pacId+" and admision="+noAdmision+" order by a.fecha desc";
al2 = SQLMgr.getDataList(sql);
if(!code.trim().equals("0"))
{

sql=" select codigo_eval as codEval, to_char(fecha,'dd/mm/yyyy hh12:mi am') as fecha, usuario_creacion as usuarioCreacion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, cod_anestesiologo as codAnestesiologo, nombre_anestesiologo as nombreAnestesiologo, procedimiento as procedimiento, cirujano as cirujano from tbl_sal_eval_preanestesica where pac_id="+pacId+" and admision="+noAdmision+" and codigo_eval= "+code+" order by 2 desc";

rev = (EvalPreAnestesica) sbb.getSingleRowBean(ConMgr.getConnection(), sql, EvalPreAnestesica.class);

}else if(code.trim().equals("0") || cdo == null)
{
     rev = new EvalPreAnestesica();
		rev.setFecha(cDate);
		rev.setCodEval(code);	
		rev.setFechaCreacion(cDateTime);
		if (UserDet.getRefType().equalsIgnoreCase("M")) // sólo si el usuario es médico..
		{
		 rev.setCodAnestesiologo(""+UserDet.getRefCode());
		 rev.setNombreAnestesiologo(""+UserDet.getName());
		}		
		rev.setUsuarioCreacion((String) session.getAttribute("_userName"));
		if(!viewMode) modeSec = "add";		
}

sql = "select a.id as pregunta, a.descripcion as descripcion, a.evaluable as evaluable, a.comentable as comentable, b.cod_respuesta as codRespuesta, b.codigo_eval as codEval, nvl(b.respuesta,'N') as respuesta, to_char(b.fecha_eval,'dd/mm/yyyy hh12:mi am') as fechaEvaluacion, b.observacion as observacion, a.orden from tbl_sal_parametro a, tbl_sal_resp_ev_preanestesica b where a.id = b.pregunta(+) and a.status = 'A' and a.tipo = 'EPA' and b.pac_id(+)="+pacId+" and b.secuencia(+)="+noAdmision+" and to_date(to_char(b.fecha_eval(+),'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') = to_date('"+fecha+" "+hora+"','dd/mm/yyyy hh12:mi am') order by a.orden asc  ";
al = sbb.getBeanList(ConMgr.getConnection(),sql,RespuestaEvalPreAnestesica.class);		
  
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Revisión PreAnestésica - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){newHeight();checkViewMode();}
function isChecked(k,trueFalse){}
function setEvaluacion(k){var fecha = eval('document.listado.fecha'+k).value ;var hora = eval('document.listado.hora'+k).value;var codEval = eval('document.listado.codEval'+k).value ;var mode = (fecha=='<%=cDateTime.substring(0,10)%>')?'edit':'view';window.location= '../expediente/exp_eval_preanestesica_new.jsp?modeSec='+mode+'&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha+'&hora='+hora+'&code='+codEval+'&desc=<%=desc%>';}
function add(fecha,hora){window.location= '../expediente/exp_eval_preanestesica_new.jsp?seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha+'&hora='+hora+'&desc=<%=desc%>';}
function getAnestesiologo(){abrir_ventana1('../common/search_medico.jsp?fp=EPA');}
function imprimirExp(){abrir_ventana1('../expediente/print_eval_preanestesica.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&code=<%=code%>');}
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
	  <td align="right">&nbsp;  
	    </td>	  
	</tr>	

	<tr class="TextRow01">
	  <td>
		<div id="proc" width="100%" class="exp h100">
		<div id="proced" width="98%" class="child">

		<table width="100%" cellpadding="1" cellspacing="0">
			<%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		    <%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("desc",desc)%>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel></td>
				<td align="right"><%if(!mode.trim().equals("view")){%>
					<a href="javascript:add('<%=cDate.substring(0,10)%>','<%=cDate.substring(11)%>')" class="Link00">[ <cellbytelabel id="2">Agregar Evaluaci&oacute;n</cellbytelabel> ]</a><%} if(al2.size()>0 ){%> 
					<a href="javascript:imprimirExp()" class="Link00">[<cellbytelabel id="3">Imprimir Todo</cellbytelabel>]</a>&nbsp;
					<%}if(!code.trim().equals("0")){%>
					<a href="javascript:imprimirExp()" class="Link00">[<cellbytelabel id="4">Imprimir</cellbytelabel>]</a>&nbsp;
					<%}%>
				</td>
			</tr>

			<tr class="TextHeader">
				<td width="20%"><cellbytelabel id="5">Fecha</cellbytelabel></td>
				<td width="20%"><cellbytelabel id="6">Hora</cellbytelabel></td>
				<td width="60" colspan="2"><cellbytelabel id="7">Anestesi&oacute;logo</cellbytelabel></td>  							
			</tr>						
							
<%


for (int i=1; i<=al2.size(); i++)
{
	CommonDataObject cdo1 = (CommonDataObject) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";%>
       
		<%=fb.hidden("fecha"+i,cdo1.getColValue("fecha"))%>
		<%=fb.hidden("hora"+i,cdo1.getColValue("hora"))%>
		<%=fb.hidden("codEval"+i,cdo1.getColValue("codEval"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEvaluacion(<%=i%>)" style="text-decoration:none; cursor:pointer">
				<td><%=cdo1.getColValue("fecha")%></td>
				<td><%=cdo1.getColValue("hora")%></td>	
				<td><%=cdo1.getColValue("nombreAnestesiologo")%></td>	
				<td>&nbsp;</td>			
		</tr>
<%
}%>

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
				<%=fb.hidden("codEval",rev.getCodEval())%>  
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("size",""+al.size())%>
				<%=fb.hidden("usuarioCreacion",rev.getUsuarioCreacion())%>
				<%=fb.hidden("fechaCreacion",rev.getFechaCreacion())%>					
	            <%=fb.hidden("desc",desc)%>
				<tr>
					<td colspan="4">
						<table width="100%" border="0" cellpadding="0" cellspacing="0" class="TextRow01">
									<tr>
										<td width="44%" ><cellbytelabel id="5">Fecha</cellbytelabel>:&nbsp;
										<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="nameOfTBox1" value="fecha" />
										<jsp:param name="valueOfTBox1" value="<%=rev.getFecha().substring(0,10)%>" />
										<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
										</jsp:include>										</td>
										<td width="50%">
										<cellbytelabel id="6">Hora</cellbytelabel>  &nbsp;&nbsp;&nbsp;&nbsp;						
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
				<td width="10%"><cellbytelabel id="7">Anestesi&oacute;logo</cellbytelabel></td>
                  <td width="90%">
				<%=fb.hidden("codAnestesiologo",""+rev.getCodAnestesiologo()/*""+UserDet.getRefCode()*/)%>
				<%//=fb.textBox("nombreAnestesiologo",""+UserDet.getName(),true,false,viewMode,55)%>
				<%=fb.textBox("nombreAnestesiologo",""+rev.getNombreAnestesiologo()/*""+UserDet.getName()*/,true,false,true,55,"Text10","","")%>
				<%=fb.button("anestesiologo","...",true,viewMode,null,null,"onClick=\"javascript:getAnestesiologo()\"","seleccionar Medico")%></td>     
				</tr>                                   
									
								<tr class="TextRow01">
								  <td width="10%"><cellbytelabel id="8">Procedimiento</cellbytelabel></td>
								<td width="90%"><%=fb.textBox("procedimiento",rev.getProcedimiento(),true,false,viewMode,55)%></td>
								</tr>
								<tr class="TextRow01">
								  <td width="10%"><cellbytelabel id="9">M&eacute;dico Cirujano</cellbytelabel></td>
								 <td width="90%"><%=fb.textBox("cirujano",rev.getCirujano(),true,false,viewMode,55)%>
								  </td>
								</tr>									
								</table></td>
							</tr> 
							
			<tr>
				<td width="100%" class="TableLeftBorder TableRightBorder">
		
		<div id="det" width="100%" class="exp h400">
		<div id="seccionDet" width="100%" class="child">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">

		<tr align="center" class="TextHeader">
								<td width="45%"><cellbytelabel id="10">Antecedentes</cellbytelabel></td>  
								<td width="10%"><cellbytelabel id="11">S&iacute;</cellbytelabel>&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel id="12">No</cellbytelabel></td>
								<!--td width="10%">No</td-->
								<td width="40%"><cellbytelabel id="13">Observaci&oacute;n</cellbytelabel></td>
							</tr>
<%
for (int i=0; i<al.size(); i++)
{
		RespuestaEvalPreAnestesica rresp = (RespuestaEvalPreAnestesica) al.get(i);
		String color = "TextRow02";
		//System.out.println("codePregnta = "+rresp.getPregunta());
		if (i % 2 == 0) color = "TextRow01";		
	%>
			<%=fb.hidden("codigo"+i,rresp.getCodRespuesta())%>	  						
			<%=fb.hidden("codEval"+i,rresp.getCodEvaluacion())%>	  						
			<%=fb.hidden("pregunta"+i,rresp.getPregunta())%>
			<%=fb.hidden("evaluable"+i,rresp.getEvaluable())%>	
	<tr class="<%=color%>">
		<td><%=rresp.getDescripcion()%></td>
			
<td align="center">
  <% if (rresp.getEvaluable().trim().equals("S")) {%>
<%=fb.radio("respuesta"+i,"S",((rresp.getRespuesta()!=null && rresp.getRespuesta().equalsIgnoreCase("S"))?true:false),viewMode,false)%>Sí             
<%=fb.radio("respuesta"+i,"N",((rresp.getRespuesta()!=null && rresp.getRespuesta().equalsIgnoreCase("N"))?true:false),viewMode,false)%>No
  <%}%>
</td>					
	 
<td><%=(rresp.getComentable().trim().equals("S"))?fb.textarea("observacion"+i,rresp.getObservacion(),false,false,viewMode,22,2,2000,null,"width='100%'",null):""%></td>
			</tr>
				
<%
}   
%>

</table>
</div>
</div>
</td>
</tr>
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
	 revi.setNombreAnestesiologo(request.getParameter("nombreAnestesiologo"));	
	 revi.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
	 revi.setFechaCreacion(request.getParameter("fechaCreacion"));
	 revi.setUsuarioModif((String) session.getAttribute("_userName"));    
	 revi.setFechaModif(cDateTime); 

	
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
