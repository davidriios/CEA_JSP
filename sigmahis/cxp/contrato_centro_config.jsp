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
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vMed" scope="session" class="java.util.Vector" />
<jsp:useBean id="iProc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vProc" scope="session" class="java.util.Vector" />
<jsp:useBean id="iOcen" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vOcen" scope="session" class="java.util.Vector" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject med = new CommonDataObject();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String num = request.getParameter("num");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
int medLastLineNo = 0;
int procLastLineNo = 0;
int ocenLastLineNo = 0;

if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (request.getParameter("medLastLineNo") != null) medLastLineNo = Integer.parseInt(request.getParameter("medLastLineNo"));
if (request.getParameter("procLastLineNo") != null) procLastLineNo = Integer.parseInt(request.getParameter("procLastLineNo"));
if (request.getParameter("ocenLastLineNo") != null) ocenLastLineNo = Integer.parseInt(request.getParameter("ocenLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		num = " ";
		med.addColValue("fecha_inicial","");
		med.addColValue("monto_desc","0");

		iMed.clear();
		vMed.clear();
		iProc.clear();
		vProc.clear();
		iOcen.clear();
		vOcen.clear();
	}
	else
	{
		if (id == null) throw new Exception("El Centro no es válido. Por favor intente nuevamente!");

		sql = "select a.num_contrato codigo, a.cod_centro_servicio centro, b.descripcion name_centro, '[ '||a.cod_centro_servicio||' ]'||b.descripcion centroDesc, a.estado,  nvl(a.porcentaje,0) porcentaje, nvl(a.cant_desc,0) cant_desc, decode(a.estado,'A','Activo','I','Inactivo') estadoDesc, a.observacion, a.tipo, to_char(a.fecha_inicial,'dd/mm/yyyy') fecha_inicial,  a.user_aprobado, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_final,'dd/mm/yyyy') fecha_final, a.cod_empresa codEmpresa, to_char(a.fecha_creacion,'dd/mm/yyyy') fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy') fecha_creacion, a.distribucion, a.responsable, a.fecha_pago dias, a.procedimiento,  nvl(a.monto_desc,0) monto_desc, c.nombre empresaNombre from tbl_cxp_contrato_centro_serv a, tbl_sec_unidad_ejec b, tbl_adm_empresa c where  b.compania = "+(String) session.getAttribute("_companyId")+" and  a.cod_centro_servicio = b.codigo and a.cod_empresa = c.codigo(+) and a.num_contrato = "+num+" and a.cod_centro_servicio='"+id+"'";
		med = SQLMgr.getData(sql);
		System.out.println("sql = "+sql);

		if (change == null)
		{
			sql = "select a.num_contrato, a.cod_centro_servicio, a.nombre_cheque, a.cod_medico, a.cod_empresa empresa, c.nombre nombreEmpresa, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, b.identificacion, b.primer_nombre, b.primer_apellido from tbl_cxp_contrato_medico a, tbl_adm_medico b, tbl_adm_empresa c where a.cod_medico = b.codigo and a.num_contrato = '"+num+"' and a.cod_centro_servicio ='"+id+"' and a.cod_empresa = c.codigo order by a.cod_centro_servicio";
			al  = SQLMgr.getDataList(sql); 
	System.out.println("sql = "+al.size()+"//"+sql);
			iMed.clear();
			vMed.clear();
			iProc.clear();
			vProc.clear();
			iOcen.clear();
			vOcen.clear();

			medLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iMed.put(key, cdo);
					vMed.addElement(cdo.getColValue("cod_medico"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}  	

			sql = "select a.cod_procedimiento, a.centro_servicio, a.num_contrato, nvl(a.monto,0) monto, a.tipo_valor, b.descripcion centroServicio, c.descripcion descProcedimiento, nvl(c.precio,0) precio from tbl_cxp_cont_proced a, tbl_sec_unidad_ejec b, tbl_cds_procedimiento c where a.cod_procedimiento = c.codigo and a.centro_servicio = b.codigo and b.compania = "+(String) session.getAttribute("_companyId")+" and a.centro_servicio='"+id+"' and a.num_contrato = '"+num+"' order by a.cod_procedimiento";
			al  = SQLMgr.getDataList(sql); 

			procLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iProc.put(key, cdo);
					vProc.addElement(cdo.getColValue("cod_procedimiento"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}  	

			sql = "select a.ubicacion, nvl(a.telefono,' ') as telefono, a.principal, b.descripcion as ubicacionDesc from tbl_adm_medico_ubicacion a, tbl_adm_ubicacion b where a.ubicacion=b.codigo and a.medico='"+id+"' order by a.ubicacion";
			al  = SQLMgr.getDataList(sql); 

			ocenLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iOcen.put(key, cdo);
					vOcen.addElement(cdo.getColValue("ubicacion"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}  	
		}
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Centro de Servicio -  Edición - '+document.title;

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}

function showCentroList()
{
	abrir_ventana1('../common/search_centro_servicio.jsp?fp=cargo_tardio');
}

function showAsociacionList()
{
	abrir_ventana1('../common/search_empresa.jsp?fp=medico');
}

function showEmpresaList(index)
{
	abrir_ventana1('../common/search_empresa.jsp?fp=contrato&index='+index);
}

function clearCentro()
{
	document.form0.centro.value = '';
	document.form0.name_centro.value = '';
}

function clearAsociacion()
{
	document.form0.codEmpresa.value = '';
	document.form0.empresaNombre.value = '';
}

function showMedicoList()
{
  abrir_ventana1('../common/check_medico.jsp?fp=doctoresResid&mode=<%=mode%>&id=<%=id%>&num=<%=num%>&medLastLineNo=<%=medLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&ocenLastLineNo=<%=ocenLastLineNo%>');
}


function showEmpresaList(index)
{

	abrir_ventana1('../common/search_empresa.jsp?fp=contrato&index='+index);
}

function showEspecialidadList()
{
  abrir_ventana1('../common/check_especialidad_med.jsp?fp=medico&mode=<%=mode%>&id=<%=id%>&num=<%=num%>&medLastLineNo=<%=medLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&ocenLastLineNo=<%=ocenLastLineNo%>');
}

function showSociedadList()
{
  abrir_ventana1('../common/check_empresa.jsp?fp=medico&mode=<%=mode%>&id=<%=id%>&num=<%=num%>&medLastLineNo=<%=medLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&ocenLastLineNo=<%=ocenLastLineNo%>');
}

function showUbicacionMedList()
{
  abrir_ventana1('../common/check_ubicacion_med.jsp?fp=medico&mode=<%=mode%>&id=<%=id%>&num=<%=num%>&medLastLineNo=<%=medLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&ocenLastLineNo=<%=ocenLastLineNo%>');
}

function principalChecked()
{
	if (document.form3.baction.value == 'Guardar' && <%=iOcen.size()%> != 0)
	{
<%
for (int i=1; i<=iOcen.size(); i++)
{
%>
		<%=(i==1)?"":"else "%>if (document.form3.principal<%=i%>.checked) return true;
<%
}
%>
		return false;
	}
	else return true;
}

function doAction()
{
	showHide(1);
	showHide(2);
	showHide(3);
<%
	if (request.getParameter("type") != null)
	{
		if (tab.equals("1"))
		{
%>
	showMedicoList();
<%
		}
		else if (tab.equals("2"))
		{
%>
		 showUbicacionMedList();
<%
		}
		else if (tab.equals("3"))
		{
%>
	  showUbicacionMedList();
<%
		}
	}
%>
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CXP - MANTENIMIENTO - CONTRATOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">



<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ========================  F O R M   S T A R T   H E R E   ======================== -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("num",num)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("medSize",""+iMed.size())%>
<%=fb.hidden("medLastLineNo",""+medLastLineNo)%>
<%=fb.hidden("procSize",""+iProc.size())%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("ocenSize",""+iOcen.size())%>
<%=fb.hidden("ocenLastLineNo",""+ocenLastLineNo)%>
<%=fb.hidden("fp",fp)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Generales del Contrato</cellbytelabel> </td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
			<tr id="panel0">
				<td>	
				<table width="100%" cellpadding="1" cellspacing="1">									
				<tr class="TextRow01">
					<td width="12%" align="right"><cellbytelabel>Num. Contrato</cellbytelabel></td>
			    <td width="30%"><%=fb.textBox("codigo",med.getColValue("codigo"),true,false,false,10,10)%></td>														
					<td width="24%" align="right"><cellbytelabel>Centro de Servicio</cellbytelabel> </td>
			    <td width="33%">&nbsp;<%=fb.intBox("centro",med.getColValue("centro"),false,false,true,5,null,null,"onDblClick=\"javascript:clearCentro()\"")%>
								<%=fb.textBox("name_centro",med.getColValue("name_centro"),false,false,true,30,null,null,"onDblClick=\"javascript:clearCentro()\"")%>
								<%=fb.button("btnCentro",".:.",false,false,null,null,"onClick=\"javascript:showCentroList()\"")%></td>							
				</tr>	
						
				<tr class="TextRow01">
					<td align="center" colspan="3"><cellbytelabel>Fecha Inicial</cellbytelabel> : &nbsp;
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="fecha_inicial" />
						<jsp:param name="valueOfTBox1" value="<%=(med.getColValue("fecha_inicial")==null)?"":med.getColValue("fecha_inicial")%>" />
						</jsp:include>
					&nbsp;<cellbytelabel>Fecha Final</cellbytelabel> : &nbsp;
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="fecha_final" />
						<jsp:param name="valueOfTBox1"value="<%=(med.getColValue("fecha_final")==null)?"":med.getColValue("fecha_final")%>" />
						
						</jsp:include>
					&nbsp; <cellbytelabel>D&iacute;as de Pago</cellbytelabel> : <%=fb.textBox("dias",med.getColValue("dias"),false,false,false,4,4)%></td>
					<td>Estado &nbsp;<%=fb.select("estado","A=ACTIVO,I=INACTIVO",med.getColValue("estado"))%> &nbsp;&nbsp;&nbsp;Porcent.(%) :&nbsp;<%=fb.textBox("porcentaje",med.getColValue("porcentaje"),false,false,false,5,5)%></td>							
				</tr>			
										
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Aprobado</cellbytelabel> : </td>
					<td><%=fb.textBox("aprobado",med.getColValue("aprobado"),false,false,false,40,40)%></td>
					<td align="right"><cellbytelabel>Monto Desc</cellbytelabel> : &nbsp; <%=fb.decBox("monto_desc",CmnMgr.getFormattedDecimal(med.getColValue("monto_desc")),false,false,false,10)%></td>
				  <td align="center"> <cellbytelabel>Cant. a Desc</cellbytelabel> : &nbsp;<%=fb.textBox("cant_desc",med.getColValue("cant_desc"),false,false,false,10,10)%></td>														
				</tr>	
				
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Responsable</cellbytelabel> : </td>
					<td><%=fb.textBox("responsable",med.getColValue("responsable"),false,false,false,40,40)%></td>
					<td align="left"><cellbytelabel>Distribuci&oacute;n</cellbytelabel> : &nbsp;<%=fb.select("distribucion","P=PERSONAL,G=GRUPAL",med.getColValue("distribucion"))%></td>
					<td align="center"><cellbytelabel>Proced</cellbytelabel> :&nbsp;<%=fb.select("procedimiento","D=DETALLADO,G=GENERAL",med.getColValue("procedimiento"),"S")%></td>
				</tr>					
				
				<tr class="TextRow01">				
					<td align="right"><cellbytelabel>Tipo de Contrato</cellbytelabel> : </td>
					<td><%=fb.select("tipo","M=MEDICO,A=ASOCIACION",med.getColValue("tipo"))%></td>
					<td align="center" colspan="2"><cellbytelabel>Empresa</cellbytelabel> : &nbsp;<%=fb.intBox("codEmpresa",med.getColValue("codEmpresa"),false,false,true,5,null,null,"onDblClick=\"javascript:clearAsociacion()\"")%>
								<%=fb.textBox("empresaNombre",med.getColValue("empresaNombre"),false,false,true,50,null,null,"onDblClick=\"javascript:clearAsociacion()\"")%>
								<%=fb.button("btnCentro1",".:.",false,false,null,null,"onClick=\"javascript:showAsociacionList()\"")%></td>
				</tr>
					
				<tr class="TextRow01">							
					<td align="right"><cellbytelabel>Observaci&oacute;n</cellbytelabel> : </td>
				  <td colspan="3"><%=fb.textBox("observacion",med.getColValue("observacion"),false,false,false,60,60)%></td>	
				</tr>	
				
				<tr class="TextRow01">
					<td align="center" colspan="4"><cellbytelabel>Usuario Creaci&oacute;n</cellbytelabel>:&nbsp;<%=fb.textBox("usuario_creacion",med.getColValue("usuario_creacion"),false,false,true,14,14)%> &nbsp; Fecha Creación : &nbsp;<%=fb.textBox("fecha_creacion",med.getColValue("fecha_creacion"),false,false,true,9,9)%>&nbsp;
							<cellbytelabel>Usuario Modificaci&oacute;n</cellbytelabel> : &nbsp;<%=fb.textBox("usuario_modificacion",med.getColValue("usuario_creacion"),false,false,true,14,14)%> &nbsp; Fecha de Modificación : <%=fb.textBox("fecha_modificacion",med.getColValue("fecha_creacion"),false,false,true,9,9)%></td>														
				</tr>
				</table>
			</td>
		</tr>

		<tr class="TextRow02">
				<td align="right">
					<cellbytelabel>Opciones de Guardar</cellbytelabel>: 
					<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel> 
					<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel> 
					<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel> 
					<%=fb.submit("save","Guardar",true,false)%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
		</tr>
<%=fb.formEnd(true)%>

<!-- ==================   F O R M   E N D   H E R E   ================= -->

		</table>

<!-- TAB0 DIV END HERE-->
</div>

<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

		<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- =================   F O R M   S T A R T   H E R E   ================== -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("num",num)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("medSize",""+iMed.size())%>
<%=fb.hidden("medLastLineNo",""+medLastLineNo)%>
<%=fb.hidden("procSize",""+iProc.size())%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("ocenSize",""+iOcen.size())%>
<%=fb.hidden("ocenLastLineNo",""+ocenLastLineNo)%>
<%=fb.hidden("fp",fp)%>
<%fb.appendJsValidation("if(document.form1.baction.value!='Guardar')return true;");%>
		<tr class="TextRow02">
				<td>&nbsp;</td>
		</tr>

		<tr>
				<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
					<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Centro de Servicio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
					</tr>
				</table>
				</td>
		</tr>
		
		<tr id="panel10">
				<td>
				<table width="100%" cellpadding="1" cellspacing="1">
					<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Contrato No</cellbytelabel>.</td>
							<td width="15%"><%=med.getColValue("codigo")%></td>
							<td width="15%" align="right"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
							<td width="55%"> 	<%=med.getColValue("centroDesc")%> </td>
					</tr>
				</table>
				</td>
		</tr>

		<tr>
				<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
					<tr class="TextPanel">
						<td width="95%">&nbsp;<cellbytelabel>Generales del M&eacute;dico</cellbytelabel></td>
						<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
					</tr>
				</table>
		  	</td>
		</tr>
		
		<tr id="panel11">
					<td>
					<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="04%"><cellbytelabel>Sec</cellbytelabel>.</td>
							<td width="08%"><cellbytelabel>C&oacute;digo M&eacute;dico</cellbytelabel></td>
							<td width="15%"><cellbytelabel>Nombre</cellbytelabel> </td>
							<td width="15%"><cellbytelabel>Apellido</cellbytelabel> </td>
							<td width="15%"><cellbytelabel>Fecha de Ingreso</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Benef. Cheque</cellbytelabel></td>
							<td width="28%"><cellbytelabel>Nombre de Empresa</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addMedico","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Médicos")%></td>
						</tr>
								<%
								al = CmnMgr.reverseRecords(iMed);				
								for (int i=1; i<=iMed.size(); i++)
								{
									key = al.get(i - 1).toString();									  
									CommonDataObject cdo = (CommonDataObject) iMed.get(key);
									String fecha_ingreso = "fecha_ingreso"+i;
								%>
						<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
						<%=fb.hidden("cod_medico"+i,cdo.getColValue("cod_medico"))%>
						<%=fb.hidden("primer_nombre"+i,cdo.getColValue("primer_nombre"))%>
						<%=fb.hidden("primer_apellido"+i,cdo.getColValue("primer_apellido"))%>
						<%=fb.hidden("nombre_cheque"+i,cdo.getColValue("nombre_cheque"))%>
						<%=fb.hidden("cod_empresa"+i,cdo.getColValue("empresa"))%>
						<%=fb.hidden("fechaIngreso"+i,cdo.getColValue("fecha_ingreso"))%>
						<%=fb.hidden("remove"+i,"")%>
					
					<tr class="TextRow01">
						
						<td><%=cdo.getColValue("key")%></td>
						<td><%=cdo.getColValue("cod_medico")%></td>
						<td><%=cdo.getColValue("primer_nombre")%></td>
						<td><%=cdo.getColValue("primer_apellido")%></td>
						<td align="center">
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="<%=fecha_ingreso%>" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_ingreso")%>" />
								</jsp:include>
						</td>
						<td><%=fb.select("nombre_cheque"+i,"M=MEDICO,A=ASOCIACION",cdo.getColValue("nombre_cheque"))%></td>
						<td><%=fb.intBox("empresa"+i,cdo.getColValue("empresa"),false,false,true,3,null,null,"onDblClick=\"javascript:clearCentro2()\"")%>
								<%=fb.textBox("nombreEmpresa"+i,cdo.getColValue("nombreEmpresa"),false,false,true,25,null,null,"onDblClick=\"javascript:clearCentro2()\"")%>
								<%=fb.button("btnCentro2"+i,".:.",false,false,null,null,"onClick=\"javascript:showEmpresaList("+i+")\"")%></td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Médico")%></td>
					
					</tr>
					
<%
}
%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel> 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- =======================   F O R M   E N D   H E R E   ======================= -->

				</table>

<!-- TAB1 DIV END HERE-->
</div>



<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- =========================   F O R M   S T A R T   H E R E   ====================== -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("num",num)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("medSize",""+iMed.size())%>
<%=fb.hidden("medLastLineNo",""+medLastLineNo)%>
<%=fb.hidden("procSize",""+iProc.size())%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("ocenSize",""+iOcen.size())%>
<%=fb.hidden("ocenLastLineNo",""+ocenLastLineNo)%>
<%=fb.hidden("fp",fp)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Centro de Servicio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
						<td width="15%" align="right"><cellbytelabel>Contrato No</cellbytelabel>.</td>
						<td width="15%"><%=med.getColValue("codigo")%></td>
						<td width="15%" align="right"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
						<td width="55%"> 	<%=med.getColValue("centroDesc")%> </td>
				</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(21)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Procedimientos</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus21" style="display:none">+</label><label id="minus21">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel21">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="50%"><cellbytelabel>Nombre del Procedimiento</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Precio</cellbytelabel></td>
							<td width="15%"><cellbytelabel>Tipo Valor</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addProc","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Procedimiento")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iProc);				
for (int i=1; i<=iProc.size(); i++)
{
  key = al.get(i - 1).toString();									  
  CommonDataObject cdo = (CommonDataObject) iProc.get(key);
%>
						<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
						<%=fb.hidden("cod_procedimiento"+i,cdo.getColValue("cod_procedimiento"))%>
						<%=fb.hidden("descProcedimiento"+i,cdo.getColValue("descProcedimiento"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("cod_procedimiento")%></td>
							<td><%=cdo.getColValue("descProcedimiento")%></td>
							<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%></td>
							<td align="center"><%=fb.select("tipo_valor"+i,"M=MONETARIO,P=PORCENTUAL",cdo.getColValue("tipo_valor"))%></td>
							<td align="right"><%=fb.decBox("monto"+i,CmnMgr.getFormattedDecimal(cdo.getColValue("monto")))%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel> 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ========================   F O R M   E N D   H E R E   ======================== -->

				</table>

<!-- TAB2 DIV END HERE-->
</div>

<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

	<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ==========================   F O R M   S T A R T   H E R E   ======================= -->

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("num",num)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("medSize",""+iMed.size())%>
<%=fb.hidden("medLastLineNo",""+medLastLineNo)%>
<%=fb.hidden("procSize",""+iProc.size())%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("ocenSize",""+iOcen.size())%>
<%=fb.hidden("ocenLastLineNo",""+ocenLastLineNo)%>
<%=fb.hidden("fp",fp)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Otros Centros</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel30">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
								<td width="15%" align="right"><cellbytelabel>Contrato No</cellbytelabel>.</td>
								<td width="15%"><%=med.getColValue("codigo")%></td>
								<td width="15%" align="right"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
								<td width="55%"> 	<%=med.getColValue("centroDesc")%> </td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(31)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Centros Beneficiarios</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus31" style="display:none">+</label><label id="minus31">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
	</tr>
	<tr id="panel31">
		<td>
		<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="50%">Descripci&oacute;n</td>
					<td width="15%"><cellbytelabel>Porcentaje</cellbytelabel></td>
					<td width="15%"><cellbytelabel>Monto</cellbytelabel></td>
					<td width="5%"><%=fb.submit("addOcentro","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Otros Centros")%></td>
				</tr>
							<%
							al = CmnMgr.reverseRecords(iOcen);				
							for (int i=1; i<=iOcen.size(); i++)
							{
								key = al.get(i - 1).toString();									  
								CommonDataObject cdo = (CommonDataObject) iOcen.get(key);
							%>
								<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
								<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
								<%=fb.hidden("codigoDesc"+i,cdo.getColValue("codigoDesc"))%>
								<%=fb.hidden("remove"+i,"")%>
			<tr class="TextRow01">
				<td><%=cdo.getColValue("codigo")%></td>
				<td><%=cdo.getColValue("codigoDesc")%></td>
				<td align="center"><%=fb.select("tipo_valor"+i,"M=MONETARIO,P=PORCENTUAL",cdo.getColValue("tipo_valor"),"S")%></td>
				<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
				<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
			</tr>
<%
}
%>
			</table>
		</td>
	</tr>

	<tr class="TextRow02">
		<td align="right">
					<cellbytelabel>Opciones de Guardar</cellbytelabel>: 
					<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel> 
					<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel> 
					<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel> 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
		</td>
	</tr>
		<%fb.appendJsValidation("if(!principalChecked()){alert(\'Por favor asignar un centro!\');error++;}");%>
		<%=fb.formEnd(true)%>

<!-- ======================   F O R M   E N D   H E R E   =================== -->

	</table>

<!-- TAB3 DIV END HERE-->
</div>

<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
if (mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Datos del Contrato'),0,'100%','');
<%
}
else
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Datos del Contrato','Médicos','Procedimientos','Otros Centros'),<%=tab%>,'100%','');
<%
}
%>
</script>

			</td>
		</tr>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	fp = request.getParameter("fp");
	if (tab.equals("0")) //contrato centro servicio
	{
		med = new CommonDataObject();

  	med.setTableName("tbl_cxp_contrato_centro_serv");
		med.addColValue("estado",request.getParameter("estado"));
		med.addColValue("fecha_inicial",request.getParameter("fecha_inicial"));
		med.addColValue("estado",request.getParameter("estado"));
		med.addColValue("distribucion",request.getParameter("distribucion"));
		if (request.getParameter("porcentaje") != null && !request.getParameter("porcentaje").equals("")) med.addColValue("porcentaje",request.getParameter("porcentaje"));
		if (request.getParameter("fecha_final") != null) med.addColValue("fecha_final",request.getParameter("fecha_final"));
		if (request.getParameter("responsable") != null) med.addColValue("responsable",request.getParameter("responsable"));
		if (request.getParameter("fecha_pago") != null) med.addColValue("fecha_pago",request.getParameter("fecha_pago"));
		if (request.getParameter("user_aprobado") != null) med.addColValue("user_aprobado",request.getParameter("user_aprobado"));
		if (request.getParameter("observacion") != null) med.addColValue("observacion",request.getParameter("observacion"));
		if (request.getParameter("procedimiento") != null) med.addColValue("procedimiento",request.getParameter("procedimiento"));
		if (request.getParameter("tipo") != null) med.addColValue("tipo",request.getParameter("tipo"));
		if (request.getParameter("codEmpresa") != null) med.addColValue("cod_empresa",request.getParameter("codEmpresa"));
		if (request.getParameter("porcentaje_clin") != null) med.addColValue("porcentaje_clin",request.getParameter("porcentaje_clin"));
		if (request.getParameter("monto_desc") != null) med.addColValue("monto_desc",request.getParameter("monto_desc"));
		if (request.getParameter("cant_desc") != null) med.addColValue("cant_desc",request.getParameter("cant_desc"));
		if (request.getParameter("deducible") != null) med.addColValue("deducible",request.getParameter("deducible"));
		if (request.getParameter("tipo_liq") != null) med.addColValue("tipo_liq",request.getParameter("tipo_liq"));
		
		med.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		med.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
      num = request.getParameter("codigo");
			id = request.getParameter("centro");
	  if (mode.equalsIgnoreCase("add"))
  	{
			med.addColValue("num_contrato",request.getParameter("codigo"));
			med.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			med.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));

			SQLMgr.insert(med);
			id = request.getParameter("codigo");
			num = request.getParameter("centro");
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
			med.setWhereClause("cod_centro_servicio = "+id+" and num_contrato="+num+"");

			SQLMgr.update(med);
		}
	}
	
	
	else if (tab.equals("1")) //MEDICOS
	{
		int size = 0;
		if (request.getParameter("medSize") != null) size = Integer.parseInt(request.getParameter("medSize"));
		String itemRemoved = "";
		String medico = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();
			medico = request.getParameter("cod_medico"+i);
			cdo.setTableName("tbl_cxp_contrato_medico");  
			cdo.setWhereClause("num_contrato = "+num+" and cod_medico = '"+medico+"' and cod_centro_servicio="+id);
			
			cdo.addColValue("nombre_cheque",request.getParameter("nombre_cheque"+i));
			cdo.addColValue("num_contrato",request.getParameter("num_contrato"+i));
			cdo.addColValue("cod_centro_servicio",request.getParameter("cod_centro_servicio"+i));
			cdo.addColValue("cod_medico",request.getParameter("cod_medico"+i));
			cdo.addColValue("cod_empresa",request.getParameter("cod_empresa"+i));
			cdo.addColValue("fecha_ingreso",request.getParameter("fechaIngreso"+i));
			
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));
			cdo.addColValue("key",request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				itemRemoved = cdo.getColValue("key");  
			else 
			{
				try
				{
					iMed.put(cdo.getColValue("key"),cdo); 
					al.add(cdo); 
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}	
		}

		if (!itemRemoved.equals(""))
		{
			vMed.remove(((CommonDataObject) iMed.get(itemRemoved)).getColValue("cod_medico"));
    	iMed.remove(itemRemoved);

	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&num="+num+"&medLastLineNo="+medLastLineNo+"&procLastLineNo="+procLastLineNo+"&ocenLastLineNo="+ocenLastLineNo);
    	return;
		}

		if (baction != null && baction.equals("+"))
		{
		
		  response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&mode="+mode+"&id="+id+"&num="+num+"&medLastLineNo="+medLastLineNo+"&procLastLineNo="+procLastLineNo+"&ocenLastLineNo="+ocenLastLineNo);
    	return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

            cdo.setTableName("tbl_cxp_contrato_medico");  
			      cdo.setWhereClause("num_contrato = '"+num+"' and cod_medico = '"+medico+"' and cod_centro_servicio='"+id+"'");

			al.add(cdo); 
		}

		SQLMgr.insertList(al);
	}
	else if (tab.equals("2")) //SOCIEDAD
	{
		int size = 0;
		if (request.getParameter("procSize") != null) size = Integer.parseInt(request.getParameter("procSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_medico_sociedad_medica");  
			cdo.setWhereClause("medico='"+id+"'");
			cdo.addColValue("empresa",request.getParameter("empresa"+i));
			cdo.addColValue("medico",id);
			cdo.addColValue("estado",request.getParameter("estado"+i));
			cdo.addColValue("comentario",request.getParameter("comentario"+i));

			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("empresaNombre",request.getParameter("empresaNombre"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				itemRemoved = cdo.getColValue("key");  
			else 
			{
				try
				{
					iProc.put(cdo.getColValue("key"),cdo); 
					al.add(cdo); 
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}	
		}

		if (!itemRemoved.equals(""))
		{
			vProc.remove(((CommonDataObject) iProc.get(itemRemoved)).getColValue("cod_procedimiento"));
    	iProc.remove(itemRemoved);

	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&id="+id+"&num="+num+"&medLastLineNo="+medLastLineNo+"&procLastLineNo="+procLastLineNo+"&ocenLastLineNo="+ocenLastLineNo);
    	return;
		}

		if (baction != null && baction.equals("+"))
		{
	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&type=1&mode="+mode+"&id="+id+"&num="+num+"&medLastLineNo="+medLastLineNo+"&procLastLineNo="+procLastLineNo+"&ocenLastLineNo="+ocenLastLineNo);
    	return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_medico_sociedad_medica");  
			cdo.setWhereClause("medico='"+id+"'");

			al.add(cdo); 
		}

		SQLMgr.insertList(al);
	}
	else if (tab.equals("3")) //OTROS CENTROS
	{
		int size = 0;
		if (request.getParameter("ocenSize") != null) size = Integer.parseInt(request.getParameter("ocenSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_medico_ubicacion");  
			cdo.setWhereClause("medico='"+id+"'");
			cdo.addColValue("ubicacion",request.getParameter("ubicacion"+i));
			cdo.addColValue("medico",id);
			cdo.addColValue("telefono",request.getParameter("telefono"+i));
			cdo.addColValue("principal",(request.getParameter("principal"+i) == null)?"N":"S");

			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("ubicacionDesc",request.getParameter("ubicacionDesc"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				itemRemoved = cdo.getColValue("key");  
			else 
			{
				try
				{
					iOcen.put(cdo.getColValue("key"),cdo); 
					al.add(cdo); 
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}	
		}

		if (!itemRemoved.equals(""))
		{
			vOcen.remove(((CommonDataObject) iOcen.get(itemRemoved)).getColValue("ubicacion"));
    	iOcen.remove(itemRemoved);

	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&id="+id+"&num="+num+"&medLastLineNo="+medLastLineNo+"&procLastLineNo="+procLastLineNo+"&ocenLastLineNo="+ocenLastLineNo);
    	return;
		}

		if (baction != null && baction.equals("+"))
		{
	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&type=1&mode="+mode+"&id="+id+"&num="+num+"&medLastLineNo="+medLastLineNo+"&procLastLineNo="+procLastLineNo+"&ocenLastLineNo="+ocenLastLineNo);
    	return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_medico_ubicacion");  
			cdo.setWhereClause("medico='"+id+"'");

			al.add(cdo); 
		}

		SQLMgr.insertList(al);
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
	if (tab.equals("0"))
	{	
		if(fp!= null && fp.equalsIgnoreCase("admision"))
		{
%>
		window.opener.location = '<%=request.getContextPath()%>/common/search_centro_servicio.jsp?fp=cargo_tardio';
		window.close();
<%
		}
		else if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxp/contrato_centro_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxp/contrato_centro_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/cxp/contrato_centro_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>&num=<%=num%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>