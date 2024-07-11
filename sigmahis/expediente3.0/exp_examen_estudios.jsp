<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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
boolean viewMode = false;
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fp = request.getParameter("fp");
String type = request.getParameter("type");
String colLabel1 = "";
String colLabel2 = "";
String cpt = request.getParameter("cpt");
String cptDesc = request.getParameter("cptDesc");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String desc = request.getParameter("desc");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (fp == null) fp = "imagenologia";
if (type == null) type = "";
if (cpt == null) cpt = "";
if (cptDesc == null) cptDesc = "";
if (fDate == null) fDate = "";
if (tDate == null) tDate = "";
String title = "Estudios y Resultados";
if (type.trim().equalsIgnoreCase("previous")) title = "Resultados Previos";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (!cpt.trim().equals("")) appendFilter += " and upper(z.cod_procedimiento) like '%"+cpt.toUpperCase()+"%'";
	if (!cptDesc.trim().equals("")) appendFilter += " and upper(nvl(y.observacion,y.descripcion)) like '%"+cptDesc.toUpperCase()+"%'";
	if (!fDate.trim().equals("")) appendFilter += " and to_date(to_char(z.fecha_solicitud,'dd/mm/yyyy'),'dd/mm/yyyy')>=to_date('"+fDate+"','dd/mm/yyyy')";
	if (!tDate.trim().equals("")) appendFilter += " and to_date(to_char(z.fecha_solicitud,'dd/mm/yyyy'),'dd/mm/yyyy')<=to_date('"+tDate+"','dd/mm/yyyy')";

	if (fp.trim().equalsIgnoreCase("laboratorio"))
	{
		appendFilter += " and z.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz='LIS')";
	/*	if (type.trim().equalsIgnoreCase("previous")) colLabel1 = "Fecha Estudio";
		else colLabel1 = "Fecha y Hora Resultados";
		colLabel2 = "C&oacute;d. Muestra";*/

		sql = "select z.codigo, z.cod_solicitud, z.csxp_admi_secuencia, z.csxp_admi_pac_codigo, z.csxp_admi_pac_fec_nac, z.cod_centro_servicio, z.pac_id, nvl(to_char(z.fecha_realizo,'dd/mm/yyyy hh12:mi:ss am'),' ') as fecha_realizo, nvl(to_char(z.fecha_solicitud,'dd/mm/yyyy'),' ') as fecha_solicitud, nvl(z.codigo_muestra,' ') as codigo_muestra, to_char(z.fecha_creac,'dd/mm/yyyy hh12:mi:ss am') as fecha_creac, nvl(z.cod_procedimiento,' ') as cpt, nvl(y.observacion,y.descripcion) as cpt_desc, nvl(z.comentario_pre,' ') as comentario_pre, z.estado,to_char(z.csxp_admi_pac_fec_nac,'ddmmyyyy') fecha_nac,z.csxp_admi_secuencia admision, z.csxp_admi_pac_codigo pac_codigo from tbl_cds_detalle_solicitud z, tbl_cds_procedimiento y,tbl_adm_admision a where z.cod_procedimiento=y.codigo(+) and z.pac_id="+pacId+" and a.adm_root="+noAdmision+appendFilter+" and a.pac_id=z.pac_id and z.csxp_admi_secuencia=a.secuencia order by z.fecha_solicitud desc";
	}
	else if (fp.trim().equalsIgnoreCase("imagenologia"))
	{
		appendFilter += " and z.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz='RIS')";
	/*	colLabel1 = "Fecha Solicitud";
		colLabel2 = "Fecha y Hora Resultados";*/

		sql = "select z.codigo, z.cod_solicitud, z.csxp_admi_secuencia, z.csxp_admi_pac_codigo, z.csxp_admi_pac_fec_nac, z.cod_centro_servicio,   z.pac_id, nvl(to_char(z.fecha_realizo,'dd/mm/yyyy hh12:mi:ss am'),' ') as fecha_realizo, nvl(to_char(z.fecha_solicitud,'dd/mm/yyyy'),' ') as fecha_solicitud, nvl(z.codigo_muestra,' ') as codigo_muestra, to_char(z.fecha_creac,'dd/mm/yyyy hh12:mi:ss am') as fecha_creac, nvl(z.cod_procedimiento,' ') as cpt, nvl(y.observacion,y.descripcion) as cpt_desc, x.codigo as cds, x.descripcion as cds_desc, nvl(z.comentario_pre,' ') as comentario_pre, z.estado ,to_char(z.csxp_admi_pac_fec_nac,'ddmmyyy') fecha_nac,z.csxp_admi_secuencia admision, z.csxp_admi_pac_codigo pac_codigo from tbl_cds_detalle_solicitud z, tbl_cds_procedimiento y, tbl_cds_centro_servicio x ,tbl_adm_admision a where z.cod_procedimiento=y.codigo(+) and z.cod_centro_servicio=x.codigo and z.pac_id="+pacId+" and a.adm_root="+noAdmision+appendFilter+" and  a.pac_id=z.pac_id and z.csxp_admi_secuencia=a.secuencia order by z.fecha_solicitud desc";
	}
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
var noNewHeight = true;
document.title = '<%=title%> - '+document.title;

function doAction(){}
function results(k){var codigo=eval('document.form0.codigo'+k).value;var cod_solicitud=eval('document.form0.cod_solicitud'+k).value;document.form0.cds.value=eval('document.form0.cds'+k).value;document.form0.cds_desc.value=eval('document.form0.cds_desc'+k).value;document.form0.cpt.value=eval('document.form0.cpt'+k).value;document.form0.cpt_desc.value=eval('document.form0.cpt_desc'+k).value;var fec_nac = eval('document.form0.fecha_nac'+k).value;var cod_pac = eval('document.form0.pac_codigo'+k).value;document.getElementById("iDetalle").src='http://192.168.40.21/AMI/html/webViewer.html/view?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&codigo='+codigo+'&cod_solicitud='+cod_solicitud+'&fp=<%=fp%>';document.getElementById("iDetalle").src='http://192.168.30.132/consulta/issi_list_orden.asp?ofree2=A'+fec_nac+'B'+cod_pac+'C<%=noAdmision%>';}
function imaginalogia(k){var codigo=eval('document.form0.codigo'+k).value;var cod_solicitud=eval('document.form0.cod_solicitud'+k).value;document.form0.cds.value=eval('document.form0.cds'+k).value;document.form0.cds_desc.value=eval('document.form0.cds_desc'+k).value;document.form0.cpt.value=eval('document.form0.cpt'+k).value;document.form0.cpt_desc.value=eval('document.form0.cpt_desc'+k).value;var fec_nac = eval('document.form0.fecha_nac'+k).value;var cod_pac = eval('document.form0.pac_codigo'+k).value;
abrir_ventana1('http://192.168.40.21/AMI/html/webViewer.html?view&pid=2-55-186');}

http://192.168.30.135/consulta/issi_list_orden.asp?ofree2=A02031966B6C2
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=title%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td colspan="4" align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextRow02">
			<td align="right">&nbsp;</td>
		</tr>
		<tr>
			<td>
<%
if (type.trim().equalsIgnoreCase("previous"))
{
%>
				<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("main",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("type",type)%>
				<tr class="TextFilter">
					<td width="15%">
						<cellbytelabel id="1">C&oacute;digo</cellbytelabel>
						<%=fb.textBox("cpt","",false,false,false,10,"Text10",null,null)%>
					</td>
					<td width="35%">
						<cellbytelabel id="2">Descripci&oacute;n</cellbytelabel>
						<%=fb.textBox("cptDesc","",false,false,false,40,"Text10",null,null)%>
					</td>
					<td width="50%">
						<%=colLabel1%>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="nameOfTBox1" value="fDate" />
						<jsp:param name="valueOfTBox1" value="" />
						<jsp:param name="nameOfTBox2" value="tDate" />
						<jsp:param name="valueOfTBox2" value="" />
						<jsp:param name="fieldClass" value="Text10" />
						<jsp:param name="buttonClass" value="Text10" />
						<jsp:param name="clearOption" value="true" />
						</jsp:include>
						<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
					</td>
				</tr>
<%=fb.formEnd()%>
				</table>
<%
}
%>
			</td>
		</tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%><%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("type",type)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("cpt","")%>
<%=fb.hidden("cpt_desc","")%>
<%=fb.hidden("cds","")%>
<%=fb.hidden("cds_desc","")%>
		<tr>
			<td>

			<div id="secciones" style="overflow:scroll;position:static;height:200">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tbody id="list">
				<tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
<%
if (fp.trim().equalsIgnoreCase("laboratorio"))
{
%>
					<td width="47%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
<%
}
else if (fp.trim().equalsIgnoreCase("imagenologia"))
{
%>
					<td width="47%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
<%
}
%>
					<td width="15%"><cellbytelabel id="3">Fecha a realizar</cellbytelabel></td>
					<td width="20%"><cellbytelabel id="4">Fecha Creaci&oacute;n / Registro</cellbytelabel></td>
					<td width="2%">&nbsp;</td>
				</tr>
<%
String colValue1 = "";
String colValue2 = "",fechaNac ="",codigoPac ="";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	fechaNac = cdo.getColValue("fecha_nac");
	codigoPac= cdo.getColValue("pac_codigo");

/*
	if (fp.trim().equalsIgnoreCase("laboratorio"))
	{
		if (type.trim().equalsIgnoreCase("previous")) colValue1 = cdo.getColValue("fecha_solicitud");
		else colValue1 = cdo.getColValue("fecha_realizo");
		colValue2 = cdo.getColValue("codigo_muestra");
	}
	else if (fp.trim().equalsIgnoreCase("imagenologia"))
	{
		colValue1 = cdo.getColValue("fecha_solicitud");
		colValue2 = cdo.getColValue("fecha_realizo");
	}*/
%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("cod_solicitud"+i,cdo.getColValue("cod_solicitud"))%>
				<%=fb.hidden("cpt"+i,cdo.getColValue("cpt"))%>
				<%=fb.hidden("cpt_desc"+i,cdo.getColValue("cpt_desc"))%>
				<%=fb.hidden("cds"+i,cdo.getColValue("cds"))%>
				<%=fb.hidden("cds_desc"+i,cdo.getColValue("cds_desc"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<%=fb.hidden("fecha_nac"+i,cdo.getColValue("fecha_nac"))%>
				<%=fb.hidden("pac_codigo"+i,cdo.getColValue("pac_codigo"))%>
				<%=fb.hidden("admision"+i,cdo.getColValue("csxp_admi_secuencia"))%>

				<tr id="rs<%=i%>" class="<%=color%>" align="center" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("cpt")%></td>
<%
if (fp.trim().equalsIgnoreCase("laboratorio"))
{
%>
					<td align="left"><%=cdo.getColValue("cpt_desc")%></td>
<%
}
else if (fp.trim().equalsIgnoreCase("imagenologia"))
{
%>
					<td align="left"><%=cdo.getColValue("cpt_desc")%></td>
<%
}
%>
					<td><%=cdo.getColValue("fecha_solicitud")%></td>
					<td><%=cdo.getColValue("fecha_creac")%></td>

	<%
if (fp.trim().equalsIgnoreCase("laboratorio"))
{
%>
				<td>				
				<img src="../images/dwn.gif" onClick="javascript:diFrame('list','9','rs<%=i%>','800','400','0','0','1','DIVExpandRowsScroll',true,'0','http://192.168.30.62/consulta/issi_list_orden.asp?ofree2=A<%=cdo.getColValue("fecha_nac")%>B<%=cdo.getColValue("pac_codigo")%>C<%=cdo.getColValue("admision")%>',false)" style="cursor:pointer">	
						</td>
<%}else if (fp.trim().equalsIgnoreCase("imagenologia"))
{
%>
<td onClick="javascript:imaginalogia(<%=i%>)" style="cursor:pointer"><img src="../images/dwn.gif"></td>	
			
<%}%>
		</tr>
<%
}
if (al.size() == 0)
{
%>
				<tr class="TextRow01" align="center">
					<td colspan="6"><cellbytelabel id="5">No hay estudios solicitados</cellbytelabel>!</td>
				</tr>
<%
}
%>      </tbody>
				</table>
			</div>
<%if (fp.trim().equalsIgnoreCase("imagenologia")){%>
<iframe id="iDetalle" name="iDetalle" width="100%" height="73" scrolling="no" frameborder="0"></iframe><!--	--->
<%}%>






			</td>
		</tr>
<%
if (fp.trim().equalsIgnoreCase("laboratorio"))
{
%>
		<tr class="TextRow01" align="center">
					<td colspan="6">
							<div id="ordenMain" width="100%" style="overflow:scroll;position:static;height:200">

								<table width="100%" cellpadding="1" cellspacing="1">
									<tr class="TextRow01" align="left">
										<td>
					<iframe name="iDetalle" id="iDetalle" frameborder="0" align="center" width="100%" height="200" scrolling="no" src="http://192.168.30.135/consulta/issi_list_orden.asp?ofree2=A<%=fechaNac%>B<%=codigoPac%>C<%=noAdmision%>"></iframe>
										</td>
									</tr>
								</table>

								</div>
					</td>
		</tr>
		<%}%>
		<tr class="TextRow02">
			<td align="right">
<%
if (fp.trim().equalsIgnoreCase("imagenologia") && !type.trim().equalsIgnoreCase("previous"))
{
%>
				<%=fb.submit("save","Guardar",true,(al.size() == 0 || viewMode),null,null,null)%>
<%
}
%>
				<%=fb.button("close","Cerrar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>

		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("tbl_cds_detalle_solicitud");
		cdo.addColValue("comentario_pre",request.getParameter("comentario_pre"+i));
		cdo.setWhereClause("pac_id="+pacId+" and csxp_admi_secuencia="+request.getParameter("admision"+i)+" and cod_solicitud="+request.getParameter("cod_solicitud"+i)+" and codigo="+request.getParameter("codigo"+i)+"");

		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.updateList(al);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&modeSec=<%=modeSec%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&type=<%=type%>';
<%
} else throw new Exception(SQLMgr.getErrMsg());
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