<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
boolean viewMode = false;

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("edit")) viewMode = true;

System.out.println("La hora de la base de datos actualmente es:"+CmnMgr.getCurrentDate("HH24:MI"));
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Turno a registrar no es válido. Por favor intente nuevamente!");

sql = "select a.codigo, a.descripcion, to_char(a.hora_entrada_desde, 'HH12:MI AM') as hora_entrada_desde, to_char(a.hora_entrada, 'HH12:MI AM') as hora_entrada, to_char(a.hora_entrada_hasta, 'HH12:MI AM') as hora_entrada_hasta, to_char(a.hora_rec_salida, 'HH12:MI AM') as hora_rec_salida, to_char(a.hora_rec_entrada, 'HH12:MI AM') as hora_rec_entrada, to_char(a.hora_salida_desde, 'HH12:MI AM') as hora_salida_desde, to_char(a.hora_salida, 'HH12:MI AM') as hora_salida, to_char(a.hora_salida_hasta, 'HH12:MI AM') as hora_salida_hasta, a.maxper_horas_extras, a.horas_diarias, nvl(a.verificar_comida,'N') as verificar_comida, a.horas_com, a.minutos_com, a.cant_min_extra, a.tipo_extra, decode(b.descripcion,null,'',b.descripcion) as tipo_extra_desc, nvl(a.turno_mixto,'N') as turno_mixto, nvl(a.tipo_turno,'D') as tipo_turno from tbl_pla_ct_turno a, tbl_pla_t_horas_ext b  where a.compania = "+session.getAttribute("_companyId")+" and a.tipo_extra = b.codigo(+) and a.codigo="+id;
		cdo = SQLMgr.getData(sql);
	}

%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Registro de turnos - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Registro de turnos - Edición - "+document.title;
<%}%>
function chkNullValues(){
	var x = 0;
	var msg='';
	if(document.form1.hora_entrada.value==''){
		msg += ', Hora de Entrada';
		x++;
	}if(document.form1.hora_entrada_desde.value==''){
		msg += ', Hora de Entrada Desde';
		x++;
	} 
	if(document.form1.hora_entrada_hasta.value==''){
		msg += ',  Hora de Entrada Hasta';
		x++;
	} 
	if(document.form1.hora_salida_desde.value==''){
		msg += ', Hora de Salida desde';
		x++;
	}
	if(document.form1.hora_salida.value==''){
		msg += ', Hora de Salida';
		x++;
	}
	if(document.form1.hora_salida_hasta.value==''){
		msg += ', Hora de Salida hasta';
		x++;
	}
	if(msg!='')alert('Seleccione valor en'+msg+'!');
	if(x>0)	return false;
	else return true;
}

function addExtra()
{
    abrir_ventana1('../common/search_horasextras.jsp?fp=horario_trab');
}

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSO HUMANOS - MANTENIMIENTO - REGISTRO DE TURNOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<tr>	
				<td colspan="6">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="6">&nbsp;</td>
			</tr>			
			<tr class="TextRow01" >
			 <td width="15%">&nbsp;C&oacute;digo</td>
			 <td width="15%">&nbsp;<%=id%></td>
			   <td width="20%">&nbsp;Descripci&oacute;n</td>
			 <td width="20%"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,viewMode,40,50)%></td>           
			 <td width="25%" colspan="2"></td>
			</tr>
			 
			 
			 <tr class="TextHeader">
				<td colspan="6" align="center">La descripción del turno debe hacerse de la siguiente manera:</td>
			</tr>
			
			
			<tr class="TextHeader">
				<td colspan="6" align="center">DE 09:00 AM A 12:00 PM  Y  DE  02:00 PM A 07:00 PM</td>
			</tr>
			 
			 
		<% if (mode.equalsIgnoreCase("edit"))
			{
		%>
		<tr class="TextRow01">
			<td>&nbsp;Entrada Desde</td>
			<td><%=fb.textBox("hora_entrada_desde",cdo.getColValue("hora_entrada_desde"),false,false,viewMode,8,8)%></td>
			<td>&nbsp;Entrada</td>
		 	<td><%=fb.textBox("hora_entrada",cdo.getColValue("hora_entrada"),false,false,viewMode,8,8)%></td>
		 	<td>&nbsp;Entrada Hasta</td>
		 	<td><%=fb.textBox("hora_entrada_hasta",cdo.getColValue("hora_entrada_hasta"),false,false,viewMode,8,8)%></td>
		</tr>	
		<tr class="TextRow01">
			<td>&nbsp;Marcar Comida</td>
			<td><%=fb.checkbox("verificar_comida","S",(cdo.getColValue("verificar_comida")!=null && cdo.getColValue("verificar_comida").equalsIgnoreCase("S")),false)%></td>
				 
			<td>&nbsp;Comida Entrada</td>
		<td><%=fb.textBox("hora_rec_entrada",cdo.getColValue("hora_rec_entrada"),false,false,viewMode,8,8)%></td>
		<td>&nbsp;Comida Salida</td>
		<td><%=fb.textBox("hora_rec_salida",cdo.getColValue("hora_rec_salida"),false,false,viewMode,8,8)%></td>
		</tr>
		<tr class="TextRow01">						
			<td>&nbsp;Salida Desde</td>
		<td><%=fb.textBox("hora_salida_desde",cdo.getColValue("hora_salida_desde"),false,false,viewMode,8,8)%></td>
			<td>&nbsp;Salida</td>
		<td><%=fb.textBox("hora_salida",cdo.getColValue("hora_salida"),false,false,viewMode,8,8)%></td>
			<td>&nbsp;Salida Hasta</td>	
			<td><%=fb.textBox("hora_salida_hasta",cdo.getColValue("hora_salida_hasta"),false,false,viewMode,8,8)%></td>
			 
			 <% } else {
				%>
			
			<tr class="TextRow01">
				<td>&nbsp;Entrada Desde</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="hora_entrada_desde"/>
					<jsp:param name="format" value="hh12:mi am" />
					<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_entrada_desde")==null)?"":cdo.getColValue("hora_entrada_desde")%>" />
					</jsp:include></td>
					
				<td>&nbsp;Entrada</td>						
				<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="hora_entrada"/>
					<jsp:param name="format" value="hh12:mi am" />
					<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_entrada")==null)?"":cdo.getColValue("hora_entrada")%>" />
					</jsp:include>	</td>
				<td>&nbsp;Entrada Hasta</td>						
				<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="hora_entrada_hasta"/>
					<jsp:param name="format" value="hh12:mi am" />
					<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_entrada_hasta")==null)?"":cdo.getColValue("hora_entrada_hasta")%>" />
					</jsp:include>	</td>
			</tr>
			<tr class="TextRow01">
			<td>&nbsp;Marcar Comida</td>
			<td><%=fb.checkbox("verificar_comida","S",(cdo.getColValue("verificar_comida")!=null && cdo.getColValue("verificar_comida").equalsIgnoreCase("S")),false)%></td>
				 
			<td>&nbsp;Comida Entrada</td>
			<td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="hora_rec_entrada"/>
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_rec_entrada")==null)?"":cdo.getColValue("hora_rec_entrada")%>" />
				</jsp:include></td>
			<td>&nbsp;Comida Salida</td>						
			<td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="hora_rec_salida"/>
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_rec_salida")==null)?"":cdo.getColValue("hora_rec_salida")%>" />
				</jsp:include></td>
			</tr>
			<tr class="TextRow01">						
			<td>&nbsp;Salida Desde</td>
			<td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="hora_salida_desde"/>
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_salida_desde")==null)?"":cdo.getColValue("hora_salida_desde")%>" />
				</jsp:include></td>
			<td>&nbsp;Salida</td>
			<td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="hora_salida"/>
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_salida")==null)?"":cdo.getColValue("hora_salida")%>" />
				</jsp:include></td>

			<td>&nbsp;Salida Hasta</td>						
			<td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="hora_salida_hasta"/>
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_salida_hasta")==null)?"":cdo.getColValue("hora_salida_hasta")%>" />
				</jsp:include></td>
			</tr>
				<%
				}
				%>	
				
			<tr class="TextRow01">
				<td colspan="6">&nbsp;</td>
			</tr>
			
			<tr class="TextHeader">
				<td colspan="6">&nbsp;HORAS</td>
			</tr>
				
			<tr class="TextRow01">
				<td>&nbsp;Horas Trabajadas</td>
				<td><%=fb.textBox("horas_diarias",cdo.getColValue("horas_diarias"),true,false,false,20,3)%></td>
				<td>&nbsp;Max Horas Extras</td>
				<td colspan="3"><%=fb.textBox("maxper_horas_extras",cdo.getColValue("maxper_horas_extras"),false,false,false,20,3)%></td>
			</tr>
			
			
			<tr class="TextRow01">
				<td colspan="6">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="6">&nbsp;RECARGO FIJO</td>
			</tr>
			
			<tr class="TextRow01" >
                <td>&nbsp;Horas de Recargos</td>
                <td><%=fb.textBox("cant_min_extra",cdo.getColValue("cant_min_extra"),false,false,viewMode,8,3)%></td>
							
                <td>&nbsp;Tipos de Horas Extras</td>
                <td colspan="3"><%=fb.intBox("tipo_extra",cdo.getColValue("tipo_extra"),false,false,true,5,2)%>
								<%=fb.textBox("tipo_extra_desc",cdo.getColValue("tipo_extra_desc"),false,false,true,35)%><%=fb.button("btnTipoExtra","...",true,false,null,null,"onClick=\"javascript:addExtra()\"")%></td>
            </tr>
            
            <tr class="TextRow01">
	    				<td colspan="6">&nbsp;</td>
	    			</tr>
	    			<tr class="TextHeader">
	    				<td colspan="6">&nbsp;TIPO DE TURNO PARA CALCULOS</td>
			</tr>
            
            <tr class="TextRow01" >
	                    <td>&nbsp;Tipo de Turno</td>
	                    <td><%=fb.select("tipo_turno","D=DIURNO,N=NOCTURNO,M=MIXTO",cdo.getColValue("tipo_turno"))%></td>
	    							
	                    <td colspan="2" class="TextRowOver">&nbsp;Si es 8va hora debes avisar soporte para habilitar ese turno en calculos de marcacion.</td>
	                    <td colspan="2"><%//=fb.select("turno_mixto","N=NO,S=SI",cdo.getColValue("turno_mixto"))%></td>
            </tr>
			
			<tr class="TextRow02">
			  	<td colspan="6" align="right"> <%=fb.submit("save","Guardar",true,false)%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	
			
			<tr>
				<td colspan="6">&nbsp;</td>
			</tr>
				 <%
				     fb.appendJsValidation("\n\tif (!chkNullValues()) error++;\n");
				 %>
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
  cdo = new CommonDataObject();
  cdo.setTableName("tbl_pla_ct_turno");
  cdo.addColValue("descripcion",request.getParameter("descripcion")); 
  cdo.addColValue("hora_entrada_desde",request.getParameter("hora_entrada_desde"));
  cdo.addColValue("hora_entrada",request.getParameter("hora_entrada"));
  cdo.addColValue("hora_entrada_hasta",request.getParameter("hora_entrada_hasta")); 
  if(request.getParameter("verificar_comida")==null) cdo.addColValue("verificar_comida","N");
  else cdo.addColValue("verificar_comida",request.getParameter("verificar_comida"));
  cdo.addColValue("hora_rec_entrada",request.getParameter("hora_rec_entrada")); 
  cdo.addColValue("hora_rec_salida",request.getParameter("hora_rec_salida")); 
  cdo.addColValue("hora_salida_desde",request.getParameter("hora_salida_desde"));
  cdo.addColValue("hora_salida",request.getParameter("hora_salida"));
  cdo.addColValue("hora_salida_hasta",request.getParameter("hora_salida_hasta"));
  cdo.addColValue("maxper_horas_extras",request.getParameter("maxper_horas_extras"));
  cdo.addColValue("horas_diarias",request.getParameter("horas_diarias"));
   cdo.addColValue("cant_min_extra",request.getParameter("cant_min_extra"));
  cdo.addColValue("tipo_extra",request.getParameter("tipo_extra"));
  if(request.getParameter("turno_mixto")==null) cdo.addColValue("turno_mixto","N");
  else cdo.addColValue("turno_mixto",request.getParameter("turno_mixto"));
  if(request.getParameter("tipo_turno")==null) cdo.addColValue("tipo_turno","D");
  else cdo.addColValue("tipo_turno",request.getParameter("tipo_turno"));
  
  if (mode.equalsIgnoreCase("add"))
  {

   cdo.setAutoIncCol("codigo");
   cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
   cdo.addColValue("fecha_creacion","sysdate");
   cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
   cdo.addColValue("fecha_modificacion","sysdate");
   cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
   SQLMgr.insert(cdo);
  }
  else
  {
   cdo.setWhereClause("codigo="+request.getParameter("id")+"and compania="+(String) session.getAttribute("_companyId"));
   cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
   cdo.addColValue("fecha_modificacion","sysdate");
   SQLMgr.update(cdo);
  }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/turnos_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/turnos_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/turnos_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
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