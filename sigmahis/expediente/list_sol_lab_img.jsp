<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
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
/*
*/
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
ArrayList alSol = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al2 = new ArrayList();

int rowCount = 0;
String sql = "";
String appendFilter = "";
String fg = request.getParameter("fg");
String area = request.getParameter("area");
String solicitado_por = request.getParameter("solicitado_por");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
int total=0;

if(fg==null) fg = "";
sql = "select codigo optValueColumn, descripcion optLabelColumn from tbl_cds_centro_servicio where estado in ('A') and interfaz='"+fg+"' order by 1";
		al = sbb.getBeanList(ConMgr.getConnection(),sql,CommonDataObject.class);
sql = "select codigo optValueColumn, descripcion optLabelColumn from tbl_cds_centro_servicio where estado = 'A' ";
if(fg.trim().equals("LIS"))sql +=" and sol_interfaz_lis is not null ";
if(fg.trim().equals("RIS"))sql +=" and sol_interfaz_ris is not null ";
sql +="  order by descripcion";
		alSol = sbb.getBeanList(ConMgr.getConnection(),sql,CommonDataObject.class);

if(request.getParameter("fecha")!=null) fecha = request.getParameter("fecha");

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

  if (request.getParameter("area") != null && !request.getParameter("area").trim().equals("")){
    appendFilter += " and a.cod_centro_servicio = "+request.getParameter("area");
    area    = request.getParameter("area");
	}
  if (request.getParameter("solicitado_por") != null && !request.getParameter("solicitado_por").trim().equals("")){
    appendFilter += "  and a.cod_sala = "+request.getParameter("solicitado_por");
    solicitado_por    = request.getParameter("solicitado_por");
	}
	
sql = "select  cds, descripcion, count(*) cantidad  from(select distinct a.cod_sala cds,(select  codigo||' - '||descripcion from tbl_cds_centro_servicio where codigo =a.cod_sala)descripcion,e.codigo,e.pac_id,e.admi_secuencia from tbl_cds_detalle_solicitud a,tbl_cds_solicitud e,tbl_adm_admision i where (a.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz ='"+fg+"')) and a.estado in ('S') and a.estudio_dev='N' and a.estudio_realizado='N'  "+appendFilter+" and trunc(a.fecha_solicitud)=to_date('"+fecha+"','dd/mm/yyyy') and a.cod_solicitud=e.codigo and a.csxp_admi_secuencia=e.admi_secuencia and a.pac_id=e.pac_id and e.admi_secuencia=i.secuencia and e.pac_id=i.pac_id and i.estado in ('A','E')) group by cds, descripcion order by  descripcion asc ";

    al2 = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
   // rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Facturacion - '+document.title;
function doAction(){loaded=true;xHeight=objHeight('_tblMain');resizeFrame();
 	timer(60,true,'timerMsgTop,timerMsgBottom','Refrescando en sss seg.','reloadPage()');
	checkPendingOM();
}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function checkPendingOM(){var gSol=parseInt(document.form0.gSol.value,10);if((gSol)>0){document.getElementById('pendingMsg').style.display='';
//setTimeout('replaySound(\'pendingSound\',5000)',10);
soundAlert();
}
}
function reloadPage()
{
	var fecha = document.search01.fecha.value;
	var area = document.search01.area.value;
	var solicitado_por = document.search01.solicitado_por.value;
	var _sysdate = '<%=CmnMgr.getCurrentDate("dd/mm/yyyy")%>';
	if(_sysdate!=document.search01.fecha.value)window.location= '../expediente/list_sol_lab_img.jsp?fecha='+_sysdate+'&fg=<%=fg%>&area='+area+'&solicitado_por='+solicitado_por;
	else window.location= '../expediente/list_sol_lab_img.jsp?fecha='+fecha+'&area='+area+'&fg=<%=fg%>&solicitado_por='+solicitado_por;
}
function verPaciente(cds)
{
	var fecha = document.search01.fecha.value;
	var area = document.search01.area.value;
	var solicitado_por = cds;
	abrir_ventana1('../expediente/det_sol_lab_img.jsp?fecha='+fecha+'&area='+area+'&fg=<%=fg%>&solicitado_por='+solicitado_por);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa"  onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="EXPEDIENTE - SOLICITUDES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0"  id="_tblMain">
  <tr>
    <td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="0">
	<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
        <%=fb.formStart()%>
        <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
        <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
        <%=fb.hidden("fg",fg)%>
		
				<tr class="TextRow02">
					<td colspan="3"><cellbytelabel id="1">Solicitud</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td class="TableBottomBorder" colspan="3">
						<table width="100%">
							<tr>
								<td width="18%"><cellbytelabel id="2">Fecha</cellbytelabel>
									<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="fecha" />
										<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
									</jsp:include>
								</td>
								<td width="40%"><cellbytelabel id="3">&Aacute;reas</cellbytelabel>:&nbsp; 
								<%=fb.select("area",al,area,false,false,0,"Text10",null,null,"","T")%>
								</td>
								<td width="42%"><cellbytelabel id="4">Solicitado por</cellbytelabel>:
								<%=fb.select("solicitado_por",alSol,solicitado_por,false,false,0,"Text10",null,null,"","T")%>
								<%=fb.submit("Ir","Ir",true,false,null,null,"")%> </td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td width="15%">&nbsp;</td>
					<td width="70%" align="center"><font size="3" id="pendingMsg" style="display:none"><cellbytelabel id="5">Hay Solicitudes pendientes</cellbytelabel>!</font><script language="javascript">blinkId('pendingMsg','red','white');</script><!--<embed id="pendingSound" src="../media/chimes.wav" autostart="false" width="0" height="0"></embed>--></td>
					<td width="15%" align="right">&nbsp;</td>
				</tr>
	<%=fb.formEnd()%>
      </table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

    </td>
  </tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
  <td class="TableLeftBorder TableRightBorder TableBottomBorder TableTopBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">

<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
	<%=fb.hidden("gSol",""+al2.size())%>
<table align="center" width="100%" cellpadding="1">
   <tr class="TextHeader" align="center">
	<td colspan="3"><label id="timerMsgTop"></label></td>
</tr>
<tr class="TextHeader" align="center">
	<td width="20%"><cellbytelabel id="1">Centro De Servicio</cellbytelabel></td>
	<td width="30%"><cellbytelabel id="2">Solicitudes</cellbytelabel></td>
	<td width="10%">&nbsp;</td>
</tr>
<%
String paciente = "",regCodigo="";
for (int i=0; i<al2.size(); i++)
{
	CommonDataObject cdod = (CommonDataObject) al2.get(i);
	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	total += Integer.parseInt(cdod.getColValue("cantidad"));
%>
<%=fb.hidden("cds"+i,""+cdod.getColValue("cds"))%>
		<tr class="<%=color%>">
			<td><%=cdod.getColValue("descripcion")%></td>
			<td  align="center">
			<authtype type='50'><a href="javascript:verPaciente(<%=cdod.getColValue("cds")%>)" class="Link00">[ <cellbytelabel><font size="4"><%=cdod.getColValue("cantidad")%></font></cellbytelabel>]</a></authtype>			
			</td>
			<td  align="center">&nbsp; </td>
		</tr>
<%}%>
<%=fb.hidden("keySize",""+al2.size())%>
<tr class="TextRow02" align="center">
	<td class="RedTextBold"><cellbytelabel id="11"><font size="4"> T O T A L</font></cellbytelabel></td>
	<td class="RedTextBold" ><font size="6"><%=total%></font></td>
	<td>&nbsp;</td>
</tr> 
</table>

<%=fb.formEnd()%>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
  </td>
</tr>
</table>
</body>
</html>
<%
}
%>
