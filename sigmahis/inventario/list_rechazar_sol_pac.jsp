
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ReqMgr" scope="page" class="issi.inventory.RequisicionMgr" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ReqMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String compania =  (String) session.getAttribute("_companyId");	
String fechafin = request.getParameter("fechafin");
String fechaini = request.getParameter("fechaini");
String wh = request.getParameter("wh");
String centro = request.getParameter("centro");
String name_centro = request.getParameter("name_centro");
String anio ="",codigo="";

if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (wh == null) wh = "";
if (appendFilter == null) appendFilter = "";
if (centro == null) centro = "";
if (!wh.trim().equals("")) appendFilter += " and a.codigo_almacen="+wh;
//if (!centro.trim().equals("")) appendFilter += " and a.centro_servicio ="+centro;

if (!fechaini.trim().equals("") && !fechafin.trim().equals("")) appendFilter += " and to_date(to_char(a.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fechaini+"','dd/mm/yyyy') and to_date('"+fechafin+"','dd/mm/yyyy')";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

	if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals("")){
	codigo = request.getParameter("codigo");
		appendFilter += " and upper(a.solicitud_no)  = "+request.getParameter("codigo");
   /* searchOn = "a.solicitud_no";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "No. Solicitud";*/
	} 
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals("")){
	anio = request.getParameter("anio");
		appendFilter += " and upper(a.anio) = "+request.getParameter("anio");
    /*searchOn = "a.anio";
    searchVal = request.getParameter("anio");
    searchType = "1";
    searchDisp = "Año";*/
	} 
	if (request.getParameter("centro") != null && !request.getParameter("centro").trim().equals("")){
		appendFilter += " and a.centro_servicio = "+request.getParameter("centro");
    /*searchOn = "a.centro_servicio";
    searchVal = request.getParameter("centro");
    searchType = "1";
    searchDisp = "centro servicio";*/
	}
	
	/*else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFrom").equals("SVF") && !request.getParameter("searchValTo").equals("SVT"))) && !request.getParameter("searchType").equals("ST")){
    if (searchType.equals("1")){
		appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
    }
  } else {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }*/
	
if(!appendFilter.trim().equals(""))
{
	sql = "select distinct a.compania, a.anio, a.solicitud_no, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha_documento, a.estado, DECODE(a.estado,'A','APROBADO','P','PENDIENTE','R','RECHAZADO','N','ANULADO','T','TRAMITE','E','ENTREGADO') desc_estado, a.paciente, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.codigo_almacen || ' ' || b.descripcion almacen_desc, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||decode(c.primer_apellido,null,'',' '||c.primer_apellido)||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) nombre_paciente, a.adm_secuencia,a.pac_id, a.centro_servicio ||' '|| d.descripcion area_desc,a.usuario_creacion FROM tbl_inv_solicitud_pac a, tbl_inv_almacen b, tbl_adm_paciente c, tbl_cds_centro_servicio d,tbl_inv_d_sol_pac ds  where a.codigo_almacen = b.codigo_almacen and a.compania = b.compania and a.pac_id = c.pac_id and a.centro_servicio = d.codigo and a.estado in ('T','A') and a.solicitud_no = ds.solicitud_no and a.anio=ds.anio and a.compania =ds.compania and ds.estado_renglon = 'P'  and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter;
	sql += " union all select distinct a.compania, a.anio, a.solicitud_no, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha_documento, a.estado, DECODE(a.estado,'A','APROBADO','P','PENDIENTE','R','RECHAZADO','N','ANULADO','T','TRAMITE','E','ENTREGADO') desc_estado, a.paciente, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.codigo_almacen || ' ' || b.descripcion almacen_desc, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||decode(c.primer_apellido,null,'',' '||c.primer_apellido)||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) nombre_paciente, a.adm_secuencia,a.pac_id, a.centro_servicio ||' '|| d.descripcion area_desc,a.usuario_creacion FROM tbl_inv_solicitud_pac a, tbl_inv_almacen b, tbl_adm_paciente c, tbl_cds_centro_servicio d  where a.codigo_almacen = b.codigo_almacen and a.compania = b.compania and a.pac_id = c.pac_id and a.centro_servicio = d.codigo and a.estado in ('T','A') and not exists(select null from tbl_inv_d_sol_pac ds where a.solicitud_no = ds.solicitud_no and a.anio=ds.anio and a.compania =ds.compania )	and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter;
	
	sql += " order by 2 desc, 3 desc  ";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");
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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Inventario - '+document.title;

function add()
{
	abrir_ventana('../inventario/reg_sol_mat_pacientes.jsp?tr=<%=tr%>');
}
function buscaCentro()
{
	abrir_ventana('../common/search_centro_servicio.jsp?fp=RSP');
}
function edit(anio, id,k)
{
	abrir_ventana('../inventario/reg_sol_mat_pacientes.jsp?mode=view&id='+id+'&anio='+anio+'&tr=RSP&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
function printList()
{
	abrir_ventana('../inventario/print_list_sol_mat_pac.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=RSP');
}
function puEstado(obj)
{
	if(obj.value =='R')
	if(confirm('¿Está seguro que desea Rechazar esta Solicitud ??'))
	{
			alert('Al Guardar se rechazaran automaticamente todos los renglones');
	}	else {obj.value=''; }
}
function getMain(formX)
{
	formX.wh.value = document.search00.wh.value;
	/*formX.centro.value = document.search00.centro.value;
	formX.fechaini.value = document.search00.fechaini.value;
	formX.fechafin.value = document.search00.fechafin.value;*/
	return true;
}
function changeDesc()
{
eval('document.search00.name_centro').value='';
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - SOL. MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">
		<%if(tr != null && !tr.trim().equals("MPS")){%>
			<!--<a href="javascript:add()" class="Link00">[ Registrar Nueva Requisici&oacute;n ]</a>--->
		<%}%>
		</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
					
	<tr class="TextFilter">
	<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%> 
	<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
	<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
	<%=fb.hidden("tr",tr)%>
		<td width="10%">Almacen</td>
		<td width="40%"><%=fb.select(ConMgr.getConnection(),"select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+compania+" order by codigo_almacen","wh",wh,"S")%>&nbsp;</td>					
		<td width="50%"> 
		<jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="2" />
      <jsp:param name="clearOption" value="true" />
      <jsp:param name="nameOfTBox1" value="fechaini" />
      <jsp:param name="valueOfTBox1" value="<%=fechaini%>" />
      <jsp:param name="nameOfTBox2" value="fechafin" />
      <jsp:param name="valueOfTBox2" value="<%=fechaini%>" />
      </jsp:include>
	</tr>		
	<tr class="TextFilter">
				<td>Centro Servicio</td>
				<td colspan="2"><%=fb.intBox("centro",centro,false,false,false,10,null,null,"onChange=\"javascript:changeDesc()\"")%>
				<%=fb.textBox("name_centro",name_centro,false,false,true,60)%> <%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaCentro()\"")%>&nbsp; 
				 </td>
			</tr>
			
        <tr class="TextFilter">
        <td>Año</td>
					<td colspan="2"> 
						<%=fb.textBox("anio",anio,false,false,false,10)%> 
						No Solicitud
						<%=fb.textBox("codigo",codigo,false,false,false,10)%> 
						<%=fb.submit("go","Ir")%> 
					</td>
        <%=fb.formEnd()%>
				</tr>
				  
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
			&nbsp;
		</td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("centro",centro)%>
				<%=fb.hidden("fechaini",fechaini)%>
				<%=fb.hidden("fechafin",fechafin)%>
				<%=fb.hidden("name_centro",name_centro)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("codigo",codigo)%>
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
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("centro",centro)%>
				<%=fb.hidden("fechaini",fechaini)%>
				<%=fb.hidden("fechafin",fechafin)%>
				<%=fb.hidden("name_centro",name_centro)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("codigo",codigo)%>
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
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>
		<%=fb.hidden("reqSize",""+al.size())%>
		<%=fb.hidden("wh",wh)%>
		<%=fb.hidden("centro",centro)%>
		<%=fb.hidden("fechaini",fechaini)%>
		<%=fb.hidden("fechafin",fechafin)%>
		<%=fb.hidden("name_centro",name_centro)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("codigo",codigo)%>
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="3%" rowspan="2">A&ntilde;o</td>
			<td width="6%" rowspan="2">No. Solicitud</td>
			<td width="6%" rowspan="2">Fecha Doc.</td>
			<td width="40%" colspan="4">Paciente</td>
			<td width="10%" rowspan="2">Estado</td>
			<td width="10%" rowspan="2">Usuario</td>
			<td width="20%" rowspan="2">Rechazar</td>
			
		</tr>
		<tr class="TextHeader" align="center">
			<td width="5%">Cod.</td>
			<td width="7%">Fecha Nac.</td>
			<td width="27%">Nombre</td>
			<td width="6%">No. Admi.</td>
		</tr>
		<%if(al.size()==0 && !appendFilter.trim().equals("")){%>
              <tr>
                <td colspan="10" class="TextRow01" align="center"> NO HAY SOLICITUDES DE MATERIALES Y MEDICAMENTOS PARA PACIENTES </td>
              </tr>
              <%}%>	
<%
String label = "R=RECHAZAR"; 
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	//if(cdo.getColValue("estado").trim().equals("T"))
	label =  "R=RECHAZAR ," +cdo.getColValue("estado")+ " = "+cdo.getColValue("desc_estado");
	
%>
		<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
		<%=fb.hidden("admision"+i,cdo.getColValue("adm_secuencia"))%>
		<%=fb.hidden("estado_sol"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
		<%=fb.hidden("noSolicitud"+i,cdo.getColValue("solicitud_no"))%>
		
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td align="center"><%=cdo.getColValue("solicitud_no")%></td>
			<td align="center"><%=cdo.getColValue("fecha_documento")%></td>
			<td align="center"><%=cdo.getColValue("paciente")%></td>
			<td align="center"><%=cdo.getColValue("fecha_nacimiento")%></td>
			<td align="left"><%=cdo.getColValue("nombre_paciente")%></td>
			<td align="center"><%=cdo.getColValue("adm_secuencia")%></td>
			<td align="center"><%=cdo.getColValue("desc_estado")%></td>
			<td align="center"><%=cdo.getColValue("usuario_creacion")%></td>
			<td align="center"><authtype type='5'><%=fb.select("estado"+i,label,"",false,false,0,"",null,"onChange=\"javascript:puEstado(this)\"",null,"S")%>
				<a href="javascript:edit(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("solicitud_no")%>,<%=i%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Detalle</a></authtype>
			</td>
			
		</tr>
<%
label ="";
}
%>
<%if(al.size() !=0){%>
<tr class="TextRow02">
          <td colspan="10" align="right"><%=fb.submit("save","Guardar",true,false)%></td>
        </tr>
	<%}%>			
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
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("centro",centro)%>
				<%=fb.hidden("fechaini",fechaini)%>
				<%=fb.hidden("fechafin",fechafin)%>
				<%=fb.hidden("name_centro",name_centro)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("codigo",codigo)%>
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
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("centro",centro)%>
				<%=fb.hidden("fechaini",fechaini)%>
				<%=fb.hidden("fechafin",fechafin)%>
				<%=fb.hidden("name_centro",name_centro)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("codigo",codigo)%>
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
<%}
//End Method GET 
else if (request.getMethod().equalsIgnoreCase("POST")) 
{ // Post
ArrayList al1= new ArrayList();
 int invSize =Integer.parseInt(request.getParameter("reqSize"));
 for(int z=0;z<invSize;z++)
 {
  if (request.getParameter("estado"+z) != null && !request.getParameter("estado"+z).equals("") && request.getParameter("estado"+z).trim().equals("R"))
  {
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_inv_solicitud_pac"); 
			cdo.addColValue("anio",request.getParameter("anio"+z));
			cdo.addColValue("noSolicitud",request.getParameter("noSolicitud"+z));
			cdo.addColValue("usuarioModifica",(String) session.getAttribute("_userName"));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
 		  al1.add(cdo);
	}
	}  
	
	ReqMgr.updateSolPac(al1);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (ReqMgr.getErrCode().equals("1")){
%>
  alert('<%=ReqMgr.getErrMsg()%>');
<%
  if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/list_rechazar_sol_pac.jsp")){
%>
  window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/list_rechazar_sol_pac.jsp")%>';
<%
  } else {
%>
  window.location = '<%=request.getContextPath()%>/inventario/list_rechazar_sol_pac.jsp';
<%
  }
%>
<%
} else throw new Exception(ReqMgr.getErrMsg());
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
