<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.StringTokenizer" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================

==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;

String sql = "";
String appendFilter = "";
String sw = "S";
String grupo = (request.getParameter("grupo")==null?"":request.getParameter("grupo"));
String empId = (request.getParameter("empId")==null?"":request.getParameter("empId"));
String desde = (request.getParameter("desde")==null?"":request.getParameter("desde"));
String hasta = (request.getParameter("hasta")==null?"":request.getParameter("hasta"));
String accion = (request.getParameter("accion")==null?"":request.getParameter("accion"));
String tipoLugar = (request.getParameter("tipoLugar")==null?"":request.getParameter("tipoLugar"));
String motivoFalta = (request.getParameter("motivoFalta")==null?"":request.getParameter("motivoFalta"));

int iconHeight = 28;
int iconWidth = 28;

System.out.println("THEBRAIN EMPID = :::::::::::::::::::::::::::::::::::::::::::::: "+empId);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if ( !desde.trim().equals("")  && !hasta.trim().equals("") ) appendFilter = " and (a.fecha >= to_date('"+desde+"','dd/mm/yyyy') and a.fecha <= to_date('"+hasta+"','dd/mm/yyyy'))" ;
	if (!grupo.trim().equals("")) appendFilter += " and a.ue_codigo = "+grupo;
	if (!empId.trim().equals("")) appendFilter += " and a.emp_id = "+empId;
	if (!tipoLugar.trim().equals("")) appendFilter += " and a.lugar = "+tipoLugar;
	if (!motivoFalta.trim().equals("")) appendFilter += " and a.mfalta = "+motivoFalta;
	if (!accion.trim().equals("")) appendFilter += " and a.estado = '"+accion+"'";

	sql = "SELECT to_char(a.fecha,'dd/mm/yyyy') as fecha, b.descripcion as mfaltaDesc, a.codigo, decode(a.estado,'ND','No Descontar','Descontar') as estado, a.emp_id, c.primer_nombre||' '||c.primer_apellido as nombre, nvl(a.ue_codigo,'0') grupo, a.aprobado FROM tbl_pla_incapacidad a, tbl_pla_motivo_falta b, tbl_pla_empleado c WHERE a.mfalta=b.codigo and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and a.emp_id = c.emp_id and a.compania = c.compania order by a.fecha desc";

	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function edit(k)
{
   var empId;
   var grupo;
   var codi;
   var fecha;

   empId = eval('document.formIncapacidad.emp_id'+k).value;
   grupo = document.formIncapacidad.grupo.value;
   codi  = eval('document.formIncapacidad.cod'+k).value;
   fecha  = eval('document.formIncapacidad.fecha'+k).value;
   var desde  = eval('document.formIncapacidad.desde').value;
   var hasta  = eval('document.formIncapacidad.hasta').value;

   abrir_ventana1('../rhplanilla/empl_incapacidad_config.jsp?mode=edit&empId='+empId+'&grupo='+grupo+'&cod='+codi+'&fecha='+fecha+'&desde='+desde+'&hasta='+hasta);
}

function add(){
    var empDet;
    var grupo = document.formIncapacidad.grupo.value;
    if(parent.getEmpDet()){
	   empDet = parent.getEmpDet();
	}

	if (!empDet) alert("Perdona, pero usted tiene que chequear un empleado!");
	else abrir_ventana("../rhplanilla/empl_incapacidades_detail.jsp?grupo="+grupo+empDet);
}

function aprueba(k)
{
   var empId;
   var grupo;
   var codi;

   var fecha  = eval('document.formIncapacidad.fecha'+k).value;
   empId = eval('document.formIncapacidad.emp_id'+k).value;
   grupo = document.formIncapacidad.grupo.value;
   codi = eval('document.formIncapacidad.cod'+k).value;
   var desde  = eval('document.formIncapacidad.desde').value;
   var hasta  = eval('document.formIncapacidad.hasta').value;

   abrir_ventana1('../rhplanilla/empl_incapacidad_config.jsp?fp=aprob&empId='+empId+'&grupo='+grupo+'&cod='+codi+'&fecha='+fecha+'&desde='+desde+'&hasta='+hasta);
}

function ver(k)
{
   var empId;
   var grupo;
   var codi;

   var fecha  = eval('document.formIncapacidad.fecha'+k).value;
   empId = eval('document.formIncapacidad.emp_id'+k).value;
   grupo = document.formIncapacidad.grupo.value;
   codi = eval('document.formIncapacidad.cod'+k).value;
   var desde  = eval('document.formIncapacidad.desde').value;
   var hasta  = eval('document.formIncapacidad.hasta').value;

   abrir_ventana1('../rhplanilla/empl_incapacidad_config.jsp?mode=view&empId='+empId+'&grupo='+grupo+'&cod='+codi+'&fecha='+fecha+'&desde='+desde+'&hasta='+hasta);
}

function printRep(k)
{
   var empId;
   var grupo;
   var codi;

   var fecha  = eval('document.formIncapacidad.fecha'+k).value;
   empId = eval('document.formIncapacidad.emp_id'+k).value;
   grupo = document.formIncapacidad.grupo.value;
   codi = eval('document.formIncapacidad.cod'+k).value;

   abrir_ventana1('../rhplanilla/print_list_incapacidad_det.jsp?empId='+empId+'&grupo='+grupo+'&cod='+codi+'&fecha='+fecha);
}


function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 1:msg='Por Empleado ';break;
		case 2:msg='Por Grupo';break;
	}
	setoverc(obj,'ImageBorderOver');
//	optDescObj.innerHTML=msg;
	obj.alt=msg;
}

function mouseOut(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	setoutc(obj,'ImageBorder');
//	optDescObj.innerHTML='&nbsp;';
}

function goOption(k)
{
 var empId;
   var grupo;
   var codi;

   var fecha  = eval('document.formIncapacidad.fecha'+k).value;
   empId = eval('document.formIncapacidad.emp_id'+k).value;
   grupo = document.formIncapacidad.grupo.value;
   codi = eval('document.formIncapacidad.cod'+k).value;


	if(k==undefined)alert('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else if(k== 1)
	{
		//	 abrir_ventana1('../rhplanilla/print_list_inc_det.jsp?empId='+empId+'&grupo='+grupo+'&cod='+codi+'&fecha='+fecha);
			  abrir_ventana1('../rhplanilla/print_list_inc_det.jsp?empId='+empId+'&grupo='+grupo+'&fecha='+fecha);
	} else if(k== 2)
	{
		//	 abrir_ventana1('../rhplanilla/print_list_inc_det.jsp?empId='+empId+'&grupo='+grupo+'&cod='+codi+'&fecha='+fecha);
			  abrir_ventana1('../rhplanilla/print_list_incapacidades.jsp?empId='+empId+'&grupo='+grupo+'&fecha='+fecha);
	}
}


function addFecha()
{
parent.showPopWin('../caja/reg_recibo_billete.jsp?grupo=<%=grupo%>&emp_id=<%=empId%>&desde=<%=desde%>&hasta=<%=hasta%>',winWidth*.90,winHeight*.50,null,null,'');
}


function fecha(k)
{
var grupo = document.formIncapacidad.grupo.value;
var desde = document.formIncapacidad.desde.value;
var hasta = document.formIncapacidad.hasta.value;

parent.showPopWin('../rhplanilla/reporte_incapacidad.jsp?rep='+k+'&grupo='+grupo+'&desde='+desde+'&hasta='+hasta+'&empId=<%=empId%>',winWidth*.75,winHeight*.5,null,null,'');
}

function doSearch(){

  var from = document.getElementById("fFechaIni").value;
  var to = document.getElementById("fFechaFin").value;
  var motivoFalta = document.getElementById("fMotivoFalta").value;
  var accion = document.getElementById("fAccion").value;
  var tipoLugar = document.getElementById("fTipoLugar").value;

  document.location = "../rhplanilla/empl_incapacidad_list.jsp?grupo=<%=grupo%>&empId=<%=empId%>&desde="+from+"&hasta="+to+"&accion="+accion+"&tipoLugar="+tipoLugar+"&motivoFalta="+motivoFalta;
}

</script>
</head>
<table align="center" width="99%" cellpadding="0" cellspacing="0">

<tr>

	<td class="TableLeftBorder TableRightBorder">
	<table align="center" width="100%" cellpadding="0" cellspacing="1">


	<tr>
		<td align="right" colspan="6"><authtype type='3'>[<a href="javascript:add()" class="Link00">Registrar Incapacidad</a>]</authtype>&nbsp;</td>
	</tr>

	<tr class="TextFilter">
		<td colspan="6">
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2"/>
			<jsp:param name="clearOption" value="true"/>
			<jsp:param name="nameOfTBox1" value="fFechaIni"/>
			<jsp:param name="valueOfTBox1" value="<%=desde%>"/>
			<jsp:param name="nameOfTBox2" value="fFechaFin"/>
			<jsp:param name="valueOfTBox2" value="<%=hasta%>"/>
			<jsp:param name="fieldClass" value="Text10"/>
			<jsp:param name="buttonClass" value="Text10"/>
			</jsp:include>&nbsp;&nbsp;
			Motivo&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_pla_motivo_falta where codigo in (select * from table ( select split(param_value) from tbl_sec_comp_param where param_name = 'INCAPACIDAD' ))","fMotivoFalta",motivoFalta,false,false,0,"Text10","width:80",null,"Motivo falta","T")%>
			&nbsp;&nbsp;
			Acci&oacute;n&nbsp;<%=fb.select("fAccion","ND=No Descontar,DS=Descontar",accion,false,false,0,"Text10",null,null)%>&nbsp;&nbsp;
			Tipo de Lugar&nbsp;
			<%=fb.select("fTipoLugar","1=Clínica Privada,2=Caja de Seguro Social,3=Clínica Externa,4=Centro Médico,5=Otro",tipoLugar,false,false,0,"Text10",null,null)%>

			<%//=fb.submit("go","Ir",false,false,"Text10","","")%>
			<%=fb.button("go","Ir",false,false,null,null,"onClick=\"javascript:doSearch()\"")%></td>
		</td>
	</tr>



<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

    <% fb = new FormBean("formIncapacidad",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
   	<%=fb.hidden("grupo",grupo)%>
   	<%=fb.hidden("desde",desde)%>
   	<%=fb.hidden("hasta",hasta)%>

	<%if(al.size() < 1){%>
	<tr class="TextHeader" align="center">
		<td width="15%">Fecha</td>
		<td width="35%">Motivo</td>
		<td width="05%">No.</td>
		<td width="15%">Acci&oacute;n</td>
		<td width="12%">&nbsp;</td>
		<td width="18%">&nbsp;</td>
	</tr>
	<%}%>

<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";

	if (i % 2 == 0) color = "TextRow01";
%>
        <%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
		<%=fb.hidden("cod"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>


		<% if (!empId.trim().equals("") && i==0){%>


		<tr class="TextHeader" align="center">
			<td width="15%">Incapacidades de:</td>
			<td width="35%"><%=cdo.getColValue("Nombre")%></td>

			<td width="05%" align="center">
					<div id="optDesc"></div>
							<authtype type='2'><a href="javascript:fecha(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/printer.jpg"></a></authtype>
				</td>
			<td width="15%">Grupo : <%=cdo.getColValue("Grupo")%></td>
			<td width="12%"><authtype type='55'><a href="javascript:fecha(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/print-shopping-cart.gif"></a></authtype></td>
			<td width="18%">&nbsp;</td>
		</tr>
	<%}%>
	<% if (i==0){%>
		<tr class="TextHeader" align="center">
			<td width="15%">Fecha</td>
			<td width="35%">Motivo</td>
			<td width="05%">No.</td>
			<td width="15%">Acci&oacute;n</td>
			<td width="12%">&nbsp;</td>
			<td width="18%">&nbsp;</td>
		</tr>
	<%}%>


		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("Fecha")%></td>
			<td><%=cdo.getColValue("mfaltaDesc")%></td>
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("estado")%></td>
			<%  if (!sw.equalsIgnoreCase(cdo.getColValue("aprobado")))
			{
			%>
			<td align="center"><a href="javascript:edit(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
			<td align="center"><authtype type='52'><a href="javascript:aprueba(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Aprobar</a>&nbsp;/&nbsp;</authtype> <a href="javascript:printRep(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Imprimir</a></td>
			<% } else { %>
			<td align="center"><a href="javascript:ver(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></td>
			<td align="center"><a href="javascript:printRep(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Imprimir</a></td>
			<% } %>




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
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
