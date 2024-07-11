<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLReader"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="xmlRdr" scope="page" class="issi.admin.XMLReader"/>
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
String tipo = request.getParameter("tipo")==null?"":request.getParameter("tipo");
String fDate = request.getParameter("fDate")==null?"":request.getParameter("fDate");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate")==null?"":request.getParameter("tDate");
String medCodigo = request.getParameter("medCodigo")==null?"":request.getParameter("medCodigo");
String medNombre = request.getParameter("medNombre")==null?"":request.getParameter("medNombre");

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
  
	if (!tipo.trim().equals("")) appendFilter += " and cds.interfaz = '"+tipo+"'";
	if (!fDate.trim().equals("") && !tDate.trim().equals("")) appendFilter += " and trunc(z.fecha_creac) between to_date('"+fDate+"','dd/mm/yyyy') and to_date('"+tDate+"','dd/mm/yyyy') ";
	if (!medCodigo.trim().equals("")) appendFilter += " and c.med_codigo_resp = '"+medCodigo+"'";
	
	sql = "select cds.interfaz as tipo, decode(cds.interfaz,'LIS','LABORATORIOS','IMAGENOLOGIAS') tipo_desc , c.med_codigo_resp as cod_medico, m.primer_nombre||' '||m.primer_apellido as med_nombre ,z.codigo, z.cod_solicitud, z.csxp_admi_secuencia, z.csxp_admi_pac_codigo, z.csxp_admi_pac_fec_nac, z.cod_centro_servicio, cds.descripcion as cds_desc, z.pac_id, p.nombre_paciente, nvl(to_char(z.fecha_realizo,'dd/mm/yyyy hh12:mi:ss am'),' ') as fecha_realizo, nvl(to_char(z.fecha_solicitud,'dd/mm/yyyy'),' ') as fecha_solicitud, nvl(z.codigo_muestra,' ') as codigo_muestra, nvl(z.cod_procedimiento,' ') as cpt, nvl(y.observacion,y.descripcion) as cpt_desc, nvl(z.comentario_pre,' ') as comentario_pre, z.estado,to_char(z.csxp_admi_pac_fec_nac,'ddmmyyyy') fecha_nac,z.csxp_admi_secuencia admision, z.csxp_admi_pac_codigo pac_codigo, to_char(z.fecha_creac,'dd/mm/yyyy') fecha_creac from tbl_cds_detalle_solicitud z,tbl_cds_solicitud c, tbl_cds_procedimiento y, tbl_adm_medico m, tbl_cds_centro_servicio cds, vw_adm_paciente p where z.cod_procedimiento=y.codigo(+) and z.pac_id=c.pac_id and z.csxp_admi_secuencia=c.admi_secuencia and z.cod_solicitud = c.codigo and c.med_codigo_resp is not null and c.med_codigo_resp = m.codigo and z.cod_centro_servicio = cds.codigo and cds.interfaz is not null and p.pac_id = z.pac_id "+appendFilter+" order  by 1, c.med_codigo_resp ";
	
	if ( request.getParameter("beginSearch") != null ){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from("+sql+") ");
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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script>
document.title = 'PROCEDIMIENTOS POR MEDICO - '+document.title;

function showMedList(){
    abrir_ventana1('../common/search_medico.jsp?fp=procedimientos_x_med&fg=');
}

function printList(){
  var medCodigo = $("#medCodigo").val() || 'ALL';
  var tipo = $("#tipo").val() || 'ALL';
  var fDate = $("#fDate").val() || '01/01/1900';
  var tDate = $("#tDate").val() || '01/01/1900';
  abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=expediente/rpt_proc_x_med_det.rptdesign&pCtrlHeader=false&medCodigo='+medCodigo+'&tipo='+tipo+'&fDesde='+fDate+'&fHasta='+tDate);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - EMAIL TO PRINTER"></jsp:param>
</jsp:include>
<table width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;</td>
  </tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextFilter">
			
					<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("beginSearch","")%>
					<td colspan="2">
						<cellbytelabel>Tipo</cellbytelabel>
						<%=fb.select("tipo","LIS=Laboratorio, RIS=Imaginología",tipo,"T")%>
                        &nbsp;
                        <cellbytelabel id="14">Fecha Solicutud</cellbytelabel>
                        <jsp:include page="../common/calendar.jsp" flush="true">
                        <jsp:param name="noOfDateTBox" value="2" />
                        <jsp:param name="nameOfTBox1" value="fDate" />
                        <jsp:param name="valueOfTBox1" value="<%=fDate%>" />
                        <jsp:param name="nameOfTBox2" value="tDate" />
                        <jsp:param name="valueOfTBox2" value="<%=tDate%>" />
                        <jsp:param name="fieldClass" value="Text10" />
                        <jsp:param name="buttonClass" value="Text10" />
                        <jsp:param name="clearOption" value="true" />
                        </jsp:include>
                        &nbspM&eacute;dico
                        <%=fb.textBox("medCodigo",medCodigo,false,false,true,4,"Text10",null,null)%>
                        <%=fb.textBox("medNombre",medNombre,false,false,true,40,"Text10",null,null)%>
                        <%=fb.button("btn_medico","...",false,false,"Text10",null,"onClick=javascript:showMedList()")%>
                        &nbsp;
                        
						<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
    <tr>
      <td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
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
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("medCodigo",medCodigo)%>
				<%=fb.hidden("medNombre",medNombre)%>
               
                <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
				<%fb=new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("medCodigo",medCodigo)%>
				<%=fb.hidden("medNombre",medNombre)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader">
			<td width="15%"><cellbytelabel>M&eacute;dico</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Paciente</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Fecha</cellbytelabel></td>
			<td width="40%"><cellbytelabel>Procedimiento</cellbytelabel></td>
		</tr>
		<%
        String grp1 = "";
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			String color = "TextRow02";
			if (i % 2 == 0) color = "TextRow01";
            
            if (!grp1.equals(cdo.getColValue("tipo"))){
        %>   
                <tr class="TextHeader">
                  <td colspan="5"><%=cdo.getColValue("tipo_desc")%></td>
                </tr>
        <%   
            }
	    %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td>[<%=cdo.getColValue("cod_medico")%>]&nbsp;<%=cdo.getColValue("med_nombre")%></td>
			<td>[<%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("csxp_admi_secuencia")%>]&nbsp;<%=cdo.getColValue("nombre_paciente")%></td>
			<td><%=cdo.getColValue("cds_desc")%></td>
			<td><%=cdo.getColValue("fecha_creac")%></td>
			<td>[<%=cdo.getColValue("cpt")%>]&nbsp;<%=cdo.getColValue("cpt_desc")%></td>
		</tr>
		<%
          grp1 = cdo.getColValue("tipo");
        }%>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("medCodigo",medCodigo)%>
				<%=fb.hidden("medNombre",medNombre)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
				<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("medCodigo",medCodigo)%>
				<%=fb.hidden("medNombre",medNombre)%>
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