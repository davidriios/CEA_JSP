<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
==============================================================================
==============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500021") || SecMgr.checkAccess(session.getId(),"500022") || SecMgr.checkAccess(session.getId(),"500023") || SecMgr.checkAccess(session.getId(),"500024"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList list = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String seccion = request.getParameter("seccion");
String area = request.getParameter("area");
String grupo = request.getParameter("grupo");
String key = "";
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String periodo = request.getParameter("periodo");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

int lastLineNo = 0;
if(anio==null) anio = "";
if(mes==null) mes = "";
//if (seccion == null) throw new Exception("La sección no es válida. Por favor intente nuevamente!");
if (area == null || grupo == null) throw new Exception("El Registro no es válido. Por favor intente nuevamente!");


if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
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

 
    String nombre="",cedula="";
  if (request.getParameter("cedula") != null && !request.getParameter("cedula").trim().equals(""))
  {
		appendFilter += " and upper(b.cedula1) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
    	cedula = request.getParameter("cedula");
  }
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
  {
		appendFilter += " and upper(b.nombre_empleado) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    nombre = request.getParameter("nombre");
  }
  

  if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
		if (searchType.equals("1"))	appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }

  if(request.getParameter("mes") != null && !request.getParameter("mes").equals("") && request.getParameter("anio") != null && !request.getParameter("anio").equals(""))
  {
	appendFilter += " and a.ubicacion_fisica = "+area+" and a.fecha_ingreso_grupo <= last_day(to_date("+request.getParameter("mes")+"||'-'||"+request.getParameter("anio")+",'mm-yyyy')) and (a.fecha_egreso_grupo is null or a.fecha_egreso_grupo >= last_day(to_date("+request.getParameter("mes")+"||'-'||"+request.getParameter("anio")+",'mm-yyyy')) or to_number(to_char(a.fecha_egreso_grupo,'yyyymm')) = to_number(to_char(to_date("+request.getParameter("mes")+"||'-'||"+request.getParameter("anio")+",'mm-yyyy'),'yyyymm')))";
  }

  sql = "SELECT a.provincia, a.sigla, a.tomo, a.asiento, a.emp_id, b.unidad_organi, to_char(a.fecha_ingreso_grupo, 'dd/mm/yyyy') as fecha, b.cedula1 as cedula, a.num_empleado, b.nombre_empleado as nombre, nvl(b.rata_hora, 0) as rata, nvl(b.horas_base, 0) as horaBase, b.fecha_inicio_incapacidad, b.cargo FROM tbl_pla_ct_empleado a, vw_pla_empleado b WHERE a.emp_id = b.emp_id and a.compania = b.compania and a.estado not in(3,13)  and a.compania="+(String) session.getAttribute("_companyId")+" and a.grupo ="+grupo+appendFilter;
  al = SQLMgr.getDataList(sql);

  iEmp.clear();
  for (int i = 1; i <= al.size(); i++)
  {
	if (i < 10) key = "00" + i;
	else if (i < 100) key = "0" + i;
	else key = "" + i;
	iEmp.put(key, al.get(i-1));
  }

	CommonDataObject cdoArea = new CommonDataObject();
	if(area!=null && !area .equals("")){
		sql = "select nombre from tbl_pla_ct_area_x_grupo where compania = "+(String) session.getAttribute("_companyId")+" and grupo = "+grupo+" and codigo = " + area;
		cdoArea = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Listado de Empleados - '+document.title;
function verifyCheck(k){
	var seccion = 0;
	if (document.formEmpleado.seccion.value != null && document.formEmpleado.seccion.value != ""){
	   seccion = document.formEmpleado.seccion.value;
	   if(seccion == '8' || seccion == '4'){ parent.doRedirect(seccion, '1', '7');}
	   else if(seccion == '7'){ parent.doRedirect(seccion, '1', '1');}
	   else {parent.doRedirect(seccion,'0',0);}
	}
}
function listar(k)
{

	var seccion;
	seccion = document.formEmpleado.seccion.value;
	if (seccion == '7')
	{
       parent.doRedirect('17','1',k);
	}
	else if (seccion == '1')
	{
	   parent.doRedirect('21','1',k);
	}
	else if (seccion == '8')
	{
	   parent.doRedirect('18','1',k);
	}
	else if (seccion == '4')
	{
	   parent.doRedirect('21','1',k);
	}
	 else if (seccion == '6')
	{
	   parent.doRedirect('16','1',k);
	}
	 else if (seccion == '9')
	{
	   parent.doRedirect('19','1',k);
	}
		else if (seccion == '5')
	{
	   parent.doRedirect('15','1',k);
	}
		else if (seccion == '24')
	{
	   parent.doRedirect('23','1',k);
	}
}
function addEmpleado(){
   var seccion;

   if (document.formEmpleado.seccion.value != ""){
      seccion = document.formEmpleado.seccion.value;
      abrir_ventana2('../common/check_empleado_asistencia.jsp?fp=empleado_asistencia&seccion='+seccion+'&grupo=<%=grupo%>&area=<%=area%>');
   } else {
      abrir_ventana2('../common/check_empleado_asistencia.jsp?fp=empleado_asistencia&grupo=<%=grupo%>&area=<%=area%>');
   }
}

function redirect(){
	document.formEmpleado.seccion.value = '13';
	parent.doRedirect('13','1');
}

function setEmpDet(cbObj,ind){
  var empId = document.getElementById("emp_id"+ind).value;
  var empNum = document.getElementById("num_empleado"+ind).value;
  var prov = document.getElementById("provincia"+ind).value;
  var sigla = document.getElementById("sigla"+ind).value;
  var tomo = document.getElementById("tomo"+ind).value;
  var asiento = document.getElementById("asiento"+ind).value;
  var nombreEmp = document.getElementById("nombre"+ind).value;
  var anio = document.getElementById("anio").value;
  var mes = document.getElementById("mes").value;

  var strQs = "&empId="+empId+"&empNum="+empNum+"&prov="+prov+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&checkedEmp="+ind+"&nombreEmp="+nombreEmp+"&anio="+anio+"&mes="+mes;

  if(!cbObj.checked) strQs = new String();

  document.getElementById("curEmpDet").value = strQs;
}
function setIndex(k){document.formEmpleado.index.value=k;checkOne('formEmpleado','check',<%=al.size()%>,eval('document.formEmpleado.check'+k),0);}
</script>
</head>
<body topmargin="0" leftmargin="0">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextFilter">
			<%fb = new FormBean("search01",request.getContextPath()+request.getServletPath());%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("area",area)%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("provincia","")%>
					<%=fb.hidden("sigla","")%>
					<%=fb.hidden("tomo","")%>
					<%=fb.hidden("asiento","")%>
					<%=fb.hidden("numEmpleado","")%>
					<%=fb.hidden("lastLineNo",""+lastLineNo)%>
					<%=fb.hidden("seccion",seccion)%>
					<tr class="TextFilter"><td width="15%">C&eacute;dula
						<%=fb.textBox("cedula","",false,false,false,10)%>
					</td>
					<td width="25%">Nombre
						<%=fb.textBox("nombre","",false,false,false,20)%>
					</td>

					<td width="60%"><%=area%>&nbsp;-&nbsp;<%=cdoArea.getColValue("nombre")%>
						<a> A&ntilde;o<%=fb.textBox("anio",anio,false,false,false,4)%></a>
						Mes<%=fb.select("mes","1=Enero,2=Febrero,3=Marzo,4=Abril,5=Mayo,6=Junio,7=Julio,8=Agosto,9=Septiembre,10=Octubre,11=Noviembre,12=Diciembre",mes,"T")%>
						<a> Quincena<%=fb.select("periodo","1=Primera,2=Segunda,3=Ambas",periodo)%>
						<%=fb.submit("go","Ir")%> </a>
					</td>
					<%=fb.formEnd()%>
					</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("formEmpleado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("periodo",periodo)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("curEmpDet","")%>
<%=fb.hidden("index","")%>
	<tr>
		<td>

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding=".5" cellspacing=".5">
				<tr class="TextHeader" align="center">
					<td colspan="4">C&eacute;dula</td>
					<td>Nombre</td>
					<td>No. Empleado</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td><%=fb.button("btnAgregar","Agregar",true,false,null,null,"onClick=\"javascript:addEmpleado()\"")%><%=fb.submit("btnInactivar","Inactivar",true,false)%></td>
					<td>&nbsp;<%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todas las funciones listadas!")%></td>
				</tr>
				<%
				    for (int i=0; i<al.size(); i++)
					{
						cdo = (CommonDataObject) al.get(i);
						String color = "TextRow02";
						if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
				<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
				<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
				<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
				<%=fb.hidden("num_empleado"+i,cdo.getColValue("num_empleado"))%>
				<%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
				<%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
				<%=fb.hidden("unidad_organi"+i,cdo.getColValue("unidad_organi"))%>
				<%=fb.hidden("rata"+i,cdo.getColValue("rata"))%>
				<%=fb.hidden("horaBase"+i,cdo.getColValue("horaBase"))%>
        <%=fb.hidden("fecha_ini_incapacidad"+i,cdo.getColValue("fecha_inicio_incapacidad"))%>
				<%=fb.hidden("cargo"+i,cdo.getColValue("cargo"))%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td width="5%"><%=cdo.getColValue("provincia")%></td>
					<td width="5%"><%=cdo.getColValue("sigla")%></td>
					<td width="5%"><%=cdo.getColValue("tomo")%></td>
					<td width="7%"><%=cdo.getColValue("asiento")%></td>
					<td width="30%"><%=cdo.getColValue("nombre")%></td>
					<td width="15%" align="center"><%=cdo.getColValue("num_empleado")%></td>
					<td width="5%" align="right"><//%=cdo.getColValue("rata")%></td>
					<td width="5%" align="right"><//%=cdo.getColValue("horaBase")%></td>
					<td width="18%">&nbsp;&nbsp;&nbsp;<%=fb.button("btnVer"+i,"Ver",true,true,null,null,"onClick=\"javascript:listar("+i+")\"")%></td>
					<td width="5%" align="center"><%=fb.checkbox("check"+i,"S",false,false,null,null,"onClick=\"setIndex("+i+"); verifyCheck("+i+"); setEmpDet(this,"+i+")\"")%></td>
				</tr>
				<%
				    }
				%>
			</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

		</td>
	</tr>
<%=fb.formEnd()%>
</table>
</body>
</html>
<%
}
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	area = request.getParameter("area");
	grupo = request.getParameter("grupo");
	seccion = request.getParameter("seccion");
	anio = request.getParameter("anio");
	mes = request.getParameter("mes");
	periodo = request.getParameter("periodo");

	System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SIZE = "+size);

	if (size > 0)
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				cdo = new CommonDataObject();

				cdo.setTableName("tbl_pla_ct_empleado");
				cdo.setWhereClause("provincia ="+request.getParameter("provincia"+i)+" and sigla='"+request.getParameter("sigla"+i)+"' and tomo ="+request.getParameter("tomo"+i)+" and asiento ="+request.getParameter("asiento"+i)+" and num_empleado ='"+request.getParameter("num_empleado"+i)+"' and grupo ="+grupo+" and compania= "+(String) session.getAttribute("_companyId"));
				cdo.addColValue("provincia",request.getParameter("provincia"+i));
				cdo.addColValue("sigla",request.getParameter("sigla"+i));
				cdo.addColValue("tomo",request.getParameter("tomo"+i));
				cdo.addColValue("asiento",request.getParameter("asiento"+i));
				cdo.addColValue("num_empleado",request.getParameter("num_empleado"+i));
				cdo.addColValue("emp_id",request.getParameter("emp_id"+i));
				cdo.addColValue("unidad_organi",request.getParameter("unidad_organi"+i));
				cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
				cdo.addColValue("grupo",grupo);
				cdo.addColValue("cedula",request.getParameter("cedula"+i));
				cdo.addColValue("nombre",request.getParameter("nombre"+i));
				cdo.addColValue("fecha_ingreso_grupo",request.getParameter("fecha"+i));
				cdo.addColValue("fecha_modificacion", "sysdate");
				cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_egreso_grupo", cDate);
				cdo.addColValue("estado","3");
			    list.add(cdo);
			}
		}
		SQLMgr.updateList(list);//FALTA IMPLEMENTAR AUDITORIA ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{alert("<%=seccion%>")
	window.location = '../rhplanilla/check_empleado.jsp?area=<%=area%>&grupo=<%=grupo%>&seccion=<%=seccion%>&anio=<%=anio%>&mes=<%=mes%>&periodo=<%=periodo%>';
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>