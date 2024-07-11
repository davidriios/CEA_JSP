<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr"       scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr"       scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet"      scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr"       scope="page"    class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr"       scope="page"    class="issi.admin.SQLMgr" />
<jsp:useBean id="fb"           scope="page"    class="issi.admin.FormBean" />
<%
/**
================================================================================
800059	AGREGAR BECARIO
800060	MODIFICAR BECARIO
================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800059") || SecMgr.checkAccess(session.getId(),"800060"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject emple = new CommonDataObject();
ArrayList al = new ArrayList();
String sql="";
String mode = request.getParameter("mode");
String prov = request.getParameter("prov");
String sig = request.getParameter("sig");
String tom = request.getParameter("tom");
String asi = request.getParameter("asi");
String tab = request.getParameter("tab");
String id= request.getParameter("id");
String key = "";
String change = request.getParameter("change");
String code =request.getParameter("code");
if(tab == null)  tab = "0";
if(mode == null) mode ="add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id="0";
		prov = "0";
		sig = "00";
		tom = "0";
		asi = "0";
		emple.addColValue("ingreso",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		emple.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		emple.addColValue("final","");
		emple.addColValue("contrato","");
		emple.addColValue("egreso",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		emple.addColValue("puestoA","");
		emple.addColValue("aumento","");
		emple.addColValue("incapacidad","");
		emple.addColValue("sigla","00");
	}
	else
	{
	if (prov == null) throw new Exception("La Provincia no es válido. Por favor intente nuevamente!");
	if (sig == null) throw new Exception("La Sigla no es válido. Por favor intente nuevamente!");
	if (tom == null) throw new Exception("El Tomo no es válido. Por favor intente nuevamente!");
	if (asi == null) throw new Exception("El Asiento no es válido. Por favor intente nuevamente!");
	
	code="0";
	sql="Select DISTINCT a.provincia|| '-' ||a.sigla|| '-' ||a.tomo|| '-' ||a.asiento as cedula,  a.provincia, a.sigla, a.tomo, a.asiento, a.cod_compania as compania, a.nombre, a.apellido, nvl(a.num_ssocial, ' ') as numSsocial, a.cod_beca as codBeca, to_char(a.fecha_nac,'dd/mm/yyyy') as fecha, a.sexo, a.direccion, a.telefono, a.estado, a.educacion, a.turno, a.anio_cursa as anioCursa, a.carrera, a.centro_edu as centro, a.telefono_centro as telefonoCentro, a.duracion, a.emp_id_aso as empId, to_char(a.fecha_ini_beca,'dd/mm/yyyy') as ingreso, to_char(a.fecha_fin_beca, 'dd/mm/yyyy') as egreso, a.tipo_becario as tipoBecario, a.provincia_aso as provinciaAso, a.sigla_aso as siglaAso, tomo_aso as tomoAso, a.asiento as asientoAso, nombre_aso as nombreAso, a.apellido_aso as apellidoAso, a.observacion, a.cheque_beneficiario as beneDesc, a.promedio, a.cheque_beneficiario_codigo as chequeBen from tbl_pla_becario a where a.cod_compania="+(String) session.getAttribute("_companyId")+" and  a.provincia="+prov+" and a.sigla='"+sig+"' and a.tomo="+tom+" and a.asiento="+asi;

		emple = SQLMgr.getData(sql);
	
			
	}//End Edit
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript" type="text/javascript">
<%if (mode.equalsIgnoreCase("add"))
{%>
document.title="Expediente Becarios- Agregar - "+document.title;
<%}
else if (mode.equalsIgnoreCase("edit")){%>
document.title="Expediente Becarios - Edición - "+document.title;
<%
}
%>
function addPert()
{
 var tipo="";
  tipo = (eval('document.form0.tipoBecario').value); 
  
  if (tipo!="P" & tipo!="O") 
    {
	 abrir_ventana1('../common/search_empleado.jsp?fp=becario');
    
  	}
	else if (tipo!="E" & tipo!="O")
	{
    abrir_ventana1('../common/search_parentesco.jsp?fp=pariente');
     }
 }

function addOtro()
{

   abrir_ventana1('../common/search_pago_otro.jsp?fp=becario');
}


</script>
</head>
<!--onLoad="javascript:doAction()"-->
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="BECARIOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
        <tr>
           <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <tr>
          <td>
<!--           
 <div id="dhtmlgoodies_tabView1">
 <div class="dhtmlgoodies_aTab">-->
<table width="100%" align="center" cellpadding="0" cellspacing="1">
<!-- =============   F O R M   S T A R T   H E R E   ================= -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%> 
	<%=fb.hidden("tab","0")%> 
	<%=fb.hidden("mode",mode)%> 
	<%=fb.hidden("prov",prov)%> 
	<%=fb.hidden("sig",sig)%> 
	<%=fb.hidden("tom",tom)%> 
	<%=fb.hidden("asi",asi)%> 
	<%=fb.hidden("id",id)%>
	<%=fb.hidden("baction","")%> 
	<%=fb.hidden("code",code)%>
		<tr>
			<td>&nbsp;</td>
		</tr>
		 <tr>
           <td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
		   	<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
				   <td width="95%">&nbsp;Becarios<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Generales del Becario </td>
				   <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
				</tr>
        	</table>
		   </td>
         </tr>
         <tr id="panel0">
            <td>
				<table width="100%" cellpadding="1" cellspacing="1">					
					<tr class="TextRow01" >
						<td width="18%">&nbsp;Tipo Becario</td>
					  <td width="32%"> <%=fb.select("tipoBecario","E=EMPLEADO, P=PARIENTE, O=OTRO",emple.getColValue("tipoBecario"))%></td>
						<td width="20%">&nbsp;Cédula</td>
					  <td width="30%"><%=fb.hidden("empId",emple.getColValue("empId"))%><%=fb.intBox("provincia",emple.getColValue("provincia"),true,mode.equals("edit"),false,5,2)%><%=fb.textBox("sigla",emple.getColValue("sigla"),true,mode.equals("edit"),false,5,2)%><%=fb.intBox("tomo",emple.getColValue("tomo"),true,mode.equals("edit"),false,5,4)%> <%=fb.intBox("asiento",emple.getColValue("asiento"),true,mode.equals("edit"),false,5,5)%><%=fb.button("btnpert","...",true,false,null,null,"onClick=\"javascript:addPert()\"")%></td>
            		</tr>					
					<tr class="TextRow01" >
						<td width="18%">&nbsp;Nombre Becario </td>
						<td width="32%" ><%=fb.textBox("nombre",emple.getColValue("nombre"),true,false,false,18,20)%><%=fb.textBox("apellido",emple.getColValue("apellido"),true,false,false,18,20)%></td>
						<td>&nbsp;Estado</td>
						<td><%=fb.select("estado","A=ACTIVO, N=NUEVO, S=SUSPENDIDO, E=ELIMINADO",emple.getColValue("estado"))%></td>
					</tr>
					<tr class="TextRow01">
						<td>&nbsp;Fecha Nacimiento</td>
						<td><jsp:include page="../common/calendar.jsp" flush="true">
						  <jsp:param name="noOfDateTBox" value="1" />
						  <jsp:param name="nameOfTBox1" value="fecha" />
						   <jsp:param name="valueOfTBox1" value="<%=emple.getColValue("fecha")%>" />
						  </jsp:include> </td>
						<td>&nbsp;No. S.S.</td>
						<td><%=fb.textBox("numSsocial", emple.getColValue("numSsocial"),false,false,false,15,20)%></td>
					</tr>
            		<tr class="TextRow01">
						<td>&nbsp;Sexo</td>
						<td><%=fb.select("sexo","M=MASCULINO, F=FEMENINO",emple.getColValue("sexo"))%></td>
						<td>&nbsp;Direcci&ograve;n</td>
						<td><%=fb.textBox("direccion",emple.getColValue("direccion"),true,false,false,34,20)%></td>
					</tr>
            	</table>
			</td>
         </tr>
         <tr>
         	<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
            		<tr class="TextPanel">
						<td width="95%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Datos de la Beca </td>
						<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
            		</tr>
           		</table>
			</td>
         </tr>
         <tr id="panel1">
            <td>
				<table width="100%" cellpadding="1" cellspacing="1" align="center">
            		<tr class="TextRow01">
						<td width="19%">&nbsp;Tipo de Beca </td>
						<td width="31%"> <%=fb.select(ConMgr.getConnection(),"select distinct cod_beca as codBeca, descripcion from tbl_pla_tipo_beca order by cod_beca","codBeca",emple.getColValue("codBeca"))%> </td>
						<td width="20%">&nbsp;A&ntilde;os de Duraci&ograve;n </td>
						<td width="30%"><%=fb.textBox("anioCursa",emple.getColValue("anioCursa"),true,false,false,34,60)%></td>
            		</tr>                      
					<tr class="TextRow01">
						<td>&nbsp;Turno </td>
						<td><%=fb.select("turno","V=VESPERTINO, M=MATUTINO, N=NOCTURNO ",emple.getColValue("turno"))%></td>
						<td>&nbsp;Teléfono</td>
						<td><%=fb.textBox("telefono",emple.getColValue("telefono"),false,false,false,34,60)%></td>
					</tr>
					<tr class="TextRow01">
						<td>&nbsp;Fecha de Inicio</td>
						<td><jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />                      
							<jsp:param name="nameOfTBox1" value="ingreso" />                      
							<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("ingreso")%>" />                      
							</jsp:include></td>
						<td>&nbsp;Fecha Final </td>
						<td><jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />                      
							<jsp:param name="nameOfTBox1" value="egreso" />                      
							<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("egreso")%>" />                      
							</jsp:include></td>
					</tr>
					<tr class="TextRow01">
						<td>&nbsp;Educaci&oacute;n </td>
						<td><%=fb.select("educacion","E=ESTATAL, P=PARTICULAR ",emple.getColValue("educacion"))%></td>
						<td>&nbsp;Años de Estudio</td>
						<td><%=fb.intBox("duracion",emple.getColValue("duracion"),true,false,false,1,1)%></td>
					</tr>
					<tr class="TextRow01">
						<td>&nbsp;Centro Educativo </td>
						<td><%=fb.textBox("centro",emple.getColValue("centro"),true,false,false,34,60)%></td>
						<td>&nbsp;Teléfono Centro </td>
						<td><%=fb.textBox("telefonoCentro",emple.getColValue("telefonoCentro"),false,false,false,34,60)%></td>
					</tr>
					<tr class="TextRow01">
						<td>&nbsp;Carrera </td>
						<td><%=fb.textBox("carrera",emple.getColValue("carrera"),false,false,false,34,60)%></td>
						<td>&nbsp;Promedio</td>
						<td><%=fb.textBox("promedio",emple.getColValue("promedio"),false,false,false,34,60)%></td>
					</tr>
            	</table> 
			</td>
         </tr>
         <tr>
         	<td onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
					<tr class="TextPanel">
						<td width="95%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Datos del Empleado </td>
						<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;</td>
					</tr>
            	</table>
			</td>
         </tr>
         <tr id="panel3">
         	<td>
				<table width="100%" align="center" cellpadding="1" cellspacing="1">
            		<tr class="TextRow01">
						<td width="18%">&nbsp;C&eacute;dula/Empleado </td>
						<td colspan="3%"><%=fb.intBox("provinciaAso",emple.getColValue("provinciaAso"),true,false,mode.equals("edit"),4,2)%><%=fb.textBox("siglaAso",emple.getColValue("siglaAso"),true,false,mode.equals("edit"),4,2)%> <%=fb.intBox("tomoAso",emple.getColValue("tomoAso"),true,false,mode.equals("edit"),5,4)%><%=fb.intBox("asientoAso",emple.getColValue("asientoAso"),true,false,mode.equals("edit"),5,5)%> </td>
           			</tr>
                    <tr class="TextRow01">
						<td>&nbsp;Nombre Empleado</td>
						<td width="32%"><%=fb.textBox("nombreAso",emple.getColValue("nombreAso"),true,false,false,35,80)%></td>
						<td width="20%">&nbsp;Apellido Empleado </td>
						<td width="30%"><%=fb.textBox("apellidoAso",emple.getColValue("apellidoAso"),true,false,false,35,80)%></td>
					</tr>
					<tr class="TextRow01">
						<td>&nbsp;Observaci&oacute;n</td>
						<td><%=fb.textBox("observacion",emple.getColValue("observacion"),false,false,false,35,80)%></td>
						<td>&nbsp;Cheque a Nombre de: </td>
						<td><%=fb.intBox("chequeBen",emple.getColValue("chequeBen"),true,false,true,5,3,"Text10",null,null)%><%=fb.textBox("beneDesc",emple.getColValue("beneDesc"),true,false,true,30,200,"Text10",null,null)%><%=fb.button("btnotro","...",true,false,null,null,"onClick=\"javascript:addOtro()\"")%>
						
						</td>
            	    </tr>
            	</table>
			</td>
         </tr>
         <tr class="TextRow02">
         	<td align="right"> Opciones de Guardar: 
			        <%=fb.radio("saveOption","N")%>Crear Otro 
				    <%=fb.radio("saveOption","O")%>Mantener Abierto 
				    <%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
				   <%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> 
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
          </tr>
<%=fb.formEnd(true)%>
</table>
<!--</div>-->
<!--<script type="text/javascript">
<%
//if (mode.equalsIgnoreCase("add"))
//{
%>
initTabs('dhtmlgoodies_tabView1',Array('Becario'),0,'100%','');
<%
//}
//else
//{

%>
<%
//}
%>
</script>-->
          </td>
        </tr>
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
	id=request.getParameter("id");

	if(tab.equals("0")) //Generales del Becario
	{
   	  emple = new CommonDataObject();
	  emple.setTableName("tbl_pla_becario");	    
      if(request.getParameter("codBeca")!=null)
	  emple.addColValue("cod_beca",request.getParameter("codBeca")); 
	  emple.addColValue("nombre", request.getParameter("nombre")); 
	  if(request.getParameter("apellido")!= null)
	  emple.addColValue("apellido",request.getParameter("apellido"));
	  if(request.getParameter("sexo")!=null)
	  emple.addColValue("sexo",request.getParameter("sexo"));
	  emple.addColValue("direccion",request.getParameter("direccion"));
	  if(request.getParameter("estado")!= null)
	  emple.addColValue("estado",request.getParameter("estado"));
	  emple.addColValue("educacion",request.getParameter("educacion"));
	  if(request.getParameter("turno")!= null)
   	  emple.addColValue("turno",request.getParameter("turno"));
	  emple.addColValue("anio_cursa",request.getParameter("anioCursa"));
	  emple.addColValue("centro_edu",request.getParameter("centro"));
	  emple.addColValue("duracion",request.getParameter("duracion"));	
	  emple.addColValue("fecha_ini_beca",request.getParameter("ingreso"));
      emple.addColValue("fecha_fin_beca",request.getParameter("egreso"));
	  emple.addColValue("tipo_becario",request.getParameter("tipoBecario")); 
	  emple.addColValue("emp_id_aso",request.getParameter("empId"));   
	  emple.addColValue("provincia_aso",request.getParameter("provinciaAso"));  
	  emple.addColValue("sigla_aso",request.getParameter("siglaAso"));
	  emple.addColValue("tomo_aso",request.getParameter("tomoAso"));
	  emple.addColValue("nombre_aso",request.getParameter("nombreAso"));
	  emple.addColValue("apellido_aso",request.getParameter("apellidoAso"));
	  emple.addColValue("asiento_aso",request.getParameter("asientoAso"));	  
      emple.addColValue("FECHA_MOD","sysdate");
  	  emple.addColValue("USUARIO_MOD",(String) session.getAttribute("_userName")); 
	  emple.addColValue("observacion",request.getParameter("observacion")); 
	  emple.addColValue("promedio",request.getParameter("promedio"));  
	  
      emple.addColValue("fecha_nac",request.getParameter("fecha"));
	  emple.addColValue("num_ssocial",request.getParameter("numSsocial"));
	  emple.addColValue("telefono",request.getParameter("telefono"));
      emple.addColValue("carrera",request.getParameter("carrera"));
	  emple.addColValue("telefono_centro",request.getParameter("telefonoCentro"));
	  emple.addColValue("observacion",request.getParameter("observacion"));
	  emple.addColValue("cheque_beneficiario",request.getParameter("beneDesc"));
	  emple.addColValue("cheque_beneficiario_codigo",request.getParameter("chequeBen"));
		
	//ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  if (mode.equalsIgnoreCase("add"))
  { 
		emple.addColValue("provincia",request.getParameter("provincia"));
		emple.addColValue("sigla",request.getParameter("sigla"));
		emple.addColValue("tomo",request.getParameter("tomo"));	
		emple.addColValue("asiento",request.getParameter("asiento"));	
		emple.addColValue("emp_id_aso",request.getParameter("empId"));  
		emple.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 	
		emple.addColValue("fecha_creacion","sysdate");	
		emple.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
			
		SQLMgr.insert(emple);
		prov = request.getParameter("provincia");
		sig  = request.getParameter("sigla"); 
		tom  = request.getParameter("tomo"); 
		asi  = request.getParameter("asiento");
	}
  else
  {
		emple.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi);
	
		SQLMgr.update(emple);
  }
	ConMgr.clearAppCtx(null);
}//End Tab de Generales de Becario
  
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
	if (tab.equals("0"))
	{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/becario_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/becario_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/becario_list.jsp';
<%
		}
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
	window.close();
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
