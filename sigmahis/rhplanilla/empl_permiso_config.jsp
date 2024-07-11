<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="per" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
================================================================================

================================================================================
**/
SecMgr.setConnection(ConMgr);
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String grupo=request.getParameter("grupo");
String empId=request.getParameter("empId");
String cod = request.getParameter("cod");
String mode = request.getParameter("mode");
String fecha = request.getParameter("fecha");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String sw = "S";
String appendFilter = "";

boolean viewMode = false;
if (fp==null) fp="";
if (mode == null) mode = "add";
if (empId==null) empId="";
if (fecha==null) fecha="";
if (cod==null) cod="";
if (grupo==null) grupo="";

if(mode.trim().equals("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{

	if (!mode.trim().equals("add"))
	{
		 	if (grupo == null) throw new Exception("El Código de Grupo no es válido. Por favor intente nuevamente!");
			if (empId == null) throw new Exception("El Código del Empleado no es válido. Por favor intente nuevamente!");

			if (request.getParameter("grupo") != null && !request.getParameter("grupo").trim().equals(""))
				  {
				    appendFilter += " and (a.ue_codigo) = '"+request.getParameter("grupo")+"'";
			  	  }
				if (request.getParameter("empId") != null && !request.getParameter("empId").trim().equals(""))
				  {
				    appendFilter += " and a.emp_id = "+request.getParameter("empId")+"";
				  }
				  if (request.getParameter("fecha") != null && !request.getParameter("fecha").trim().equals(""))
				  {
				       appendFilter += " and a.fecha = to_date('"+request.getParameter("fecha")+"','dd/mm/yyyy')";
				  }
				  if (request.getParameter("cod") != null && !request.getParameter("cod").trim().equals(""))
				  {
				    appendFilter += " and a.codigo  = "+request.getParameter("cod");
		 	  }

		   	sql = "SELECT a.emp_id as empId, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora_salida,'hh12:mi am') as salida,  a.motivo, a.mfalta, to_char(a.hora_entrada,'hh12:mi am') as entrada, to_char(a.hora_desde,'hh12:mi am') as desde,  to_char(a.hora_hasta,'hh12:mi am') as hasta, b.descripcion as mfaltaDesc, a.codigo, to_char(a.fecha_fin,'dd/mm/yyyy') as fechafinal, a.motivo_lic licencia, decode(a.estado,'ND','NO DESCONTAR','DS','DESCONTAR','PE','PENDIENTE','DV','DEVOLVER') as estadoDesc, a.estado, a.emp_id, a.num_empleado, m.descripcion as licDesc, c.primer_nombre||' '||c.primer_apellido as nombre, nvl(a.ue_codigo,'0') grupo, a.aprobado, a.forma_des, a.cod_turno_ini, a.prog_turno_ini, c.nombre_empleado as nombreEmpleado, c.cedula1 as cedula, c.num_empleado numEmp, m.descripcion motivoLicDesc, /*d.descripcion*/  case when a.prog_turno_ini='S' then  (select h.descripcion from tbl_pla_ct_turno h where h.compania= a.compania and to_char(h.codigo)=a.cod_turno_ini)    else   (select h.descripcion from tbl_pla_horario_trab h where h.compania= a.compania and to_char(h.codigo)=a.cod_turno_ini)  end dsp_turno_ini, /*e.descripcion*/  case when a.prog_turno_fin='S' then (select h.descripcion from tbl_pla_ct_turno h where h.compania= a.compania and to_char(h.codigo)=a.cod_turno_fin)   else   (select h.descripcion from tbl_pla_horario_trab h where h.compania= a.compania and to_char(h.codigo)=a.cod_turno_fin)  end dsp_turno_fin, a.cod_turno_ini, a.prog_turno_ini, a.cod_turno_fin, a.prog_turno_fin from tbl_pla_permiso a, tbl_pla_motivo_falta b, vw_pla_empleado c, /*tbl_pla_ct_turno d, tbl_pla_ct_turno e,*/ tbl_pla_motivo_licencia m where a.mfalta=b.codigo and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and a.motivo_lic = m.codigo(+) and a.emp_id = c.emp_id and a.compania = c.compania /*and a.compania = d.compania and a.cod_turno_ini = to_char(d.codigo) and a.compania = e.compania(+) and a.cod_turno_fin = e.codigo(+)*/";

			per = SQLMgr.getData(sql);
	} else
	{
		per.addColValue("mfalta","38");
		per.addColValue("mfaltaDesc","LICENCIA SIN SUELDO");
		per.addColValue("estado","DS");
		per.addColValue("estadoDesc","DESCONTAR");
		per.addColValue("grupo",grupo);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>

</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
function doSubmit()
{
   var	motivo = eval('document.formPermiso.motivo_lic').value;
   var	tipo   = eval('document.formPermiso.mfalta').value;

   if (tipo == "40"   && (motivo==null ||motivo==""))
   {
   		alert('Debe registrar un Tipo de Licencia para este motivo de PERMISO!');
   		
   }
   else

{
  document.formPermiso.submit();
}
}
function addMotivo()
{
    abrir_ventana2("../common/search_motivo_falta.jsp?fp=permisos_empleado");
}

function printLista()
{
   var empId;
   var grupo;
   var codi;
   var fecha;
   var lic;

   empId = eval('document.formPermiso.empId').value;
   codi  = eval('document.formPermiso.codigo').value;
   fecha = eval('document.formPermiso.fecha').value;
   lic   = eval('document.formPermiso.licencia').value;


	if(lic == null || lic == "")
	{
   	abrir_ventana1('../rhplanilla/print_permiso.jsp?empId='+empId+'&cod='+codi+'&fecha='+fecha);
	} 	else
		 {
		 abrir_ventana1('../rhplanilla/print_permiso_lic.jsp?empId='+empId+'&cod='+codi+'&fecha='+fecha);
		 }
}

function turnoIni()
{
  var fechaIni = "";
  var cod      = 0;
  var nulo     = 0;
  var msg      = "";
  var anio     = "";
  var mes      = "";
  var dia      = "";
  var mode     = "add";

  var	emp_id   = eval('document.formPermiso.empId').value;
  var	codi     = eval('document.formPermiso.codigo').value;
  var	fecha    = eval('document.formPermiso.fecha').value;
  var	grupo    = eval('document.formPermiso.grupo').value;
  var	num_emp  = eval('document.formPermiso.num_empleado').value;


   if (emp_id==null ||emp_id=="")
   {
   		alert('Debe indicar primero el EMPLEADO a quien pertenece este PERMISO!');
   		eval('document.formPermiso.fechaR').value = "";
   }
   else
   {


			fechaIni = eval('document.formPermiso.fechaR').value;
			var ini  = new Date(fechaIni);

		        var count = parseInt(getDBData('<%=request.getContextPath()%>', 'count(*) count', 'tbl_pla_inasistencia_emp', 'compania = <%=(String) session.getAttribute("_companyId")%> and estado <> \'EL\'  and to_date(to_char(fecha, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fechaIni+'\',\'dd/mm/yyyy\') and emp_id = '+emp_id,''),10);
			if(count>0){ alert('Tiene registrada una Inasistencia para esta fecha,  Verifique e inténtelo nuevamente!'); }
				else
			 	{
				var countIn	= parseInt(getDBData('<%=request.getContextPath()%>', 'count(*) count', 'tbl_pla_permiso', 'compania = <%=(String) session.getAttribute("_companyId")%> and to_date(to_char(fecha, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fechaIni+'\',\'dd/mm/yyyy\') and emp_id = '+emp_id,''),10);
				if(countIn>0)
					{ alert('Este colaborador YA TIENE registrado un PERMISO para esta fecha, Por favor asegúrese de no estar DUPLICANDO la información!'); }
					//else
					//{
					if(fechaIni != '' )
						{
						var x = getDBData('<%=request.getContextPath()%>', 'getDataVarios(\''+fechaIni+'\','+emp_id+',\''+num_emp+'\',<%=(String) session.getAttribute("_companyId")%>,'+grupo+',\''+mode+'\')','dual','','');

						var arr_cursor = new Array();
							if(x!='')
							{
							arr_cursor = splitCols(x);
								if(arr_cursor[3]!=' ') eval('document.formPermiso.prog_turno_ini').value = arr_cursor[3];
								if(arr_cursor[4]!=' ') eval('document.formPermiso.cod_turno_ini').value = arr_cursor[4];
								if(arr_cursor[5]!=' ') eval('document.formPermiso.dsp_turno_ini').value = arr_cursor[5];
							}
						}
					//}
				 }
	}
 }

function turnoFin()
{
   var fechaFin = "";
   var cod 	= 0;
   var nulo 	= 0;
   var msg 	="";
   var anio 	= "";
   var mes 	= "";
   var dia 	="";
   var mode 	= "add";


   var	emp_id   = eval('document.formPermiso.empId').value;
   var	codi     = eval('document.formPermiso.codigo').value;
   var	fecha    = eval('document.formPermiso.fecha').value;
   var	grupo    = eval('document.formPermiso.grupo').value;
   var	num_emp  = eval('document.formPermiso.num_empleado').value;

   if (emp_id==null ||emp_id=="")
   {
   		alert('Debe indicar primero el EMPLEADO a quien pertenece este PERMISO!');
   		eval('document.formPermiso.fechafinal').value = "";
   }
   else
   {

			fechaFin = eval('document.formPermiso.fechafinal').value;
			var ini  = new Date(fechaFin);




			var count	= parseInt(getDBData('<%=request.getContextPath()%>', 'count(*) count', 'tbl_pla_inasistencia_emp', 'compania = <%=(String) session.getAttribute("_companyId")%> and estado <> \'EL\'  and to_date(to_char(fecha, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fechaFin+'\',\'dd/mm/yyyy\') and emp_id = '+emp_id,''),10);
			if(count>0){
				alert('Tiene registrada una Inasistencia para esta fecha,  Verifique e inténtelo nuevamente!');
			  	   }
			else
				   {
		   		   var countIn	= parseInt(getDBData('<%=request.getContextPath()%>', 'count(*) count', 'tbl_pla_permiso', 'compania = <%=(String) session.getAttribute("_companyId")%> and to_date(to_char(fecha, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fechaFin+'\',\'dd/mm/yyyy\') and emp_id = '+emp_id,''),10);
					if(countIn>0)
					{
						alert('Tiene registrada un Permiso para esta fecha,  Verifique e inténtelo nuevamente!');
					}
					else
					{
					if(fechaFin != '' )
						{
						eval('document.formPermiso.prog_turno_fin').value = '';
						eval('document.formPermiso.cod_turno_fin').value = '';
						eval('document.formPermiso.dsp_turno_fin').value = '';

						var x = getDBData('<%=request.getContextPath()%>', 'getDataVarios(\''+fechaFin+'\','+emp_id+',\''+num_emp+'\',<%=(String) session.getAttribute("_companyId")%>,'+grupo+',\''+mode+'\')','dual','','');

						var arr_cursor = new Array();
						if(x!='')
							{
							arr_cursor = splitCols(x);
							if(arr_cursor[3]!=' ') eval('document.formPermiso.prog_turno_fin').value = arr_cursor[3];
							if(arr_cursor[4]!=' ') eval('document.formPermiso.cod_turno_fin').value = arr_cursor[4];
						  	if(arr_cursor[5]!=' ') eval('document.formPermiso.dsp_turno_fin').value = arr_cursor[5];
							}
						}
					}
				   }
	}
}


function addLicencia()
{
   abrir_ventana1('../common/search_motivo_licencia.jsp?fp=permisos_empleado');
}

function showEmpleadoList(){abrir_ventana('../common/select_ctempleado.jsp?fp=permiso&grupo=<%=grupo%>');}

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSO HUMANOS - PROCESO - PERMISOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	    <td class="TableBorder">
		    <table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("formPermiso",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("empId",per.getColValue("empId"))%>
			<%=fb.hidden("grupo",per.getColValue("grupo"))%>
			<%=fb.hidden("fecha",fecha)%>
			<%=fb.hidden("provincia",per.getColValue("provincia"))%>
			<%=fb.hidden("sigla",per.getColValue("sigla"))%>
			<%=fb.hidden("tomo",per.getColValue("tomo"))%>
			<%=fb.hidden("asiento",per.getColValue("asiento"))%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("estado",per.getColValue("estado"))%>
			<%=fb.hidden("licencia",per.getColValue("licencia"))%>
			<%=fb.hidden("num_empleado",per.getColValue("num_empleado"))%>
			<%String functionName = "turnoIni" , functionFin = "turnoFin";%>
			<tr class="TextHeader02">
				<td colspan="4">&nbsp;DATOS DEL EMPLEADO</td>
			</tr>
			<tr class="TextRow01">
				<td width="10%">Empleado:</td>
				<td width="44%"><%=fb.textBox("nombreEmpleado",per.getColValue("nombreEmpleado"),false,false,true,50,50,"",null,null)%>
							<%=fb.button("btnEmpleado","...",true,viewMode,null,"","onClick=\"javascript:showEmpleadoList()\"")%>
				</td>
				<td width="6%">No. Emp.</td>
				<td width="40%"><%=fb.textBox("numEmpleado",per.getColValue("num_empleado"),false,false,true,6,10,"",null,null)%></td>
			</tr>
			<tr class="TextRow01">
				<td width="10%">C&eacute;dula:</td>
				<td width="44%"><%=fb.textBox("cedula",per.getColValue("cedula"),false,false,true,50,50,"",null,null)%></td>
				<td width="6%">&nbsp;Emp. ID</td>
				<td width="40%"><%=fb.textBox("empIdDsp",per.getColValue("empId"),false,false,true,10,10,"",null,null)%></td>
			</tr>

			<tr class="TextHeader02">
				<td colspan="4">&nbsp;DETALLE DEL PERMISO</td>
			</tr>

			<tr class="TextRow01">
				<td width="10%">Motivo</td>
				<td width="44%"><%=fb.intBox("mfalta",per.getColValue("mfalta"),false,viewMode,true,5,3)%>
								<%=fb.textBox("mfaltaDesc",per.getColValue("mfaltaDesc"),false,false,true,30,30)%>
								<%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addMotivo()\"")%></td>
				<td width="6%">No.</td>
				<td width="40%"><%=fb.intBox("codigo",per.getColValue("codigo"),false,viewMode,true,16,1)%></td>
			</tr>

			<tr class="TextRow01">
				<td>Tipo Licencia</td>
				<td colspan="3">
				<%=fb.intBox("motivo_lic",per.getColValue("licencia"),false,false,true,5,4,"",null,null)%>
				<%=fb.textBox("motivoLicDesc",per.getColValue("motivoLicDesc"),false,false,true,40,60,"",null,null)%>
				<%=fb.button("btnlicencia","...",false,(per.getColValue("mfalta").equals("40")?false:true),null,null,"onClick=\"javascript:addLicencia()\"")%></td>
			</tr>

			<tr class="TextRow02">
				<td>Fecha Inicio</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
				    <jsp:param name="noOfDateTBox" value="1" />
				    <jsp:param name="clearOption" value="true" />
				    <jsp:param name="nameOfTBox1" value="fechaR"/>
				    <jsp:param name="valueOfTBox1" value="<%=(per.getColValue("fecha")==null)?"":per.getColValue("fecha")%>" />
				    <jsp:param name="fieldClass" value="Text10" />
				    <jsp:param name="buttonClass" value="Text10" />
      				    <jsp:param name="clearOption" value="true" />
				    <jsp:param name="jsEvent" value="turnoIni()"/>
				    <jsp:param name="onChange" value="turnoIni()"/>

				    </jsp:include>
					<%=fb.hidden("cod_turno_ini",per.getColValue("cod_turno_ini"))%>
					<%=fb.hidden("prog_turno_ini",per.getColValue("prog_turno_ini"))%> &nbsp;
					<%=fb.textBox("dsp_turno_ini",per.getColValue("dsp_turno_ini"),false,false,true,55,80,"Text10",null,null)%>
				</td>



				<td>Desde</td>
				<td>
         			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="salida"/>
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="valueOfTBox1" value="<%=(per.getColValue("salida")==null)?"":per.getColValue("salida")%>" />
				</jsp:include>&nbsp; &nbsp;&nbsp; Hasta <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="entrada"/>
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="valueOfTBox1" value="<%=(per.getColValue("entrada")==null)?"":per.getColValue("entrada")%>" />
				</jsp:include>

				<%//=fb.intBox("entrada",per.getColValue("entrada"),false,viewMode,false,8,8)%>
				<%//=fb.intBox("salida",per.getColValue("salida"),false,viewMode,false,8,8)%></td>
			</tr>

			<tr class="TextRow01">
				<td>Fecha Final</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fechafinal"/>
					<jsp:param name="valueOfTBox1" value="<%=(per.getColValue("fechafinal")==null)?"":per.getColValue("fechafinal")%>" />
					<jsp:param name="fieldClass" value="Text10" />
					<jsp:param name="buttonClass" value="Text10" />
      					<jsp:param name="clearOption" value="true" />

					<jsp:param name="jsEvent" value="turnoFin()"/>
				     <jsp:param name="onChange" value="turnoFin()"/>
					</jsp:include>
					<%=fb.hidden("cod_turno_fin",per.getColValue("cod_turno_fin"))%>
					<%=fb.hidden("prog_turno_fin",per.getColValue("prog_turno_fin"))%> &nbsp;
					<%=fb.textBox("dsp_turno_fin",per.getColValue("dsp_turno_fin"),false,false,true,55,80,"Text10",null,null)%>

				</td>
				<td>Desde</td>
				<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="desde"/>
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="valueOfTBox1" value="<%=(per.getColValue("desde")==null)?"":per.getColValue("desde")%>" />
				</jsp:include>&nbsp; &nbsp;&nbsp; Hasta
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="hasta"/>
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="valueOfTBox1" value="<%=(per.getColValue("hasta")==null)?"":per.getColValue("hasta")%>" />
				</jsp:include>
				<%//=fb.intBox("desde",per.getColValue("desde"),false,viewMode,false,8,8)%>
				<%//=fb.intBox("hasta",per.getColValue("hasta"),false,viewMode,false,8,8)%></td>
			</tr>

			<tr class="TextRow02">
				<td>Observaci&oacute;n</td>
  			    	<td><%=fb.textarea("motivo",per.getColValue("motivo"),false,false,false,45,4)%></td>
				<td>Acci&oacute;n</td>
				<td><%=fb.textBox("estadoDesc",per.getColValue("estadoDesc"),false,false,true,30,30,"",null,null)%></td>

			</tr>

			<tr class="TextRow02">
				<td colspan="3">&nbsp;</td>
					<td> Estado
					<%if (fp.equalsIgnoreCase("A")|| (mode.equalsIgnoreCase("view")))
					{%>
						<%=fb.select("aprobado","S=APROBADO,N=REGISTRADO",per.getColValue("aprobado"))%>
					<% } else {
					%>
						<%=fb.select("aprobado","N=REGISTRADO,X=OMITIDO",per.getColValue("aprobado"))%>
					<% } %>
					</td>
				<tr class="TextRow02">
					<td align="right" colspan="2">&nbsp;</td>
					<td align="center" colspan="1">	<%=fb.button("print","Imprimir",false,(mode.equalsIgnoreCase("add")),null,null,"onClick=\"javascript:printLista()\"")%></td>
					<td align="right"><%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit()\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				</tr>
			<tr>
			  <td colspan="4">&nbsp;</td>
			</tr>
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

   String codigo = "";
   String aprob = "N";
    String fechaR = "";

   fg = request.getParameter("fg");
   fp = request.getParameter("fp");
   grupo = request.getParameter("grupo");
   empId = request.getParameter("empId");
   fecha = request.getParameter("fecha");
   fechaR = request.getParameter("fechaR");
   codigo = request.getParameter("codigo");
   aprob = request.getParameter("aprobado");

   CommonDataObject cdo = new CommonDataObject();

   cdo.setTableName("tbl_pla_permiso");

   cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
   cdo.addColValue("fecha",request.getParameter("fechaR"));
   cdo.addColValue("hora_salida",request.getParameter("salida"));
   cdo.addColValue("hora_entrada",request.getParameter("entrada"));
   cdo.addColValue("motivo",request.getParameter("motivo"));
   cdo.addColValue("estado",request.getParameter("estado"));
   cdo.addColValue("hora_desde",request.getParameter("desde"));
   cdo.addColValue("hora_hasta",request.getParameter("hasta"));

   cdo.addColValue("mfalta",request.getParameter("mfalta"));
   cdo.addColValue("motivo_lic",request.getParameter("motivo_lic"));
//   cdo.addColValue("codigo",request.getParameter("codigo"));
   cdo.addColValue("cod_turno_ini",request.getParameter("cod_turno_ini"));
   cdo.addColValue("prog_turno_ini",request.getParameter("prog_turno_ini"));

   if (request.getParameter("cod_turno_fin") != null && !request.getParameter("cod_turno_fin").trim().equals(""))  cdo.addColValue("cod_turno_fin",request.getParameter("cod_turno_fin"));

   if (request.getParameter("prog_turno_fin") != null && !request.getParameter("prog_turno_fin").trim().equals(""))  cdo.addColValue("prog_turno_fin",request.getParameter("prog_turno_fin"));

   if (request.getParameter("fechafinal") != null && !request.getParameter("fechafinal").trim().equals(""))  cdo.addColValue("fecha_fin",request.getParameter("fechafinal"));

   cdo.addColValue("fecha_modificacion", "sysdate");
   cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));

   cdo.addColValue("forma_des","1");
   cdo.addColValue("aprobado",aprob);

	if (mode.equalsIgnoreCase("add")){
		cdo.addColValue("ue_codigo",grupo);
		cdo.addColValue("provincia",request.getParameter("provincia"));
		cdo.addColValue("sigla",request.getParameter("sigla"));
		cdo.addColValue("tomo",request.getParameter("tomo"));
		cdo.addColValue("asiento",request.getParameter("asiento"));
		cdo.addColValue("num_empleado",request.getParameter("numEmpleado"));
   		cdo.addColValue("fecha_creacion", "sysdate");
   		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));

		cdo.setAutoIncWhereClause("emp_id="+empId+" and fecha=to_date('"+fechaR+"','dd/mm/yyyy') and compania="+(String) session.getAttribute("_companyId"));
		cdo.setAutoIncCol("codigo");
		SQLMgr.insert(cdo);
	} else	{
		cdo.setWhereClause("emp_id="+empId+" and fecha=to_date('"+fecha+"','dd/mm/yyyy') and codigo="+codigo+" and compania="+(String) session.getAttribute("_companyId"));
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

	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_permiso.jsp?fg=<%=fg%>&grupo=<%=grupo%>';

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