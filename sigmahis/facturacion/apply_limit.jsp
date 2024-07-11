<%@ page errorPage="../error.jsp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="FacMgr" scope="page" class="issi.facturacion.FacturaMgr"/>
<jsp:useBean id="iLim" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vLim" scope="session" class="java.util.Vector"/>
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
FacMgr.setConnection(ConMgr);

CommonDataObject lim = new CommonDataObject();
ArrayList al = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
StringBuffer sbSql = new StringBuffer();
String change = request.getParameter("change");
String id = request.getParameter("id");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String esJubilado = request.getParameter("esJubilado");

if (id == null) id = "0";
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (esJubilado == null) esJubilado = "N";

boolean viewMode = false;
String mode = request.getParameter("mode");
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET")) {

	sbSql.append("select -999 as optValueColumn, 'TODOS' as optLabelColumn, -999 as optTitleColumn from dual union all select z.codigo, z.descripcion, z.codigo from tbl_cds_centro_servicio z where z.compania_unorg = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and exists (select null from tbl_fac_det_tran where pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and fac_secuencia = ");
	sbSql.append(noAdmision);
	sbSql.append(" and centro_servicio = z.codigo) order by 2");
	ArrayList alCds = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);

	if (change == null) {

		iLim.clear();
		vLim.clear();

		if (pacId.trim().equals("") || noAdmision.trim().equals("")) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
		sbSql = new StringBuffer();
		if (viewMode) {

			sbSql.append("select nvl(min(limit_id),0) as id from (");
				sbSql.append("select limit_id, fecha_creacion, last_value(fecha_creacion) over (order by fecha_creacion range between unbounded preceding and unbounded following) as last_rec, (last_value(fecha_creacion) over (order by fecha_creacion range between unbounded preceding and unbounded following) - fecha_creacion) * 24 * 3600 as diff/*in seconds*/ from tbl_fac_factura where compania = ");
				sbSql.append(session.getAttribute("_companyId"));
				sbSql.append(" and pac_id = ");
				sbSql.append(pacId);
				sbSql.append(" and admi_secuencia = ");
				sbSql.append(noAdmision);
				sbSql.append(" and facturar_a in ('P','E')");
			sbSql.append(") where diff <= 1");

		} else {
			
			sbSql.append("select id from tbl_fac_limit where pac_id = ");
			sbSql.append(pacId);
			sbSql.append(" and admision = ");
			sbSql.append(noAdmision);
			sbSql.append(" and compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and factura = '0'");
			
		}
		lim = SQLMgr.getData(sbSql);
		if (lim != null) id = lim.getColValue("id");

		al = SQLMgr.getDataList(sbSql);
		sbSql = new StringBuffer();
		sbSql.append("select cds, descripcion, monto, aplicar_a as aplicarA from tbl_fac_limit_det where id = ");
		sbSql.append(id);
		al = SQLMgr.getDataList(sbSql);
		for (int i=0; i<al.size(); i++) {
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			try {
				cdo.setKey(iLim.size());
				iLim.put(cdo.getKey(),cdo);
				vLim.add(cdo.getColValue("cds"));
			} catch(Exception e) {
				System.err.println("Unable to set CDS LIMIT!"+e.getMessage());
			}
		}

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title='Análisis Manual Límite - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function updAction(k){eval('document.form0.iAction'+k).value='U';}
</script>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextRow02">
			<td>&nbsp;</td>
		</tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("esJubilado",esJubilado)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+iLim.size())%>
		<tr>
			<td>
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="35%"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
					<td width="32%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="12%"><cellbytelabel>Monto</cellbytelabel></td>
					<td width="16%"><cellbytelabel>Paga</cellbytelabel></td>
					<td width="5%">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="5"><iframe name="addFrame" id="addFrame" align="center" width="100%" height="100" scrolling="no" frameborder="0" border="0" src="../facturacion/add_limit.jsp?mode=<%=mode%>&id=<%=id%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&esJubilado=<%=esJubilado%>"></iframe></td>
				</tr>
<%
if (iLim.size() != 0) al = CmnMgr.reverseRecords(iLim);
for (int i=0; i<iLim.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) iLim.get(al.get(i).toString());

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String displayRec = "";
	if (cdo.getAction() != null && cdo.getAction().equalsIgnoreCase("D")) displayRec = " style=\"display:none\"";
%>
				<%=fb.hidden("key"+i,cdo.getKey())%>
				<%=fb.hidden("remove"+i,"")%>
				<%=fb.hidden("iAction"+i,cdo.getAction())%>
				<tr class="<%=color%>" align="center"<%=displayRec%>>
					<td><%=fb.select("cds"+i,alCds,cdo.getColValue("cds"),true,false,true,0,"Text10",null,null,null,"S")%></td>
					<td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),true,false,viewMode,40,100,"Text10",null,"onChange=\"javascript:updAction("+i+")\"")%></td>
					<td><%=fb.decPlusZeroBox("monto"+i,cdo.getColValue("monto"),true,false,viewMode,10,10.2,"Text10",null,"onChange=\"javascript:updAction("+i+")\"")%></td>
					<td><%=fb.select("aplicarA"+i,"P=PACIENTE,E=EMPRESA",cdo.getColValue("aplicarA"),true,false,viewMode,0,"Text10",null,"onChange=\"javascript:updAction("+i+")\"",null,"S")%></td>
					<td><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
				</tr>
<% } %>
				</table>
</div>
</div>
			</td>
		</tr>
		<tr class="TextRow02">
			<td align="right">
				<%=fb.submit("save","Guardar",true,viewMode,null,"","onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {

	String baction = request.getParameter("baction");System.out.println("............action = "+baction);
	int size = 0;
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));
	String itemRemoved = "";

	lim.setTableName("TBL_FAC_LIMIT");
	lim.setWhereClause("id = "+id);
	//requires to set pk cols with value used to match with ref cols
	lim.addPkColValue("id",id);
	//mapping header column with detail column
	lim.addRefColValue("id","id");
	if (id != null && !id.equals("0")) lim.setAction("U");
	else {

		lim.setAction("I");
		lim.addSeqColValue("id","seq_fac_limit_id");
		lim.addColValue("usuario_creacion",UserDet.getUserName());
		lim.addColValue("fecha_creacion","sysdate");
		lim.addColValue("pac_id",pacId);
		lim.addColValue("admision",noAdmision);
		lim.addColValue("compania",(String) session.getAttribute("_companyId"));
		lim.addColValue("factura","0");
		lim.addColValue("usuario_modificacion",UserDet.getUserName());
		lim.addColValue("fecha_modificacion","sysdate");

	}

	iLim.clear();
	vLim.clear();
	al.clear();
	int nRemoved = 0;
	for (int i=0; i<size; i++) {
		CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("TBL_FAC_LIMIT_DET");
		cdo.setWhereClause("id = "+id+" and cds = "+request.getParameter("cds"+i));
		//requires to set pk cols used to match with ref cols
		cdo.addPkColValue("id",id);
		cdo.addPkColValue("cds",request.getParameter("cds"+i));
		cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
		cdo.addColValue("monto",request.getParameter("monto"+i));
		cdo.addColValue("aplicarA",request.getParameter("aplicarA"+i));
		cdo.addColValue("aplicar_a",request.getParameter("aplicarA"+i));
		cdo.addColValue("usuario_creacion",UserDet.getUserName());
		cdo.addColValue("fecha_creacion","sysdate");
		cdo.addColValue("usuario_modificacion",UserDet.getUserName());
		cdo.addColValue("fecha_modificacion","sysdate");

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).trim().equals("")) {

			itemRemoved = request.getParameter("cds"+i);
			if (request.getParameter("iAction"+i).equalsIgnoreCase("I")) cdo.setAction("X");
			else cdo.setAction("D");

		} else {

			cdo.setAction(request.getParameter("iAction"+i));
			if (cdo.getAction().equalsIgnoreCase("D")) nRemoved++;
			else vLim.addElement(request.getParameter("cds"+i));

		}
		if (baction.equalsIgnoreCase("Guardar") || baction.equalsIgnoreCase("X")) {

			cdo.addColValue("id",id);
			cdo.addColValue("cds",request.getParameter("cds"+i));

		}

		if (!cdo.getAction().equalsIgnoreCase("X")) {

			try {
				cdo.setKey(iLim.size());
				iLim.put(cdo.getKey(),cdo);
				al.add(cdo);
			} catch(Exception e) {
				System.err.println("Unable to set CDS LIMIT!"+e.getMessage());
			}

		}
	}

	if (!itemRemoved.equals("")) {

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode=edit&id="+id+"&pacId="+pacId+"&noAdmision="+noAdmision+"&esJubilado="+esJubilado);
		return;

	}

	if (baction.equalsIgnoreCase("Guardar")) {

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		SQLMgr.save(lim,al,true,false,true,true);
		ConMgr.clearAppCtx(null);

	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>alert('<%=SQLMgr.getErrMsg()%>');<% } else throw new Exception(FacMgr.getErrException()); %>
parent.window.location=window.location='../facturacion/reg_facturacion_manual.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&esJubilado=<%=esJubilado%><%=((al.size() == nRemoved)?"":"&mode=edit&limit")%>';
parent.hidePopWin(false);
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>
