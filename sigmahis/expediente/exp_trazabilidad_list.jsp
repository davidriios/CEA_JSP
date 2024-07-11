<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

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
String pacId  = "";
String admision   = "";
String usuario  = "";
String userId = "";
String seccion  = "";
String fechaAccessoF = request.getParameter("fecha_acceso_f");
String fechaAccessoT = request.getParameter("fecha_acceso_t");

if (fechaAccessoF == null) fechaAccessoF = "";
if (fechaAccessoT == null) fechaAccessoT = "";

if (!fechaAccessoF.trim().equals("") && !fechaAccessoT.trim().equals("")) {
  //fechaAccessoF = CmnMgr.getCurrentDate("dd/mm/yyyy");
  //fechaAccessoT = fechaAccessoF;
  appendFilter = " and  trunc(l.access_date) between to_date('"+fechaAccessoF+"', 'dd/mm/yyyy') and to_date('"+fechaAccessoT+"', 'dd/mm/yyyy')";
}

boolean search = request.getParameter("searching") != null;

if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=200;
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
	
 if (request.getParameter("pacId") != null && !request.getParameter("pacId").trim().equals("") ) {
	appendFilter = appendFilter+" and l.pac_id = "+request.getParameter("pacId");	
	pacId   = request.getParameter("pacId");
 }
 
  if (request.getParameter("admision") != null && !request.getParameter("admision").trim().equals("") ) {
	appendFilter = appendFilter+" and l.admision = "+request.getParameter("admision");	
	admision   = request.getParameter("admision");
 }
 
  if (request.getParameter("section") != null && !request.getParameter("section").trim().equals("") ) {
	appendFilter = appendFilter+" and l.seccion = "+request.getParameter("section");	
	seccion   = request.getParameter("section");
 }
 
 if (request.getParameter("userId") != null && !request.getParameter("userId").trim().equals("") ) {
	appendFilter = appendFilter+" and l.user_id = "+request.getParameter("userId");	
	userId   = request.getParameter("userId");
 }
 
 
 if (search) {
sql="select l.pac_id, l.admision, p.nombre_paciente, l.user_id, l.ip, to_char(l.access_date, 'dd/mm/yyyy hh12:mi am') access_date_dsp, to_char(l.access_timestamp, 'dd/mm/yyyy hh12:mi am') access_timestamp,l.seccion, l.description,u.user_name from tbl_sec_user_log_exp l, tbl_sec_users u, vw_adm_paciente p where l.user_id = u.user_id and l.pac_id = p.pac_id "+appendFilter+" order by l.seccion, l.user_id, l.access_date desc";

	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) from ("+sql+") ");
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
document.title = 'Expediente - Auditoría - Trazabilidad - '+document.title;

function  printList(){
   abrir_ventana('../cellbyteWV/report_container.jsp?reportName=expediente/rpt_list_trazabilidad.rptdesign&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&pCtrlHeader=true');
}

$(function(){
  allowWriting({
    inputs: "#pacId, #nombrePaciente, #nombreUsuario, #section_desc",
    listener: "keydown",
    keycode: 9,
    keyboard: true,
    iframe: "#preventPopupFrame",
    searchParams: {
        pacId: "pacId", nombrePaciente: "nombre", nombreUsuario: 'userName', section_desc: 'descripcion',
    },
    toBeCleaned: {
      pacId: ['pacId', 'nombrePaciente',],
      nombrePaciente: ['pacId', 'nombrePaciente',],
      nombreUsuario: ['nombreUsuario', 'userId'],
      section_desc: ['section_desc', 'section'],
    },
    btnsToDisabled: ['go'],
    baseUrls: {
        pacId: "../common/search_paciente.jsp?fp=trazabilidad&status=A",
        nombrePaciente: "../common/search_paciente.jsp?fp=trazabilidad&status=A",
        nombreUsuario: '../common/check_user.jsp?fp=trazabilidad',
        section_desc: '../common/check_seccion.jsp?fp=trazabilidad',
    } 
  });
  
  $("input[name='go']").click(function(e) {
    if ( $.trim($("#pacId").val()) && $("#admision").val() ) $("#search01").submit();
    else if (! $("#fecha_acceso_f").val() || ! $("#fecha_acceso_t").val ()) alert("Por favor ingrese un rango de fecha.");
    else $("#search01").submit();
  });
});

function showUsoList(){
  abrir_ventana1('../admin/list_servicio.jsp?fp=tarifa_uso');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - TARIFAS DE USO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="4" align="right">
		<iframe id="preventPopupFrame" name="preventPopupFrame" frameborder="0" width="99%" height="200" src="" scroll="no" style="display:none;"></iframe>
		</td>
	</tr>
	
	<tr>
    <td style="color:red">
    <b>*** Para evitar abrir listados para las b&uacute;squedas, se activa la funcionalidad en línea. Es decir, despu&eacute;s de escribir, es necesario presionar la tecla TAB o cliquea afuera antes de cliquear el bot&oacute;n IR</b>
    </td>
	</tr>
	

	<tr class="TextFilter">
     <!-- ============================   S E A R C H   E N G I N E S   S T A R T   H E R E   ============================= -->

		<%fb = new FormBean("search01",request.getContextPath()+request.getServletPath());%>	
		<%=fb.formStart()%>
		<td width="100%">
      Paciente
      <%=fb.intBox("pacId","",false,false,false,5)%>
      - <%=fb.intBox("admision","",false,false,true,2)%>
      <%=fb.textBox("nombrePaciente","",false,false,false,20)%>
      
      Usuario
      <%=fb.hidden("userId","")%>
      <%=fb.hidden("searching","")%>
      <%=fb.textBox("nombreUsuario","",false,false,false,10)%>
      
      Secci&oacute;n
      <%=fb.hidden("section","")%>
      <%=fb.textBox("section_desc","",false,false,false,20)%>
      
        <cellbytelabel>Accesso</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fecha_acceso_f" />
				<jsp:param name="valueOfTBox1" value="" />
				<jsp:param name="nameOfTBox2" value="fecha_acceso_t" />
				<jsp:param name="valueOfTBox2" value="" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
				
		
		

			<%=fb.button("go","Ir")%>	
		</td>
		<%=fb.formEnd()%>
			
	<!-- =============================   S E A R C H   E N G I N E S   E N D   H E R E   ============================= -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
		  <authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista (Excel) ]</a></authtype>
		</td>
	</tr>	
</table>	

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
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("admision",admision)%>
				<%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("usuario",usuario)%>
				<%=fb.hidden("fecha_acceso_f",fechaAccessoF)%>
				<%=fb.hidden("fecha_acceso_t",fechaAccessoT)%>
				<%=fb.hidden("searching","")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
					<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("admision",admision)%>
				<%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("usuario",usuario)%>
				<%=fb.hidden("fecha_acceso_f",fechaAccessoF)%>
				<%=fb.hidden("fecha_acceso_t",fechaAccessoT)%>
				<%=fb.hidden("searching","")%>
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

<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader" align="center">
		<td width="15%">PID</td>
		<td width="50%">Nombre Paciente</td>
		<td width="15%">Fecha Accesso</td>
		<td width="20%">Direcci&oacute;n IP</td>
	</tr>
<%
				String seccionG = "", userIdG = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				if (!seccionG.equals(cdo.getColValue("seccion")))
					{
				%>
				<tr class="TextHeader01">
					<td colspan="8">SECCION: <%=cdo.getColValue("description")%></td>
				</tr>
				<%
				}
				
				if (!userIdG.equals( cdo.getColValue("user_id")+" - "+cdo.getColValue("seccion") )) {
				%>
          <tr class="TextHeader">
            <td colspan="8">USUARIO: <%=cdo.getColValue("user_name")%></td>
          </tr>
				<%
				}
				%>						 
			
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("admision")%></td>
					<td><%=cdo.getColValue("nombre_paciente")%></td>
					<td align="center"><%=cdo.getColValue("access_date_dsp")%></td>
					<td align="center"><%=cdo.getColValue("ip")%></td>
				</tr>
				<%
				seccionG = cdo.getColValue("seccion");
				userIdG = cdo.getColValue("user_id")+" - "+cdo.getColValue("seccion");
				}
				%>													
								
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
				fb = new FormBean("bottomPrevious",request.getContextPath()+request.getServletPath());
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
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("admision",admision)%>
				<%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("usuario",usuario)%>
				<%=fb.hidden("fecha_acceso_f",fechaAccessoF)%>
				<%=fb.hidden("fecha_acceso_t",fechaAccessoT)%>
				<%=fb.hidden("searching","")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+request.getServletPath());
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
					<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("admision",admision)%>
				<%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("usuario",usuario)%>
				<%=fb.hidden("fecha_acceso_f",fechaAccessoF)%>
				<%=fb.hidden("fecha_acceso_t",fechaAccessoT)%>
				<%=fb.hidden("searching","")%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

</body>
</html>
<%
}
%>
