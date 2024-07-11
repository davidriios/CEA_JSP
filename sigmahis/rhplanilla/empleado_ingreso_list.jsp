<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="hteducacion"  scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htcursof"     scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="hthabilidad"  scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htentrevista" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htidioma"     scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htenfermedad" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htmedida"     scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htreconocit"  scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htpariente"   scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vcteducacion" scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctcursof"    scope="session" class="java.util.Vector"/>
<jsp:useBean id="vcthabilidad" scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctentrete"   scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctidioma"    scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctenfermed"  scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctmedidas"   scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctreconoc"   scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctpariente"  scope="session" class="java.util.Vector"/>
<%
/**
==============================================================================================
==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alEduc = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String index = request.getParameter("index");
String tipo = request.getParameter("tipo");
String key = "";
if(tipo == null) tipo = "E";
int educaLastLineNo = 0;
int cursoLastLineNo = 0;
int habilidadLastLineNo = 0;
int entrenimientoLastLineNo = 0;
int idiomaLastLineNo = 0;
int enfermedadLastLineNo= 0;
int medidadLastLineNo = 0;
int reconocimientoLastLineNo = 0;
int parienteLastLineNo =0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage=100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}
	String nombre="",cedula ="";
	if (request.getParameter("cedula") != null && !request.getParameter("cedula").equals(""))
	{
		appendFilter += " and upper(provincia||'-'||sigla||'-'||tomo||'-'||asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
		cedula = request.getParameter("cedula");
	}
	if (request.getParameter("nombre") != null && !request.getParameter("nombre").equals(""))
	{
		appendFilter += " and upper(primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_casada,null,'',' '||apellido_casada))) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		nombre = request.getParameter("nombre");
	}
	
	
	if (fp.equalsIgnoreCase("ingreso_empleado"))
	{
			sql = "select * from (select  'E' as tipo ,'EMPLEADO' as DESCTIPO, 'EMPLEADOS CESANTES' as descreg, to_char(provincia)||'-'|| sigla||'-'|| tomo||'-'||asiento cedula, primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido||' '||apellido_casada as nombre, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, apellido_casada, provincia, sigla, tomo, asiento, emp_id, num_empleado, num_ssocial, 0 solicitud_anio, 0 solicitud_no,cargo codigoestructura, unidad_organi unidadadm,nvl((select denominacion from tbl_pla_cargo where compania = "+(String) session.getAttribute("_companyId")+" and codigo = cargo), ' ') newcargodest,nvl((select descripcion from tbl_sec_unidad_ejec where compania = "+(String) session.getAttribute("_companyId")+" and codigo = unidad_organi), ' ') newPosicionDest,salario_base as salariodest from  vw_pla_empleado where estado =  3 and compania= "+(String) session.getAttribute("_companyId")+appendFilter+"  /* union select 'S' as tipo, 'ASPIRANTE' as desctipo, 'SOLICITUDES REGISTRADAS' as descreg, to_char(provincia)||'-'|| sigla||'-'|| to_char(tomo,'09999')||'-'||to_char(asiento,'099999') cedula, primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido||' '||apellido_casada as nombre,  primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, apellido_casada, provincia, sigla, tomo, asiento, null as emp_id, null as num_empleado, '9999999' as num_ssocial, anio solicitud_anio, consecutivo solicitud_no from   tbl_pla_solicitante where estado_solicitante not in(4,5) and compania = "+(String) session.getAttribute("_companyId")+appendFilter+"*/ order by   tipo, nombre ) where tipo = '"+tipo+"'" ;

		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

	} else if (fp.equalsIgnoreCase("ingreso_solicitud"))
	{
	 sql = "select to_char(provincia)||'-'||sigla||'-'||to_char(tomo,'09999')||'-'||to_char(asiento,'099999') cedula, primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido||' '||apellido_casada nombre,  primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, apellido_casada, provincia, sigla, tomo, asiento, anio||' - '||consecutivo as emp_id,'S' as tipo, 'ASPIRANTE' as desctipo, 'SOLICITANTES REGISTRADOS' as descreg  from   tbl_pla_solicitante where estado_solicitante not in(4,5) and compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by  nombre " ;
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

		/////  EDUCAcION DEL SOLICITANTE ///////
		sql="select a.sol_anio as anio, a.sol_consecutivo as cons, a.codigo, a.centro_educativo, a.carrera, a.certificado_obt, to_char(a.fecha_inicio,'dd/mm/yyyy') as fecha_inicio, to_char(a.fecha_final,'dd/mm/yyyy') as fecha_final, a.anio_cursado, a.tipo_educacion as tipo, a.termino, b.provincia as pr, b.sigla as s, b.tomo as t, b.asiento as ast, b.primer_nombre, b.primer_apellido, c.codigo as cot, c.descripcion as educacioName from tbl_pla_educacion_soli a, tbl_pla_solicitante b, tbl_pla_tipo_educacion c where a.sol_anio=b.anio and a.sol_consecutivo = b.consecutivo and a.tipo_educacion=c.codigo  and b.compania="+(String) session.getAttribute("_companyId");
		alEduc=SQLMgr.getDataList(sql);

		hteducacion.clear();
		htcursof.clear();
		hthabilidad.clear();
		htentrevista.clear();
		htidioma.clear();
		htenfermedad.clear();
		htmedida.clear();
		htreconocit.clear();
		htpariente.clear();
		vcteducacion.clear();
		vctcursof.clear();
		vcthabilidad.clear();
		vctentrete.clear();
		vctidioma.clear();
		vctenfermed.clear();
		vctmedidas.clear();
		vctreconoc.clear();
		vctpariente.clear();

		educaLastLineNo= alEduc.size();
		for(int i=1; i<=alEduc.size(); i++)
		{
		CommonDataObject cdo = (CommonDataObject) alEduc.get(i-1);

		if(i<10)  key = "00"+i;
		else if(i<100)
		key = "0"+i;
		else
		key= ""+i;
		cdo.addColValue("key",key);
		try
		{
		hteducacion.put(key,cdo);
		vcteducacion.addElement(cdo.getColValue("tipo"));
		}//End Try
		catch (Exception e)
		{
		System.err.println(e.getMessage());
		}//End Catch
		}//End for

	}


	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);

	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;

	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Empleados - Aspirantes '+document.title;

function setEmpleado(k)
{
		<%
	if (fp.equalsIgnoreCase("ingreso_empleado"))
	{
		%>
	var tipo= eval('document.empleado.tipo'+k).value;
		if(tipo=="E")
		{
		window.opener.document.form4.provincia.value = eval('document.empleado.provincia'+k).value;
		window.opener.document.form4.sigla.value = eval('document.empleado.sigla'+k).value;
		window.opener.document.form4.tomo.value = eval('document.empleado.tomo'+k).value;
		window.opener.document.form4.asiento.value = eval('document.empleado.asiento'+k).value;
		window.opener.document.form4.emp_id.value = eval('document.empleado.emp_id'+k).value;
		window.opener.document.form4.primer_nombre.value = eval('document.empleado.primer_nombre'+k).value;
		window.opener.document.form4.segundo_nombre.value = eval('document.empleado.segundo_nombre'+k).value;
		window.opener.document.form4.primer_apellido.value = eval('document.empleado.primer_apellido'+k).value;
		window.opener.document.form4.segundo_apellido.value = eval('document.empleado.segundo_apellido'+k).value;
		window.opener.document.form4.apellido_casada.value = eval('document.empleado.apellido_casada'+k).value;
		//window.opener.document.form4.numEmpleado.value = eval('document.empleado.num_empleado'+k).value;
		window.opener.document.form4.numSS.value = eval('document.empleado.num_ssocial'+k).value;
		window.opener.document.form4.origenDatos.value = 2;
		window.opener.document.form4.seccion_dest.value = eval('document.empleado.unidadadm'+k).value;		
		window.opener.document.form4.seccion_desc.value = eval('document.empleado.newPosicionDest'+k).value;
		window.opener.document.form4.cargo_dest.value = eval('document.empleado.cargo'+k).value;
		window.opener.document.form4.cargo_desc.value = eval('document.empleado.newcargodest'+k).value;
		window.opener.document.form4.newSalario.value = eval('document.empleado.salariodest'+k).value;
		
		}
		else
		{
			var prov  = eval('document.empleado.provincia'+k).value;
			var sig   = eval('document.empleado.sigla'+k).value;
			var tom   = eval('document.empleado.tomo'+k).value;
			var asi   = eval('document.empleado.asiento'+k).value;
			var empId = eval('document.empleado.emp_id'+k).value;

			window.opener.document.form4.provincia.value = eval('document.empleado.provincia'+k).value;
		window.opener.document.form4.sigla.value = eval('document.empleado.sigla'+k).value;
		window.opener.document.form4.tomo.value = eval('document.empleado.tomo'+k).value;
		window.opener.document.form4.asiento.value = eval('document.empleado.asiento'+k).value;
		window.opener.document.form4.emp_id.value = eval('document.empleado.emp_id'+k).value;
		window.opener.document.form4.primer_nombre.value = eval('document.empleado.primer_nombre'+k).value;
		window.opener.document.form4.segundo_nombre.value = eval('document.empleado.segundo_nombre'+k).value;
		window.opener.document.form4.primer_apellido.value = eval('document.empleado.primer_apellido'+k).value;
		window.opener.document.form4.segundo_apellido.value = eval('document.empleado.segundo_apellido'+k).value;
		window.opener.document.form4.apellido_casada.value = eval('document.empleado.apellido_casada'+k).value;
		//window.opener.document.form4.numEmpleado.value = eval('document.empleado.num_empleado'+k).value;
		//window.opener.document.form4.numSocial.value = eval('document.empleado.num_ssocial'+k).value;
		window.opener.document.form4.origenDatos.value = 1;
		window.opener.document.form4.sol_empleo_anio.value = eval('document.empleado.solicitud_anio'+k).value;
		window.opener.document.form4.sol_empleo_no.value = eval('document.empleado.solicitud_no'+k).value;



		//  abrir_ventana2('../rhplanilla/expediente_empleado_config.jsp?fp=ingreso&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi);
		}
	<%
		} else
	if (fp.equalsIgnoreCase("ingreso_solicitud"))
	{
	%>
			var prov = eval('document.empleado.provincia'+k).value;
			var sig  = eval('document.empleado.sigla'+k).value;
			var tom  = eval('document.empleado.tomo'+k).value;
			var asi  = eval('document.empleado.asiento'+k).value;
			var anio = eval('document.empleado.anio'+k).value;
			var cons = eval('document.empleado.cons'+k).value;

		abrir_ventana2('../rhplanilla/expediente_empleado_config.jsp?fg=ingreso&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi+'&anio='+anio+'&consecutivo='+cons);
	<%
	}
	%>

		window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<td width="50%">
					C&eacute;dula
					<%=fb.textBox("cedula","",false,false,false,40)%>
					</td>
					<td width="50%">
					Nombre
					<%=fb.textBox("nombre","",false,false,false,40)%>
					<%
					if (fp.equalsIgnoreCase("ingreso_empleado")){
					%>
					&nbsp;&nbsp;
					Tipo:
					<%=fb.select("tipo", "E=Empleado", tipo)%>
					<%
					}
					%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>

				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("cedula",cedula)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("cedula",cedula)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="expe">
				<tr class="TextHeader" align="center">
					<td width="20%">No.</td>
					<td width="30%">C&eacute;dula</td>
					<td width="40%">Nombre</td>
					<td width="10%">Tipo</td>
				</tr>
<%
fb = new FormBean("empleado",request.getContextPath()+"/common/urlRedirect.jsp");
%>
<%=fb.formStart()%>
<%
String desc = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";

	if (i % 2 == 0) color = "TextRow01";

%>

				<%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
				<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
				<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
				<%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
				<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
				<%=fb.hidden("primer_nombre"+i,cdo.getColValue("primer_nombre"))%>
				<%=fb.hidden("segundo_nombre"+i,cdo.getColValue("segundo_nombre"))%>
				<%=fb.hidden("primer_apellido"+i,cdo.getColValue("primer_apellido"))%>
				<%=fb.hidden("segundo_apellido"+i,cdo.getColValue("segundo_apellido"))%>
				<%=fb.hidden("apellido_casada"+i,cdo.getColValue("apellido_casada"))%>
				<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
				<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
				<%=fb.hidden("cons"+i,cdo.getColValue("cons"))%>
				<%=fb.hidden("num_empleado"+i,cdo.getColValue("num_empleado"))%>
				<%=fb.hidden("num_ssocial"+i,cdo.getColValue("num_ssocial"))%>
				<%=fb.hidden("solicitud_no"+i,cdo.getColValue("solicitud_no"))%>
				<%=fb.hidden("solicitud_anio"+i,cdo.getColValue("solicitud_anio"))%>
				<%=fb.hidden("unidadadm"+i,cdo.getColValue("unidadadm"))%>
				<%=fb.hidden("newcargodest"+i,cdo.getColValue("newcargodest"))%>
				<%=fb.hidden("newPosicionDest"+i,cdo.getColValue("newPosicionDest"))%>
				<%=fb.hidden("cargo"+i,cdo.getColValue("codigoestructura"))%>
				<%=fb.hidden("salariodest"+i,cdo.getColValue("salariodest"))%>
			<%
			if (!desc.equalsIgnoreCase(cdo.getColValue("tipo")))
			 {
			%>

			<tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
						<td colspan="4" class="TitulosdeTablas"> <%=cdo.getColValue("descreg")%></td>
						 </tr>
			<%
				}
			%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEmpleado(<%=i%>)" style="cursor:pointer">
					<td><%=cdo.getColValue("emp_id")%></td>
					<td><%=cdo.getColValue("cedula")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=cdo.getColValue("desctipo")%></td>
				</tr>
<%
		 desc=cdo.getColValue("tipo");
}
%>
<%=fb.formEnd()%>
</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
<%
fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("cedula",cedula)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("cedula",cedula)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
