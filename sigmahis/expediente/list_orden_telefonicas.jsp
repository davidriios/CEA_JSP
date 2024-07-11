<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

if (request.getMethod().equalsIgnoreCase("GET")) {
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null) {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

	String mType = request.getParameter("mType");
	String validated  = request.getParameter("validated");
	String dob = request.getParameter("dob");
	String codigo = request.getParameter("codigo");
	String noAdmision = request.getParameter("noAdmision");
	String pacBarcode = request.getParameter("pacBarcode");
	String cedulaPasaporte = request.getParameter("cedulaPasaporte");
	String paciente = request.getParameter("paciente");	
	String medico = request.getParameter("medico");	
	String barPacId="";
	String validada= request.getParameter("validada");	
	 
	
	if (mType == null) mType = "";
	if (validated == null) validated = "N";
 	if (dob == null) dob = "";
	if (codigo == null) codigo = "";
	if (noAdmision == null) noAdmision = "";
	if (pacBarcode == null) pacBarcode = "";
	if (cedulaPasaporte == null) cedulaPasaporte = "";
	if (paciente == null) paciente = "";
	if (medico == null){if(UserDet.getRefType().equalsIgnoreCase("M"))medico=UserDet.getRefCode(); else medico = "";}
	if (validada == null) validada = "N";
	 
	if (!dob.trim().equals("")) { sbFilter.append(" and trunc(p.fecha_nac) = to_date('"); sbFilter.append(dob); sbFilter.append("','dd/mm/yyyy')"); }
	if (!codigo.trim().equals("")) { sbFilter.append(" and b.pac_id = "); sbFilter.append(codigo); }
	if (!noAdmision.trim().equals("")) { sbFilter.append(" and b.secuencia="); sbFilter.append(noAdmision);} 
	if (!pacBarcode.trim().equals("")) { barPacId=pacBarcode.substring(0,10); sbFilter.append(" and b.pac_id=");sbFilter.append(barPacId);
	sbFilter.append(" and b.secuencia="+pacBarcode.substring(10)); }
	if (!cedulaPasaporte.trim().equals("")) { sbFilter.append(" and p.id_paciente = '"); sbFilter.append(cedulaPasaporte); sbFilter.append("'"); }
	if (!medico.trim().equals("")) { sbFilter.append(" and exists(select null from tbl_adm_medico where nvl(reg_medico,codigo)= '"); sbFilter.append(medico); sbFilter.append("' and codigo=a.medico )"); }
	if (validada.trim().equals("N"))sbFilter.append("and nvl(b.validada,'N') ='N' ");
	else sbFilter.append("and nvl(b.validada,'N') ='S' ");
	
	sbSql.append("select p.nombre_paciente,b.pac_id,b.secuencia,b.pac_id||' - '||b.secuencia as id,(select t.descripcion from tbl_sal_tipo_orden_med t where t.codigo = b.tipo_orden ) as tipoOrden, to_char(b.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_crea,(select '['||codigo||'] '||decode(sexo,'F','DRA. ','M','DR. ')||primer_nombre||decode(segundo_nombre,null,' ',segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ', segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',apellido_de_casada)) from tbl_adm_medico where codigo= a.medico) as medico,decode(b.tipo_orden,3,'DIETA - '||'  '||decode(b.nombre,null,' ',' - '||b.nombre), 1, b.nombre||decode(b.prioridad,'H','  --> HOY  '||to_char(b.fecha_orden,'dd-mm-yyyy'),'U',' - HOY URGENTE  '||to_char(b.fecha_orden,'dd-mm-yyyy'),'M','  --> MAÑANA '||to_char(b.fecha_orden,'dd-mm-yyyy'),'O','  --> '||to_char(b.fecha_orden,'dd-mm-yyyy')),  7,b.observacion,b.nombre) as descOrden,b.usuario_creacion, b.codigo,b.orden_med,nvl(b.validada,'N') as validada,to_char(b.fecha_validacion,'dd/mm/yyyy hh12:mi:ss am') as f_valida,b.usuario_valida as u_valida from tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b,vw_adm_paciente p  where  b.pac_id=p.pac_id  and a.pac_id=b.pac_id and a.secuencia=b.secuencia and a.codigo=b.orden_med  and b.forma_solicitud='T' and ((b.omitir_orden='N' and b.estado_orden='A') or (b.ejecutado='N' and b.estado_orden='S' ))  ");
	sbSql.append(sbFilter);	   
	sbSql.append("order by b.fecha_creacion desc");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a)");
    rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");

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
document.title = 'Interfaz de Mediciones - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function validate(k)
{
	var pacId = eval('document.form0.pacId'+k).value;
	var admision = eval('document.form0.admision'+k).value;
	var codDet = eval('document.form0.codigo'+k).value;
	var orden_med = eval('document.form0.orden_med'+k).value;
	var userMod = '<%=(String) session.getAttribute("_userName")%>';
	var validada = eval('document.form0.validada'+k).value
  if(validada=='N')
  {	
	if(executeDB('<%=request.getContextPath()%>','update tbl_sal_detalle_orden_med set validada=\'S\',fecha_validacion=sysdate,usuario_valida =\''+userMod+'\',fecha_modificacion = sysdate  where pac_id = '+pacId+' and secuencia = '+admision+'  and orden_med = '+orden_med+'  and codigo = '+codDet))
	{
	  eval('document.form0.validada'+k).value = 'S'; 
	  $('#img'+k).hide();
	}
  }  
	 	
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - ORDENES TELEFONICAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
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
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("validated",validated)%>
			<td>
				 
				<cellbytelabel id="8">Fecha Nac.</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="dob" />
				<jsp:param name="valueOfTBox1" value="<%=dob%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
				<cellbytelabel id="9">ID. Pac.</cellbytelabel>
				<%=fb.intBox("codigo","",false,false,false,5,"Text10",null,null)%>
				<cellbytelabel id="10">No. Adm.</cellbytelabel>
				<%=fb.intBox("noAdmision","",false,false,false,3,5,"Text10",null,null)%>
				<cellbytelabel id="11">Barcode</cellbytelabel>
				<%=fb.textBox("pacBarcode","",false,false,false,20,"Text10",null,null)%>
			 
				<cellbytelabel id="12">C&eacute;dula/Pasaporte</cellbytelabel>
				<%=fb.textBox("cedulaPasaporte","",false,false,false,15,"Text10",null,null)%>
				<cellbytelabel id="13">Paciente</cellbytelabel>
				<%=fb.textBox("paciente","",false,false,false,30,"Text10",null,null)%> 
				Medico:<%=fb.textBox("medico","",false,false,false,10,"Text10",null,null)%> 
				<%=fb.select("validada","N=NO VALIDADA,S=VALIDADA",validada,false,false,0,"Text10",null,null,null,null,null,"",null)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
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
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("validated",validated)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("pacBarcode",pacBarcode)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("medico",medico)%>
<%=fb.hidden("validada",validada)%>

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
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("validated",validated)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("pacBarcode",pacBarcode)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("validada",validada)%>

			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">

<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%> 
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("validated",validated)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("pacBarcode",pacBarcode)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("validada",validada)%>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader">
			<td width="10%"><cellbytelabel>Tipo Orden</cellbytelabel></td><!--obx6-->
			<td width="12%"><cellbytelabel>Fecha Creacion</cellbytelabel></td><!--obx7-->
			<td width="13%"><cellbytelabel>Usuario Creacion </cellbytelabel></td>
			<td width="15%"><cellbytelabel>Descripcion</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Medico Sol. </cellbytelabel></td>
			<td width="15%"><cellbytelabel>Fecha Validacion </cellbytelabel></td>
			<td width="15%"><cellbytelabel>Usuario Validacion </cellbytelabel></td>			
			<td width="5%">&nbsp;</td>
		</tr>
<%
String groupBy = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";	
	if (!groupBy.equals(cdo.getColValue("id"))) {%>
		<tr class="TextFilter">
			<td colspan="8">PACIENTE: <%=cdo.getColValue("id")%>-<%=cdo.getColValue("nombre_paciente")%></td>			 
		</tr>
<%}%> 
<%=fb.hidden("pacId"+i,cdo.getColValue("pac_id"))%>
<%=fb.hidden("admision"+i,cdo.getColValue("secuencia"))%> 
<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%> 
<%=fb.hidden("orden_med"+i,cdo.getColValue("orden_med"))%>  
<%=fb.hidden("validada"+i,"N")%>  
	 	
			 
 		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("tipoOrden")%></td>
			<td><%=cdo.getColValue("fecha_crea")%></td>
			<td><%=cdo.getColValue("usuario_creacion")%></td>
			<td><%=cdo.getColValue("descOrden")%></td>
			<td><%=cdo.getColValue("medico")%></td>
			<td><%=cdo.getColValue("f_valida")%></td> 
			<td><%=cdo.getColValue("u_valida")%></td> 
			<td align="center"><%			
			if(cdo.getColValue("validada").trim().equals("N")){if(UserDet.getUserProfile().contains("0") || UserDet.getRefType().trim().equalsIgnoreCase("M")||UserDet.getXtra5().trim().equalsIgnoreCase("S")){%><a href="javascript:validate(<%=i%>)"><img src="../images/checked.png" width="30" height="30" id="img<%=i%>"></a><%}}%>&nbsp;</td>
		</tr>
<% 
	groupBy = cdo.getColValue("id");
}
%>
		</table>
<%=fb.formEnd()%>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
</div>
</div>

	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
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
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("validated",validated)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("pacBarcode",pacBarcode)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("validada",validada)%>
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
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("validated",validated)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("pacBarcode",pacBarcode)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("validada",validada)%>
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
} else{
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
alert('<%=SQLMgr.getErrMsg()%>');
<% } else throw new Exception(SQLMgr.getErrException()); %>
window.location='<%=request.getContextPath()+request.getServletPath()%>?fDate=<%=request.getParameter("fDate")%>&tDate=<%=request.getParameter("tDate")%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>