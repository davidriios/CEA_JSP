<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.AccountMap"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="MapMgr" scope="page" class="issi.contabilidad.AccountMapMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
MapMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String mode = request.getParameter("mode");
String cds = request.getParameter("cds");
String serviceType = request.getParameter("serviceType");
String refTable = request.getParameter("refTable");
String refPk = request.getParameter("refPk");
String selectOption = "S";//Blank=Mandatory, S=Display Select option (optional)
String admType = request.getParameter("admType");

if (mode == null) mode = "add";
AccountMap header = new AccountMap();

if(request.getMethod().equalsIgnoreCase("GET")) {
	if (mode.equalsIgnoreCase("add")) {
		sbSql = new StringBuffer();
		sbSql.append("select a.id as accTypeId, a.description as accTypeDesc, 0 as id, 'S' as defType, '-' as refTable, '-' as refPk, (select nvl(min(centro_servicio),-1) from tbl_cds_servicios_x_centros z where exists (select null from tbl_cds_centro_servicio where codigo = z.centro_servicio and compania_unorg = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(")) as cds, '-' as serviceType, '-' as description, '-' as comments, 'A' as status from tbl_con_acctype a where a.status = 'A' order by a.description");
		System.out.println("SQL=\n"+sbSql);
		al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),AccountMap.class);
		if (al.size() == 0) throw new Exception("No existen Tipo de Cuentas. Por favor intente nuevamente!");
		cds = ((AccountMap) al.get(0)).getCds();
		serviceType = "-";
		refTable = "-";
		refPk = "-";
		admType = "T";
	} else {
		if (cds == null) throw new Exception("El Centro de Servicio no es válido. Por favor intente nuevamente!");
		if (serviceType == null) throw new Exception("El Tipo de Servicio no es válido. Por favor intente nuevamente!");
		if (refTable == null) throw new Exception("La Tabla de Referencia no es válida. Por favor intente nuevamente!");
		if (refPk == null) throw new Exception("El Valor de Referencia no es válido. Por favor intente nuevamente!");
		if (admType == null) throw new Exception("La Categoria no es válida. Por favor intente nuevamente!");

		sbSql = new StringBuffer();
		sbSql.append("select distinct b.descripcion as cdsDesc, nvl((select descripcion from tbl_cds_tipo_servicio where codigo = a.service_type),'NO APLICA') as serviceTypeDesc, decode(a.ref_table,'-','NO APLICA','TBL_CDS_PROCEDIMIENTO','PROCEDIMIENTO','TBL_FAC_OTROS_CARGOS','OTROS CARGOS','TBL_CDS_PRODUCTO_X_CDS','PRODUCTO X CDS','TBL_SAL_HABITACION','HABITACION','TBL_INV_ARTICULO','ARTICULO','TBL_SAL_USO','USO','TBL_ADM_MEDICO','MEDICO','TBL_ADM_EMPRESA','EMPRESA') as refTable, a.ref_pk as refPk, nvl(a.adm_type,'T') as admType, nvl((select distinct decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') from tbl_adm_categoria_admision where adm_type = a.adm_type),'TODOS') as admTypeDesc from tbl_con_accdef a, tbl_cds_centro_servicio b where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.cds = ");
		sbSql.append(cds);
		sbSql.append(" and upper(a.service_type) = '");
		sbSql.append(serviceType.toUpperCase());
		sbSql.append("' and upper(a.ref_table) = '");
		sbSql.append(refTable.toUpperCase());
		sbSql.append("' and upper(a.ref_pk) = '");
		sbSql.append(refPk.toUpperCase());
		sbSql.append("' and upper(a.adm_type) = '");
		sbSql.append(admType.toUpperCase());
		sbSql.append("' and a.cds = b.codigo");
		System.out.println("SQL=\n"+sbSql);
		header = (AccountMap) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),AccountMap.class);
		if (header == null) mode = "add";

		sbSql = new StringBuffer();
		sbSql.append("select a.id as accTypeId, a.description as accTypeDesc, nvl(b.id,0) as id, nvl(b.def_type,'S') as defType, nvl(b.ref_table,'-') as refTable, nvl(b.ref_pk,'-') as refPk, nvl(b.cds,-1) as cds, nvl(b.service_type,'-') as serviceType, nvl(b.cta1,'-') as cta1, nvl(b.cta2,'-') as cta2, nvl(b.cta3,'-') as cta3, nvl(b.cta4,'-') as cta4, nvl(b.cta5,'-') as cta5, nvl(b.cta6,'-') as cta6, nvl(b.description,'-') as description, nvl(b.comments,'-') as comments, nvl(b.status,'A') as status from tbl_con_acctype a, (select * from tbl_con_accdef where compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and cds = ");
		sbSql.append(cds);
		sbSql.append(" and upper(service_type) = '");
		sbSql.append(serviceType.toUpperCase());
		sbSql.append("' and upper(ref_table) = '");
		sbSql.append(refTable.toUpperCase());
		sbSql.append("' and upper(ref_pk) = '");
		sbSql.append(refPk.toUpperCase());
		sbSql.append("' and upper(adm_type) = '");
		sbSql.append(admType.toUpperCase());
		sbSql.append("') b where a.id = b.acctype_id(+) and a.status = 'A' order by a.description");
		System.out.println("SQL=\n"+sbSql);
		al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),AccountMap.class);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Mapping de Cuentas x Servicio - '+document.title;

function loadTS()
{
	<%if (mode.equalsIgnoreCase("add")){%>
	checkRef();
	loadXML('../xml/cdsService.xml','serviceType','<%=serviceType%>','VALUE_COL','LABEL_COL','<%=cds%>','KEY_COL','<%=selectOption%>');
	<%}%>
}

function checkRef()
{
	if(document.form1.refTable.value=='-'){document.form1.refPk.value='';document.form1.refPk.readOnly=true;}
	else document.form1.refPk.readOnly=false;
}

function verify(k)
{
	var id=eval('document.form1.id'+k).value;
	var cta1=eval('document.form1.cta1'+k).value;
	var cta2=eval('document.form1.cta2'+k).value;
	var cta3=eval('document.form1.cta3'+k).value;
	var cta4=eval('document.form1.cta4'+k).value;
	var cta5=eval('document.form1.cta5'+k).value;
	var cta6=eval('document.form1.cta6'+k).value;
	if(cta1!=''&&cta2!=''&&cta3!=''&&cta4!=''&&cta5!=''&&cta6!='')
	{
		if(hasDBData('<%=request.getContextPath()%>','tbl_con_catalogo_gral','compania = <%=session.getAttribute("_companyId")%> and cta1 = \''+cta1+'\' and cta2 = \''+cta2+'\' and cta3 = \''+cta3+'\' and cta4 = \''+cta4+'\' and cta5 = \''+cta5+'\' and cta6 = \''+cta6+'\'',''))
		{
			if(id=='0')
			{
				var cds=document.form1.cds.value;
				var serviceType=document.form1.serviceType.value;
				var refTable=document.form1.refTable.value;
				var refPk=document.form1.refPk.value;
				var admType=document.form1.admType.value;
				if(admType=='')admType='T';
				if(hasDBData('<%=request.getContextPath()%>','tbl_con_accdef','compania = <%=session.getAttribute("_companyId")%> and cds = '+cds+' and service_type = \''+((serviceType=='')?'-':serviceType)+'\' and ref_table = \''+refTable+'\' and ref_pk = \''+((refPk=='')?'-':refPk)+'\' and adm_type in (\'T\',\''+admType+'\') and cta1 = \''+cta1+'\' and cta2 = \''+cta2+'\' and cta3 = \''+cta3+'\' and cta4 = \''+cta4+'\' and cta5 = \''+cta5+'\' and cta6 = \''+cta6+'\'',''))alert('La Cuenta ya existe en la Definición de Cuentas!');
				else return true;
			}
			else return true;
		}
		else alert('La Cuenta introducida no existe en el Catálogo de Cuentas!');
	}
	return false;
}

function verifyAccounts()
{
	var valid=0;
	var size=parseInt(document.form1.size.value,10);
	for(i=0;i<size;i++)
	{
		if(verify(i))valid++;
	}
	if(valid==0)
	{
		alert('Por favor introduzca cuentas válidas!');
		return false;
	}
	else return true;
}

function verifyService()
{
	var cds=document.form1.cds.value;
	var serviceType=document.form1.serviceType.value;
	var refTable=document.form1.refTable.value;
	var refPk=document.form1.refPk.value;
	var admType=document.form1.admType.value;
	if(admType=='')admType='T';
	if(hasDBData('<%=request.getContextPath()%>','tbl_con_accdef','compania = <%=session.getAttribute("_companyId")%> and cds = '+cds+' and service_type = \''+((serviceType=='')?'-':serviceType)+'\' and ref_table = \''+refTable+'\' and ref_pk = \''+((refPk=='')?'-':refPk)+'\' and adm_type in (\'T\',\''+admType+'\')',''))
	{
		alert('El Servicio ya existe en la Definición de Cuentas!');
		return false;
	}
	return true;
}

function getCta(k)
{
	abrir_ventana1('../common/search_catalogo_gral.jsp?fp=mapping&index='+k);
}

function checkServiceType()
{
	if(document.form1.serviceType.value=='')
	{
		if(confirm('Esta seguro de generar este maping por centro de servicio ??. \n Solo para Descuentos por Centros.'))
		{
			return true;
		}
		else
		{
			alert('Por favor seleccione el Tipo de Servicio!');return false;
		}
	}else return true;
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();loadTS();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,350);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SERVICIOS CON MAPPING"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(!checkServiceType())error++;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("size",""+al.size())%>
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
<% if (mode.equalsIgnoreCase("add")) { %>
		<tr class="TextRow01">
			<td width="15%">Centro de Servicio</td>
			<td width="35%"><%=fb.select(ConMgr.getConnection(),"select a.codigo, a.descripcion||' [ '||a.codigo||' ]' from tbl_cds_centro_servicio a where compania_unorg = "+session.getAttribute("_companyId")+" and exists (select null from tbl_cds_servicios_x_centros where centro_servicio = a.codigo) order by 2","cds",cds,false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/cdsService.xml','serviceType','"+serviceType+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','"+selectOption+"')\"")%></td>
			<td width="15%">Tipo de Servicio</td>
			<td width="35%">
				<%=fb.select("serviceType","","")%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td>Categor&iacute;a Ingreso:</td>
			<td colspan="3"><%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') categoria from tbl_adm_categoria_admision order by 1","admType",admType,"T")%></td>
		</tr>
		<tr class="TextRow01">
			<td>Tipo de Referencia</td>
			<td><%=fb.select("refTable","-=NO APLICA,TBL_CDS_PROCEDIMIENTO=PROCEDIMIENTO,TBL_FAC_OTROS_CARGOS=OTROS CARGOS,TBL_CDS_PRODUCTO_X_CDS=PRODUCTO X CDS,TBL_SAL_HABITACION=HABITACION,TBL_INV_ARTICULO=ARTICULO,TBL_SAL_USO=USO,TBL_ADM_MEDICO=MEDICO,TBL_ADM_EMPRESA=EMPRESA",refTable,false,false,0,null,null,"onChange=\"javascript:checkRef()\"")%></td>
			<td>Referencia</td>
			<td><%=fb.textBox("refPk",(refPk.equals("-"))?"":refPk,false,false,false,40)%></td>
		</tr>
<% } else { %>
		<%=fb.hidden("cds",cds)%>
		<%=fb.hidden("serviceType",serviceType)%>
		<%=fb.hidden("refTable",refTable)%>
		<%=fb.hidden("refPk",refPk)%>
		<%=fb.hidden("admType",admType)%>
		<tr class="TextRow01">
			<td width="15%">Centro de Servicio</td>
			<td width="35%"><%=header.getCdsDesc()%> [ <%=cds%> ]</td>
			<td width="15%">Tipo de Servicio</td>
			<td width="35%"><%=(serviceType.trim().equals("-"))?serviceType:header.getServiceTypeDesc()+" [ "+serviceType+" ]"%></td>
		</tr>
		<tr class="TextRow01">
			<td>Categor&iacute;a Ingreso:</td>
			<td colspan="3"><%=(admType.trim().equals("-"))?admType:"["+admType+"] "+header.getAdmTypeDesc()%></td>
		</tr>
		<tr class="TextRow01">
			<td>Tipo de Referencia</td>
			<td><%=header.getRefTable()%></td>
			<td>Referencia</td>
			<td><%=header.getRefPk()%></td>
		</tr>
<% } %>
		<tr>
			<td colspan="4">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="10%">Tipo de Cuenta</td>
					<td width="26%">No. Cuenta</td>
					<td width="28%">Descripci&oacute;n</td>
					<td width="28%">Comentarios</td>
					<td width="8%">Estado</td>
				</tr>
<%
for (int i=0; i<al.size(); i++) {
	AccountMap am = (AccountMap) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("id"+i,am.getId())%>
				<%=fb.hidden("accTypeId"+i,am.getAccTypeId())%>
				<%=fb.hidden("accTypeDesc"+i,am.getAccTypeDesc())%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
					<td><%=am.getAccTypeDesc()%></td>
					<td>
						<%=fb.textBox("cta1"+i,(am.getCta1().equals("-"))?"":am.getCta1().trim(),false,false,false,3,"Text10",null,"onBlur=\"javascript:verify("+i+")\"")%>
						<%=fb.textBox("cta2"+i,(am.getCta2().equals("-"))?"":am.getCta2().trim(),false,false,false,2,"Text10",null,"onBlur=\"javascript:verify("+i+")\"")%>
						<%=fb.textBox("cta3"+i,(am.getCta3().equals("-"))?"":am.getCta3().trim(),false,false,false,3,"Text10",null,"onBlur=\"javascript:verify("+i+")\"")%>
						<%=fb.textBox("cta4"+i,(am.getCta4().equals("-"))?"":am.getCta4().trim(),false,false,false,3,"Text10",null,"onBlur=\"javascript:verify("+i+")\"")%>
						<%=fb.textBox("cta5"+i,(am.getCta5().equals("-"))?"":am.getCta5().trim(),false,false,false,3,"Text10",null,"onBlur=\"javascript:verify("+i+")\"")%>
						<%=fb.textBox("cta6"+i,(am.getCta6().equals("-"))?"":am.getCta6().trim(),false,false,false,3,"Text10",null,"onBlur=\"javascript:verify("+i+")\"")%>
						<%=fb.button("btnCta"+i,"...",true,false,null,null,"onClick=\"javascript:getCta("+i+")\"")%>
					</td>
					<td><%=fb.textBox("description"+i,am.getDescription(),false,false,false,50,50,"Text10",null,null)%></td>
					<td><%=fb.textarea("comments"+i,am.getComments(),false,false,false,40,2,250,"Text12",null,null)%></td>
					<td><%=fb.select("status"+i,"A=ACTIVO,I=INACTIVO",am.getStatus(),false,false,0,"Text10",null,null)%></td>
				</tr>
<%
}
if (mode.equalsIgnoreCase("add")) fb.appendJsValidation("if(!verifyService())error++;");
fb.appendJsValidation("if(error==0&&!verifyAccounts())error++;");
%>
				</table>
</div>
</div>
			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				Opciones de Guardar:
				<%=fb.radio("saveOption","N")%>Crear Otro
				<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
				<%=fb.radio("saveOption","C",false,false,false)%>Cerrar
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int size = Integer.parseInt(request.getParameter("size"));
	al = new ArrayList();
	for (int i=0; i<size; i++) {
		AccountMap am = new AccountMap();

		am.setCompania((String) session.getAttribute("_companyId"));
		am.setCds(request.getParameter("cds"));
		am.setCdsDesc(request.getParameter("cdsDesc"));
		am.setServiceType(request.getParameter("serviceType"));
		if (am.getServiceType().trim().equals("")) am.setServiceType("-");
		am.setServiceTypeDesc(request.getParameter("serviceTypeDesc"));
		am.setRefTable(request.getParameter("refTable"));
		if (am.getRefTable().equals("-")) {
			am.setDefType("S");
			am.setRefPk("-");
		} else {
			am.setDefType("R");
			am.setRefPk(request.getParameter("refPk"));
		}
		if (am.getServiceType().trim().equals("-"))am.setDefType("C");
		am.setAdmType(request.getParameter("admType"));
		if (am.getAdmType().trim().equals("")) am.setAdmType("T");

		am.setId(request.getParameter("id"+i));
		am.setAccTypeId(request.getParameter("accTypeId"+i));
		am.setAccTypeDesc(request.getParameter("accTypeDesc"+i));
		am.setCta1(request.getParameter("cta1"+i));
		am.setCta2(request.getParameter("cta2"+i));
		am.setCta3(request.getParameter("cta3"+i));
		am.setCta4(request.getParameter("cta4"+i));
		am.setCta5(request.getParameter("cta5"+i));
		am.setCta6(request.getParameter("cta6"+i));
		am.setDescription((request.getParameter("description"+i).trim().equals(""))?"-":request.getParameter("description"+i));
		am.setComments((request.getParameter("comments"+i).trim().equals(""))?"-":request.getParameter("comments"+i));
		am.setStatus(request.getParameter("status"+i));

		al.add(am);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&cds="+cds+"&serviceType="+serviceType+"&refTable="+refTable+"&refPk="+refPk+"&admType="+admType);
	MapMgr.saveDefinition(al);
	ConMgr.clearAppCtx(null);

	cds = MapMgr.getPkColValue("cds");
	serviceType = MapMgr.getPkColValue("serviceType");
	refTable = MapMgr.getPkColValue("refTable");
	refPk = MapMgr.getPkColValue("refPk");
	admType = MapMgr.getPkColValue("admType");
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (MapMgr.getErrCode().equals("1")) { %>
	alert('<%=MapMgr.getErrMsg()%>');
<% if (mode.equalsIgnoreCase("add")) { %>
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/list_mapping_service.jsp")) { %>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/list_mapping_service.jsp")%>';
<% } else { %>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/list_mapping_service.jsp';
<% } %>
<% } %>
<% if (saveOption.equalsIgnoreCase("N")) { %>
	setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	window.close();
<% } %>
<% } else throw new Exception(MapMgr.getErrMsg()); %>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&cds=<%=cds%>&serviceType=<%=serviceType%>&refTable=<%=refTable%>&refPk=<%=refPk%>&admType=<%=admType%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>
