<%@ page errorPage="../error.jsp"%>
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
/**
==================================================================================
==================================================================================
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

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
 
	String codigo = request.getParameter("codigo");
	String nombre = request.getParameter("nombre");
	String fecha_ini = request.getParameter("fecha_ini");
	String fecha_fin = request.getParameter("fecha_fin");
	String cod_hon = request.getParameter("cod_hon");
	String tipoFecha = request.getParameter("tipoFecha");
	String pacId = request.getParameter("pacId");
	String admision = request.getParameter("admision");
	
	if (codigo == null) codigo = "";
	if (nombre == null) nombre = "";
	if (fecha_ini == null) fecha_ini = "";
	if (fecha_fin == null) fecha_fin = "";
	if (cod_hon == null) cod_hon = "";
	if (tipoFecha == null) tipoFecha = "fecha_creacion";
	if (pacId == null) pacId = "";
	if (admision == null) admision = "";
	
	sbSql = new StringBuffer();
	if(!nombre.equals(""))sbSql.append(" select * from (");
  sbSql.append("select distinct ft.fecha_creacion as sort_by, ft.no_documento,ft.pac_id||' - '||ft.admi_secuencia cuenta, ft.pac_id,ft.admi_secuencia admision, (select nombre_paciente from vw_adm_paciente where pac_id = ft.pac_id)nombre_paciente,(case when ft.pagar_sociedad = 'S' then to_char(ft.empre_codigo) else ft.med_codigo end) cod_medico,ft.usuario_creacion,to_char(ft.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion,ft.codigo,decode(ft.pagar_sociedad,'S',(select nombre from tbl_adm_empresa where codigo=ft.empre_codigo),(select m.primer_nombre || ' '||m.segundo_nombre|| ' '||m.primer_apellido|| ' '||m.segundo_apellido|| ' '||m.apellido_de_casada from tbl_adm_medico m where m.codigo= ft.med_codigo)) nombre_medico,ft.tipo_transaccion tipo, nvl((select sum(decode(z.centro_servicio,0,decode(z.tipo_transaccion,'H',z.cantidad,-z.cantidad)) * (z.monto + nvl(z.recargo,0))) from tbl_fac_detalle_transaccion z where z.compania =ft.compania and z.seq_trx = ft.seq_trx),0) as monto from tbl_fac_transaccion ft where ft.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
  sbSql.append(" and (ft.empre_codigo is not null or ft.med_codigo is not null )");
    if(pacId.equals(""))sbSql.append(" and ft.no_documento is not null");
	
	if(!fecha_ini.trim().equals(""))
	{
		sbSql.append(" and trunc(ft.");
		sbSql.append(tipoFecha);
		sbSql.append(") >=to_date('");
		sbSql.append(fecha_ini);
		sbSql.append("','dd/mm/yyyy')");
	}
	if(!fecha_fin.trim().equals(""))
	{
		sbSql.append(" and trunc(ft.");
		sbSql.append(tipoFecha);
		sbSql.append(") <=to_date('");
		sbSql.append(fecha_fin);
		sbSql.append("','dd/mm/yyyy')");
	}
	if(!codigo.equals("")){
		sbSql.append(" and ft.no_documento like '%");
		sbSql.append(codigo);
		sbSql.append("%'");
	}
	if(!pacId.equals("")){
		sbSql.append(" and ft.pac_id =");sbSql.append(pacId); 
	}
	if(!admision.equals("")){
		sbSql.append(" and ft.admi_secuencia =");sbSql.append(admision); 
	}
	if(!cod_hon.equals("")){
		sbSql.append(" and (case when ft.pagar_sociedad = 'S' then to_char(ft.empre_codigo) else ft.med_codigo end) like '%");
		sbSql.append(cod_hon);
		sbSql.append("%'");
	}
	
	if(!nombre.equals("")){
		
		sbSql.append(") where nombre_medico like '%");
		sbSql.append(nombre);
		sbSql.append("%'");
	}
	sbSql.append(" order by 1");
  
  if(request.getParameter("fecha_fin")!= null){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		StringBuffer sqlCount = new StringBuffer();
		sqlCount.append("select count(*) from (");
		sqlCount.append(sbSql.toString());
		sqlCount.append(")");
		rowCount = CmnMgr.getCount(sqlCount.toString());
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
document.title = '- Honorarios - Boletas - '+document.title;
function printList(){
  var codigo = $("#codigo").val() || 'ALL';
  var codHon = $("#cod_hon").val() || 'ALL';
  var nombre = $("#nombre").val() || 'ALL';
  var tipoFecha = $("#tipoFecha").val() || 'ALL';
  var fDesde = $("#fecha_ini").toRptFormat() || '1970-01-01';
  var fHasta = $("#fecha_fin").toRptFormat() || '1970-01-01';
  var pacId = $("#pacId").val() || 'ALL';
  var admision = $("#admision").val() || 'ALL';
  
  abrir_ventana("../cellbyteWV/report_container.jsp?reportName=cxp/print_list_hon.rptdesign&pCtrlHeader=false&codigo="+codigo+"&cod_hon="+codHon+"&nombre="+nombre+"&tipo_fecha="+tipoFecha+"&fDesde="+fDesde+"&fHasta="+fHasta+"&pac_id="+pacId+"&admision="+admision)
}
function viewBoletas(pacId, admision,codigo,tipo)
{
	abrir_ventana('../facturacion/reg_cargo_dev.jsp?mode=view&pacienteId='+pacId+'&noAdmision='+admision+'&tt='+tipo+'&codigo='+codigo);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR PAGAR - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">		
                    <%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				    <td><cellbytelabel>No. Boleta</cellbytelabel>:
					<%=fb.textBox("codigo",codigo,false,false,false,5,"text10",null,"")%> 
					<cellbytelabel>Codigo</cellbytelabel>:
                <%=fb.textBox("cod_hon",cod_hon,false,false,false,5,"text10",null,"")%>
                <cellbytelabel>Beneficiario</cellbytelabel>:
                <%=fb.textBox("nombre",nombre,false,false,false,18,"text10",null,"")%> 
					<cellbytelabel>Fecha</cellbytelabel>
					<%=fb.select("tipoFecha","fecha=CARGO,fecha_creacion=CREACION",tipoFecha,false,false,false,0,"Text10",null,null)%>:
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2" />
					<jsp:param name="nameOfTBox1" value="fecha_ini" />
					<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>" />
					<jsp:param name="nameOfTBox2" value="fecha_fin" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>" />
					</jsp:include> 
					Id. Pac:<%=fb.intBox("pacId",pacId,false,false,false,4,"text10",null,"")%> 
					Adm.:<%=fb.intBox("admision",admision,false,false,false,3,"text10",null,"")%>
						<%=fb.submit("go","Ir")%>		  
            </td>
				    <%=fb.formEnd()%>	   </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right">
		  		<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cod_hon",cod_hon)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("tipoFecha",tipoFecha)%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cod_hon",cod_hon)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("tipoFecha",tipoFecha)%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
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
				<tr class="TextHeader">
					<td width="9%" align="center"><cellbytelabel>Boleta</cellbytelabel></td>
					<td width="23%" align="center"><cellbytelabel>M&eacute;dico/Sociedad</cellbytelabel></td>
					<td width="23%" align="center"><cellbytelabel>Paciente</cellbytelabel></td>
					<td width="10%" align="center"><cellbytelabel>No. Cuenta</cellbytelabel></td>
					<td width="9%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
					<td width="9%" align="center"><cellbytelabel>Usuario Creaci&oacute;n</cellbytelabel></td>
					<td width="12%" align="center"><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
					<td width="5%" align="center">&nbsp;</td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("no_documento")%></td>
					<td>[<%=cdo.getColValue("cod_medico")%>]&nbsp;-&nbsp;<%=cdo.getColValue("nombre_medico")%></td>
					<td><%=cdo.getColValue("nombre_paciente")%></td>
					<td align="center"><%=cdo.getColValue("cuenta")%></td>
					<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
					<td><%=cdo.getColValue("usuario_creacion")%></td>
					<td><%=cdo.getColValue("fecha_creacion")%></td>
				
					<td align="center">
					<a href="javascript:viewBoletas('<%=cdo.getColValue("pac_id")%>','<%=cdo.getColValue("admision")%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("tipo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><img height="20" width="20" class="ImageBorder" src="../images/search.gif"></a>
					</td>
				</tr>
				<%
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cod_hon",cod_hon)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("tipoFecha",tipoFecha)%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cod_hon",cod_hon)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("tipoFecha",tipoFecha)%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
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