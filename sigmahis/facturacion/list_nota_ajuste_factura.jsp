<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	//	if (SecMgr.checkAccess(session.getId(),"0")) {
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String id = request.getParameter("id");
String fp= request.getParameter("fp");
String index = request.getParameter("index");
String nt = request.getParameter("nt");
String fecha_ini = request.getParameter("fecha_ini");
String fecha_fin = request.getParameter("fecha_fin");
String nombre = request.getParameter("nombre");
if(nombre==null)nombre="";
//int rowCount = 0;
int iconHeight = 48;
int iconWidth = 48;
if(request.getMethod().equalsIgnoreCase("GET"))
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
	
  String codigo ="", paciente="",facturar_a="";
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(f.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    codigo = request.getParameter("codigo");
  }
  if (request.getParameter("paciente") != null && !request.getParameter("codigo").trim().equals(""))
  {
     appendFilter += " and upper(m.primer_nombre||decode(m.segundo_nombre,null,'',' '||m.segundo_nombre)||decode(m.primer_apellido,null,'',' '||m.primer_apellido)||decode(m.segundo_apellido,null,'',' '||m.segundo_apellido)||decode(m.sexo,'F',decode(m.apellido_de_casada,null,'',' '||m.apellido_de_casada))) like '%"+request.getParameter("paciente").toUpperCase()+"%'";
    paciente = request.getParameter("paciente");
  }
  if (request.getParameter("facturar_a") != null  && !request.getParameter("facturar_a").trim().equals(""))
  {
   	appendFilter += " and upper(f.facturar_a) ='"+request.getParameter("facturar_a")+"'";
    facturar_a = request.getParameter("facturar_a");
  }
  if (fecha_ini != null && !fecha_ini.trim().equals(""))
  {
    appendFilter += " and to_date(to_char(f.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fecha_ini+"','dd/mm/yyyy')";
  }
 if (fecha_fin != null && !fecha_fin.trim().equals(""))
  {
    appendFilter += " and to_date(to_char(f.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fecha_fin+"','dd/mm/yyyy')";
  }
  if (!nombre.trim().equals(""))
  {
    appendFilter += " and (e.nombre like '%"+nombre+"%' or m.nombre_paciente like '%"+nombre+"%')";
  }
  
  if(request.getParameter("facturar_a") != null){
sql="select e.nombre as emp_nombre,m.PRIMER_NOMBRE||' '||m.SEGUNDO_NOMBRE||' '||DECODE(m.APELLIDO_DE_CASADA,NULL,m.PRIMER_APELLIDO||' '||m.SEGUNDO_APELLIDO,m.APELLIDO_DE_CASADA)as pac_nombre,decode(f.facturar_a,'P', 'PACIENTE', 'E','EMPRESA', 'O','OTROS') as fact_a, f.codigo,f.facturar_a, f.fecha, nvl(f.grang_total,0)grang_total, f.admi_secuencia admision,to_char(f.admi_fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento,f.admi_codigo_paciente as paciente, f.numero_factura, f.pac_id, coalesce(e.nombre, m.nombre_paciente)as descripcion from tbl_fac_factura f,tbl_adm_empresa e, vw_adm_paciente m where f.cod_empresa= e.codigo(+) and f.pac_id= m.pac_id(+) and  f.estatus = 'P' and f.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by f.facturar_a desc";	

al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
   rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
document.title = 'Facturas - '+document.title;

function edit(k)
{
		
	var pac_id = eval('document.form0.pac_id'+k).value ;
	var admision = eval('document.form0.amision'+k).value; 
	var fac = eval('document.form0.codigo'+k).value ;
	var tt = '<%=nt%>';
	abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pac_id+'&noAdmision='+admision+'&factura='+fac+'&nt='+tt);
}
function setIndex(k)
{
  document.form0.index.value=k;
  checkOne('form0','check',<%=al.size()%>,eval('document.form0.check'+k),0);
}
function goOption(option)
{
if(option==undefined)CBMSG.warning('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
  else
  {
    var k=document.form0.index.value;
    if(k=='' && option==3)abrir_ventana1('../facturacion/notas_ajustes_config.jsp?fg=AR');
		else if(k=='')CBMSG.warning('Por favor seleccione una factura antes de ejecutar una acción!');
    else
    {
			var pac_id = eval('document.form0.pac_id'+k).value ;
			var admision = eval('document.form0.amision'+k).value; 
			var fac = eval('document.form0.codigo'+k).value ;
			//var tt = '<%=nt%>';
	//abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pac_id+'&noAdmision='+admision+'&factura='+fac+'&nt='+tt);

 			if(option==1) abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pac_id+'&noAdmision='+admision+'&factura='+fac+'&nt=C&fg=C&tr=RE');
			if(option==2) abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pac_id+'&noAdmision='+admision+'&factura='+fac+'&nt=D&fg=D&tr=RE');
			if(option==3) abrir_ventana1('../facturacion/notas_ajustes_config.jsp?fg=AR&factura='+fac);
			if(option==4) abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pac_id+'&noAdmision='+admision+'&factura='+fac+'&nt=H&fg=C&tr=RE');
			if(option==5) abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pac_id+'&noAdmision='+admision+'&factura='+fac+'&nt=H&fg=D&tr=RE');
			if(option==6){ 
				var pac_id = eval('document.form0.pac_id'+k).value;
				var factId = eval('document.form0.codigo'+k).value;
				abrir_ventana1('../facturacion/print_estado_cargo_det.jsp?pacId='+pac_id+'&factId='+factId);
			}
			if(option==7) abrir_ventana1('../facturacion/notas_ajustes_config.jsp?fg=AF&factura='+fac);
		}
	}
}
function mouseOver(obj,option)
{
  var optDescObj=document.getElementById('optDesc');
  var msg='&nbsp;';
  switch(option)
  {
    
    case 1:msg='Ajustes a Cargos';break;
    case 2:msg='Ajuste de Devolución';break;
	case 3:msg='Otros Ajustes Recibo';break;
	case 4:msg='Ajuste a Cargos de Honorarios';break;
	case 5:msg='Ajuste a Devolución de Honorarios';break;
	case 6:msg='Estado de Cuenta detallado por factura';break;
	case 7:msg='Otros Ajustes Factura';break;
  }
  setoverc(obj,'ImageBorderOver');
  optDescObj.innerHTML=msg;
  obj.alt=msg;
}

function mouseOut(obj,option)
{
  var optDescObj=document.getElementById('optDesc');
  setoutc(obj,'ImageBorder');
  optDescObj.innerHTML='&nbsp;';
}

function printECDPF(i){
	var pac_id = document.form8.pacId.value;
	var factId = eval('document.form8.factId'+i).value;
	abrir_ventana1('../facturacion/print_estado_cargo_det.jsp?pacId='+pac_id+'&factId='+factId);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/shopping-cart-full-plus.gif"></a>
		<a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/drug-basket.jpg"></a>
		<a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/dollar_circle_adjust.gif"></a><!---->
		
		
		<a href="javascript:goOption(4)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/doctor-money.jpg"></a>
		<a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/payment.jpg"></a>
		<a href="javascript:goOption(6)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/print_bill_details.gif"></a>
		<a href="javascript:goOption(7)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/payment_adjust.gif"></a>
		</td>
	</tr>
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
				<%=fb.hidden("nt",nt)%>
				<td>&nbsp;<cellbytelabel>No. Factura</cellbytelabel>
							<%=fb.textBox("codigo","",false,false,false,10,null,null,null)%>
				</td>
				<td>&nbsp;<cellbytelabel>Facturar a</cellbytelabel>
							<%=fb.select("facturar_a","P = PACIENTE, E=EMPRESA , O=OTROS","","S")%>
				</td>
				<td>&nbsp;<cellbytelabel>Nombre</cellbytelabel>
							<%=fb.textBox("nombre","",false,false,false,40,null,null,null)%>
				</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="2" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha_ini" />
								<jsp:param name="valueOfTBox1" value="" />
								<jsp:param name="nameOfTBox2" value="fecha_fin" />
								<jsp:param name="valueOfTBox2" value="" />
								</jsp:include> 
				
							<%=fb.submit("go","Ir")%>	
				</td>
				<%=fb.formEnd()%>	
			</tr>
			
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	
</table>	
<tr><td colspan="2">&nbsp;</td></tr>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
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
					<%=fb.hidden("nt",nt)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("facturar_a",""+facturar_a)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					
<%
fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
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
					<%=fb.hidden("nt",nt)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("facturar_a",""+facturar_a)%>

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
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="dirc">
	<tr class="TextHeader">
	  <td width="10%">&nbsp;<cellbytelabel>No. Factura</cellbytelabel></td>
		<td width="15%">&nbsp;<cellbytelabel>Facturar a</cellbytelabel> </td>	
	  <td width="30%">&nbsp;<cellbytelabel>Empresa/Paciente</cellbytelabel></td>	
		<td width="25%">&nbsp;<cellbytelabel>Paciente</cellbytelabel> </td>
		<td width="15%" align="right"><cellbytelabel>Monto</cellbytelabel></td>	
		<td width="5%">&nbsp;</td>	
		
	</tr>
	
	<%
	for (int i=0; i<al.size(); i++)
	{
	 CommonDataObject cdo = (CommonDataObject) al.get(i);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	
%>
	<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
	<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
	<%=fb.hidden("fact_a"+i,cdo.getColValue("fact_a"))%>
	<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
	<%=fb.hidden("paciente"+i,cdo.getColValue("paciente"))%>
	<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
	<%=fb.hidden("amision"+i,cdo.getColValue("admision"))%>

	
	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" >
		<td>&nbsp;<%=cdo.getColValue("codigo")%></td>
		<td>&nbsp;<%=cdo.getColValue("fact_a")%></td>
		<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
		<td>&nbsp;<%=cdo.getColValue("pac_nombre")%></td>
		<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("grang_total"))%></td>
		<td align="center"><%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
	</tr>
	<%
	}
	%>						
					
</table>
<%=fb.formEnd()%>			
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
					<%=fb.hidden("nt",nt)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("facturar_a",""+facturar_a)%>

					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					
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
					<%=fb.hidden("nt",nt)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("facturar_a",""+facturar_a)%>

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
